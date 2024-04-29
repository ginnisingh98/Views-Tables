--------------------------------------------------------
--  DDL for Package Body CS_SERVICEREQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICEREQUEST_PVT" AS
/* $Header: csvsrb.pls 120.48.12010000.19 2010/05/14 22:32:58 rtripath ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_ServiceRequest_PVT';
G_INITIALIZED       CONSTANT VARCHAR2(1)  := 'R';
G_SR_SUBTYPE        CONSTANT VARCHAR2(5)  := 'INC';
G_API_REVISION      CONSTANT NUMBER       := 1.0;
G_TABLE_NAME        CONSTANT VARCHAR2(40) := 'CS_INCIDENTS_ALL_B';
G_TL_TABLE_NAME     CONSTANT VARCHAR2(40) := 'CS_INCIDENTS_ALL_TL';

--siahmed added for 12.1.2 project where
--to prevent multiple query to check weather we are updating onetime address or not
G_ONETIME_ADD_CNT     NUMBER := 0;
--end of siahmed

--
--This procedure checks if an attribute is g_miss_char, if no then it returns.
--otherwise it checks if the given attribute is part of
--global context, if yes then it sets attribute value to value from old record
--otherwise it sets attribute to null.
PROCEDURE set_attribute_value(x_attr_val     in out nocopy varchar2,
                              p_attr_val_old in            varchar2,
                              p_ff_name      in            varchar2,
                              p_attr_col     in            varchar2);
--============================================================================
-- PROCEDURE : Get_incident_type_details   PRIVATE
-- PARAMETERS: p_incident_typeId           Incicent Type identifier
-- COMMENT   : This procedure gets business process associated with incident type.
--           :
-- PRE-COND  : Incident Type is assumed to be valid
--           :
-- EXCEPTIONS: None
-- Modification History:
-- Date     Name     Desc
-- ------- -------- ------------------------------------------------------------
-- 07/11/05 smisra   Added abort workflow, launch workflow, workflow columns
--                   to select statement and out parameters to this procedure
-- -----------------------------------------------------------------------------
PROCEDURE get_incident_type_details
( p_incident_type_id          IN         NUMBER
, x_business_process_id       OUT NOCOPY NUMBER
, x_autolaunch_workflow_flag  OUT NOCOPY VARCHAR2
, x_abort_workflow_close_flag OUT NOCOPY VARCHAR2
, x_workflow                  OUT NOCOPY VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT
    business_process_id
  , autolaunch_workflow_flag
  , abort_workflow_close_flag
  , workflow
  INTO
    x_business_process_id
  , x_autolaunch_workflow_flag
  , x_abort_workflow_close_flag
  , x_workflow
  FROM
    cs_incident_types_b
  WHERE incident_type_id = p_incident_type_id;

EXCEPTION
  WHEN no_data_found THEN
    x_workflow                  := NULL;
    x_business_process_id       := NULL;
    x_autolaunch_workflow_flag  := NULL;
    x_abort_workflow_close_flag := NULL;
    x_return_status             := FND_API.G_RET_STS_ERROR;
  WHEN others THEN
    x_return_status             := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token
    ('P_TEXT'
    , 'CS_SERVICEREQUEST_UTIL.get_incident_type_details'||'-'||SQLERRM
    );
    FND_MSG_PUB.ADD;
END get_incident_type_details;
-- -----------------------------------------------------------------------------
-- PROCEDURE : Get_default_contract   PRIVATE
-- PARAMETERS: p_business_process_id  Business Process associayed with incident type
--           : p_customer_id          Service Request customer
--           : p_install_site_use_id  Install site
--           : p_account_id           Customer Account
--           : p_system_id            System Id
--           : p_inventory_item_id    Inventory Item
--           : p_customer_product_id  Customer Product
--           : p_request_date         Service Request Date
--           : p_severity_id          Service Request Severity
--           : p_time_zone_id         Time Zone
--           : p_incident_location_type     Service request location type
--           : p_incident_location_id       Service Request Location Id
--           : p_primary_contact_party_id   party id of the SR primary contact
--           : p_primary_contact_point_id   contact point id of the SR primary contact
--           : p_incident_id                Request Identifier
-- COMMENT   : This procedure gets a contract applicable to service request attributes
--           :
--           :
-- PRE-COND  : All input parameters are process for g_miss values
--           :
-- EXCEPTIONS: None
-- Modification History:
-- Date     Name     Desc
-- ------- -------- ------------------------------------------------------------
-- 07/11/05 smisra   added new parameters primary contact, contact point,
--                   location id, location type and incident id to this
--                   procedure for timezone changes
--                   Called  CS_TZ_GET_DETAILS_PVT.customer_preferred_time_zone
--                   to get customer preferred time zone. This time zone is
--                   passed to contract API.
-- 08/03/05 smisra   added a new paramter p_incident_occurred_date
--                   passed incident_occurred_date, time_zone_id and
--                   dates_in_input_tz to contract record.
-- 12/23/05 smisra   Bug 4894942
--                   Added a new parameter p_default_coverage_template_id
--                   Moved the logic based on default coverage template from
--                   Create service request to this procedure
-- -----------------------------------------------------------------------------
PROCEDURE get_default_contract
( p_business_process_id        IN NUMBER
, p_customer_id                IN NUMBER
, p_install_site_use_id        IN NUMBER
, p_account_id                 IN NUMBER
, p_system_id                  IN NUMBER
, p_inventory_item_id          IN NUMBER
, p_customer_product_id        IN NUMBER
, p_request_date               IN DATE
, p_incident_occurred_date     IN DATE
, p_severity_id                IN NUMBER
, p_time_zone_id               IN NUMBER
, p_incident_location_type     IN VARCHAR2
, p_incident_location_id       IN NUMBER
, p_primary_contact_party_id   IN NUMBER
, p_primary_contact_point_id   IN NUMBER
, p_incident_id                IN NUMBER
, p_default_coverage_template_id   IN      NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_contract_id                OUT NOCOPY NUMBER
, x_contract_number            OUT NOCOPY VARCHAR2
, x_contract_service_id        OUT NOCOPY NUMBER
, x_exp_resolution_date        OUT NOCOPY DATE
, x_obligation_date            OUT NOCOPY DATE
)
IS
  px_inp_rec      OKS_ENTITLEMENTS_PUB.get_contin_rec;
  l_inp_rec       OKS_COV_ENT_PUB.gdrt_inp_rec_type;
  l_react_rec     OKS_COV_ENT_PUB.rcn_rsn_rec_type;
  l_resolve_rec   OKS_COV_ENT_PUB.rcn_rsn_rec_type;
  l_ent_contracts OKS_ENTITLEMENTS_PUB.get_contop_tbl;
  Li_TableIdx     BINARY_INTEGER;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  lx_timezone_id       NUMBER;
  lx_timezone_name     VARCHAR2(80);
  l_server_timezone_id NUMBER;
  l_log_module         VARCHAR2(255);
BEGIN
  l_log_module                := 'cs.plsql.' || 'CS_SERVICEREQUEST_PVT.get_default_contract' || '.';
  px_inp_rec.contract_number          := NULL;
  px_inp_rec.contract_number_modifier := NULL;
  px_inp_rec.service_line_id          := NULL;
  px_inp_rec.party_id                 := p_customer_id;
  px_inp_rec.site_id                  := p_install_site_use_id;
  px_inp_rec.cust_acct_id             := p_account_id;
  px_inp_rec.system_id                := p_system_id;
  px_inp_rec.item_id                  := p_inventory_item_id;
  px_inp_rec.product_id               := p_customer_product_id;
  px_inp_rec.request_date             := p_request_date;
  px_inp_rec.incident_date            := p_incident_occurred_date;
  px_inp_rec.severity_id              := p_severity_id;
  px_inp_rec.time_zone_id             := p_time_zone_id;
  px_inp_rec.business_process_id      := p_business_process_id;
  px_inp_rec.calc_resptime_flag       := 'Y';
  px_inp_rec.validate_flag            := 'Y';
  px_inp_rec.dates_in_input_tz        := 'N';

  -- 12.1.2-srt order issue, sanjana rao
  --px_inp_rec.sort_key                 := 'RSN';

--The value set in this profile option will be passed to the contracts API to
--return the contract lines sorted based on Reaction Rime(RCN)/ Resolution Time(RSN)/
--Importance Level(COVTYP_IMP).
--Default value: Resolution time (to be backward compatible)


   px_inp_rec.sort_key := fnd_profile.value('CS_SR_CONTRACT_SORT_ORDER');
   if  px_inp_rec.sort_key is null then
      px_inp_rec.sort_key := 'RSN';
   end if;

-- 12.1.2 sort order issue, sanjana rao


  CS_TZ_GET_DETAILS_PVT.customer_preferred_time_zone
  ( p_incident_id             => p_incident_id
  , p_task_id                 => NULL
  , p_resource_id             => NULL
  , p_incident_location_id    => p_incident_location_id
  , p_incident_location_type  => p_incident_location_type
  , p_contact_party_id        => p_primary_contact_party_id
  , p_contact_phone_id        => p_primary_contact_point_id
  , p_customer_id             => p_customer_id
  , x_timezone_id             => lx_timezone_id
  , x_timezone_name           => lx_timezone_name
  );


  IF lx_timezone_id IS NOT NULL
  THEN
    px_inp_rec.time_zone_id := lx_timezone_id;
  ELSE
    px_inp_rec.time_zone_id := p_time_zone_id;
  END IF ;

--------------------Call to Get contracts Starts Here--------------------------
  IF ((px_inp_rec.business_process_id IS NULL) OR
      (px_inp_rec.severity_id         IS NULL) OR
      (px_inp_rec.time_zone_id        IS NULL) )
  THEN
    FND_MESSAGE.SET_NAME      ('CS','CS_SR_DEF_SLA_INSUFF_PARAMS');
    FND_MSG_PUB.ADD_DETAIL    (p_message_type=>FND_MSG_PUB.G_INFORMATION_MSG);
    --FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data  => x_msg_data);
  ELSE
    OKS_ENTITLEMENTS_PUB.get_contracts
         (p_api_version              => 1.0,
          p_init_msg_list            => fnd_api.g_false ,
          p_inp_rec                  => px_inp_rec,
          x_return_status            => x_return_status,
          x_msg_count                => l_msg_count,
          x_msg_data                 => l_msg_data,
          x_ent_contracts            => l_ent_contracts);
    IF (x_return_status = 'S' AND l_ent_contracts.count > 0)
    THEN
      Li_TableIdx           := l_ent_contracts.FIRST                           ;
      x_contract_id         := l_ent_contracts(Li_TableIdx).contract_id        ;
      x_contract_number     := l_ent_contracts(Li_TableIdx).contract_number    ;
      x_contract_service_id := l_ent_contracts(Li_TableIdx).service_line_id    ;
      x_exp_resolution_date := l_ent_contracts(Li_TableIdx).exp_resolution_time;
      x_obligation_date     := l_ent_contracts(Li_TableIdx).exp_reaction_time  ;
    ELSE
      x_contract_id         := null ;
      x_contract_number     := null ;
      x_contract_service_id := null ;
      x_exp_resolution_date := null ;
      x_obligation_date     := null ;

      FND_MESSAGE.set_name('CS','CS_SR_UNABLE_DEF_CONTR');
      FND_MSG_PUB.add_detail(p_message_type=>FND_MSG_PUB.G_INFORMATION_MSG);
      -- in case of update API, this param is always passed as NULL
      -- so this will not execute for update API
      IF p_default_coverage_template_id is NOT NULL
      THEN
        l_inp_rec.Coverage_template_id := p_default_coverage_template_id ;
        l_inp_rec.Business_process_id  := p_business_process_id;
        l_inp_rec.request_date         := p_request_date ;
        l_inp_rec.Severity_id          := p_severity_id;
        l_inp_rec.Time_zone_id         := lx_timezone_id;
        l_inp_rec.dates_in_input_tz    := 'N';
        OKS_COV_ENT_PUB.Get_default_react_resolve_by
        ( p_api_version          =>1.0
        , p_init_msg_list        => FND_API.G_FALSE
        , p_inp_rec              => l_inp_rec
        , x_return_status        => x_return_status
        , x_msg_count            => l_msg_count
        , x_msg_data             => l_msg_data
        , x_react_rec            => l_react_rec
        , x_resolve_rec          => l_resolve_rec
        );
        IF l_react_rec.by_date_end   IS NOT NULL            AND
           l_resolve_rec.by_date_end IS NOT NULL            AND
           l_react_rec.by_date_end   <> FND_API.G_MISS_DATE AND
           l_resolve_rec.by_date_end <> FND_API.G_MISS_DATE
        THEN
          x_obligation_date     := l_react_rec.by_date_end;
          x_exp_resolution_date := l_resolve_rec.by_date_end;
          --
          IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            ( FND_LOG.level_procedure , L_LOG_MODULE || ''
             , 'The defaulted value of parameter exp_resolution_date :' || x_exp_resolution_date
            );
            FND_LOG.String
            ( FND_LOG.level_procedure , L_LOG_MODULE || ''
            , 'The defaulted value of parameter obligation_date :' || x_obligation_date
            );
	  END IF;
        END IF; -- Returned value of dates are not null
      END IF; -- if p_default_coverage is not null
    END IF; -- else return status = 'S'
  END IF;  -- all required param are available
---------------------Call to Get contracts end Here-----------------------------
END get_default_contract;
-- -----------------------------------------------------------------------------
-- PROCEDURE : vldt_sr_rec            PRIVATE
-- PARAMETERS: p_sr_rec               Service Requesr Record after processing for
--                                    G_miss values
--           : p_sr_rec_inp           Service Requesr Record as input to API
--           : p_sr_related_data      This record hold SR related values such as
--                                    status flags, workflow flag, business
--                                    process id etc.
--           : p_mode                 it can 2 values 'CREATE' or 'UPDATE'
--                                    indicating SR creation or update
--           : p_request_id           SR identifier
--           : p_object_version_number SR object version
--           : p_last_updated_by       User Id
--           : p_validation_level      Validation level passed to SR API
--           : p_default_contract_sla_ind Default contract SLA indicator
--           : p_auto_assign              Auto assignment flag passed to API
--           : p_old_xxxx             these parameters hold old value of
--                                    corresponding SR attributes
--           : x_return_status        Indicates success or failure
--                                    encountered by the procedure
-- COMMENT   : This procedure validates following attributes
--             1. incident location
--             2. incident owner
--             3. Service contract
--             This procedure derives follwing attribute
--             1. incident country
--             2. resource type
--             3. service contract if p_default_contract_sla_ind is passed as Y
--             4. incident owner if p_auto_assign is passed as 'Y'
--             5. incident owner group if p_auto_assign is passed as 'Y'
--             6. Determines coverage if contract is available to SR
--
-- PRE-COND  : All input parameters are processed for g_miss values i.e SR Rec
--             should not have any G_MISS values
--           :
-- EXCEPTIONS: None
-- Modification History:
-- Date     Name     Desc
-- ------- -------- ------------------------------------------------------------
-- 12/14/05 smisra   Created
--                   Bug 4386870. Added call to validate_inc_location_id
-- 12/23/05 smisra   Bug 4894942, 4892782
--                   Added following calls
--                   1. Validate contract service id
--                   2. Call to default contract
--                   3. Call to determine coverage type based on contract
--                      service identifier
--                   4. Service request auto assignment
-- 12/30/05 smisra   Bug 4773215
--                   Added two parameters:
--                   1. p_old_site_id and
--                   2. p_old_resource_type
--                   Added validation of resource id. This will set resource
--                   type and site id based on resource
-- 11/14/08 Ranjan  Bug 7561640
--            in vldt_sr_rec it is overiding resource type value with party site
--            id
-- ------- -------- ------------------------------------------------------------
PROCEDURE  vldt_sr_rec
( p_sr_rec                     IN OUT NOCOPY service_request_rec_type
, p_sr_rec_inp                 IN            service_request_rec_type
, p_sr_related_data            IN            RELATED_DATA_TYPE
, p_mode                       IN            VARCHAR2 DEFAULT NULL
, p_request_id                 IN            NUMBER   DEFAULT NULL
, p_object_version_number      IN            NUMBER   DEFAULT NULL
, p_last_updated_by            IN            NUMBER
, p_validation_level           IN            NUMBER   DEFAULT NULL
, p_default_contract_sla_ind   IN            VARCHAR2
, p_default_coverage_template_id IN      NUMBER DEFAULT NULL
, p_auto_assign                  IN      VARCHAR2
, p_old_incident_location_id   IN            NUMBER   DEFAULT NULL
, p_old_incident_location_type IN            VARCHAR2 DEFAULT NULL
, p_old_incident_country       IN            VARCHAR2 DEFAULT NULL
, p_old_incident_owner_id      IN            NUMBER   DEFAULT NULL
, p_old_owner_group_id         IN            NUMBER   DEFAULT NULL
, p_old_resource_type          IN            VARCHAR2 DEFAULT NULL
, p_old_site_id                IN            NUMBER   DEFAULT NULL
, p_old_obligation_date          IN          DATE   DEFAULT NULL
, p_old_expected_resolution_date IN          DATE   DEFAULT NULL
, p_old_contract_id              IN          NUMBER DEFAULT NULL
, p_old_contract_service_id      IN          NUMBER DEFAULT NULL
, p_old_install_site_id          IN          NUMBER DEFAULT NULL
, p_old_system_id                IN          NUMBER DEFAULT NULL
, p_old_account_id               IN          NUMBER DEFAULT NULL
, p_old_inventory_item_id        IN          NUMBER DEFAULT NULL
, p_old_customer_product_id      IN          NUMBER DEFAULT NULL
, p_old_incident_type_id         IN          NUMBER DEFAULT NULL
, p_old_time_zone_id             IN          NUMBER DEFAULT NULL
, p_old_incident_severity_id     IN          NUMBER DEFAULT NULL
, x_contract_number            IN OUT NOCOPY VARCHAR2
, x_return_status                 OUT NOCOPY VARCHAR2
) IS
l_return_status             VARCHAR2(1);
l_contract_service_id_valid VARCHAR2(1);
l_api_name                  VARCHAR2(80);
l_log_module                VARCHAR2(255) ;
l_contract_defaulted        VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_auto_assign_level         fnd_profile_option_values.profile_option_value % TYPE;
l_asgn_owner_id             cs_incidents_all_b.incident_owner_id           % TYPE;
l_asgn_resource_type        cs_incidents_all_b.resource_type               % TYPE;
l_asgn_owner_group_id       cs_incidents_all_b.owner_group_id              % TYPE;
l_asgn_owner_type           cs_incidents_all_b.resource_type               % TYPE;
l_territory_id              NUMBER;
l_orig_group_type_null varchar2(1) := 'N';
l_owner_id                  CS_INCIDENTS_ALL_B.incident_owner_id   % TYPE;
l_owner_name                jtf_rs_resource_extns_tl.resource_name % TYPE;
--siahmed 12.1.2 project
l_request_date              DATE;
-- end of addition by siahmed
BEGIN
  l_api_name                  := 'CS_SERVICEREQUEST_PVT.vldt_sr_rec';
  l_log_module                := 'cs.plsql.' || l_api_name || '.';
  l_contract_service_id_valid := 'Y';
  l_contract_defaulted        := 'N';
  x_return_status             := FND_API.G_RET_STS_SUCCESS;

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
  THEN
    --
    --  incident location validation
    --
    -- siahmed adding for 12.1.2 project added the additional condition
    -- where we are only goiung to do this validation if the address
    -- is not a onetime address
    IF (p_sr_rec.incident_location_id IS NOT NULL) AND (G_ONETIME_ADD_CNT <1)
    THEN
      IF p_sr_rec.incident_location_id            <> NVL(p_old_incident_location_id,-9) OR
         NVL(p_sr_rec.incident_location_type,'X') <> NVL(p_old_incident_location_type,'Y') OR
         p_old_incident_country IS NULL
      THEN
        CS_ServiceRequest_UTIL.Validate_Inc_Location_Id
        ( p_api_name                 => l_api_name
        , p_parameter_name           => 'p_incident_location_id'
        , p_incident_location_type   => p_sr_rec.incident_location_type
        , p_incident_location_id     => p_sr_rec.incident_location_id
        , x_incident_country         => p_sr_rec.incident_country
        , x_return_status            => x_return_status
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RETURN;
        END IF;
      END IF;  -- check on change in other related parameters
    END IF;  -- null check on incident location
    --
    -- Incident Owner Validation
    --
    IF p_sr_rec.owner_id IS NULL
    THEN
      p_sr_rec.resource_type := NULL;
      p_sr_rec.site_id       := NULL;
    ELSE
      -- if new owner is same as old owner then set resource type as old resource type
      IF p_sr_rec.owner_id = p_old_incident_owner_id
      THEN
        p_sr_rec.resource_type := p_old_resource_type;
-- fix for   Bug 7561640
        p_sr_rec.site_id := p_old_site_id;
-- end fix for   Bug 7561640
      END IF;
      -- Validate owner id and set resource type if it is not null
      IF p_sr_rec.owner_id               <> NVL(p_old_incident_owner_id, -1) OR
         p_sr_rec.type_id                <> NVL(p_old_incident_type_id , -9) OR
         NVL(p_sr_rec.owner_group_id,-1) <> NVL(p_old_owner_group_id   , -1) OR
         NVL(p_sr_rec.resource_type ,'Y')<> NVL(p_old_resource_type    ,'x')
      THEN
        CS_SERVICEREQUEST_UTIL.validate_owner
        ( p_api_name             => NULL
        , p_parameter_name       => 'owner id'
        , p_owner_id             => p_sr_rec.owner_id
        , p_group_type           => p_sr_rec.group_type
        , p_owner_group_id       => p_sr_rec.owner_group_id
        , p_org_id               => NULL -- not used in validation
        , p_incident_type_id     => p_sr_rec.type_id
        , p_mode                 => p_mode
        , x_owner_name           => l_owner_name
        , x_owner_id             => l_owner_id
        , x_resource_type        => p_sr_rec.resource_type
        , x_support_site_id      => p_sr_rec.site_id
        , x_return_status        => l_return_status
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
        IF p_mode = 'CREATE'
        THEN
          p_sr_rec.owner_id := l_owner_id;
        END IF;
      END IF;
    END IF;
    --
    -- Contract Service Id Validation
    --
    IF p_sr_rec.contract_service_id IS NOT NULL
    THEN
      IF p_sr_rec.contract_service_id         <> NVL(p_old_contract_service_id,-9) OR
         NVL(p_sr_rec.type_id            ,-9) <> NVL(p_old_incident_type_id   ,-9) OR
         NVL(p_sr_rec.system_id          ,-9) <> NVL(p_old_system_id          ,-9) OR
         NVL(p_sr_rec.account_id         ,-9) <> NVL(p_old_account_id         ,-9) OR
         NVL(p_sr_rec.contract_id        ,-9) <> NVL(p_old_contract_id        ,-9) OR
         NVL(p_sr_rec.install_site_id    ,-9) <> NVL(p_old_install_site_id    ,-9) OR
         NVL(p_sr_rec.inventory_item_id  ,-9) <> NVL(p_old_inventory_item_id  ,-9) OR
         NVL(p_sr_rec.customer_product_id,-9) <> NVL(p_old_customer_product_id,-9)
      THEN
	CS_SERVICEREQUEST_UTIL.Validate_Contract_Service_Id
        ( p_api_name            => l_api_name
        , p_parameter_name      => 'p_contract_service_id'
        , p_contract_service_id => p_sr_rec.contract_service_id
        , x_contract_id         => p_sr_rec.contract_id
        , x_contract_number     => x_contract_number
        , x_return_status       => l_return_status
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          l_contract_service_id_valid := 'N';
        ELSE
          CS_SERVICEREQUEST_UTIL.contracts_cross_val
          ( p_parameter_name        => 'contract_service_id'
          , p_contract_service_id   => p_sr_rec.contract_service_id
          , p_busiproc_id           => p_sr_related_data.business_process_id
          , p_request_date          => p_sr_rec.request_date
          , p_inventory_item_id     => p_sr_rec.inventory_item_id
          , p_inv_org_id            => p_sr_rec.inventory_org_id
          , p_install_site_id       => p_sr_rec.install_site_id
          , p_customer_product_id   => p_sr_rec.customer_product_id
          , p_account_id            => p_sr_rec.account_id
          , p_customer_id           => p_sr_rec.customer_id
	  , p_system_id             => p_sr_rec.system_id
          , x_return_status         => l_return_status
          );
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
          THEN
	    l_contract_service_id_valid := 'N';
	    p_sr_rec.contract_id        := NULL;
	    x_contract_number           := NULL;
          END IF;
        END IF; -- end of else after validate_contract_service_id procedure
      END IF;  --  Some of contract related attributes changes
    END IF;  -- Check for contract service id is not null
    --
    --
    --
  END IF; -- check on validation level parameter
  --
  -- Get Default contract
  --
  IF (p_default_contract_sla_ind = 'Y')
  THEN
    IF p_sr_rec_inp.obligation_date     = FND_API.G_MISS_DATE AND
       p_sr_rec_inp.exp_resolution_date = FND_API.G_MISS_DATE AND
       p_sr_rec_inp.contract_id         = FND_API.G_MISS_NUM  AND
       p_sr_rec_inp.contract_service_id = FND_API.G_MISS_NUM  AND
       ( p_mode = 'CREATE' OR
          (l_contract_service_id_valid = 'N' OR
             (p_old_obligation_date          IS NULL AND
              p_old_expected_resolution_date IS NULL AND
              p_old_contract_id              IS NULL AND
              p_old_contract_service_id      IS NULL
             ) OR
             ( p_old_contract_service_id IS NULL AND
               (NVL(p_sr_rec.install_site_id,-9)     <> NVL(p_old_install_site_id,-9)     OR
                NVL(p_sr_rec.system_id,-9)           <> NVL(p_old_system_id,-9)           OR
                NVL(p_sr_rec.account_id,-9)          <> NVL(p_old_account_id,-9)          OR
                NVL(p_sr_rec.inventory_item_id,-9)   <> NVL(p_old_inventory_item_id,-9)   OR
                NVL(p_sr_rec.customer_product_id,-9) <> NVL(p_old_customer_product_id,-9) OR
                NVL(p_sr_rec.type_id,-9)             <> NVL(p_old_incident_type_id,-9)    OR
                NVL(p_sr_rec.time_zone_id,-9)        <> NVL(p_old_time_zone_id,-9)        OR
                NVL(p_sr_rec.severity_id,-9)         <> NVL(p_old_incident_severity_id,-9)
               )
             )
          )
       )
    THEN
      l_contract_defaulted        := 'Y';

      --12.1.2 siahmed changes for the
      -- Provide option to start SLA calculations during default contract processing
      IF (fnd_profile.value('CS_SR_SLA_CALCULATE_DATE') = 'CREATED_ON_DATE') THEN
        l_request_date := p_sr_rec.creation_date;
      ELSE
        l_request_date := p_sr_rec.request_date;
      END IF;
      -- end of addition siahmed and added the value in the api call below before it was passing p_sr_rec.request_date directly.

      CS_SERVICEREQUEST_PVT.get_default_contract
      ( p_business_process_id       => p_sr_related_data.business_process_id
      , p_customer_id               => p_sr_rec.customer_id
      , p_install_site_use_id       => p_sr_rec.install_site_use_id
      , p_account_id                => p_sr_rec.account_id
      , p_system_id                 => p_sr_rec.system_id
      , p_inventory_item_id         => p_sr_rec.inventory_item_id
      , p_customer_product_id       => p_sr_rec.customer_product_id
      , p_request_date              => l_request_date
      , p_incident_occurred_date    => p_sr_rec.incident_occurred_date
      , p_severity_id               => p_sr_rec.severity_id
      , p_time_zone_id              => p_sr_rec.time_zone_id
      , p_incident_location_type    => p_sr_rec.incident_location_type
      , p_incident_location_id      => p_sr_rec.incident_location_id
      , p_primary_contact_party_id  => p_sr_related_data.primary_party_id
      , p_primary_contact_point_id  => p_sr_related_data.primary_contact_point_id
      , p_incident_id               => p_request_id
      , p_default_coverage_template_id => p_default_coverage_template_id
      , x_return_status             => x_return_status
      , x_contract_id               => p_sr_rec.contract_id
      , x_contract_number           => x_contract_number
      , x_contract_service_id       => p_sr_rec.contract_service_id
      , x_exp_resolution_date       => p_sr_rec.exp_resolution_date
      , x_obligation_date           => p_sr_rec.obligation_date
      ) ;
      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS )
      THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'The defaulted value of parameter contra_id :' || p_sr_rec.contract_id
        );
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'The defaulted value of parameter contract_number :' || x_contract_number
        );
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'The defaulted value of parameter contract_service_id :' || p_sr_rec.contract_service_id
        );
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'The defaulted value of parameter exp_resolution_date :' || p_sr_rec.exp_resolution_date
        );
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'The defaulted value of parameter obligation_date :' || p_sr_rec.obligation_date
        );
      END IF; -- check of FND_LOG.level_procedure
      IF p_old_contract_service_id IS NOT NULL AND
         NVL(p_sr_rec.contract_service_id,-99) <> p_old_contract_service_id
      THEN
        FND_MESSAGE.SET_NAME('CS','CS_SR_CONTRACT_ASSIGN_CHANGED');
        FND_MSG_PUB.ADD_DETAIL(p_message_type=>FND_MSG_PUB.G_INFORMATION_MSG);
      END IF ;
    END IF; -- contract service or related attributes are null
     -- move the above part to get_default_contract
  END IF;  -- if default contrct sla ind is 'Y'
  IF l_contract_service_id_valid <> 'Y' AND
     l_contract_defaulted <> 'Y'
  THEN
    FND_MESSAGE.set_name ('CS', 'CS_SR_CONTRACT_INVALID');
    FND_MESSAGE.set_token('API_NAME', 'CS_SERVICEREQUEST_UTIL.contracts_cross_val' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- End of Default contract SLA processing
  --
  -- Get Coverage Type
  --
  IF p_sr_rec.contract_service_id IS NOT NULL
  THEN
    IF p_validation_level > FND_API.G_VALID_LEVEL_NONE   OR
       (p_validation_level = FND_API.G_VALID_LEVEL_NONE  AND
        p_sr_rec.coverage_type IS NULL)
    THEN
      OKS_ENTITLEMENTS_PUB.Get_Coverage_Type
      ( p_api_version      => 2.0
      , p_init_msg_list    => FND_API.G_FALSE
      , p_contract_line_id => p_sr_rec.contract_service_id
      , x_return_status    => l_return_status
      , x_msg_count        => l_msg_count
      , x_msg_data         => l_msg_data
      , x_coverage_type    => coverage_type_rec
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF coverage_type_rec.code IS NOT NULL AND
         coverage_type_rec.code <> FND_API.G_MISS_CHAR
      THEN
        p_sr_rec.coverage_type := coverage_type_rec.code ;
      END IF ;
    END IF ;
  END IF;
  --
  -- Start of owner assignment to service request
  --
  IF p_auto_assign NOT IN ('Y','N','y','n')
  THEN
    FND_MESSAGE.Set_Name('CS', 'CS_SR_INVALID_AUTOASSIGN_PARAM');
    FND_MESSAGE.Set_Token('API_NAME', l_api_name);
    FND_MSG_PUB.ADD;
  END IF;
  IF p_sr_rec.owner_id IS NULL AND
     LOWER(p_auto_assign) = 'y' AND
     NVL(p_sr_related_data.old_disallow_request_update,'N') = 'N'
  THEN
    l_auto_assign_level := fnd_profile.value('CS_SR_OWNER_AUTO_ASSIGN_LEVEL');
    -- For bug 3702091 - AM API should not be called even if the Auto Assignment is ON
    -- and the Assignment level is Group and Owner is passed
    IF ((l_auto_assign_level = 'INDIVIDUAL' AND NVL(p_sr_related_data.old_disallow_owner_update,'N') = 'N') OR
        (l_auto_assign_level = 'GROUP'      AND p_sr_rec.owner_group_id is null))
    THEN
      p_sr_rec.load_balance := 'Y';
      p_sr_rec.assign_owner := 'Y';
      IF p_sr_rec.group_type IS NULL
      THEN
        p_sr_rec.group_type    := 'RS_GROUP';
        l_orig_group_type_null := 'Y';
      END IF;
      CS_Assign_Resource_PKG.Assign_ServiceRequest_Main
      ( p_api_name              => 'Assign_ServiceRequest_Main'
      , p_api_version           => 1.0
      , p_init_msg_list         => fnd_api.g_false
      , p_commit                => fnd_api.g_false
      , p_incident_id           => p_request_id
      , p_object_version_number => p_object_version_number
      , p_last_updated_by       => p_last_updated_by
      , p_service_request_rec   => p_sr_rec
      , x_owner_id              => l_asgn_owner_id
      , x_owner_type            => l_asgn_resource_type
      , x_territory_id          => l_territory_id
      , x_return_status         => l_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      , x_owner_group_id        => l_asgn_owner_group_id
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        FND_MSG_PUB.Count_And_Get
        ( p_count => l_msg_count
        , p_data  => l_msg_data
        );
        IF (l_orig_group_type_null = 'Y') then
          p_sr_rec.group_type := NULL;
        END IF;
      ELSE
        IF l_asgn_owner_group_id IS NOT NULL AND
           NVL(p_sr_rec.owner_group_id,-1) <> l_asgn_owner_group_id
        THEN
          p_sr_rec.owner_group_id := l_asgn_owner_group_id;
          IF p_sr_rec.group_type IS NULL
          THEN
            p_sr_rec.group_type := 'RS_GROUP';
            -- this is needed otherwise combination of group id and group type will
            -- becomes invalid 12/9/03 smisra
          END IF;
        END IF;
        IF l_asgn_owner_id IS NOT NULL AND
           NVL(p_sr_rec.owner_id,-1) <> l_asgn_owner_id
        THEN
          p_sr_rec.owner_id      := l_asgn_owner_id;
          p_sr_rec.resource_type := l_asgn_resource_type;
        END IF;
        -- Add information message if AM API does not return anything
        IF l_asgn_owner_group_id IS NULL AND l_asgn_owner_id IS NULL
        THEN
          FND_MESSAGE.Set_Name('CS', 'CS_SR_AM_API_RETURNED_NULL');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name);
          FND_MSG_PUB.ADD;
        END IF;
        p_sr_rec.territory_id := l_territory_id;
      END IF; -- AM API returned with success
    END IF; -- is call to assign_servicerequest needed?
  END IF; -- if p_auto_assign is 'Y'
  --
  --
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status             := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token
    ('P_TEXT'
    , 'CS_SERVICEREQUEST_UTIL.vldt_sr_rec'||'-'||SQLERRM
    );
    FND_MSG_PUB.ADD;
END vldt_sr_rec;
--============================================================================
-- PROCEDURE : set_time_zone        PRIVATE
-- PARAMETERS: p_contact_party_id   Contact party
--           : p_contact_point_type it could PHONE or EMAIL
--           : p_contact_point_id   primary key to hz_contact_points
--           : p_incident_id        primary key to incidents table
-- COMMENT   : This procedure will determine timezone based on primary contact's
--           : phone or identifying address and update incidents table
--           : If no timezone is found then incidents table is not updated
-- PRE-COND  : contact party and contact point type, contact point id and incident
--           : id must be valid
-- EXCEPTIONS: None
--============================================================================
PROCEDURE set_time_zone(p_contact_party_id              NUMBER,
                        p_contact_point_type            VARCHAR2,
                        p_contact_point_id              NUMBER,
                        p_incident_id                   NUMBER) IS
  CURSOR c_phone_timezone IS
    SELECT
      timezone_id
    FROM
      hz_contact_points
    WHERE contact_point_id = p_contact_point_id;

  CURSOR c_addr_timezone IS
    SELECT
      loc.timezone_id
    FROM
      hz_party_sites site
    , hz_locations loc
    WHERE site.location_id              = loc.location_id
      AND site.party_id                 = p_contact_party_id
      AND site.identifying_address_flag = 'Y'
      AND site.status                   = 'A';
  l_timezone_id NUMBER;
BEGIN
  l_timezone_id := null;
  IF (p_contact_point_type = 'PHONE') THEN
    OPEN c_phone_timezone;
    FETCH c_phone_timezone INTO l_timezone_id;
    IF (c_phone_timezone % NOTFOUND)
    THEN
      l_timezone_id := null;
    END IF;
    CLOSE c_phone_timezone;
  END IF;
  --
  -- either primary contact point type is not a phone or no timezone is
  -- associated with primary phone. So get it from primary contact's
  -- identifying address.`
  --
  IF (l_timezone_id IS NULL)
  THEN
    OPEN c_addr_timezone;
    FETCH c_addr_timezone INTO l_timezone_id;
    IF (c_addr_timezone % NOTFOUND)
    THEN
      l_timezone_id := null;
    END IF;
    CLOSE c_addr_timezone;
  END IF;
  --
  -- update incidents table only if timezone is found
  --
  IF (l_timezone_id IS NOT NULL)
  THEN
    UPDATE CS_INCIDENTS_ALL_B
       SET time_zone_id = l_timezone_id
     WHERE incident_id  = p_incident_id;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
END set_time_zone;
--
-- This procedure is defined only in body
-- if x_new_value is g_miss_char then x_new_value is set to p_old_value
PROCEDURE handle_missing_value(x_new_value in out nocopy varchar2,
                               p_old_value in            varchar2);
-- Added dj
-- Local procedure to get the business usage of the responsibility that is
-- attempting to create/update the SR.
PROCEDURE GET_BUSINESS_USAGE (
   p_responsibility_id     IN           NUMBER,
   p_application_id        IN           NUMBER,
   x_business_usage        OUT  NOCOPY  VARCHAR2 )
IS
BEGIN
   select business_usage
   into   x_business_usage
   from   cs_service_responsibility
   where  responsibility_id = p_responsibility_id
   and    application_id    = p_application_id;

EXCEPTION
   when others then
      x_business_usage := NULL;
END GET_BUSINESS_USAGE;

-- Local procedure to get the attribute that indicates if security is enabled
-- for self service responsibilities
PROCEDURE GET_SS_SEC_ENABLED (
   x_ss_sr_type_restrict      OUT  NOCOPY  VARCHAR2 )
IS
BEGIN
   select ss_srtype_restrict
   into   x_ss_sr_type_restrict
   from   cs_system_options;
EXCEPTION
   when others then
      x_ss_sr_type_restrict := NULL;
END GET_SS_SEC_ENABLED;

PROCEDURE Create_SR_Validation
( p_api_name             IN      VARCHAR2,
  p_service_request_rec  IN      service_request_rec_type,
  p_contacts             IN      contacts_table,
  p_resp_id              IN      NUMBER    DEFAULT NULL,
  p_resp_appl_id         IN      NUMBER    DEFAULT NULL,
  p_user_id              IN      NUMBER,
  p_login_id             IN      NUMBER    DEFAULT NULL,
  p_org_id               IN      NUMBER    DEFAULT NULL,
  p_request_id           IN      NUMBER    DEFAULT NULL,
  p_request_number       IN      VARCHAR2  DEFAULT NULL,
  p_validation_level     IN      NUMBER    DEFAULT fnd_api.g_valid_level_full,
  p_commit               IN      VARCHAR2  DEFAULT fnd_api.g_false,
  x_msg_count            OUT     NOCOPY NUMBER,
  x_msg_data             OUT     NOCOPY VARCHAR2,
  x_return_status        OUT     NOCOPY VARCHAR2,
  x_contra_id            OUT     NOCOPY NUMBER,
  x_contract_number      OUT     NOCOPY VARCHAR2,
  x_owner_assigned_flag  OUT     NOCOPY VARCHAR2,
  x_req_id               OUT     NOCOPY NUMBER,
  x_request_id           OUT     NOCOPY NUMBER,
  x_req_num              OUT     NOCOPY VARCHAR2,
  x_request_number       OUT     NOCOPY VARCHAR2,
  x_autolaunch_wkf_flag  OUT     NOCOPY VARCHAR2,
  x_abort_wkf_close_flag OUT     NOCOPY VARCHAR2,
  x_wkf_process_name     OUT     NOCOPY VARCHAR2,
  x_audit_vals_rec	 OUT	 NOCOPY	sr_audit_rec_type,
  x_service_request_rec  OUT     NOCOPY service_request_rec_type,
  p_cmro_flag            IN     VARCHAR2,
  p_maintenance_flag     IN     VARCHAR2,
  p_auto_assign           IN     VARCHAR2 := 'N'
);


PROCEDURE Update_SR_Validation
( p_api_version           IN     VARCHAR2,
  p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false,
  p_service_request_rec   IN     service_request_rec_type,
  p_invocation_mode       IN     VARCHAR2 := 'NORMAL',
  p_notes                 IN     notes_table,
  p_contacts              IN     contacts_table,
  p_audit_comments        IN     VARCHAR2 DEFAULT NULL,
  p_resp_id               IN     NUMBER    DEFAULT NULL,
  p_resp_appl_id          IN     NUMBER    DEFAULT NULL,
  p_request_id            IN     NUMBER,
  p_validation_level      IN     NUMBER    DEFAULT fnd_api.g_valid_level_full,
  p_commit                IN     VARCHAR2  DEFAULT fnd_api.g_false,
  p_last_updated_by       IN     NUMBER,
  p_last_update_login     IN     NUMBER    DEFAULT NULL,
  p_last_update_date      IN     DATE,
  p_object_version_number IN     NUMBER,
  x_return_status         OUT    NOCOPY VARCHAR2,
  x_contra_id             OUT    NOCOPY NUMBER,
  x_contract_number       OUT    NOCOPY VARCHAR2,
  x_owner_assigned_flag   OUT    NOCOPY VARCHAR2,
  x_msg_count             OUT    NOCOPY NUMBER,
  x_msg_data              OUT    NOCOPY VARCHAR2,
  x_audit_vals_rec	  OUT	 NOCOPY	sr_audit_rec_type,
  x_service_request_rec   OUT    NOCOPY service_request_rec_type,
  x_autolaunch_wkf_flag   OUT    NOCOPY VARCHAR2,
  x_abort_wkf_close_flag  OUT    NOCOPY VARCHAR2,
  x_wkf_process_name      OUT    NOCOPY VARCHAR2,
  x_workflow_process_id   OUT    NOCOPY NUMBER,
  x_interaction_id        OUT    NOCOPY NUMBER,
  p_update_desc_flex      IN     VARCHAR2  DEFAULT fnd_api.g_false,
  p_called_by_workflow    IN     VARCHAR2  DEFAULT fnd_api.g_false,
  p_workflow_process_id   IN     NUMBER    DEFAULT NULL,
  p_cmro_flag             IN     VARCHAR2,
  p_maintenance_flag      IN     VARCHAR2,
  p_auto_assign           IN     VARCHAR2 := 'N'
);

PROCEDURE Validate_ServiceRequest_Record
( p_api_name                IN  VARCHAR2,
  p_service_request_rec     IN  Request_Validation_Rec_Type,
  p_request_date            IN  DATE                := FND_API.G_MISS_DATE,
  p_org_id                  IN  NUMBER              := NULL,
  p_resp_appl_id            IN  NUMBER              := NULL,
  p_resp_id                 IN  NUMBER              := NULL,
  p_user_id                 IN  NUMBER              := NULL,
  p_operation               IN  VARCHAR2            := NULL,
  p_close_flag              OUT NOCOPY VARCHAR2,
  p_disallow_request_update OUT NOCOPY VARCHAR2,
  p_disallow_owner_update   OUT NOCOPY VARCHAR2,
  p_disallow_product_update OUT NOCOPY VARCHAR2,
  p_employee_name   	    OUT NOCOPY VARCHAR2,
  p_inventory_item_id       OUT NOCOPY NUMBER,
  p_contract_id             OUT NOCOPY NUMBER,
  p_contract_number         OUT NOCOPY VARCHAR2,
  x_bill_to_site_id         OUT NOCOPY NUMBER,
  x_ship_to_site_id         OUT NOCOPY NUMBER,
  x_bill_to_site_use_id     OUT NOCOPY NUMBER,
  x_ship_to_site_use_id     OUT NOCOPY NUMBER,
  x_return_status   	    OUT NOCOPY VARCHAR2,
  x_group_name              OUT NOCOPY VARCHAR2,
  x_owner_name              OUT NOCOPY VARCHAR2,
  x_product_revision        OUT NOCOPY VARCHAR2,
  x_component_version       OUT NOCOPY VARCHAR2,
  x_subcomponent_version    OUT NOCOPY VARCHAR2,
  p_cmro_flag               IN  VARCHAR2,
  p_maintenance_flag        IN  VARCHAR2,
  p_sr_mode                 IN  VARCHAR2
);


FUNCTION Get_Importance_Level(P_Severity_Id IN NUMBER) RETURN NUMBER;

FUNCTION Get_Old_Importance_level(p_incident_id IN NUMBER) RETURN NUMBER;

FUNCTION Get_Title(P_Object_Code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Message(p_message_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Owner_id(p_incident_id IN NUMBER) RETURN NUMBER;

--------------------------------------------------------------------------
-- Procedure Log_SR_PVT_Parameters
-- Description:
--   This procedure used to log the parameters of service_request_type_rec,
--   Notes table and the Contacts table
--   This procedure is only going to be called from the Create_ServiceRequest
--   and Update_ServiceRequest procedure.
--------------------------------------------------------------------------

 PROCEDURE Log_SR_PVT_Parameters
( p_service_request_rec   	  IN         service_request_rec_type
,p_notes                 	  IN         notes_table
,p_contacts              	  IN         contacts_table
);

----------------anmukher--------------07/31/03
-- Overloaded procedure added for backward compatibility in 11.5.10
-- since several new OUT parameters have been added to the 11.5.9 signature
-- in the form of a new record type, sr_create_out_rec_type
PROCEDURE Create_ServiceRequest
  ( p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_org_id                 IN    NUMBER   DEFAULT NULL,
    p_request_id             IN    NUMBER   DEFAULT NULL,
    p_request_number         IN    VARCHAR2 DEFAULT NULL,
    p_invocation_mode        IN    VARCHAR2 := 'NORMAL',
    p_service_request_rec    IN    service_request_rec_type,
    p_notes                  IN    notes_table,
    p_contacts               IN    contacts_table,
  -- Added for Assignment Manager 11.5.9 change
  p_auto_assign                   IN      VARCHAR2  Default 'N',
  p_default_contract_sla_ind      IN      VARCHAR2 Default 'N',
  x_request_id			  OUT     NOCOPY NUMBER,
  x_request_number		  OUT     NOCOPY VARCHAR2,
  x_interaction_id                OUT     NOCOPY NUMBER,
  x_workflow_process_id           OUT     NOCOPY NUMBER,
  -- These 3 parameters are added for Assignment Manager 115.9 changes.
  x_individual_owner              OUT   NOCOPY NUMBER,
  x_group_owner                   OUT   NOCOPY NUMBER,
  x_individual_type               OUT   NOCOPY VARCHAR2
 )
IS
  l_api_version        CONSTANT NUMBER          := 3.0;
  l_api_name           CONSTANT VARCHAR2(30)    := 'Create_ServiceRequest';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_return_status               VARCHAR2(1);
  -- Added for making call to 11.5.10 signature of Create SR private API
  l_sr_create_out_rec	sr_create_out_rec_type;
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Create_ServiceRequest_PVT;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 CS_ServiceRequest_PVT.Create_ServiceRequest
    ( p_api_version                  => 4.0,
      p_init_msg_list                => fnd_api.g_false ,
      p_commit                       => p_commit,
      p_validation_level	     => p_validation_level,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_resp_appl_id                 => p_resp_appl_id,
      p_resp_id                      => p_resp_id,
      p_user_id                      => p_user_id,
      p_login_id                     => p_login_id,
      p_org_id                       => p_org_id,
      p_request_id                   => p_request_id,
      p_request_number               => p_request_number,
      p_invocation_mode		     => p_invocation_mode,
      p_service_request_rec          => p_service_request_rec,
      p_notes                        => p_notes,
      p_contacts                     => p_contacts,
      p_auto_assign                  => p_auto_assign,
      p_auto_generate_tasks	     => 'N',
      p_default_contract_sla_ind     => p_default_contract_sla_ind,
      p_default_coverage_template_id => NULL,
      x_sr_create_out_rec      	     => l_sr_create_out_rec
    );

  x_return_status	:= l_return_status;

  x_request_id		:= l_sr_create_out_rec.request_id;
  x_request_number	:= l_sr_create_out_rec.request_number;
  x_interaction_id	:= l_sr_create_out_rec.interaction_id;
  x_workflow_process_id	:= l_sr_create_out_rec.workflow_process_id;
  x_individual_owner	:= l_sr_create_out_rec.individual_owner;
  x_group_owner		:= l_sr_create_out_rec.group_owner;
  x_individual_type	:= l_sr_create_out_rec.individual_type;

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Create_ServiceRequest;

--------------------------------------------------------------------------
-- Create_ServiceRequest
--------------------------------------------------------------------------
-- Modification History:
-- Date     Name     Desc
---------- -------- ------------------------------------------------------------
-- 04/29/05 smisra   removed contact point logic and replacd it with procedures
--                   cs_srcontact_pkg.process to validate contact points and
--                   cs_srcontact_pkg.create_update to insert or update
--                   service request contact points
-- 05/09/05 smisra   Added defaulting of org_id before call to
--                   creat_sr_validation.
--                   modified insert to cs_incidents_all_b and passed values for
--                   columns org_id and maint_organization_id
-- 05/27/05 smisra   Bug 4227769
--                   Removed owner and group_owner columns from insert into
--                   cs_incidents_all_tl table.
-- 06/07/05 smisra   Release 12 changes
--                   Raised error msg when maint_organization_id is passed for
--                   Non EAM service requests
--                   Raised error msg when maint_organization_id is NOT passed
--                   for EAM SRs with customer product
-- 07/11/05 smisra   Release 12 changes
--                   Called  CS_TZ_GET_DETAILS_PVT.customer_preferred_time_zone
--                   to get customer preferred time zone. This time zone is
--                   passed to contract API
--                   Modified call to cs_srcontact_pkg.process and received two
--                   new parameters primary contact id and primary contact point
--                   id
--                   Moved contact point creation after SR audit creation so
--                   that SR audit has audit for SR creation first then child
--                   audit for contacts
-- 07/21/05 smisra   Added code to set expected resolution and obligation dates
--                   in audit record just before call to create audit rec
--                   procedure. This was needed because call to get contract may
--                   set these dates.
-- 07/26/05 smisra   Added code to set expected resolution and obligation dates
--                   modified create_servicerequest procedure and moved
--                   check on value of maint_organization inside if
--                   condition of p_validation_level so that this check
--                   is not made when PVT API is called with validation
--                   level NONE.
-- 08/06/05 smisra   correct multi org OU name
-- 08/03/05 smisra   Contract Time zone changes
--                   passed incident_occurred_date, time_zone_id and
--                   dates_in_input_tz to contract record.
--                   Raised error if item_serial_number is passed to this proc
-- 08/16/05 smisra   set last_update_program_code in audit record to
--                   creation_program_code value
-- 08/17/05 smisra   changed org id profile name from CS_SR_DEFAULT_MULTI_ORG_OU
--                   to CS_SR_ORG_ID
-- 10/03/05 smisra   moved create SR audit and create contact points call before
--                   raising business events.
-- 11/16/05 smisra   Set coverage_type of audit record using SR Rec column
-- 12/14/05 smisra   Bug 4386870. Called vldt_sr_rec after create_sr_validation
--                   set incident_country, incident_location_id and
--                   incident_locatiomn_type attribute of audit record just-
--                   before call to create audit
-- 12/23/05 smisra   Bug 4894942, 4892782
--                   1. Called get_incident_type_details if def contr sla is Y
--                      because contract defaulting needs business process id
--                   2. Passed additional parameters to vldt_sr_rec call
--                   3. Removed the code to get coverage type. This code is
--                      moved to vldt_sr_rec
--                   4. Removed the code to default contract service id, Now
--                      this code is part of vldt_sr_rec.
--                   5. Removed the code to get SLA dates. Now this code is part
--                      of get_default_contract procedure.
--                   6. Added auditing of following attributes just before call
--                      to create audit
--                      a. resource_type
--                      b. group_type
--                      c. incident_owner_id
--                      d. group_owner_id
--                      e. owner_assigned_time
--                      f. territory_id
-- 12/30/05 smisra   Bug 4869065
--                   Set site_id cols of audit record just before call to
--                   create audit
--------------------------------------------------------------------------------
PROCEDURE Create_ServiceRequest
  ( p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_org_id                 IN    NUMBER   DEFAULT NULL,
    p_request_id             IN    NUMBER   DEFAULT NULL,
    p_request_number         IN    VARCHAR2 DEFAULT NULL,
    p_invocation_mode        IN    VARCHAR2 := 'NORMAL',
    p_service_request_rec    IN    service_request_rec_type,
    p_notes                  IN    notes_table,
    p_contacts               IN    contacts_table ,
    -- Added for Assignment Manager 11.5.9 change
    p_auto_assign            IN    VARCHAR2  DEFAULT 'N',
    --------------anmukher----------------------07/31/03
    -- Added for 11.5.10 projects (AutoTask, Miscellaneous ERs)
    p_auto_generate_tasks		IN		VARCHAR2 Default 'N',
    p_default_contract_sla_ind		IN		VARCHAR2 Default 'N',
    p_default_coverage_template_id	IN		NUMBER Default NULL,
    x_sr_create_out_rec			OUT NOCOPY	sr_create_out_rec_type
    ---------------anmukher----------------------08/07/03
    -- The following OUT parameters have been added to the record type sr_create_out_rec_type
    -- and have therefore been commented out. This will allow avoidance of future overloading
    -- if a new OUT parameter were to be needed, since it can be added to the same record type.
    -- x_request_id             OUT   NOCOPY NUMBER,
    -- x_request_number         OUT   NOCOPY VARCHAR2,
    -- x_interaction_id         OUT   NOCOPY NUMBER,
    -- x_workflow_process_id    OUT   NOCOPY NUMBER,
    -- These 3 parameters are added for Assignment Manager 115.9 changes.
    -- x_individual_owner       OUT   NOCOPY NUMBER,
    -- x_group_owner            OUT   NOCOPY NUMBER,
    -- x_individual_type        OUT   NOCOPY VARCHAR2
  )
  IS
     l_api_name                   CONSTANT VARCHAR2(30)    := 'Create_ServiceRequest';
-- changed the version from 3.0 to 4.0 anmukher aug 11 2003
     l_api_version                CONSTANT NUMBER          := 4.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
     l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
     l_return_status              VARCHAR2(1);
---  AUDIT
     l_audit_vals_rec		      sr_audit_rec_type;
     l_service_request_val_rec    Request_Validation_Rec_Type;
     l_service_request_rec        service_request_rec_type DEFAULT p_service_request_rec;
     x_service_request_rec        service_request_rec_type DEFAULT p_service_request_rec;
     l_transaction_type           CONSTANT VARCHAR2(61)    := G_PKG_NAME||'_'||l_api_name;
     l_message_revision           NUMBER;
     l_maintenance_mode           VARCHAR2(30);
     l_sr_contact_point_id        NUMBER DEFAULT NULL;
     l_contacts                   contacts_table := p_contacts;
     p_update_desc_flex           VARCHAR2(1);
     p_object_version_number      NUMBER;
     l_audit_id                   NUMBER;
     l_enqueue_number             VARCHAR2(64);
     -- Added for automatic assignment
     l_owner_assign_forms         VARCHAR2(1);
     l_owner_assign_html          VARCHAR2(1);
     l_load_balance_forms         VARCHAR2(1);
     l_load_balance_html          VARCHAR2(1);
     l_temp_owner_id              NUMBER;
     l_temp_owner_type            VARCHAR2(30);
     l_object_version_number      NUMBER;
     l_jtf_note_id                NUMBER ;
     l_owner_assigned_flag        VARCHAR2(1);
     l_employee_name              VARCHAR(240);
     l_contra_id                  NUMBER;
     l_contract_number            VARCHAR2(120);
     l_request_id                 NUMBER         := p_request_id;
     l_request_number             VARCHAR2(64)   := p_request_number;
     l_req_id                     NUMBER;
     l_req_num                    VARCHAR2(64);
     l_temp_id                    NUMBER;
     l_temp_num                   VARCHAR2(64);

     l_note_index                 BINARY_INTEGER;
     l_note_id                    NUMBER;
     l_note_context_id            NUMBER;
     l_notes_detail               VARCHAR2(32767);
     l_contact_index              BINARY_INTEGER;

     l_autolaunch_workflow_flag   VARCHAR2(1);
     l_abort_workflow_close_flag  VARCHAR2(1);
     l_workflow_process_name      VARCHAR2(30);
     l_workflow_process_id        NUMBER;

     l_org_id    NUMBER;

     l_interaction_id             NUMBER;

     l_bind_data_id               NUMBER;

     l_primary_contact_found      VARCHAR2(1) := 'N' ;
     l_contacts_passed            VARCHAR2(1) :=  'N';

     -- For Workflow Hook
     l_workflow_item_key         NUMBER;

     l_test  NUMBER;

    -- for UWQ message
     l_msg_id   NUMBER;
     l_msg_count    NUMBER;
     l_msg_data   VARCHAR2(2000);

     --Fixed bug#2802393, changed length from 255 to 2500
     l_uwq_body  VARCHAR2(2500);
     l_imp_level  NUMBER;
     --Fixed bug#2802393, changed length from 30 to 80
     l_title VARCHAR2(80);
     l_send_uwq_notification BOOLEAN := FALSE;
     --Fixed bug#2802393, changed length from 40 to 2000
     l_uwq_body1 VARCHAR2(2000);
     p_uwq_msg_notification  VARCHAR2(30) :='CS_SR_UWQ_NOTIFICATION';

--     l_coverage_type_rec    coverage_type_rec; ---- PKESANI
     Auto_Assign_Excep            EXCEPTION;
	 invalid_install_site		  EXCEPTION;
   -- Added for enh. 2655115
     l_status_flag                VARCHAR2(1);

   -- Added for enh. 2690787
   l_primary_contact            NUMBER;

   -- Added to be used as OUT parameters in the call to the Business Events wrapper
   -- API.
   lx_return_status              VARCHAR2(3);
   lx_msg_count                  NUMBER(15);
   lx_msg_data                   VARCHAR2(2000);

   -- for cmro-eam; Local variable to store the eam/cmro type flags that
   -- will be used to populate the sr record type variable that is passed to the
   -- user hooks
   l_maintenance_flag           VARCHAR2(3):= l_service_request_rec.new_type_maintenance_flag;
   l_cmro_flag 			VARCHAR2(3):= l_service_request_rec.new_type_CMRO_flag;
    -- Changes for usability changes enh, 11.5.10 project
   l_responded_flag             VARCHAR2(1);
   l_resolved_flag              VARCHAR2(1);

   -- Added to be used as OUT parameter for calling CS_AutoGen_Task_PVT.Auto_Generate_Tasks API
   l_auto_task_gen_rec		CS_AutoGen_Task_PVT.auto_task_gen_rec_type;
   l_task_template_group_rec	JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info;
   l_task_template_table	JTF_TASK_INST_TEMPLATES_PUB.task_template_info_tbl;
    -- Added for Misc ER :Owner auto assignment changes
       l_work_item_id             NUMBER;

   --Added for calling Auditing project of 11.5.10
   lx_audit_id			NUMBER;

   -- Added for 11.5.10 Misc ER : Default SLA (iSupport changes)
   px_inp_rec             OKS_ENTITLEMENTS_PUB.get_contin_rec;
   l_inp_rec              OKS_COV_ENT_PUB.gdrt_inp_rec_type;
   l_react_rec            OKS_COV_ENT_PUB.rcn_rsn_rec_type;
   l_resolve_rec          OKS_COV_ENT_PUB.rcn_rsn_rec_type;
   l_ent_contracts        OKS_ENTITLEMENTS_PUB.get_contop_tbl;
   Li_TableIdx BINARY_INTEGER;

   -- Added for API changes for unassigned_indicator
   l_unassigned_indicator NUMBER := 0 ;

   -- Local variable to store business usage for security validation
   l_business_usage       VARCHAR2(30);

   -- Local variable to store attribute if security is enabled for self service resps.
   l_ss_sr_type_restrict   VARCHAR2(10);

   -- local variable to get org_id of the SR
   l_inc_org_id            NUMBER ;

   -- local variable for  validate owner
   lx_owner_name           VARCHAR2(240);
   lx_owner_id             NUMBER;
   x_msg_index_out               NUMBER;
   l_auto_assign_level fnd_profile_option_values.profile_option_value % type;

  --  Local variable to store the request_id, to be passed to IEU procedure.
   q_request_id           NUMBER;
   l_note_status          VARCHAR2(3);
   l_old_contacts         contacts_table;
   l_processed_contacts   contacts_table;
   l_sr_related_data      RELATED_DATA_TYPE;

   lx_timezone_id             NUMBER;
   lx_timezone_name           VARCHAR2(80);
   l_primary_contact_party_id NUMBER := NULL;
   l_primary_contact_point_id NUMBER := NULL;
   l_hook_request_number		varchar2(64):=NULL; -- To be use to store the request number from pre hook

   --added by siahmed for onetime address creation
   l_incident_location_id    NUMBER;
   l_onetime_add_cnt         NUMBER;
   --end of addition by siahmed for onetime address creation

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Create_ServiceRequest_PVT;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF ( l_service_request_rec.initialize_flag IS NULL OR
       l_service_request_rec.initialize_flag <> G_INITIALIZED) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_user_id:' || p_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_login_id:' || p_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_org_id:' || p_org_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_request_id:' || p_request_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_request_number:' || p_request_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_invocation_mode:' || p_invocation_mode
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_auto_assign:' || p_auto_assign
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_auto_generate_tasks:' || p_auto_generate_tasks
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_default_contract_sla_ind:' || p_default_contract_sla_ind
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_default_coverage_template_id:' || p_default_coverage_template_id
    );

 -- --------------------------------------------------------------------------
 -- This procedure Logs the record paramters of SR and NOTES, CONTACTS tables.
 -- --------------------------------------------------------------------------
    Log_SR_PVT_Parameters
    ( p_service_request_rec   	=> p_service_request_rec
    , p_notes                 	=> p_notes
    , p_contacts              	=> p_contacts
    );

  END IF;


  IF l_service_request_rec.item_serial_number <> FND_API.G_MISS_CHAR
  THEN
    FND_MESSAGE.set_name ('CS', 'CS_SR_ITEM_SERIAL_OBSOLETE');
    FND_MESSAGE.set_token
    ( 'API_NAME'
    , 'CS_SERVICEREQUEST_PVT.create_servicerequest'
    );
    FND_MSG_PUB.ADD_DETAIL
    ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.ITEM_SERIAL_NUMBER'
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


   if ( p_validation_level > FND_API.G_VALID_LEVEL_NONE ) then
      -- First step is to validate if the current responsibility has access to the
      -- SR type being created. Invoke the VALIDATE_TYPE procedure that has the
      -- logic to check for security access

      -- Get the business usage of the responsibility that is attempting to create
      -- the SR.
      get_business_usage (
         p_responsibility_id      => p_resp_id,
         p_application_id         => fnd_global.resp_appl_id,
         x_business_usage         => l_business_usage );

      -- Get indicator of self service security enabled or not
      if ( l_business_usage = 'SELF_SERVICE' ) then
         get_ss_sec_enabled (
	    x_ss_sr_type_restrict => l_ss_sr_type_restrict );
      end if;

      -- For bug 3370562 - pass resp_id an appl_id
      -- validate security in create
      cs_servicerequest_util.validate_type (
         p_parameter_name       => NULL,
         p_type_id   	        => p_service_request_rec.type_id,
         p_subtype  	        => G_SR_SUBTYPE,
         p_status_id            => p_service_request_rec.status_id,
         p_resp_id              => p_resp_id,
         p_resp_appl_id         => NVL(p_resp_appl_id,fnd_global.resp_appl_id),
         p_business_usage       => l_business_usage,
         p_ss_srtype_restrict   => l_ss_sr_type_restrict,
         p_operation            => 'CREATE',
         x_return_status        => lx_return_status,
         x_cmro_flag            => l_cmro_flag,
         x_maintenance_flag     => l_maintenance_flag );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- security violation; responsibility does not have access to SR Type
         -- being created. Stop and raise error.
         RAISE FND_API.G_EXC_ERROR;
      end if;

   IF NVL(l_maintenance_flag,'N') <> 'Y'
   THEN
     IF p_service_request_rec.maint_organization_id <> FND_API.G_MISS_NUM
     THEN
       FND_MESSAGE.set_name ('CS', 'CS_SR_MAINT_ORG_NOT_ALLOWED');
       FND_MESSAGE.set_token
       ( 'API_NAME'
       , 'CS_SERVICEREQUEST_PVT.create_servicerequest'
       );
       FND_MSG_PUB.ADD_DETAIL
       ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.MAINT_ORGANIZATION_ID'
       );
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   ELSE -- maintenance flag is 'Y'
     IF (p_service_request_rec.customer_product_id IS NOT NULL AND
         p_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM)
     THEN
       IF p_service_request_rec.maint_organization_id = FND_API.G_MISS_NUM
       THEN
         CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(l_api_name_full, 'Maint_organization_id');
         RAISE FND_API.G_EXC_ERROR;
       ELSIF (p_service_request_rec.maint_organization_id IS NULL) THEN
         CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'Maint_organization_id');
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   END IF;
   end if;   -- if ( p_validation_level > FND_API.G_VALID_LEVEL_NONE ) then

  -- Initialize the value of the parameter from profile cs_sr_restrict_ib
  -- by shijain 4th dec 2002

   g_restrict_ib:= fnd_profile.value('CS_SR_RESTRICT_IB');

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The Value of profile CS_SR_RESTRICT_IB :' || g_restrict_ib
    );
  END IF;
  -- At present the call below in needed only for defaulting contract
  -- if type attributes are needed for some other purpose then the if condition
  -- can be modified accordingly
  IF p_default_contract_sla_ind = 'Y'
  THEN
    CS_SERVICEREQUEST_PVT.get_incident_type_details
    ( p_incident_type_id          => p_service_request_rec.type_id
    , x_business_process_id       => l_sr_related_data.business_process_id
    , x_autolaunch_workflow_flag  => l_sr_related_data.autolaunch_workflow_flag
    , x_abort_workflow_close_flag => l_sr_related_data.abort_workflow_close_flag
    , x_workflow                  => l_sr_related_data.workflow
    , x_return_status             => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
      ( p_token_an     => l_api_name_full
      , p_token_v      => TO_CHAR(p_service_request_rec.type_id)
      , p_token_p      => 'p_type_id'
      , p_table_name   => G_TABLE_NAME
      , p_column_name  => 'INCIDENT_TYPE_ID'
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The defaulted value of parameter business_process_id :'
      || l_sr_related_data.business_process_id
      );
    END IF;
  END IF;

  --
  -- Make the preprocessing call to the user hooks
  --
  -- Pre call to the Customer Type User Hook
  --
   IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'B', 'C')  THEN

-- hardcoded the version 2.0 shijain nov 27 2002

    	l_hook_request_number:=null;
    cs_servicerequest_cuhk.Create_ServiceRequest_Pre(
    p_api_version            =>   2.0,
    p_init_msg_list          =>   fnd_api.g_false ,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_org_id                 =>   p_org_id,
    p_request_id             =>   l_request_id,
    p_request_number         =>   l_request_number,
    p_invocation_mode        =>   p_invocation_mode,
    p_service_request_rec    =>   l_service_request_rec,
    p_notes                  =>   p_notes,
    p_contacts               =>   p_contacts,
    -- Changed out parameter references to out rec references
    x_request_id             =>   x_sr_create_out_rec.request_id,
    x_request_number         =>   x_sr_create_out_rec.request_number,
    x_interaction_id         =>   x_sr_create_out_rec.interaction_id,
    x_workflow_process_id    =>   x_sr_create_out_rec.workflow_process_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Incorporate the following changes
    -- if user hook return a number use that to stamp as service request number
    if x_sr_create_out_rec.request_number  is not null then
    	l_hook_request_number:=x_sr_create_out_rec.request_number ;
    end if;
   END IF;

  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'B', 'V')  THEN

-- hardcoded the version 2.0 shijain nov 27 2002

    cs_servicerequest_vuhk.Create_ServiceRequest_Pre(
    p_api_version            =>   2.0,
    p_init_msg_list          =>   fnd_api.g_false ,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_org_id                 =>   p_org_id,
    p_request_id             =>   l_request_id,
    p_request_number         =>   l_request_number,
    p_service_request_rec    =>   l_service_request_rec,
    p_notes                  =>   p_notes,
    p_contacts               =>   p_contacts,
    -- Changed out parameter references to out rec references
    x_request_id             =>   x_sr_create_out_rec.request_id,
    x_request_number         =>   x_sr_create_out_rec.request_number,
    x_interaction_id         =>   x_sr_create_out_rec.interaction_id,
    x_workflow_process_id    =>   x_sr_create_out_rec.workflow_process_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Pre call to the Internal Type User Hook
  --
  -- Code to populate the global record type with the passed record type
  --
  -- internal_user_hooks_rec.customer_id  :=  l_old_ServiceRequest_rec.customer_id ;
  -- internal_user_hooks_rec.request_id   :=  p_request_id ;

  -- Mobile FS team usually has packages registered for execution
  -- So, if the API returns an unexpected error, please check
  -- JTF_HOOKS_DATA for the Mobile FS packges and check if they are invalid

    cs_servicerequest_iuhk.Create_ServiceRequest_Pre( x_return_status=>l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF p_org_id IS NULL
  THEN
    l_org_id := to_number(FND_PROFILE.value('CS_SR_ORG_ID'));

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The Value of profile CS_SR_ORG_ID :' || l_org_id
      );
    END IF;

  ELSE
    l_org_id := p_org_id;
  END IF;
  -- use hook return value if it is not null otherwise use p_request_number
  if l_hook_request_number is null then
    l_hook_request_number:=p_request_number;
  end if;
  CS_ServiceRequest_PVT.Create_SR_Validation
   (   p_api_name            => l_api_name_full,
       p_service_request_rec => p_service_request_rec,
       p_contacts            => p_contacts,
       p_resp_id             => p_resp_id,
       p_resp_appl_id        => p_resp_appl_id,
       p_user_id             => p_user_id,
       p_login_id            => p_login_id,
       p_org_id              => l_org_id,
       p_request_id          => p_request_id,
       p_request_number      => l_hook_request_number,
       p_validation_level    => p_validation_level,
       p_commit              => p_commit,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       x_return_status       => l_return_status,
       x_contra_id           => l_contra_id,
       x_contract_number     => l_contract_number,
       x_owner_assigned_flag => l_owner_assigned_flag,
       x_req_id              => l_req_id,
       x_request_id          => l_request_id,
       x_req_num             => l_req_num,
       x_request_number      => l_request_number,
       x_autolaunch_wkf_flag => l_autolaunch_workflow_flag,
       x_abort_wkf_close_flag=> l_abort_workflow_close_flag,
       x_wkf_process_name    => l_workflow_process_name,
	   x_audit_vals_rec	     => l_audit_vals_rec,
       x_service_request_rec => l_service_request_rec,
       -- for cmro
       p_cmro_flag           => l_cmro_flag,
       p_maintenance_flag    => l_maintenance_flag,
       p_auto_assign         => p_auto_assign
   );

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- for cmro_eam

	l_service_request_rec.New_type_CMRO_flag := l_cmro_flag;
	l_service_request_rec.New_type_Maintenance_flag := l_maintenance_flag;

-- end for cmro



  /***************************************************************
    This is a tempopary solution for Depot Repair team to get the site_use_id
    if the site_id is passed from the SR form and the validation level is none
    **********************************************/

IF ( p_validation_level = FND_API.G_VALID_LEVEL_NONE ) THEN
  IF ( p_service_request_rec.bill_to_site_id <> FND_API.G_MISS_NUM  AND
       p_service_request_rec.bill_to_site_id IS NOT NULL ) THEN

    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => 'Get bill to site use id',
        p_parameter_name      => 'Bill_To Site ',
        p_bill_to_site_id     => p_service_request_rec.bill_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.bill_to_party_id,
        p_site_use_type       => 'BILL_TO',
        x_site_use_id         => l_service_request_rec.bill_to_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF ( p_service_request_rec.ship_to_site_id <> FND_API.G_MISS_NUM  AND
       p_service_request_rec.ship_to_site_id IS NOT NULL ) THEN

    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => 'Get ship to site use id',
        p_parameter_name      => 'Ship_To Site ',
        p_bill_to_site_id     => p_service_request_rec.ship_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.ship_to_party_id,
        p_site_use_type       => 'SHIP_TO',
        x_site_use_id         => l_service_request_rec.ship_to_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF ( p_service_request_rec.install_site_id <> FND_API.G_MISS_NUM) THEN
      l_service_request_rec.install_site_use_id:=
                                          p_service_request_rec.install_site_id;
  END IF;
END IF;
 -- For BUG # 2933250 check to see if install_site_id and install_site_use_id are same . -- pkesani

	IF (p_service_request_rec.install_site_id <> FND_API.G_MISS_NUM) AND
	   (p_service_request_rec.install_site_use_id <> FND_API.G_MISS_NUM) THEN
	   IF	( p_service_request_rec.install_site_id <> p_service_request_rec.install_site_use_id) THEN
	   RAISE invalid_install_site;
	   END IF;
	END IF;


/********************************************************************
Changes for depot repair finished, need to remove all this for 115.10
***********************************************************************/

 ----- Validate owner id .
 --- If the passed owner_id is not valid , NULL will be assigned to
 --- incident_owner_id column in the DB.


   -- UWQ pop up in service request
   -- while creating an SR from Teleservice
   l_imp_level := Get_Importance_Level(p_service_request_rec.severity_id);
   --select the l_title from jtf_objects_vl
   l_title := Get_Title('SR');
   -- Assign the value of request_id to the local variable that will be passed to the
   -- IEU procedure .
    IF l_request_id IS NULL THEN
         q_request_id := l_req_id ;
         ELSE
         q_request_id := l_request_id;
    END IF;

   l_uwq_body1 := Get_Message(p_uwq_msg_notification);

   l_uwq_body := l_title ||' '|| l_req_num ||' '|| l_uwq_body1 ||' '||TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'); --with time;

   IF (l_service_request_rec.last_update_channel in ('PHONE', 'AGENT')  AND
        l_imp_level =1 AND
        l_service_request_rec.owner_id IS NOT NULL AND
        l_service_request_rec.owner_id <> FND_API.G_MISS_NUM) OR
        (l_service_request_rec.last_update_channel = 'WEB' AND
        (l_imp_level =1 OR l_imp_level =2)  AND
         l_service_request_rec.owner_id IS NOT NULL AND
         l_service_request_rec.owner_id <> FND_API.G_MISS_NUM) THEN
         l_send_uwq_notification := TRUE;
   END IF;

   IF l_send_uwq_notification THEN
          IEU_MSG_PRODUCER_PUB.Send_Plain_text_Msg (
            p_api_version      => 1.0,
            p_init_msg_list    => fnd_api.g_false,
            p_commit           => fnd_api.g_false,
            p_application_id   => 170,
            p_resource_id      => l_service_request_rec.owner_id,
            p_resource_type    => l_service_request_rec.resource_type,
            p_title            => l_title,
            p_body             => l_uwq_body,
            p_workitem_obj_code=> 'SR',
            p_workitem_pk_id   => q_request_id,
            x_message_id       => l_msg_id,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data );
   END IF;

/* Added call to get_status_flag for enh 2655115, to get the status flag
   based on the closed flag by shijain date 27th nov 2002*/

-- for bug 3050727 - commented out as the flag is updated in the create_Sr_validation
--   l_status_flag:= get_status_flag ( l_service_request_rec.status_id);

 /* this code is moved in create_sr_validate. it's presence after create_sr_validation
    stops stamping of incident_resolved_date and inc_responded_by_date to audit rec
    smisra 12/31/2003
    SELECT  responded_flag,resolved_flag
    INTO l_responded_flag,l_resolved_flag
    FROM  cs_incident_statuses_vl
    WHERE incident_status_id=l_service_request_rec.status_id ;

   IF ((l_responded_flag='Y') OR (l_resolved_flag ='Y')) THEN
     IF((l_responded_flag='Y' ) AND (l_service_request_rec.inc_responded_by_date is NULL OR
       l_service_request_rec.inc_responded_by_date= FND_API.G_MISS_DATE ))
     THEN
       l_service_request_rec.inc_responded_by_date := SYSDATE;

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The defaulted value of parameter inc_responded_by_date :'
	    || l_service_request_rec.inc_responded_by_date
	    );
	  END IF;
     END IF;

    IF((l_resolved_flag ='Y' ) AND (l_service_request_rec.incident_resolved_date is NULL
       OR l_service_request_rec.incident_resolved_date = FND_API.G_MISS_DATE ))
    THEN
       l_service_request_rec.incident_resolved_date := SYSDATE;

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The defaulted value of parameter incident_resolved_date :'
	    || l_service_request_rec.incident_resolved_date
	    );
	  END IF;
    END IF;
  END IF;
  */
  /* end of usability changes*/
-- Validate service request contacts
 CS_SRCONTACT_PKG.process
 ( p_mode            => 'CREATE'
 , p_incident_id     => NULL
 , p_caller_type     => l_service_request_rec.caller_type
 , p_customer_id     => l_service_request_rec.customer_id
 , p_validation_mode => p_validation_level
 , p_contact_tbl     => p_contacts
 , x_contact_tbl     => l_processed_contacts
 , x_old_contact_tbl => l_old_contacts
 , x_primary_party_id         => l_sr_related_data.primary_party_id
 , x_primary_contact_point_id => l_sr_related_data.primary_contact_point_id
 , x_return_status   => l_return_status
 );
 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
 THEN
   RAISE FND_API.G_EXC_ERROR;
 END IF;
-- End of SR contact validation
   vldt_sr_rec
   ( p_sr_rec           => l_service_request_rec
   , p_sr_rec_inp       => p_service_request_rec
   , p_sr_related_data  => l_sr_related_data
   , p_mode             => 'CREATE'
   , p_request_id               => NULL
   , p_object_version_number    => NULL
   , p_last_updated_by          => p_user_id
   , p_validation_level         => p_validation_level
   , p_default_contract_sla_ind => p_default_contract_sla_ind
   , p_default_coverage_template_id => p_default_coverage_template_id
   , p_auto_assign                  => p_auto_assign
   , x_contract_number  => l_contract_number
   , x_return_status    => l_return_status
   );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   l_contra_id := l_service_request_rec.contract_id;


    -- Code Changes for setting unassigned_indicator
    -- 12/3/03 smisra. as l_service_request_rec will have owner, group info
    -- returned by Assignment manager API, so using l_ser.. instead of p_service..
	IF (l_service_request_rec.owner_id  <> FND_API.G_MISS_NUM  AND
	    l_service_request_rec.owner_id IS NOT NULL ) AND
	   (l_service_request_rec.owner_group_id  <> FND_API.G_MISS_NUM  AND
	    l_service_request_rec.owner_group_id IS NOT NULL ) THEN
	    l_unassigned_indicator := 3 ;
	ELSIF (l_service_request_rec.owner_id  <> FND_API.G_MISS_NUM  AND
	    l_service_request_rec.owner_id IS  NOT NULL ) AND
	   (l_service_request_rec.owner_group_id  = FND_API.G_MISS_NUM  OR
	    l_service_request_rec.owner_group_id IS NULL ) THEN
	    l_unassigned_indicator := 1 ;
	ELSIF (l_service_request_rec.owner_id  = FND_API.G_MISS_NUM  OR
	    l_service_request_rec.owner_id IS  NULL ) AND
	   (l_service_request_rec.owner_group_id  <> FND_API.G_MISS_NUM  AND
	    l_service_request_rec.owner_group_id IS NOT NULL ) THEN
	    l_unassigned_indicator := 2 ;
	ELSE
	    l_unassigned_indicator := 0 ;
	END IF;
-- Start of change , Sanjana Rao, bug 6955756
	 IF (l_service_request_rec.owner_id  <> FND_API.G_MISS_NUM  AND
	    l_service_request_rec.owner_id IS NOT NULL )
  THEN
       l_service_request_rec.owner_assigned_time   := SYSDATE;
  END IF;
--- End of change , Sanjana Rao , bug 6955756

 x_sr_create_out_rec.individual_owner := l_service_request_rec.owner_id;
 x_sr_create_out_rec.individual_type  := l_service_request_rec.resource_type;
 x_sr_create_out_rec.group_owner      := l_service_request_rec.owner_group_id;
  -- March 23 2000, customer_number is not to be stored in cs_incidents_all_b
  -- If passed to teh api, it is used to retrieve the id from customer table
  -- l_service_request_rec.customer_number,       /*CUSTOMER_NUMBER*/


  -------------------------------------------------------
  --siahmed start of code for creating onetime address
  IF (l_service_request_rec.incident_location_id IS null) THEN
      --(l_service_request_rec.incident_location_id = FND_API.G_MISS_NUM)) THEN
     IF ((l_service_request_rec.incident_address  IS NOT null) OR
         (l_service_request_rec.incident_address2 IS NOT null) OR
         (l_service_request_rec.incident_address3 IS NOT null) OR
         (l_service_request_rec.incident_address4 IS NOT null) OR
         (l_service_request_rec.incident_city     IS NOT null) OR
         (l_service_request_rec.incident_state    IS NOT null) OR
         (l_service_request_rec.incident_postal_code IS NOT null) OR
         (l_service_request_rec.incident_county   IS NOT null) OR
         (l_service_request_rec.incident_province IS NOT null) OR
         (l_service_request_rec.incident_country  IS NOT null) OR
         (l_service_request_rec.site_name   IS NOT NULL) OR
         (l_service_request_rec.site_number IS NOT NULL) OR
         (l_service_request_rec.addressee   IS NOT NULL)) THEN

         --call create onetime address creation procedure
         CREATE_ONETIME_ADDRESS (
           p_service_req_rec   =>  l_service_request_rec,
           x_msg_count         =>  l_msg_count,
           x_msg_data          =>  l_msg_data,
           x_return_status     =>  l_return_status,
           x_location_id       =>  l_incident_location_id
         );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.Set_Name('CS', 'CS_SR_ONETIME_CREATE_ERROR');
            FND_MESSAGE.Set_Token('API_NAME', l_api_name||'CREATE_ONETIME_ADDRESS');
            FND_MSG_PUB.ADD;
         ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            --so that the new party_site_id gets stamped in the cs_incidents_all_b table
            l_service_request_rec.incident_location_id := l_incident_location_id;
            l_service_request_rec.incident_location_type := 'HZ_PARTY_SITE';


            --stamp the out rec type with the incident location_id
            x_sr_create_out_rec.incident_location_id := l_incident_location_id;

         END IF;
            --set the variables to null so that they dont get stored in the incidents table
            l_service_request_rec.incident_address  := null;
            l_service_request_rec.incident_address2 := null;
            l_service_request_rec.incident_address3 := null;
            l_service_request_rec.incident_address4 := null;
            l_service_request_rec.incident_city     := null;
            l_service_request_rec.incident_state    := null;
            l_service_request_rec.incident_postal_code := null;
            l_service_request_rec.incident_county   := null;
            l_service_request_rec.incident_province := null;
            l_service_request_rec.incident_country  := null;
            l_service_request_rec.site_name   := null;
            l_service_request_rec.site_number := null;
            l_service_request_rec.addressee   := null;
            --fix for bug 8563365
            l_service_request_rec.incident_addr_lines_phonetic := null;
            l_service_request_rec.incident_postal_plus4_code := null;

            --end of fix for bug 8563365
      END IF;
   --if they pass an incidnt_id then it should not be of type
   --SR_ONETIME because SR_ONTIME can only be associated for the
   --life of one SR so it should be an existing address but not
   -- SR_ONEIME
   ELSIF (l_service_request_rec.incident_location_id IS NOT NULL) THEN
        --check if created by module = 'SR_ONETIME'
	   -- fix for bug 8594093 to check for location as well Ranjan
	   if l_service_request_rec.incident_location_type='HZ_PARTY_SITE' then
        	SELECT count(party_site_id) into l_onetime_add_cnt
        	FROM hz_party_sites
        	WHERE party_site_id = l_service_request_rec.incident_location_id
        	AND created_by_module = 'SR_ONETIME';
	   elsif l_service_request_rec.incident_location_type='HZ_LOCATION' then
        	SELECT count(location_id) into l_onetime_add_cnt
        	FROM hz_locations
        	WHERE location_id = l_service_request_rec.incident_location_id
        	AND created_by_module = 'SR_ONETIME';
	   end if;


        -- if the incident_location_id is of type SR_ONETIME NULL the
        -- incident location_id
        IF (l_onetime_add_cnt >= 1) THEN
             l_service_request_rec.incident_location_id := null;
	     --Fix for bug 8594093
              l_service_request_rec.incident_location_type := null;
	      l_service_request_rec.incident_address  := null;
              l_service_request_rec.incident_address2 := null;
              l_service_request_rec.incident_address3 := null;
              l_service_request_rec.incident_address4 := null;
              l_service_request_rec.incident_city     := null;
              l_service_request_rec.incident_state    := null;
              l_service_request_rec.incident_postal_code := null;
              l_service_request_rec.incident_county   := null;
              l_service_request_rec.incident_province := null;
              l_service_request_rec.incident_country  := null;
              l_service_request_rec.site_name   := null;
              l_service_request_rec.site_number := null;
              l_service_request_rec.addressee   := null;
              l_service_request_rec.incident_addr_lines_phonetic := null;
              l_service_request_rec.incident_postal_plus4_code := null;
	     --End of changes for bug 8594093
	     FND_MESSAGE.Set_Name('CS', 'CS_SR_INVALID_INCIDENT_ADDRESS');
             FND_MESSAGE.Set_Token('API_NAME', l_api_name||'CREATE_INCIDENT_ADDRESS');
             FND_MSG_PUB.ADD;
        END IF;

   END IF;

  --end of code siahmed
  -------------------------------------------------------

  --
  -- Insert into _B table
  --
  INSERT INTO cs_incidents_all_b
    ( incident_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      incident_number,
      incident_status_id,
      incident_type_id,
      incident_urgency_id,
      incident_severity_id,
      incident_owner_id,
      resource_type,
--       resource_subtype_id, -- For BUG 2748584
      inventory_item_id,
      caller_type,
      customer_id,
      account_id,
      employee_id,
      current_serial_number,
      expected_resolution_date,
      actual_resolution_date,
      customer_product_id,
      bill_to_site_use_id,
      bill_to_contact_id,
      ship_to_site_use_id,
      ship_to_contact_id,
      install_site_use_id,
      incident_attribute_1,
      incident_attribute_2,
      incident_attribute_3,
      incident_attribute_4,
      incident_attribute_5,
      incident_attribute_6,
      incident_attribute_7,
      incident_attribute_8,
      incident_attribute_9,
      incident_attribute_10,
      incident_attribute_11,
      incident_attribute_12,
      incident_attribute_13,
      incident_attribute_14,
      incident_attribute_15,
      incident_context,
      external_attribute_1,
      external_attribute_2,
      external_attribute_3,
      external_attribute_4,
      external_attribute_5,
      external_attribute_6,
      external_attribute_7,
      external_attribute_8,
      external_attribute_9,
      external_attribute_10,
      external_attribute_11,
      external_attribute_12,
      external_attribute_13,
      external_attribute_14,
      external_attribute_15,
      external_context,
      resolution_code,
      incident_date,
      problem_code,
      original_order_number,
      purchase_order_num,
      close_date,
      publish_flag,
      obligation_date,
      qa_collection_id,
      contract_service_id,
      contract_id,
      contract_number,
      project_number,
      customer_po_number,
      customer_ticket_number,
      time_zone_id,
      time_difference,
      platform_id,
      platform_version,
      platform_version_id,
      db_version,
      cp_component_id,
      cp_component_version_id,
      cp_subcomponent_id,
      cp_subcomponent_version_id,
      cp_revision_id,
      inv_item_revision,
      inv_component_id,
      inv_component_version,
      inv_subcomponent_id,
      inv_subcomponent_version,
      site_id,
      customer_site_id,
      territory_id,
      inv_organization_id,
      object_version_number,
      -----Added for enhancement 11.5.6
      cust_pref_lang_id,
      tier,
      tier_version,
      operating_system,
      operating_system_version,
      DATABASE,
      category_id,
      group_type,
      owner_group_id,
      group_territory_id,
      owner_assigned_time,
      owner_assigned_flag,
      --- Added for the unassigned_ind enh.
      unassigned_indicator,
      inv_platform_org_id,
      product_revision,
      component_version,
      subcomponent_version,
      comm_pref_code,
      cust_pref_lang_code,
      last_update_channel,
      category_set_id,
      external_reference,
      system_id,
      error_code,
      incident_occurred_date,
      incident_resolved_date,
      inc_responded_by_date,
      incident_location_id ,
      incident_address ,
      incident_city,
      incident_state,
      incident_country,
      incident_province ,
      incident_postal_code ,
      incident_county,
      sr_creation_channel ,
      -- Added for ER# 2320056
      coverage_type ,
      -- Added For ER# 2433831
      bill_to_account_id ,
      ship_to_account_id ,
      --  Added for ER# 2463321
      customer_phone_id,
      customer_email_id,
      -- Added for source changes for 1159 by shijain oct 11 2002
      creation_program_code,
      last_update_program_code,
      bill_to_party_id,
      ship_to_party_id,
      bill_to_site_id,
      ship_to_site_id,
      program_id                 ,
      program_application_id     ,
      request_id            ,
      program_login_id ,
      -- Added for enh 2655115
      status_flag,
      -- Added address field by shijain dec5th 2002
      incident_point_of_interest  ,
      incident_cross_street ,
      incident_direction_qualifier ,
      incident_distance_qualifier  ,
      incident_distance_qual_uom  ,
      incident_address2   ,
      incident_address3 ,
      incident_address4  ,
      incident_address_style ,
      incident_addr_lines_phonetic  ,
      incident_po_box_number  ,
      incident_house_number ,
      incident_street_suffix ,
      incident_street ,
      incident_street_number ,
      incident_floor,
      incident_suite  ,
      incident_postal_plus4_code ,
      incident_position  ,
      incident_location_directions,
      incident_location_description  ,
      install_site_id,
      -- for cmro_eam
      owning_department_id,
      -- Added for MIsc ERs project of 11.5.10 --anmukher --08/26/03
      incident_location_type,
      -- Added for Auditing project of 11.5.10 --anmukher --09/03/03
      incident_last_modified_date	           ,
      maint_organization_id,
      org_id,
	 -- Credit Card 9358401
	 instrument_payment_use_id
    )
  VALUES
    ( DECODE(l_request_id,NULL,l_req_id,l_request_id), /* INCIDENT_ID */
      l_service_request_rec.last_update_date,          /* LAST_UPDATE_DATE */
      l_service_request_rec.last_updated_by,           /* LAST_UPDATED_BY */
      l_service_request_rec.creation_date,             /* CREATION_DATE */
      l_service_request_rec.created_by,                /* CREATED_BY */
      l_service_request_rec.last_update_login,         /* LAST_UPDATE_LOGIN */
      DECODE(l_request_number,NULL,l_req_num,l_request_number), /* INCIDENT_NUMBER */
      l_service_request_rec.status_id,                 /* INCIDENT_STATUS_ID */
      l_service_request_rec.type_id,                   /* INCIDENT_TYPE_ID */
      l_service_request_rec.urgency_id,                /* INCIDENT_URGENCY_ID */
      l_service_request_rec.severity_id,               /* INCIDENT_SEVERITY_ID */
      l_service_request_rec.owner_id,                  /* INCIDENT_OWNER_ID */
      l_service_request_rec.resource_type,             /* RESOURCE_TYPE */
--      l_service_request_rec.resource_subtype_id,       /* RESOURCE_SUBTYPE_ID */ For BUG 2748584
      l_service_request_rec.inventory_item_id,         /* INVENTORY_ITEM_ID */
      l_service_request_rec.caller_type,               /* CALLER_TYPE */
      -- removed decode for 11.5.6 enhancement
      l_service_request_rec.customer_id,               /* CUSTOMER_ID */
      l_service_request_rec.account_id,                /* ACCOUNT_ID */
      l_service_request_rec.employee_id,               /* EMPLOYEE_ID */
      l_service_request_rec.current_serial_number,     /* CURRENT_SERIAL_NUMBER */
      l_service_request_rec.exp_resolution_date,       /* EXPECTED_RESOLUTION_DATE */
      l_service_request_rec.act_resolution_date,       /* ACTUAL_RESOLUTION_DATE */
      l_service_request_rec.customer_product_id,       /* CUSTOMER_PRODUCT_ID */
      l_service_request_rec.bill_to_site_use_id,       /* BILL_TO_SITE_USE_ID */
      l_service_request_rec.bill_to_contact_id,        /* BILL_TO_CONTACT_ID */
      l_service_request_rec.ship_to_site_use_id,       /* SHIP_TO_SITE_USE_ID */
      l_service_request_rec.ship_to_contact_id,        /* SHIP_TO_CONTACT_ID */
      l_service_request_rec.install_site_use_id,       /* INSTALL_SITE_USE_ID */
      l_service_request_rec.request_attribute_1,       /* INCIDENT_ATTRIBUTE_1 */
      l_service_request_rec.request_attribute_2,       /* INCIDENT_ATTRIBUTE_2 */
      l_service_request_rec.request_attribute_3,       /* INCIDENT_ATTRIBUTE_3 */
      l_service_request_rec.request_attribute_4,       /* INCIDENT_ATTRIBUTE_4 */
      l_service_request_rec.request_attribute_5,       /* INCIDENT_ATTRIBUTE_5 */
      l_service_request_rec.request_attribute_6,       /* INCIDENT_ATTRIBUTE_6 */
      l_service_request_rec.request_attribute_7,       /* INCIDENT_ATTRIBUTE_7 */
      l_service_request_rec.request_attribute_8,       /* INCIDENT_ATTRIBUTE_8 */
      l_service_request_rec.request_attribute_9,       /* INCIDENT_ATTRIBUTE_9 */
      l_service_request_rec.request_attribute_10,      /* INCIDENT_ATTRIBUTE_10 */
      l_service_request_rec.request_attribute_11,      /* INCIDENT_ATTRIBUTE_11 */
      l_service_request_rec.request_attribute_12,      /* INCIDENT_ATTRIBUTE_12 */
      l_service_request_rec.request_attribute_13,      /* INCIDENT_ATTRIBUTE_13 */
      l_service_request_rec.request_attribute_14,      /* INCIDENT_ATTRIBUTE_14 */
      l_service_request_rec.request_attribute_15,      /* INCIDENT_ATTRIBUTE_15 */
      l_service_request_rec.request_context,           /* INCIDENT_CONTEXT */
      l_service_request_rec.external_attribute_1,      /* EXTERNAL_ATTRIBUTE_1 */
      l_service_request_rec.external_attribute_2,      /* EXTERNAL_ATTRIBUTE_2 */
      l_service_request_rec.external_attribute_3,      /* EXTERNAL_ATTRIBUTE_3 */
      l_service_request_rec.external_attribute_4,      /* EXTERNAL_ATTRIBUTE_4 */
      l_service_request_rec.external_attribute_5,      /* EXTERNAL_ATTRIBUTE_5 */
      l_service_request_rec.external_attribute_6,      /* EXTERNAL_ATTRIBUTE_6 */
      l_service_request_rec.external_attribute_7,      /* EXTERNAL_ATTRIBUTE_7 */
      l_service_request_rec.external_attribute_8,      /* EXTERNAL_ATTRIBUTE_8 */
      l_service_request_rec.external_attribute_9,      /* EXTERNAL_ATTRIBUTE_9 */
      l_service_request_rec.external_attribute_10,     /* EXTERNAL_ATTRIBUTE_10 */
      l_service_request_rec.external_attribute_11,     /* EXTERNAL_ATTRIBUTE_11 */
      l_service_request_rec.external_attribute_12,     /* EXTERNAL_ATTRIBUTE_12 */
      l_service_request_rec.external_attribute_13,     /* EXTERNAL_ATTRIBUTE_13 */
      l_service_request_rec.external_attribute_14,     /* EXTERNAL_ATTRIBUTE_14 */
      l_service_request_rec.external_attribute_15,     /* EXTERNAL_ATTRIBUTE_15 */
      l_service_request_rec.external_context,          /* EXTERNAL_CONTEXT */
      UPPER(l_service_request_rec.resolution_code),    /* RESOLUTION_CODE */
      l_service_request_rec.request_date,              /* INCIDENT_DATE */
      UPPER(l_service_request_rec.problem_code),       /* PROBLEM_CODE */
      l_service_request_rec.original_order_number,     /* ORIGINAL_ORDER_NUMBER */
      l_service_request_rec.purchase_order_num,        /* PURCHASE_ORDER_NUM */
      l_service_request_rec.closed_date,               /* CLOSE_DATE */
      l_service_request_rec.publish_flag,              /* PUBLISH_FLAG */
      l_service_request_rec.obligation_date,
      l_service_request_rec.qa_collection_plan_id,
      l_service_request_rec.contract_service_id,
      l_contra_id,
      l_contract_number,
      l_service_request_rec.project_number,
      l_service_request_rec.cust_po_number,
      l_service_request_rec.cust_ticket_number,
      l_service_request_rec.time_zone_id,
      l_service_request_rec.time_difference,
      l_service_request_rec.platform_id,
      l_service_request_rec.platform_version,
      l_service_request_rec.platform_version_id,
      l_service_request_rec.db_version,
      l_service_request_rec.cp_component_id,
      l_service_request_rec.cp_component_version_id,
      l_service_request_rec.cp_subcomponent_id,
      l_service_request_rec.cp_subcomponent_version_id,
      l_service_request_rec.cp_revision_id,
      l_service_request_rec.inv_item_revision,
      l_service_request_rec.inv_component_id,
      l_service_request_rec.inv_component_version,
      l_service_request_rec.inv_subcomponent_id,
      l_service_request_rec.inv_subcomponent_version,
      l_service_request_rec.site_id,
      l_service_request_rec.customer_site_id,
      l_service_request_rec.territory_id,
      l_service_request_rec.inventory_org_id,
	 1,
      --- Added for enhancement 11.5.6
      l_service_request_rec.cust_pref_lang_id,
      l_service_request_rec.tier,
      l_service_request_rec.tier_version,
      l_service_request_rec.operating_system,
      l_service_request_rec.operating_system_version,
      l_service_request_rec.DATABASE,
      l_service_request_rec.category_id,
      l_service_request_rec.group_type,
      l_service_request_rec.owner_group_id,
      l_service_request_rec.group_territory_id,
      l_service_request_rec.owner_assigned_time,
      l_service_request_rec.owner_assigned_flag,
      l_unassigned_indicator,
      l_service_request_rec.inv_platform_org_id,
      l_service_request_rec.product_revision,
      l_service_request_rec.component_version,
      l_service_request_rec.subcomponent_version,
      l_service_request_rec.comm_pref_code,
      l_service_request_rec.cust_pref_lang_code,
      l_service_request_rec.last_update_channel,
      l_service_request_rec.category_set_id,
      l_service_request_rec.external_reference,
      l_service_request_rec.system_id,
      l_service_request_rec.error_code,
      l_service_request_rec.incident_occurred_date,
      l_service_request_rec.incident_resolved_date,
      l_service_request_rec.inc_responded_by_date,
      l_service_request_rec.incident_location_id ,
      l_service_request_rec.incident_address ,
      l_service_request_rec.incident_city,
      l_service_request_rec.incident_state,
      l_service_request_rec.incident_country,
      l_service_request_rec.incident_province ,
      l_service_request_rec.incident_postal_code ,
      l_service_request_rec.incident_county,
      l_service_request_rec.sr_creation_channel ,
      -- Added for ER# 2320056
      l_service_request_rec.coverage_type,
      -- Added For ER# 2433831
      l_service_request_rec.bill_to_account_id ,
      l_service_request_rec.ship_to_account_id ,
      --  Added for ER# 2463321
      l_service_request_rec.customer_phone_id,
      l_service_request_rec.customer_email_id,
      -- Added for source changes for 1159 by shijain oct 11 2002
      l_service_request_rec.creation_program_code,
      l_service_request_rec.creation_program_code,
      l_service_request_rec.bill_to_party_id,
      l_service_request_rec.ship_to_party_id,
      l_service_request_rec.bill_to_site_id,
      l_service_request_rec.ship_to_site_id,
      l_service_request_rec.program_id                 ,
      l_service_request_rec.program_application_id     ,
      l_service_request_rec.conc_request_id            ,
      l_service_request_rec.program_login_id  ,
      -- Added for enh. 2655115
      --l_status_flag ,
      --for bug 3050727
      l_service_request_rec.status_flag,
      l_service_request_rec.incident_point_of_interest,
      l_service_request_rec.incident_cross_street,
      l_service_request_rec.incident_direction_qualifier,
      l_service_request_rec.incident_distance_qualifier,
      l_service_request_rec.incident_distance_qual_uom,
      l_service_request_rec.incident_address2,
      l_service_request_rec.incident_address3,
      l_service_request_rec.incident_address4,
      l_service_request_rec.incident_address_style,
      l_service_request_rec.incident_addr_lines_phonetic,
      l_service_request_rec.incident_po_box_number,
      l_service_request_rec.incident_house_number,
      l_service_request_rec.incident_street_suffix,
      l_service_request_rec.incident_street,
      l_service_request_rec.incident_street_number,
      l_service_request_rec.incident_floor,
      l_service_request_rec.incident_suite,
      l_service_request_rec.incident_postal_plus4_code,
      l_service_request_rec.incident_position,
      l_service_request_rec.incident_location_directions,
      l_service_request_rec.incident_location_description,
      l_service_request_rec.install_site_id,
       --for cmro_eam
      l_service_request_rec.owning_dept_id,
      -- Added for Misc ERs project of 11.5.10 --anmukher --08/26/03
      l_service_request_rec.incident_location_type,
      -- Added for Auditing project of 11.5.10 --anmukher --09/03/03
      l_service_request_rec.last_update_date ,   /* INCIDENT_LAST_MODIFIED_DATE */
      l_service_request_rec.maint_organization_id,
      l_org_id,
	 --Credit Card 9358401
      l_service_request_rec.instrument_payment_use_id
  ) RETURNING INCIDENT_ID, INCIDENT_NUMBER, ORG_ID  INTO l_request_id, l_request_number, l_inc_org_id;

  --
  -- Insert into _TL table
  --
  INSERT INTO cs_incidents_all_tl (
    incident_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    summary,
    resolution_summary ,
    LANGUAGE,
    source_lang,
    text_index
  ) SELECT
      l_request_id,
      l_service_request_rec.creation_date,
      l_service_request_rec.created_by,
      l_service_request_rec.last_update_date,
      l_service_request_rec.last_updated_by,
      l_service_request_rec.last_update_login,
      l_service_request_rec.summary,
      l_service_request_rec.resolution_summary ,
      L.LANGUAGE_CODE,
      USERENV('LANG'),
      'A'
    FROM FND_LANGUAGES L
    WHERE l.installed_flag IN ('I', 'B')
    AND NOT EXISTS
    (SELECT NULL
     FROM cs_incidents_all_tl t
     WHERE t.incident_id = l_request_id
     AND t.LANGUAGE = l.language_code
    );

  -- ----------------------------------------------------------------------
  -- Reindex if ConText Option is enabled and summary, problem description
  -- or resolution description is inserted.
  -- Reindex even if the service request is not published (bug 841260).
  -- ----------------------------------------------------------------------

  -- Added for Auditing project of 11.5.10 --anmukher --09/15/03
  -- Assignments are made here (and not immediately before calling Create_Audit_record)
  -- in order to ensure that the audit rec is fully populated
  -- before CS_SR_AUDIT_CHILD API is called after contact point creation.

  l_audit_vals_rec.incident_number		:= l_request_number;

  IF (l_contra_id <> FND_API.G_MISS_NUM) AND
    (l_contra_id IS NOT NULL) THEN
    l_audit_vals_rec.CONTRACT_ID		:= l_contra_id;
  END IF;

  IF (l_service_request_rec.contract_service_id <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.contract_service_id IS NOT NULL) THEN
    l_audit_vals_rec.CONTRACT_SERVICE_ID	:= l_service_request_rec.contract_service_id ;
  END IF;

  IF (l_contract_number <> FND_API.G_MISS_CHAR) AND
    (l_contract_number IS NOT NULL) THEN
    l_audit_vals_rec.CONTRACT_NUMBER		:= l_contract_number;
  END IF;

  IF (l_unassigned_indicator <> FND_API.G_MISS_NUM) AND
    (l_unassigned_indicator IS NOT NULL) THEN
    l_audit_vals_rec.UNASSIGNED_INDICATOR	:= l_unassigned_indicator;
  END IF;
  -- At this point l_servicerequest_rec has been processed for g_miss values
  -- so no need to check for g_miss. directly assign the value to audit rec.
  l_audit_vals_rec.coverage_type	:= l_service_request_rec.coverage_type;


  -- This record creation should  not take place if caller_type is CALLER_EMP
  -- For Caller type Employee, should not create any contacts
  /*  updating value of the primary_contact_id in the cs_incidents_all_b table
      after we insert record in cs_hz_sr_contact_points, so that
      sr_contact_point_id can be inserted as primary_contact_id by shijain
      for enh. 2690787

    l_primary_contact:= get_primary_contact(l_request_id);

    IF l_primary_contact is not null THEN

        UPDATE cs_incidents_all_b
        SET    primary_contact_id = l_primary_contact
        WHERE  incident_id = l_request_id;

    END IF;
  */

-- END IF;  --  caller type check
/****************Delete Above code***************************************/

  -- ------------------------------------------------------
  -- Insert a record into the audit table
  -- ------------------------------------------------------

  --Added for Auditing project of 11.5.10 --anmukher --09/03/03
  l_audit_vals_rec.updated_entity_code		:= 'SR_HEADER';
  l_audit_vals_rec.updated_entity_id		:= l_request_id;
  l_audit_vals_rec.entity_activity_code         := 'C';
  l_audit_vals_rec.incident_last_modified_date  := l_service_request_rec.last_update_date ;
  -- R12 changes
  l_audit_vals_rec.org_id                       := l_org_id;
  l_audit_vals_rec.old_org_id                   := null ;
  l_audit_vals_rec.maint_organization_id        := l_service_request_rec.maint_organization_id ;
  l_audit_vals_rec.old_maint_organization_id    := null ;
  l_audit_vals_rec.last_update_program_code     := l_service_request_rec.creation_program_code ;
  --
  IF l_service_request_rec.exp_resolution_date IS NULL
  THEN
    l_audit_vals_rec.CHANGE_RESOLUTION_FLAG := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_RESOLUTION_FLAG := 'Y';
    l_audit_vals_rec.EXPECTED_RESOLUTION_DATE        := l_service_request_rec.exp_resolution_date;
  END IF;

  IF l_service_request_rec.obligation_date IS NULL
  THEN
    l_audit_vals_rec.CHANGE_OBLIGATION_FLAG := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_OBLIGATION_FLAG := 'Y';
    l_audit_vals_rec.obligation_date        := l_service_request_rec.obligation_date;
  END IF;
  l_audit_vals_rec.incident_country        := l_service_request_rec.incident_country;
  l_audit_vals_rec.incident_location_id    := l_service_request_rec.incident_location_id;
  l_audit_vals_rec.incident_location_type  := l_service_request_rec.incident_location_type;
  -- Owner and Group Related Columns
  IF l_service_request_rec.owner_id IS NULL
  THEN
    l_audit_vals_rec.change_incident_owner_flag := 'N';
  ELSE
    l_audit_vals_rec.change_incident_owner_FLAG := 'Y';
    l_audit_vals_rec.incident_owner_id          := l_service_request_rec.owner_id;

   --commented by Sanjana Rao, bug 6955756
   -- l_service_request_rec.owner_assigned_time   := SYSDATE;
  END IF;

  IF l_service_request_rec.OWNER_ASSIGNED_TIME IS NULL
  THEN
    l_audit_vals_rec.CHANGE_ASSIGNED_TIME_FLAG  := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_ASSIGNED_TIME_FLAG  := 'Y';
    l_audit_vals_rec.OWNER_ASSIGNED_TIME        := l_service_request_rec.OWNER_ASSIGNED_TIME;
  END IF;

  IF l_service_request_rec.OWNER_GROUP_ID IS NULL
  THEN
    l_audit_vals_rec.CHANGE_GROUP_FLAG := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_GROUP_FLAG := 'Y';
    l_audit_vals_rec.GROUP_ID          := l_service_request_rec.OWNER_GROUP_ID;
  END IF;

  IF l_service_request_rec.group_type IS NULL
  THEN
    l_audit_vals_rec.CHANGE_GROUP_TYPE_FLAG := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_GROUP_TYPE_FLAG := 'Y';
    l_audit_vals_rec.group_type             := l_service_request_rec.group_type;
  END IF;

  IF l_service_request_rec.RESOURCE_TYPE IS NULL
  THEN
    l_audit_vals_rec.CHANGE_RESOURCE_TYPE_FLAG  := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_RESOURCE_TYPE_FLAG  := 'Y';
    l_audit_vals_rec.RESOURCE_TYPE              := l_service_request_rec.RESOURCE_TYPE;
  END IF;

  IF l_service_request_rec.territory_id IS NULL
  THEN
    l_audit_vals_rec.CHANGE_TERRITORY_ID_FLAG := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_TERRITORY_ID_FLAG := 'Y';
    l_audit_vals_rec.territory_id             := l_service_request_rec.territory_id;
  END IF;

  IF l_service_request_rec.site_id IS NULL
  THEN
    l_audit_vals_rec.CHANGE_SITE_FLAG := 'N';
  ELSE
    l_audit_vals_rec.CHANGE_SITE_FLAG := 'Y';
    l_audit_vals_rec.site_id          := l_service_request_rec.site_id;
  END IF;

  --siahmed added for disabling aduit when invocation_mode is set to REPLAY
  IF (p_invocation_mode <> 'REPLAY' ) THEN
  CS_ServiceRequest_PVT.Create_Audit_Record (
       p_api_version         => 2.0,
       x_return_status       => l_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       p_request_id          => l_request_id,
       p_audit_id            => l_audit_id,
       p_audit_vals_rec      => l_audit_vals_rec,
       p_user_id             => l_service_request_rec.last_updated_by,
       p_login_id            => l_service_request_rec.last_update_login,
       p_last_update_date    => l_service_request_rec.last_update_date,
       p_creation_date       => l_service_request_rec.last_update_date,
       x_audit_id            => l_audit_id
     );
   END IF; --end of invocationn_mode check for audit

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CS_SRCONTACT_PKG.create_update
    ( p_incident_id     => l_request_id
    , p_invocation_mode => p_invocation_mode
    , p_sr_update_date  => l_service_request_rec.last_update_date
    , p_sr_updated_by   => l_service_request_rec.last_updated_by
    , p_sr_update_login => l_service_request_rec.last_update_login
    , p_contact_tbl     => l_processed_contacts
    , p_old_contact_tbl => l_old_contacts
    , x_return_status   => l_return_status
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----- AUDIT

    -- Call to Enqueuer API if it is in Maintenance Mode
    -- added b'coz l_req_num will always be null,when request_number is passed
       l_enqueue_number := NVL(l_request_number,l_req_num);

    FND_PROFILE.get('APPS_MAINTENANCE_MODE', l_maintenance_mode);

      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The Value of profile APPS_MAINTENANCE_MODE :' || l_maintenance_mode
	);
      END IF;


    IF (l_maintenance_mode = 'MAINT' AND
        p_invocation_mode <> 'REPLAY' ) THEN

-- hardcoded the version 2.0 shijain nov 27 2002

     CS_ServiceRequest_ENQUEUE_PKG.EnqueueSR(
       p_init_msg_list         => fnd_api.g_false ,
       p_api_version           => 2.0,
       p_commit                => p_commit,
       p_validation_level      => p_validation_level,
       x_return_status         => l_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_request_id            => l_req_id,
       p_request_number        => l_enqueue_number,
       p_audit_id              => l_audit_id,
       p_resp_appl_id          => p_resp_appl_id,
       p_resp_id               => p_resp_id,
       p_user_id               => p_user_id,
       p_login_id              => p_login_id,
       p_org_id                => p_org_id,
       p_update_desc_flex      => p_update_desc_flex,
       p_object_version_number => p_object_version_number,
       p_transaction_type      => l_transaction_type,
       p_message_rev           => l_message_revision,
       p_servicerequest        => l_service_request_rec,
       p_contacts              => l_contacts
     );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    END IF;

  --
  -- Create entries in JTF_NOTES from p_notes
  --
  l_note_index := p_notes.FIRST;
  WHILE l_note_index IS NOT NULL LOOP
    /* Create JTF_NOTES */
    --l_notes_detail := DBMS_LOB.SUBSTR(p_notes(l_note_index).note_detail);

   IF ((p_notes(l_note_index).note IS NOT NULL) AND
        (p_notes(l_note_index).note <> FND_API.G_MISS_CHAR)) THEN

    l_note_status := null ;

    IF ((p_notes(l_note_index).note_status IS NULL) OR
        (p_notes(l_note_index).note_status = FND_API.G_MISS_CHAR)) THEN
        l_note_status := 'E';
    ELSE
        l_note_status := p_notes(l_note_index).note_status ;
    END IF ;

     jtf_notes_pub.create_note(
      p_api_version    => 1.0,
      p_init_msg_list  => FND_API.G_FALSE,
      p_commit         => FND_API.G_FALSE,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_source_object_id => l_request_id,
      p_source_object_code => 'SR',
      p_notes              => p_notes(l_note_index).note,
      p_notes_detail       => p_notes(l_note_index).note_detail,
      p_note_type          => p_notes(l_note_index).note_type,
      p_note_status        => l_note_status,
      p_entered_by         => p_user_id,
      p_entered_date       => SYSDATE,
      p_created_by         => p_user_id,
      p_creation_date      => SYSDATE,
      p_last_updated_by    => p_user_id,
      p_last_update_date   => SYSDATE,
      x_jtf_note_id        => l_note_id
    );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
        END IF;

   END IF;


   IF ((p_notes(l_note_index).note_context_type_01 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_01 <> FND_API.G_MISS_CHAR) AND
        (p_notes(l_note_index).note_context_type_id_01 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_id_01 <> FND_API.G_MISS_NUM)) THEN

      jtf_notes_pub.create_note_context(
        x_return_status        => x_return_status,
        p_creation_date        => SYSDATE,
        p_last_updated_by      => p_user_id,
        p_last_update_date     => SYSDATE,
        p_jtf_note_id          => l_note_id,
        p_note_context_type    => p_notes(l_note_index).note_context_type_01,
        p_note_context_type_id => p_notes(l_note_index).note_context_type_id_01,
        x_note_context_id      => l_note_context_id
      );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;


    IF ((p_notes(l_note_index).note_context_type_02 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_02 <> FND_API.G_MISS_CHAR) AND
        (p_notes(l_note_index).note_context_type_id_02 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_id_02 <> FND_API.G_MISS_NUM))THEN


       jtf_notes_pub.create_note_context(
        x_return_status        => x_return_status,
        p_creation_date        => SYSDATE,
        p_last_updated_by      => p_user_id,
        p_last_update_date     => SYSDATE,
        p_jtf_note_id          => l_note_id,
        p_note_context_type    => p_notes(l_note_index).note_context_type_02,
        p_note_context_type_id => p_notes(l_note_index).note_context_type_id_02,
        x_note_context_id      => l_note_context_id

      );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


    IF ((p_notes(l_note_index).note_context_type_03 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_03 <> FND_API.G_MISS_CHAR) AND
        (p_notes(l_note_index).note_context_type_id_03 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_id_03 <> FND_API.G_MISS_NUM)) THEN


      jtf_notes_pub.create_note_context(
        x_return_status        => x_return_status,
        p_creation_date        => SYSDATE,
        p_last_updated_by      => p_user_id,
        p_last_update_date     => SYSDATE,
        p_jtf_note_id          => l_note_id,
        p_note_context_type    => p_notes(l_note_index).note_context_type_03,
        p_note_context_type_id => p_notes(l_note_index).note_context_type_id_03,
        x_note_context_id      => l_note_context_id
      );

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                 END IF;
   END IF;

   l_note_index := p_notes.NEXT(l_note_index);
  END LOOP;


  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #8');
  -- Launching the workflow (HOOK)
  IF (JTF_USR_HKS.Ok_To_Execute('CS_ServiceRequest_PVT', 'Create_ServiceRequest',
                                'W', 'W')) THEN

     IF (cs_servicerequest_cuhk.Ok_To_Launch_Workflow(p_request_id => l_request_id,
                                                      p_service_request_rec=>l_service_request_rec)) THEN

       l_bind_data_id := JTF_USR_HKS.Get_bind_data_id ;
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'USER_ID', p_user_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'RESP_ID', p_resp_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'RESP_APPL_ID', p_resp_appl_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_ID', l_request_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_DATE', l_service_request_rec.request_date, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_TYPE', l_service_request_rec.type_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_STATUS', l_service_request_rec.status_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_SEVERITY', l_service_request_rec.severity_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_URGENCY', l_service_request_rec.urgency_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'OWNER_ID', l_service_request_rec.owner_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_SUMMARY', l_service_request_rec.summary, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_CUSTOMER', l_service_request_rec.customer_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'INVENTORY_ITEM_ID', l_service_request_rec.inventory_item_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'CUSTOMER_PRODUCT_ID', l_service_request_rec.customer_product_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'PROBLEM_CODE', l_service_request_rec.problem_code, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'EXPECTED_RESOLUTION_DATE', l_service_request_rec.exp_resolution_date, 'W', 'T');

       -- Before the call to WorkFlow Hook, generate a unique item key using the workflow sequence
       SELECT cs_wf_process_id_s.NEXTVAL INTO l_workflow_item_key FROM dual;

       JTF_USR_HKS.WrkflowLaunch(p_wf_item_name => 'SERVEREQ',
                                 p_wf_item_process_name => 'CALL_SUPPORT',
                                 p_wf_item_key => 'SR' || TO_CHAR(l_workflow_item_key),
                                 p_bind_data_id => l_bind_data_id,
                                 x_return_code => l_return_status);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   END IF ;
  END IF ;

  --
  -- Make the post processing call to the user hooks
  --
  -- Post call to the Customer Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'A', 'C')  THEN

-- hardcoded the version 2.0 shijain nov 27 2002

    cs_servicerequest_cuhk.Create_ServiceRequest_Post(
    p_api_version            =>   2.0,
    p_init_msg_list          =>   fnd_api.g_false ,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_org_id                 =>   p_org_id,
    p_request_id             =>   l_request_id,
    p_request_number         =>   l_request_number,
    p_invocation_mode        =>   p_invocation_mode,
    p_service_request_rec    =>   l_service_request_rec,
    p_notes                  =>   p_notes,
    p_contacts               =>   p_contacts,
    -- Changed out parameter references to out rec references
    x_request_id             =>   x_sr_create_out_rec.request_id,
    x_request_number         =>   x_sr_create_out_rec.request_number,
    x_interaction_id         =>   x_sr_create_out_rec.interaction_id,
    x_workflow_process_id    =>   x_sr_create_out_rec.workflow_process_id);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'A', 'V')  THEN

-- hardcoded the version 2.0 shijain nov 27 2002

    cs_servicerequest_vuhk.Create_ServiceRequest_Post(
    p_api_version            =>   2.0,
    p_init_msg_list          =>   fnd_api.g_false ,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_org_id                 =>   p_org_id,
    p_request_id             =>   l_request_id,
    p_request_number         =>   l_request_number,
    p_service_request_rec    =>   l_service_request_rec,
    p_notes                  =>   p_notes,
    p_contacts               =>   p_contacts,
    -- Changed out parameter references to out rec references
    x_request_id             =>   x_sr_create_out_rec.request_id,
    x_request_number         =>   x_sr_create_out_rec.request_number,
    x_interaction_id         =>   x_sr_create_out_rec.interaction_id,
    x_workflow_process_id    =>   x_sr_create_out_rec.workflow_process_id);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;



  -- Post call to the internal Type User Hook
  --
  -- Fix to bug # 2986971
  -- Code to populate the global record type. These globals can be used by the internal
  -- user hooks procedures registered to be executed by the Create SR Private proc.

    user_hooks_rec.customer_id := l_service_request_rec.customer_id ;
    user_hooks_rec.request_id  := l_request_id ;

  -- for cmro_eam
  -- set additional paramters for cmro_eam
  -- status_flag,pls_type_cmro_flag,new_type_cmro_flag,customer_product_id,
  -- status_id,exp_resolution_date

    user_hooks_rec.status_flag 		:= l_service_request_rec.status_flag;
    user_hooks_rec.old_type_cmro_flag 	:= NULL;
    user_hooks_rec.new_type_cmro_flag 	:= l_service_request_rec.New_type_CMRO_flag;
    user_hooks_rec.customer_product_id 	:= l_service_request_rec.customer_product_id;
    user_hooks_rec.status_id 		:= l_service_request_rec.status_id;
    user_hooks_rec.exp_resolution_date 	:= l_service_request_rec.exp_resolution_date;

    -- end for cmro_eam

    cs_servicerequest_iuhk.Create_ServiceRequest_Post( x_return_status=>l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- ----------------------------------------------------------------------
  -- Insert interaction record
  -- ----------------------------------------------------------------------
  IF (l_service_request_rec.parent_interaction_id IS NULL) THEN
    /* CREATE INTERACTION */ /* l_interaction_id := */
    NULL;
  END IF;

  -- Changed out parameter references to out rec references
  x_sr_create_out_rec.interaction_id := l_interaction_id;

  --
  -- Create INTERACTION_ACTIVITY
  --

  --
  -- Set OUT values
  --
  -- Changed out parameter references to out rec references
  x_sr_create_out_rec.request_id := l_request_id;
  x_sr_create_out_rec.request_number := l_request_number;

  -- Standard call for message generation
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'M', 'M')  THEN

    IF (cs_servicerequest_cuhk.Ok_To_Generate_Msg(p_request_id  => l_request_id,
                                                p_service_request_rec=>l_service_request_rec)) THEN

      l_bind_data_id := JTF_USR_HKS.Get_bind_data_id;

      JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'incident_id', l_request_id, 'S', 'N');

      JTF_USR_HKS.generate_message(p_prod_code => 'CS',
                                 p_bus_obj_code => 'SR',
                                 p_action_code => 'I',
                                 p_bind_data_id => l_bind_data_id,
                                 x_return_code => l_return_status);


       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

--- Added for HA Enhancement

    IF (p_invocation_mode <> 'REPLAY' ) THEN
      -- Raise BES Event that the SR is created. Before business events, a WF process
      -- was kicked off if the following conditions were met:
      -- if l_autolaunch_wf_flag = 'Y' AND resource_type = 'RS_EMPLOYEE' AND
      -- owner_id IS NOT NULL. After the introduction of business event, the SR API
      -- calls the CS BES wrapper API and this wrapper API raises the needed business
      -- events, in this case - SR Created,  after checking the required conditions.

      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
         -- These 4 parameters added for bug #2798269
         p_api_version           => p_api_version,
         p_init_msg_list         => fnd_api.g_false ,
         p_commit                => p_commit,
         p_validation_level      => p_validation_level,
         p_event_code            => 'CREATE_SERVICE_REQUEST',
         p_incident_number       => l_request_number,
         p_user_id               => p_user_id,
         p_resp_id               => p_resp_id,
         p_resp_appl_id          => p_resp_appl_id,
	 p_old_sr_rec            => NULL,
	 p_new_sr_rec            => l_service_request_rec, -- using l_ser...coz this is the
							   -- rec. type used in the insert.
	 p_contacts_table        => p_contacts,
         p_link_rec              => NULL,  -- using default value
         p_wf_process_id         => NULL,  -- using default value
         p_owner_id		 => NULL,  -- using default value
         p_wf_manual_launch	 => 'N' ,  -- using default value
         x_wf_process_id         => l_workflow_process_id,
         x_return_status         => lx_return_status,
         x_msg_count             => lx_msg_count,
         x_msg_data              => lx_msg_data );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	 -- do nothing in this API. The BES wrapper API will have to trap this
	 -- situation and send a notification to the SR owner that the BES has
	 -- not been raised. If the BES API return back a failure status, it
	 -- means only that the BES raise event has failed, and has nothing to
	 -- do with the creation of the SR.
	 null;
      end if;
    END IF;   -- IF (p_invocation_mode <> 'REPLAY' )
    -- Changed out parameter reference to out rec reference
    x_sr_create_out_rec.workflow_process_id  := l_workflow_process_id ;

/*resetting the parameter value shijain 4th dec 2002*/
  g_restrict_ib:=NULL;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );


-- Moved before calling the assignment manager
-- *****************************************************************/

/******************** Commit moved for bug 2857350*****************************/

  -- Assign the incident id and the incident number for the new service request to the Out Rec attributes --anmukher -- 08/25/03
  x_sr_create_out_rec.request_id 	:= l_request_id;
  x_sr_create_out_rec.request_number	:= l_request_number;

  -- Added for Auto Task Generation Project of 11.5.10 -- anmukher --08/25/03
  -- Check if Auto Generate Tasks parameters is set ON

  -- For bug 3535918 - remove case sensitivity and add ignore message

  If (p_auto_generate_tasks = 'Y' OR p_auto_generate_tasks = 'y') Then

    -- Check if the Service Request has been closed at the time of creation
    If l_service_request_rec.status_flag = 'C' Then
      x_sr_create_out_rec.auto_task_gen_attempted 	:= FALSE;
    Else
      -- Service Request is Open and Auto Generate Task parameter is On, So call the Auto Generate Tasks API
      CS_AutoGen_Task_PVT.Auto_Generate_Tasks
      ( p_api_version			=> 1.0,
        p_init_msg_list			=> fnd_api.g_false ,
        p_commit			=> p_commit,
        p_validation_level		=> p_validation_level,
        p_incident_id                   => l_request_id ,
        p_service_request_rec		=> l_service_request_rec,
        p_task_template_group_owner	=> null,-- l_service_request_rec.owner_group_id,
        p_task_tmpl_group_owner_type    => null,-- l_service_request_rec.owner_type,
        p_task_template_group_rec	=> l_task_template_group_rec,
        p_task_template_table		=> l_task_template_table,
        x_auto_task_gen_rec		=> l_auto_task_gen_rec,
        x_return_status			=> l_return_status,
        x_msg_count			=> x_msg_count,
        x_msg_data			=> x_msg_data
      );
    End If; -- If l_service_request_rec.status_flag = 'C'

    If l_return_status = FND_API.G_RET_STS_SUCCESS Then
      x_sr_create_out_rec.auto_task_gen_status		:= FND_API.G_RET_STS_SUCCESS;
      x_sr_create_out_rec.auto_task_gen_attempted	:= l_auto_task_gen_rec.auto_task_gen_attempted;
      x_sr_create_out_rec.field_service_task_created	:= l_auto_task_gen_rec.field_service_task_created;
    Else
      x_sr_create_out_rec.auto_task_gen_status		:= FND_API.G_RET_STS_ERROR ;
      x_sr_create_out_rec.auto_task_gen_attempted	:= TRUE;

/* Commented out since the service request should be created even if creation of task fails. -- spusegao
   Rolling back the partial task creation, if any , is handled in Auto_Task_Generate API.

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
*/
    End If; -- If l_return_status = FND_API.G_RET_STS_SUCCESS

  Else
    x_sr_create_out_rec.auto_task_gen_attempted 	:= FALSE;

     IF (p_auto_generate_tasks <> 'N' AND p_auto_generate_tasks <> 'n') THEN
              FND_MESSAGE.Set_Name('CS', 'CS_SR_INVALID_AUTOTASK_PARAM');
              FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
              FND_MSG_PUB.ADD;
     END IF;

  End If; -- If p_auto_generate_tasks = 'Y'


  -- Added this call for Misc ER: Owner auto assignment changes


        CS_SR_WORKITEM_PVT.Create_Workitem(
                   p_api_version        => 1.0,
                   p_init_msg_list      => fnd_api.g_false ,
                   p_commit             => p_commit,
                   p_incident_id        => l_request_id,
                   p_incident_number    => l_request_number ,
                   p_sr_rec             => l_service_request_rec,
                   p_user_id            => l_service_request_rec.last_updated_by,
                   p_resp_appl_id       => p_resp_appl_id ,
                   p_login_id           => l_service_request_rec.last_update_login,
                   x_work_item_id       => l_work_item_id,
                   x_return_status      => l_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data) ;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
         );
       END IF;

 -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN Auto_Assign_Excep THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
     FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
--- For BUG # 2933250
  WHEN invalid_install_site THEN
  	ROLLBACK TO Create_ServiceRequest_PVT;
  	x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('CS','CS_SR_INVALID_INSTALL_SITE');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Create_ServiceRequest;


----------------anmukher---------------08/11/2003
-- Added overloaded SR Update API for backward compatibility with 11.5.9
-- This will call the 11.5.10 version of the API
PROCEDURE Update_ServiceRequest
  ( p_api_version			IN	NUMBER,
    p_init_msg_list			IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit				IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level			IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status			OUT	NOCOPY VARCHAR2,
    x_msg_count				OUT	NOCOPY NUMBER,
    x_msg_data				OUT	NOCOPY VARCHAR2,
    p_request_id			IN	NUMBER,
    p_audit_id				IN      NUMBER ,
    p_object_version_number		IN      NUMBER,
    p_resp_appl_id			IN	NUMBER   DEFAULT NULL,
    p_resp_id				IN	NUMBER   DEFAULT NULL,
    p_last_updated_by			IN	NUMBER,
    p_last_update_login	     		IN	NUMBER   DEFAULT NULL,
    p_last_update_date	     		IN	DATE,
    p_service_request_rec    		IN    service_request_rec_type,
    p_invocation_mode        		IN    VARCHAR2 := 'NORMAL',
    p_update_desc_flex       		IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_notes                  		IN    notes_table,
    p_contacts               		IN    contacts_table,
    p_audit_comments         		IN    VARCHAR2 DEFAULT NULL,
    p_called_by_workflow     		IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id    		IN    NUMBER   DEFAULT NULL,
    p_default_contract_sla_ind          IN    VARCHAR2 Default 'N',
    x_workflow_process_id    		OUT   NOCOPY NUMBER,
    x_interaction_id	    		OUT   NOCOPY NUMBER
    )
IS

  l_api_version	       CONSTANT	NUMBER		:= 3.0;
  l_api_version_back   CONSTANT	NUMBER		:= 2.0;
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Update_ServiceRequest';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);

  l_sr_update_out_rec		sr_update_out_rec_type;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Update_ServiceRequest_PVT;

  -- Standard call to check for call compatibility
  -- Added the and condition for backward compatibility project, now
  -- both the version 2.0 and 3.0 are valid as this procedure can be called
  -- from both 1158 or 1159 env.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME)
  AND NOT FND_API.Compatible_API_Call(l_api_version_back, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- This check is not needed here. It is included in version 4.0 of the API, which this API calls by anmukher 08/12/03
  -- IF (l_service_request_rec.initialize_flag IS NULL OR l_service_request_rec.initialize_flag <> G_INITIALIZED) THEN
  --  RAISE FND_API.G_EXC_ERROR;
  -- END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Call 11.5.10 version of the Update SR API
  CS_ServiceRequest_PVT.Update_ServiceRequest
    ( p_api_version           => 4.0,
      p_init_msg_list	      => FND_API.G_FALSE,
      p_commit		      => p_commit,
      p_validation_level      => p_validation_level,
      x_return_status	      => x_return_status,
      x_msg_count	      => x_msg_count,
      x_msg_data	      => x_msg_data,
      p_request_id	      => p_request_id,
      p_audit_id	      => p_audit_id,
      p_object_version_number => p_object_version_number,
      p_resp_appl_id          => p_resp_appl_id,
      p_resp_id               => p_resp_id,
      p_last_updated_by	      => p_last_updated_by,
      p_last_update_login     => p_last_update_login,
      p_last_update_date      => p_last_update_date,
      p_service_request_rec   => p_service_request_rec,
      p_invocation_mode	      => p_invocation_mode,
      p_update_desc_flex      => p_update_desc_flex,
      p_notes                 => p_notes,
      p_contacts              => p_contacts,
      p_audit_comments	      => p_audit_comments,
      p_called_by_workflow    => p_called_by_workflow,
      p_workflow_process_id   => p_workflow_process_id,
      p_auto_assign	      => 'N',
      p_validate_sr_closure   => 'N',
      p_auto_close_child_entities => 'N',
      p_default_contract_sla_ind  => p_default_contract_sla_ind,
      x_sr_update_out_rec     => l_sr_update_out_rec
    );

  -- Assign values returned by the called API to the OUT parameters
  x_workflow_process_id		:= l_sr_update_out_rec.workflow_process_id;
  x_interaction_id		:= l_sr_update_out_rec.interaction_id;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    raise FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
    --IF (l_ServiceRequest_csr%ISOPEN) THEN
    --  CLOSE l_ServiceRequest_csr;
    -- END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
   -- IF (l_ServiceRequest_csr%ISOPEN) THEN
    --  CLOSE l_ServiceRequest_csr;
  --  END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN OTHERS THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
   -- IF (l_ServiceRequest_csr%ISOPEN) THEN
    --  CLOSE l_ServiceRequest_csr;
  --  END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Update_ServiceRequest;


--------------------------------------------------------------------------
-- Update_ServiceRequest
--------------------------------------------------------------------------
--    p_org_id			    IN	NUMBER   DEFAULT NULL,

-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 03/04/05 smisra   Reopened Bug 3958329.
--                   Modified IF condition for calling get_default_contract
--                   procedure and added one more condition to call
--                   get_default_contract. Now contract defaulting will happen
--                   when contract related attributes change and existing
--                   contract service id is NULL.
-- 04/29/05 smisra   removed contact point logic and replacd it with procedures
--                   cs_srcontact_pkg.process to validate contact points and
--                   cs_srcontact_pkg.create_update to insert or update
--                   service request contact points
-- 05/09/05 smisra   updated maint_organization_id col from SR Rec record.
--                   set maint_organization_id and inventory_item_id cols of
--                   audit record.
-- 05/27/05 smisra   Bug 4227769
--                   Removed owner and group_owner columns from update to
--                   cs_incidents_all_tl table.
-- 06/07/05 smisra   Release 12 changes
--                   Raised error msg when maint_organization_id is passed for
--                   Non EAM service requests
--                   Raised error msg when maint_organization_id is NOT passed
--                   for EAM SRs with customer product
-- 07/11/05 smisra   Release 12 ERES changes
--                   called CS_SERVICEREQUEST_UTIL.get_status_details to
--                   details of old status and new status.
--                   if request updated is not allowed and new status has
--                   intermediate status id then do the following
--                   1. Warn user that only status will be updated
--                   2. intialize SR record
--                   3. set status_id and last_updated_by from input SR record
--                      p_servicerequest_rec
--                   If new status has intermediate status then set variable
--                   l_start_eres_flag ot Y
--                   if new status has pending approval flag as 'Y' then raise
--                   error because SR cannot be updated to an status needing
--                   approval
--                   Added new parameters to procedure
--                   CS_SERVICEREQUEST_PVT.get_default_contract call
--                   Moved SR Audit creation after ERES processing
--                   If SR status needs approval then Call ERES apporval
--                   CS_ERES_INT_PKG.start_approval_process procedure.
--                   if this procedure return NO_ACTION then do the following
--                   1. validate target status
--                   2. get response, resolution and close dates
--                   3. get status_flag
--                   4. update SR with target status, response, resolution,
--                      close date, status flag
--                   5. if target status is a closed status the
--                      a. call CS_SR_STATUS_PROPAGATION_PKG.CLOSE_SR_CHILDREN
--                         to close SR child entities
--                      b. abort any open workflow if new type allows
--                   Moved raise business event after ERES approval processing
-- 08/01/05 smisra   passed intermediate status id instead of target status
--                   to ERES call
-- 08/03/05 smisra   Raised error if item_serial_number is passed to this proc
--                   passed incident_occurred_date to get_default_contract
-- 08/29/05 smisra   Called task_restrict_close_cross_val procedure for
--                   Service request needing ERES procesing.
-- 10/05/05 smisra   Added a call to update_task_address.
--                   This procedure is called when validation level is FULL and
--                   incident location id or type is changed
-- 10/11/05 smisra   Bug 4666784
--                   called validate_sr_closure and close_sr_children only
--                   if old close flag is 'N' and new close flag is 'Y'
-- 10/14/05 smisra   fixed Bug 4674131
--                   moved update_task_address under condition
--                   l_only_status_updated <> 'Y' so that task address update
--                   does not happen when only status is changed
-- 12/14/05 smisra   Bug 4386870. Called vldt_sr_rec after update_sr_validation
--                   set incident_country, incident_location_id and
--                   incident_locatiomn_type attribute of audit record just-
--                   before call to create audit
-- 12/23/05 smisra   Bug 4894942
--                   1. Passed additional parameters to vldt_sr_rec call
--                   2. Removed the code to default contract service id, Now
--                      this code is part of vldt_sr_rec.
--                   3. Removed the code to get coverage type. This code is
--                      moved to vldt_sr_rec
--                   4. Added auditing of following attributes just before call
--                      to create audit
--                      a. resource_type
--                      b. group_type
--                      c. incident_owner_id
--                      d. group_owner_id
--                      e. owner_assigned_time
--                      f. territory_id
-- 12/30/05 smisra   Bug 4869065
--                   Set site_id cols of audit record just before call to
--                   create audit
-- 03/01/05 spusegao Modified to allow service request status update using SR Update api for ERES call back procedure.
--------------------------------------------------------------------------------
PROCEDURE Update_ServiceRequest
  ( p_api_version			IN	NUMBER,
    p_init_msg_list			IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit				IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level			IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status			OUT	NOCOPY VARCHAR2,
    x_msg_count				OUT	NOCOPY NUMBER,
    x_msg_data				OUT	NOCOPY VARCHAR2,
    p_request_id			IN	NUMBER,
    p_audit_id				IN      NUMBER ,
    p_object_version_number		IN      NUMBER,
    p_resp_appl_id			IN	NUMBER   DEFAULT NULL,
    p_resp_id				IN	NUMBER   DEFAULT NULL,
    p_last_updated_by			IN	NUMBER,
    p_last_update_login	     		IN	NUMBER   DEFAULT NULL,
    p_last_update_date	     		IN	DATE,
    p_service_request_rec    		IN    service_request_rec_type,
    p_invocation_mode        		IN    VARCHAR2 := 'NORMAL',
    p_update_desc_flex       		IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_notes                  		IN    notes_table,
    p_contacts               		IN    contacts_table,
    p_audit_comments         		IN    VARCHAR2 DEFAULT NULL,
    p_called_by_workflow     		IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id    		IN    NUMBER   DEFAULT NULL,
    -- Commented out since these are now part of the out rec type --anmukher--08/08/03
    -- x_workflow_process_id    	OUT   NOCOPY NUMBER,
    -- x_interaction_id	    		OUT   NOCOPY NUMBER
    ----------------anmukher--------------------08/05/03
    -- Added for 11.5.10 projects
    p_auto_assign		    	IN	VARCHAR2 Default 'N',
    p_validate_sr_closure	    	IN	VARCHAR2 Default 'N',
    p_auto_close_child_entities	    	IN	VARCHAR2 Default 'N',
    p_default_contract_sla_ind          IN      VARCHAR2 Default 'N',
    x_sr_update_out_rec		    	OUT NOCOPY sr_update_out_rec_type
    )
  IS
     l_api_name                   CONSTANT VARCHAR2(30)    := 'Update_ServiceRequest';

-- changed the version from 3.0 to 4.0 anmukher aug 11 2003

     l_api_version                CONSTANT NUMBER          := 4.0;
     l_api_version_back           CONSTANT NUMBER          := 3.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
     l_log_module                 CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
     l_return_status              VARCHAR2(1);
     l_return_status_onetime	  VARCHAR2(1);
     l_cp_inventory_item_id       NUMBER;
     l_close_flag                 VARCHAR2(1);
     l_service_request_rec        service_request_rec_type DEFAULT p_service_request_rec;
     l_sr_rec_temp                service_request_rec_type DEFAULT p_service_request_rec;
     l_transaction_type           CONSTANT VARCHAR2(61)    := G_PKG_NAME||'_'||l_api_name;
     l_message_revision           NUMBER;
     l_maintenance_mode           VARCHAR2(30);
     p_request_number             VARCHAR2(30) DEFAULT NULL;
     p_user_id                    NUMBER DEFAULT  NULL;
     p_login_id                   NUMBER DEFAULT  NULL;
     p_org_id                     NUMBER DEFAULT  NULL;
     l_contacts                   contacts_table ;
     l_update_flag                VARCHAR2(1);
     l_dummy                      NUMBER;
     l_audit_id                   NUMBER;

     l_jtf_note_id                NUMBER ;
     l_owner_assigned_flag        VARCHAR2(1);

     l_bind_data_id               NUMBER;
     l_contra_id                  NUMBER;
     l_contract_number            VARCHAR2(120) ;

     l_msg_id   NUMBER;
     l_msg_count    NUMBER;
     l_msg_data   VARCHAR2(2000);

     -- Added for enh. 2655115
     l_status_flag  VARCHAR2(1);
    -- changes for  11.5.10 usability enhancement
    l_old_responded_flag   VARCHAR2(1);
    l_old_resolved_flag    VARCHAR2(1);
    l_new_responded_flag   VARCHAR2(1);
    l_new_resolved_flag    VARCHAR2(1);
    l_res_close_flag       VARCHAR2(1);
    --Fixed bug#2802393, changed length from 255 to 2500
    l_uwq_body  VARCHAR2(2500);
    l_imp_level  NUMBER;
    l_imp_level_old NUMBER;
    --Fixed bug#2802393, changed length from 30 to 80
    l_title VARCHAR2(80);
    l_send_uwq_notification  BOOLEAN := FALSE;
    l_uwq_body2 VARCHAR2(2000);
    p_uwq_msg_notification  VARCHAR2(30) := 'CS_SR_UWQ_NOTIFICATION';
    p_uwq_upd_notification  VARCHAR2(30) := 'CS_SR_UWQ_UPDATION';
    l_old_owner_id     NUMBER;
    --	l_coverage_type_rec  coverage_type_rec; ----pkesani
    lv_primary_flag VARCHAR2(3) ;

    SR_Lock_Row                  EXCEPTION;
    invalid_install_site           EXCEPTION;

     PRAGMA EXCEPTION_INIT( SR_Lock_Row, -54 );

/* **************** This cursor is no longer needed as the
   l_old_ServiceRequest_rec is now changed to type sr_oldvalues_rec_type .

   Replacing the select list of columns with a select * so that the
   subtype defined in the spec can be used to pass the old SR values as
   a parameter to other procedures

* *****************/
 -- This rec type was changed to sr_oldvalues_rec_type as the
 -- workitem API (Misc ER owner Auto Assginment )needed a record type
 -- with old values , also the API validations needed the oldvalues_rec .

     CURSOR L_SERVICEREQUEST_CSR IS
     SELECT *
     from   cs_incidents_all_vl
     where  incident_id = p_request_id
     for    update nowait;

     L_OLD_SERVICEREQUEST_REC     SR_OLDVALUES_REC_TYPE;

     -- out rec for servicerequest_cross_val

	 l_sr_cross_val_out_rec       CS_ServiceRequest_UTIL.sr_cross_val_out_rec_type;

     -- Validation record
     l_sr_validation_rec          request_validation_rec_type;

     l_audit_vals_rec		      sr_audit_rec_type;

     -- Some temp variables
     l_update_desc_flex           VARCHAR2(1) := p_update_desc_flex;
     l_type_id_temp               NUMBER;
     l_only_status_update_flag    VARCHAR2(1) := 'N';
     l_inventory_org_id           NUMBER;
     l_closed_flag_temp           VARCHAR2(1);
     l_status_validated           BOOLEAN:= FALSE;
     l_contact_phone_num          VARCHAR2(36);
     l_contact_fax_num            VARCHAR2(36);
     l_employee_name              VARCHAR2(240);

     l_note_index                 BINARY_INTEGER;
     l_contact_index              BINARY_INTEGER;
     l_note_id                    NUMBER;
     l_note_context_id            NUMBER;
     l_notes_detail               VARCHAR2(32767);
     l_interaction_id             NUMBER;

     l_bill_to_customer_id        NUMBER;
     l_bill_to_location_id        NUMBER;
     l_ship_to_customer_id        NUMBER;
     l_ship_to_location_id        NUMBER;
     l_install_customer_id        NUMBER;
     l_install_location_id        NUMBER;

     l_org_id                     NUMBER;

     l_contract_id                NUMBER;
     l_project_number             VARCHAR2(120);

     l_primary_contact_found      VARCHAR2(1) := 'N';
     l_contacts_passed            VARCHAR2(1) := 'N' ;

     l_old_close_flag             VARCHAR2(1) ;
     l_new_close_flag             VARCHAR2(1) ;

     -- For Workflow Hook
     l_workflow_item_key          NUMBER;

     l_autolaunch_workflow_flag   VARCHAR2(1);
     l_abort_workflow_close_flag  VARCHAR2(1);

     l_disallow_request_update   VARCHAR2(1);
     l_disallow_owner_update     VARCHAR2(1);
     l_disallow_product_update   VARCHAR2(1);

     l_sr_contact_point_id NUMBER;
     p_sr_contact_point_id NUMBER;

     l_party_id_update             VARCHAR2(1);
     l_contact_point_id_update     VARCHAR2(1);
     l_contact_point_type_update   VARCHAR2(1);
     l_contact_type_update         VARCHAR2(1);
     l_primary_flag_update         VARCHAR2(1) ;

     l_old_party_id           NUMBER;
     l_old_contact_point_id   NUMBER;
     l_old_contact_point_type VARCHAR2(30);
     l_old_contact_type       VARCHAR2(30);
     l_old_primary_flag       VARCHAR2(1) ;

     l_primary_contact_point_id    NUMBER;
     l_saved_primary_contact_id    NUMBER;
     l_saved_contact_point_id      NUMBER ;

     l_primary_contact_change      VARCHAR2(1) := 'N';

     l_count                  NUMBER;

     ---Added so that workflow can call Update SR API  instead of Calling Create Audit API
     ----bug 1485825
     l_wf_process_itemkey    VARCHAR2(30);
     l_workflow_process_name  VARCHAR2(30);
     l_workflow_process_id    NUMBER;
     DestUpdated          EXCEPTION;
	 NoUpdate			  EXCEPTION;
	 TargUpdated		  EXCEPTION;

   -- Added for enh. 2690787
   l_primary_contact       NUMBER;

   -- Added to be used as OUT parameters in the call to the Business Events wrapper
   -- API.
   lx_return_status              VARCHAR2(3);
   lx_msg_count                  NUMBER(15);
   lx_msg_data                   VARCHAR2(2000);

   -- The BES wraper requires the old and new values of the updated SR to be passed
   -- as service_request_rec_type data types. The new values are accepted as an IN
   -- parameter, but there is'nt an equivalent rec type for the old values.
   -- This rec type will be populated only with attributes that can potentially be
   -- used to raise Business events. eg. Staus, Urgency, Owner, etc.
   l_old_sr_rec                  service_request_rec_type;

   -- for cmro-eam; Local variable to store the old and new eam/cmro type flags that
   -- will be used to populate the sr record type variable that is passed to the
   -- user hooks

   l_old_maintenance_flag        VARCHAR2(3) := l_service_request_rec.old_type_maintenance_flag;
   l_new_maintenance_flag        VARCHAR2(3) := l_service_request_rec.new_type_maintenance_flag;

   l_old_cmro_flag               VARCHAR2(3) := l_service_request_rec.old_type_CMRO_flag;
   l_new_cmro_flag               VARCHAR2(3) := l_service_request_rec.new_type_CMRO_flag;

   --Added for 11.5.10 Auditing project
   lx_audit_id			NUMBER;

   -- Added for API changes for unassigned_indicator
   l_unassigned_indicator NUMBER := 0 ;

   -- Local variable to store business usage for security validation
   l_business_usage       VARCHAR2(30);

   -- Local variable to store attribute if security is enabled for self service resps.
   l_ss_sr_type_restrict   VARCHAR2(10);

   -- bug 3077818

   l_primary_flag         VARCHAR2(3) := 'N';
   l_note_status          VARCHAR2(3) ;
   l_timezone_id              NUMBER        ;

   l_primary_flag_temp        VARCHAR2(1)   ;
   l_contact_point_id_temp    NUMBER        ;
   l_contact_party_id_temp    NUMBER        ;
   l_contact_point_type_temp  VARCHAR2(30)  ;
   l_contact_type_temp        VARCHAR2(30)  ;
l_business_process_id       NUMBER;
l_contract_service_id_valid VARCHAR2(1);
l_old_contacts         contacts_table;
l_processed_contacts   contacts_table;

l_start_eres_flag              VARCHAR2(1);
l_approval_status              VARCHAR2(80);
l_sr_related_data              RELATED_DATA_TYPE;
l_primary_contact_party_id     cs_hz_sr_contact_points.party_id % TYPE;
l_last_updated_by_temp         NUMBER;

   --siahmed added for update onetime address
   l_incident_location_id     NUMBER;
   l_onetime_add_cnt          NUMBER;
   --end of addition by siahmed


BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Update_ServiceRequest_PVT;

  -- Standard call to check for call compatibility
  -- Added the and condition for backward compatibility project, now
  -- both the version 2.0 and 3.0 are valid as this procedure can be called
  -- from both 1158 or 1159 env.
  -- The previous version, 3.0, is supported by the overloaded procedure. This API can be
  -- called only with ver 4.0
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
  -- AND NOT FND_API.Compatible_API_Call(l_api_version_back, p_api_version, l_api_name,
  --                                   G_PKG_NAME)
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( l_service_request_rec.initialize_flag IS NULL OR
       l_service_request_rec.initialize_flag <> G_INITIALIZED ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_audit_comments:' || P_audit_comments
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_object_version_number:' || P_object_version_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Last_updated_by:' || P_Last_updated_by
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Last_update_login:' || P_Last_update_login
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Last_update_date:' || P_Last_update_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_request_id:' || p_request_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_request_number:' || p_request_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_auto_assign:' || p_auto_assign
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Called_by_workflow:' || P_Called_by_workflow
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Workflow_process_id:' || P_Workflow_process_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Validate_SR_Closure:' || P_Validate_SR_Closure
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Auto_Close_Child_Entities:' || P_Auto_Close_Child_Entities
    );

 -- --------------------------------------------------------------------------
 -- This procedure Logs the record paramters of SR and NOTES, CONTACTS tables.
 -- --------------------------------------------------------------------------
    Log_SR_PVT_Parameters
    ( p_service_request_rec   	=> p_service_request_rec
    , p_notes                 	=> p_notes
    , p_contacts              	=> p_contacts
    );

  END IF;

  -- Initialize the value of the parameter from profile cs_sr_restrict_ib
  -- by shijain 4th dec 2002

     g_restrict_ib:= fnd_profile.value('CS_SR_RESTRICT_IB');

     IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
     THEN
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The Value of profile CS_SR_RESTRICT_IB :' || g_restrict_ib
       );
     END IF;

    BEGIN

    SELECT object_version_number INTO l_dummy
    FROM cs_incidents_all_b
    WHERE incident_id = p_request_id;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	       l_return_status := FND_API.G_RET_STS_ERROR;
		  CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
              (p_token_an     => l_api_name_full,
			   p_token_v      => TO_CHAR(p_request_id),
			   p_token_p      => 'Request ID' ,
               p_table_name   => G_TABLE_NAME,
               p_column_name  => 'INCIDENT_ID');
	    RAISE FND_API.G_EXC_ERROR;
    END ;



    IF (l_dummy > p_object_version_number ) THEN
      RAISE DestUpdated;
    ELSIF (l_dummy < p_object_version_number ) THEN
	     IF  (p_invocation_mode = 'NORMAL')THEN
	        RAISE NoUpdate;
		 ELSIF (p_invocation_mode = 'REPLAY')THEN
		    NULL;
		 END IF;
    ELSE
  	  	 IF (p_invocation_mode = 'REPLAY') THEN
		    RAISE TargUpdated;
		 ELSIF (p_invocation_mode = 'NORMAL')THEN
		    NULL;
		 END IF;

  END IF;

  -- Check if mandatory parameter is passed
  IF (p_request_id IS NULL ) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                             (p_token_an    => l_api_name_full,
                              p_token_np     => 'SR Incident Id',
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'INCIDENT_ID' );

      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_object_version_number IS NULL ) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                           (p_token_an   => l_api_name_full,
                            p_token_np    => 'SR Object Version Number',
                            p_table_name => G_TABLE_NAME,
                            p_column_name => 'OBJECT_VERSION_NUMBER');

      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if user has passed null to mandatory parameters.

  IF  (l_service_request_rec.type_id  IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                              (p_token_an    => l_api_name_full,
                               p_token_np     => 'SR Type',
                               p_table_name  => G_TABLE_NAME,
                               p_column_name => 'INCIDENT_TYPE_ID');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF  (l_service_request_rec.status_id  IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                                 (p_token_an    => l_api_name_full,
                                  p_token_np     =>  'SR Status',
                                  p_table_name  => G_TABLE_NAME,
                                  p_column_name => 'INCIDENT_STATUS_ID');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF  (l_service_request_rec.severity_id  IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                             (p_token_an    => l_api_name_full,
                              p_token_np     => 'SR Severity',
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'SEVERITY_ID');

      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Request Date is a reqd field, so check if passed, else return error
  IF  (l_service_request_rec.request_date IS NULL) THEN
    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                             (p_token_an    => l_api_name_full,
                              p_token_np     => 'SR Request Date',
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'REQUEST_DATE');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF (l_service_request_rec.summary IS NULL) THEN
    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg (
       p_token_an    => l_api_name_full,
       p_token_np     => 'SR Summary',
       p_table_name  => G_TABLE_NAME,
       p_column_name => 'SUMMARY');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Fetch and lock the original values
  OPEN  l_ServiceRequest_csr;
  FETCH l_ServiceRequest_csr INTO l_old_ServiceRequest_rec;

  IF ( l_ServiceRequest_csr%NOTFOUND ) THEN

     CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                               ( p_token_an    =>  l_api_name_full,
                                 p_token_v     =>  TO_CHAR(p_request_id),
                                 p_token_p     =>  'p_request_id',
                                 p_table_name  => G_TABLE_NAME,
                                 p_column_name => 'REQUEST_ID' );

    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- check for item serial number. it must be null or G_miss_char
  IF l_service_request_rec.item_serial_number <> FND_API.G_MISS_CHAR
  THEN
    FND_MESSAGE.set_name ('CS', 'CS_SR_ITEM_SERIAL_OBSOLETE');
    FND_MESSAGE.set_token
    ( 'API_NAME'
    , 'CS_SERVICEREQUEST_PVT.update_servicerequest'
    );
    FND_MSG_PUB.ADD_DETAIL
    ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.ITEM_SERIAL_NUMBER'
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF l_service_request_rec.type_id = FND_API.G_MISS_NUM
  THEN
    l_service_request_rec.type_id := l_old_servicerequest_rec.incident_type_id;
  END IF;
  IF l_service_request_rec.status_id = FND_API.G_MISS_NUM
  THEN
    l_service_request_rec.status_id := l_old_servicerequest_rec.incident_status_id;
  END IF;

  CS_SERVICEREQUEST_PVT.get_incident_type_details
  ( p_incident_type_id          => l_service_request_rec.type_id
  , x_business_process_id       => l_sr_related_data.business_process_id
  , x_autolaunch_workflow_flag  => l_sr_related_data.autolaunch_workflow_flag
  , x_abort_workflow_close_flag => l_sr_related_data.abort_workflow_close_flag
  , x_workflow                  => l_sr_related_data.workflow
  , x_return_status             => l_return_status
  );
  IF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
    ( p_token_an     => l_api_name_full
    , p_token_v      => TO_CHAR(l_service_request_rec.type_id)
    , p_token_p      => 'p_type_id'
    , p_table_name   => G_TABLE_NAME
    , p_column_name  => 'INCIDENT_TYPE_ID'
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The defaulted value of parameter business_process_id :'
    || l_sr_related_data.business_process_id
    );
  END IF;

   -- 1. Perform the security check if validation level is > none
   -- 2. Perform the SR Type change check for EAM to non-EAM and vice versa
   -- 3. Check if the install site and site use are the same

   IF ( p_validation_level > fnd_api.g_valid_level_none ) then
      -- dj api cleanup
      -- Validate if the current responsibility has access to the SR type being update.
      -- If the SR Type is itself being updated, then first validate if the responsibility
      -- has access to the old SR Type and then vaidate if the responsibility has accesss
      -- to the new SR Type as well.
      -- Invoke the VALIDATE_TYPE procedure that has the logic to check for security
      -- access

      -- Get the business usage of the responsibility that is attempting to create
      -- the SR.
      get_business_usage (
         p_responsibility_id      => p_resp_id,
         p_application_id         => fnd_global.resp_appl_id,
         x_business_usage         => l_business_usage );

      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The defaulted value of parameter business_usage :' || l_business_usage
	);
      END IF;

      -- Get indicator of self service security enabled or not
      if ( l_business_usage = 'SELF_SERVICE' ) then
         get_ss_sec_enabled (
	    x_ss_sr_type_restrict => l_ss_sr_type_restrict );
      end if;


      -- For bug 3370562 - pass resp_id an appl_id
      -- validate security in update; first against old sr type

      -- For bug 3474365 - pass different operation code for old sr type
      cs_servicerequest_util.validate_type (
         p_parameter_name       => NULL,
         p_type_id   	        => l_old_servicerequest_rec.incident_type_id,
         p_subtype  	        => G_SR_SUBTYPE,
         p_status_id            => p_service_request_rec.status_id, -- not used
         p_resp_id              => p_resp_id,
         p_resp_appl_id         => NVL(p_resp_appl_id, fnd_global.resp_appl_id),
         p_business_usage       => l_business_usage,
         p_ss_srtype_restrict   => l_ss_sr_type_restrict,
         p_operation            => 'UPDATE_OLD',
         x_return_status        => lx_return_status,
         x_cmro_flag            => l_old_cmro_flag,
         x_maintenance_flag     => l_old_maintenance_flag );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- security violation; responsibility does not have access to SR Type
         -- being created. Stop and raise error.
         RAISE FND_API.G_EXC_ERROR;
      end if;

      -- For bug 3370562 - pass resp_id an appl_id
      -- if type has changed and is not the same as the existing type, then validate
      -- if the responsibility has access to the new SR Type
      IF ( p_service_request_rec.type_id <> FND_API.G_MISS_NUM   AND
	   p_service_request_rec.type_id <> l_old_ServiceRequest_rec.incident_type_id ) then
         cs_servicerequest_util.validate_type (
            p_parameter_name       => NULL,
            p_type_id   	   => p_service_request_rec.type_id,
            p_subtype  	           => G_SR_SUBTYPE,
            p_status_id            => p_service_request_rec.status_id, -- not used
            p_resp_id              => p_resp_id,
            p_resp_appl_id         => NVL(p_resp_appl_id, fnd_global.resp_appl_id),
            p_business_usage       => l_business_usage,
            p_ss_srtype_restrict   => l_ss_sr_type_restrict,
            p_operation            => 'UPDATE',
            x_return_status        => lx_return_status,
            x_cmro_flag            => l_new_cmro_flag,
            x_maintenance_flag     => l_new_maintenance_flag );

         if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) then
            -- security violation; responsibility does not have access to SR Type
            -- being created. Stop and raise error.
            RAISE FND_API.G_EXC_ERROR;
         end if;

	 -- if the type has changed, check if the change is EAM <-> non-EAM.
         cs_servicerequest_util.validate_type_change (
           p_old_eam_type_flag        => l_old_maintenance_flag,
           p_new_eam_type_flag        => l_new_maintenance_flag,
           x_return_status            => lx_return_status );

         if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) then
            -- Type change is not allowed. Msg put on stack by val. proc
            RAISE FND_API.G_EXC_ERROR;
         end if;

      ELSE  -- the type has not changed; assign old flag values to the new flags
         l_new_cmro_flag          := l_old_cmro_flag;
         l_new_maintenance_flag   := l_old_maintenance_flag;
      END IF;
      IF NVL(l_new_maintenance_flag,'N') <> 'Y'
      THEN
        IF p_service_request_rec.maint_organization_id <> FND_API.G_MISS_NUM
        THEN
          FND_MESSAGE.set_name ('CS', 'CS_SR_MAINT_ORG_NOT_ALLOWED');
          FND_MESSAGE.set_token
          ( 'API_NAME'
          , 'CS_SERVICEREQUEST_PVT.update_servicerequest'
          );
          FND_MSG_PUB.ADD_DETAIL
          ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.MAINT_ORGANIZATION_ID'
          );
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE -- maintenance flag is 'Y'
        IF (p_service_request_rec.customer_product_id IS NOT NULL AND
            p_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM)
        THEN
          IF (p_service_request_rec.maint_organization_id = FND_API.G_MISS_NUM AND
              l_old_servicerequest_rec.maint_organization_id IS NULL)
          THEN
            CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(l_api_name_full, 'Maint_organization_id');
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (p_service_request_rec.maint_organization_id IS NULL) THEN
            CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'Maint_organization_id');
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      --- For BUG # 2933250, check to see if install_site_id and install_site_use_id are same . -- pkesani

      IF (l_service_request_rec.install_site_id = FND_API.G_MISS_NUM)  THEN
         IF ( l_service_request_rec.install_site_use_id <>  FND_API.G_MISS_NUM) THEN
            l_service_request_rec.install_site_id := l_service_request_rec.install_site_use_id;
         END IF;
      ELSIF (l_service_request_rec.install_site_id IS NOT NULL) THEN
         IF (l_service_request_rec.install_site_use_id = FND_API.G_MISS_NUM) THEN
            l_service_request_rec.install_site_use_id := l_service_request_rec.install_site_id;
         ELSIF (l_service_request_rec.install_site_use_id <> l_service_request_rec.install_site_id) THEN
            RAISE invalid_install_site;
         ELSIF (l_service_request_rec.install_site_use_id IS NULL) THEN
            RAISE invalid_install_site;
         END IF;
      ELSIF (l_service_request_rec.install_site_id IS NULL) THEN
         IF (l_service_request_rec.install_site_use_id = FND_API.G_MISS_NUM) THEN
            l_service_request_rec.install_site_use_id := l_service_request_rec.install_site_id;
         ELSIF (l_service_request_rec.install_site_use_id IS NOT NULL) THEN
            RAISE invalid_install_site;
         END IF;
      END IF;

      IF (l_new_maintenance_flag = 'y' OR l_new_maintenance_flag = 'Y') THEN
         IF (l_service_request_rec.inventory_org_id IS NULL) THEN
            CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
                               l_api_name_full, 'Inventory Org ID');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- popluate the record for the user hooks
      l_service_request_rec.Old_type_CMRO_Flag        := l_old_cmro_flag;
      l_service_request_rec.Old_type_Maintenance_Flag := l_old_maintenance_flag;
      l_service_request_rec.New_type_CMRO_flag        := l_new_cmro_flag;
      l_service_request_rec.New_type_Maintenance_flag := l_new_maintenance_flag;

   END IF;   -- IF ( p_validation_level > fnd_api.g_valid_level_none )

   l_sr_related_data.target_status_id := l_service_request_rec.status_id;
   CS_SERVICEREQUEST_UTIL.get_status_details
   ( p_status_id                  => l_old_servicerequest_rec.incident_status_id
   , x_close_flag                 => l_sr_related_data.old_close_flag
   , x_disallow_request_update    => l_sr_related_data.old_disallow_request_update
   , x_disallow_agent_dispatch    => l_sr_related_data.old_disallow_owner_update
   , x_disallow_product_update    => l_sr_related_data.old_disallow_product_update
   , x_pending_approval_flag      => l_sr_related_data.old_pending_approval_flag
   , x_intermediate_status_id     => l_sr_related_data.old_intermediate_status_id
   , x_approval_action_status_id  => l_sr_related_data.old_approval_action_status_id
   , x_rejection_action_status_id => l_sr_related_data.old_rejection_action_status_id
   , x_return_status              => l_return_status
   );
   l_start_eres_flag := 'N';
   IF (l_service_request_rec.status_id <> FND_API.G_MISS_NUM AND
       l_service_request_rec.status_id <> l_old_servicerequest_rec.incident_status_id)
   THEN
     CS_SERVICEREQUEST_UTIL.get_status_details
     ( p_status_id                  => l_sr_related_data.target_status_id
     , x_close_flag                 => l_sr_related_data.close_flag
     , x_disallow_request_update    => l_sr_related_data.disallow_request_update
     , x_disallow_agent_dispatch    => l_sr_related_data.disallow_owner_update
     , x_disallow_product_update    => l_sr_related_data.disallow_product_update
     , x_pending_approval_flag      => l_sr_related_data.pending_approval_flag
     , x_intermediate_status_id     => l_sr_related_data.intermediate_status_id
     , x_approval_action_status_id  => l_sr_related_data.approval_action_status_id
     , x_rejection_action_status_id => l_sr_related_data.rejection_action_status_id
     , x_return_status              => l_return_status
     );

     IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
     THEN
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter disallow_request_update :'
       || l_sr_related_data.disallow_request_update
       );
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter disallow_owner_update :'
       || l_sr_related_data.disallow_owner_update
       );
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter disallow_product_update :'
       || l_sr_related_data.disallow_product_update
       );
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter pending_approval_flag :'
       || l_sr_related_data.pending_approval_flag
       );
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter intermediate_status_id :'
       || l_sr_related_data.intermediate_status_id
       );
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter approval_action_status_id :'
       || l_sr_related_data.approval_action_status_id
       );
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter rejection_action_status_id :'
       || l_sr_related_data.rejection_action_status_id
       );
     END IF;

     IF (l_sr_related_data.intermediate_status_id IS NOT NULL AND
         l_sr_related_data.intermediate_status_id <> l_old_servicerequest_rec.incident_status_id AND
         NVL(p_service_request_rec.last_update_program_code,'UNKOWN') <> 'ERES')
     THEN
       l_start_eres_flag := 'Y';
       l_service_request_rec.status_id := l_sr_related_data.intermediate_status_id;
     END IF;

     IF (l_sr_related_data.pending_approval_flag = 'Y' AND
         NVL(p_service_request_rec.last_update_program_code,'UNKOWN') <> 'ERES')
     THEN
       FND_MESSAGE.set_name ('CS', 'CS_SR_INTERMEDIATE_STATUS');
       FND_MESSAGE.set_token
       ( 'API_NAME'
       , 'CS_SERVICEREQUEST_PVT.update_servicerequest'
       );
       FND_MESSAGE.set_token('STATUS_ID',l_sr_related_data.target_status_id);
       FND_MSG_PUB.ADD_DETAIL
       ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.incident_status_id'
       );
       RAISE FND_API.G_EXC_ERROR;
     END IF; -- l_pending approval flag is Y
   ELSE -- status_id <> G_MISS and not equal to old value
     l_sr_related_data.close_flag             := l_sr_related_data.old_close_flag;
     l_sr_related_data.target_status_id       := l_old_servicerequest_rec.incident_status_id;
     l_sr_related_data.intermediate_status_id := l_sr_related_data.old_intermediate_status_id;

     IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
     THEN
       FND_LOG.String
       ( FND_LOG.level_procedure , L_LOG_MODULE || ''
       , 'The defaulted value of parameter intermediate_status_id :'
       || l_sr_related_data.intermediate_status_id
       );
     END IF;
   END IF;
   IF l_sr_related_data.old_disallow_request_update = 'Y' AND
      l_sr_related_data.intermediate_status_id IS NOT NULL AND
      NVL(p_service_request_rec.last_update_program_code,'UNKOWN') <> 'ERES'
   THEN
     FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ONLY_STATUS_UPDATED');
     FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
     FND_MSG_PUB.Add_Detail
     ( p_message_type => fnd_msg_pub.G_WARNING_MSG
     , p_same_associated_columns => 'CS_INCIDENTS_ALL_B.INCIDENT_STATUS_ID'
     );
     IF l_old_servicerequest_rec.incident_status_id = l_service_request_rec.status_id
     THEN
       CS_ServiceRequest_UTIL.Add_Same_Val_Update_Msg
       ( p_token_an     => 'CS_SERVICEREQUEST_PUB.update_servicerequest'
       , p_token_p      => 'p_status_id'
       , p_table_name   => G_TABLE_NAME
       , p_column_name  => 'INCIDENT_STATUS_ID'
       );
       RETURN;
     ELSE
       l_last_updated_by_temp := l_service_request_rec.last_updated_by;
       CS_SERVICEREQUEST_PVT.initialize_rec(l_service_request_rec);
       -- we need to copy back intermediate status because this case will happen only if
       -- input status has intermediate status
       l_service_request_rec.status_id        := l_sr_related_data.intermediate_status_id;
       l_service_request_rec.last_updated_by  := p_service_request_rec.last_updated_by;
     END IF;
   END IF;

   -- end of cmro_eam

  -- Made changes for bug #2835847, if either last_update_date is passed
  -- in the parameter (p_last_updated_by or in the service request rec.
  -- last_updated_by, both will be considered.

     IF (l_service_request_rec.last_updated_by IS NULL OR
         l_service_request_rec.last_updated_by = FND_API.G_MISS_NUM) THEN
         IF (p_last_updated_by IS NOT NULL AND
             p_last_updated_by <>FND_API.G_MISS_NUM) THEN
              l_service_request_rec.last_updated_by := p_last_updated_by;
         END IF;
     END IF;

  -- Make the preprocessing call to the user hooks
  --
  -- Pre call to the Customer Type User Hook

  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'B', 'C')  THEN

-- hardcoded the version 2.0 shijain nov 27 2002

    cs_servicerequest_cuhk.Update_ServiceRequest_Pre
    ( p_api_version         => 2.0,
    p_init_msg_list         => fnd_api.g_false ,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    x_return_status         => l_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data,
    p_request_id            => p_request_id ,
    p_object_version_number => p_object_version_number,
    p_resp_appl_id          => p_resp_appl_id,
    p_resp_id               => p_resp_id,
    p_last_updated_by       => p_last_updated_by,
    p_last_update_login     => p_last_update_login,
    p_last_update_date      => p_last_update_date,
    p_invocation_mode       => p_invocation_mode,
    p_service_request_rec   => l_service_request_rec,
    p_update_desc_flex      => p_update_desc_flex,
    p_notes                 => p_notes,
    p_contacts              => p_contacts,
    p_audit_comments        => p_audit_comments,
    p_called_by_workflow    => p_called_by_workflow,
    p_workflow_process_id   => p_workflow_process_id,
    x_workflow_process_id   => x_sr_update_out_rec.workflow_process_id,
    x_interaction_id        => x_sr_update_out_rec.interaction_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'B', 'V')  THEN

-- hardcoded the version 2.0 shijain nov 27 2002

    cs_servicerequest_vuhk.Update_ServiceRequest_Pre
    ( p_api_version           => 2.0,
      p_init_msg_list         => fnd_api.g_false ,
      p_commit                => p_commit,
      p_validation_level      => p_validation_level,
      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      p_request_id            => p_request_id ,
      p_object_version_number => p_object_version_number,
      p_resp_appl_id          => p_resp_appl_id,
      p_resp_id               => p_resp_id,
      p_last_updated_by       => p_last_updated_by,
      p_last_update_login     => p_last_update_login,
      p_last_update_date      => p_last_update_date,
      p_service_request_rec   => l_service_request_rec,
      p_update_desc_flex      => p_update_desc_flex,
      p_notes                 => p_notes,
      p_contacts              => p_contacts,
      p_audit_comments        => p_audit_comments,
      p_called_by_workflow    => p_called_by_workflow,
      p_workflow_process_id   => p_workflow_process_id,
      x_workflow_process_id   => x_sr_update_out_rec.workflow_process_id,
      x_interaction_id        => x_sr_update_out_rec.interaction_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Pre call to the Internal Type User Hook
  --

  --Code to populate the global record type with the passed record type
  --
  user_hooks_rec.customer_id  :=  l_old_ServiceRequest_rec.customer_id ;
  user_hooks_rec.request_id   :=  p_request_id ;

-- for cmro_eam
  -- set additional paramters for cmro_eam
  -- status_flag,old_type_cmro_flag,new_type_cmro_flag,customer_product_id,
  -- status_id,exp_resolution_date

    if (l_service_request_rec.status_id = FND_API.G_MISS_NUM) then
        l_service_request_rec.status_id := l_old_ServiceRequest_rec.incident_status_id;
    end if;

    if (l_service_request_rec.customer_product_id = FND_API.G_MISS_NUM) then
        l_service_request_rec.customer_product_id := l_old_ServiceRequest_rec.customer_product_id;
    end if;

    if (l_service_request_rec.exp_resolution_date = FND_API.G_MISS_DATE) then
        l_service_request_rec.exp_resolution_date := l_old_ServiceRequest_rec.expected_resolution_date;
    end if;

    user_hooks_rec.status_flag 		:= get_status_flag(l_service_request_rec.status_id);
    user_hooks_rec.old_type_cmro_flag 	:= l_service_request_rec.Old_type_CMRO_Flag;
    user_hooks_rec.new_type_cmro_flag 	:= l_service_request_rec.New_type_CMRO_flag;
    user_hooks_rec.customer_product_id 	:= l_service_request_rec.customer_product_id;
    user_hooks_rec.status_id 		:= l_service_request_rec.status_id;
    user_hooks_rec.exp_resolution_date 	:= l_service_request_rec.exp_resolution_date;

-- end for cmro_eam

   cs_servicerequest_iuhk.Update_ServiceRequest_Pre(x_return_status=>l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   -- siahmed 12.1.2 project this to make sure that the address field that will be updated
   -- is a one_time_address. This is doen to make so that we can use this
   -- global variabel in the update_sr_validation the country gets assigned
   -- with the old country valu which is preventing the onetime address
   -- to change a country once it has been assined. Using the global
   -- variable we will assign the value accordingly.
   --check if created by module = 'SR_ONETIME'
	   -- fix for bug 8594093 to check for location as well Ranjan
	   if l_service_request_rec.incident_location_type='HZ_PARTY_SITE' then
        	SELECT count(party_site_id) into G_ONETIME_ADD_CNT
        	FROM hz_party_sites
        	WHERE party_site_id = l_service_request_rec.incident_location_id
        	AND created_by_module = 'SR_ONETIME';
	   elsif l_service_request_rec.incident_location_type='HZ_LOCATION' then
        	SELECT count(location_id) into G_ONETIME_ADD_CNT
        	FROM hz_locations
        	WHERE location_id = l_service_request_rec.incident_location_id
        	AND created_by_module = 'SR_ONETIME';
	   end if;
	   /*
     SELECT count(party_site_id) into G_ONETIME_ADD_CNT
     FROM hz_party_sites
     WHERE party_site_id = l_service_request_rec.incident_location_id
     AND created_by_module = 'SR_ONETIME';
	*/

   --end of addition by siahmed


-- hardcoded the version 2.0 shijain nov 27 2002

   l_sr_rec_temp := l_service_request_rec;

     Update_SR_Validation
      (   p_api_version           => 2.0,
          p_init_msg_list         => fnd_api.g_false ,
          --p_service_request_rec   => p_service_request_rec,
          p_service_request_rec   => l_sr_rec_temp,
          p_contacts              => p_contacts,
          p_notes                 => p_notes,
          p_audit_comments        => p_audit_comments,
          p_invocation_mode       => p_invocation_mode,
          p_resp_id               => p_resp_id,
          p_resp_appl_id          => p_resp_appl_id,
          p_request_id            => p_request_id,
          p_validation_level      => p_validation_level,
          p_commit                => p_commit,
          p_last_updated_by       => p_last_updated_by,
          p_last_update_login     => p_last_update_login,
          p_last_update_date      => p_last_update_date,
          p_object_version_number => p_object_version_number,
          x_return_status         => l_return_status,
          x_contra_id             => l_contra_id,
          x_contract_number       => l_contract_number,
          x_owner_assigned_flag   => l_owner_assigned_flag,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
	      x_audit_vals_rec	      => l_audit_vals_rec,
          x_service_request_rec   => l_service_request_rec,
          x_autolaunch_wkf_flag   => l_autolaunch_workflow_flag,
          x_abort_wkf_close_flag  => l_abort_workflow_close_flag,
          x_wkf_process_name      => l_workflow_process_name,
          x_workflow_process_id   => l_workflow_process_id,
          x_interaction_id        => l_interaction_id,
          p_update_desc_flex      => p_update_desc_flex,
          p_called_by_workflow    => p_called_by_workflow,
          p_workflow_process_id   => p_workflow_process_id,
          -- for cmro
         p_cmro_flag              => l_new_cmro_flag,
         p_maintenance_flag       => l_new_maintenance_flag,
         p_auto_assign            => p_auto_assign
      );


-- for cmro_eam
         l_service_request_rec.Old_type_CMRO_Flag 	 := l_old_cmro_flag;
         l_service_request_rec.Old_type_Maintenance_Flag := l_old_maintenance_flag;
         l_service_request_rec.New_type_CMRO_flag 	 := l_new_cmro_flag;
         l_service_request_rec.New_type_Maintenance_flag := l_new_maintenance_flag;

     -- end of cmro_eam

    IF (l_return_status = 'R' ) THEN
       l_only_status_update_flag := 'Y';

-- hardcoded the version 2.0 shijain nov 27 2002
-- for bug # 3640344 - pkesani added the parameter p_closed_date.
      -- Give a message to user
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ONLY_STATUS_UPDATED');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add_Detail
        ( p_message_type            => fnd_msg_pub.G_WARNING_MSG
        , p_same_associated_columns => 'T'
        );
      END IF;


       CS_Servicerequest_PVT.Update_Status
       ( p_api_version       => 2.0,
        p_init_msg_list      => fnd_api.g_false ,
        p_resp_id            => p_resp_id,
        p_validation_level   => fnd_api.g_valid_level_full,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_request_id         => p_request_id,
        p_object_version_number => p_object_version_number,
        p_status_id          => l_service_request_rec.status_id,
        p_closed_date        => l_service_request_rec.closed_date,
        p_last_updated_by    => l_service_request_rec.last_updated_by ,
        p_last_update_login  => l_service_request_rec.last_update_login ,
        p_last_update_date   => l_service_request_rec.last_update_date ,
        x_interaction_id     => l_interaction_id
       );


       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

    ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   IF (l_only_status_update_flag <> 'Y') THEN

     vldt_sr_rec
     ( p_sr_rec                       => l_service_request_rec
     , p_sr_rec_inp                   => p_service_request_rec
     , p_sr_related_data              => l_sr_related_data
     , p_mode                         => 'UPDATE'
     , p_validation_level             => p_validation_level
     , p_request_id                   => p_request_id
     , p_object_version_number        => p_object_version_number
     , p_last_updated_by              => p_last_updated_by
     , p_default_contract_sla_ind     => p_default_contract_sla_ind
     , p_auto_assign                  => p_auto_assign
     , p_old_incident_location_id     => l_old_servicerequest_rec.incident_location_id
     , p_old_incident_location_type   => l_old_servicerequest_rec.incident_location_type
     , p_old_incident_country         => l_old_servicerequest_rec.incident_country
     , p_old_incident_owner_id        => l_old_servicerequest_rec.incident_owner_id
     , p_old_owner_group_id           => l_old_servicerequest_rec.owner_group_id
     , p_old_resource_type            => l_old_servicerequest_rec.resource_type
     , p_old_site_id                  => l_old_servicerequest_rec.site_id
     , p_old_obligation_date          => l_old_servicerequest_rec.obligation_date
     , p_old_expected_resolution_date => l_old_servicerequest_rec.expected_resolution_date
     , p_old_contract_id              => l_old_servicerequest_rec.contract_id
     , p_old_contract_service_id      => l_old_servicerequest_rec.contract_service_id
     , p_old_install_site_id          => l_old_servicerequest_rec.install_site_id
     , p_old_system_id                => l_old_servicerequest_rec.system_id
     , p_old_account_id               => l_old_servicerequest_rec.account_id
     , p_old_inventory_item_id        => l_old_servicerequest_rec.inventory_item_id
     , p_old_customer_product_id      => l_old_servicerequest_rec.customer_product_id
     , p_old_incident_type_id         => l_old_servicerequest_rec.incident_type_id
     , p_old_time_zone_id             => l_old_servicerequest_rec.time_zone_id
     , p_old_incident_severity_id     => l_old_servicerequest_rec.incident_severity_id
     , x_contract_number              => l_contract_number
     , x_return_status                => l_return_status
     );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     l_contra_id := l_service_request_rec.contract_id;
      -- API cleanup for 11.5.10
      -- Call the cross validation procedure if the validation level is
      -- more than none.
      -- The cross validation procedure executes all the data relationships
      -- that exist between the SR attributes. This was introduced in
      -- Release 11.5.10 as part of the API Cleanup projecT
      --
      l_contract_service_id_valid := 'Y';
      IF ( p_validation_level > FND_API.G_VALID_LEVEL_NONE ) THEN
        CS_ServiceRequest_UTIL.SERVICEREQUEST_CROSS_VAL (
           p_new_sr_rec            =>  l_service_request_rec,
           p_old_sr_rec            =>  l_old_ServiceRequest_rec,
           x_cross_val_out_rec     =>  l_sr_cross_val_out_rec,
           x_return_status         =>  l_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    -- Assigning the values from the out parameters to respective fields .

   -- For bug 3340433 - populate directly as the out rec will have the current value
   /* IF (l_service_request_rec.customer_product_id IS NOT NULL) AND
       (l_sr_cross_val_out_rec.inventory_item_id <> l_old_ServiceRequest_rec.inventory_item_id) THEN
      l_service_request_rec.inventory_item_id := l_sr_cross_val_out_rec.inventory_item_id;
    END IF; */

    l_service_request_rec.inventory_item_id := l_sr_cross_val_out_rec.inventory_item_id;

    IF (l_sr_cross_val_out_rec.bill_to_site_id IS NOT NULL) then
        l_service_request_rec.bill_to_site_id := l_sr_cross_val_out_rec.bill_to_site_id;
    END IF;
    IF (l_sr_cross_val_out_rec.bill_to_site_use_id IS NOT NULL) then
        l_service_request_rec.bill_to_site_use_id := l_sr_cross_val_out_rec.bill_to_site_use_id;
    END IF;
    IF (l_sr_cross_val_out_rec.ship_to_site_id IS NOT NULL) then
        l_service_request_rec.ship_to_site_id := l_sr_cross_val_out_rec.ship_to_site_id;
    END IF;
    IF (l_sr_cross_val_out_rec.ship_to_site_use_id IS NOT NULL) then
        l_service_request_rec.ship_to_site_use_id := l_sr_cross_val_out_rec.ship_to_site_use_id;
    END IF;
    IF (l_sr_cross_val_out_rec.contract_id IS NOT NULL) then
        l_contra_id := l_sr_cross_val_out_rec.contract_id;
    END IF;
    IF (l_sr_cross_val_out_rec.contract_number IS NOT NULL) then
        l_contract_number := l_sr_cross_val_out_rec.contract_number;
    END IF;
    -- Product Revision
    l_service_request_rec.product_revision := l_sr_cross_val_out_rec.product_revision;
    IF (l_service_request_rec.product_revision = FND_API.G_MISS_CHAR) then
        l_service_request_rec.product_revision := null;
    END IF;
    IF  (nvl(l_service_request_rec.product_revision,'-999') = nvl(l_old_ServiceRequest_rec.product_revision,'-999')) THEN
      l_audit_vals_rec.CHANGE_PRODUCT_REVISION_FLAG  := 'N';
      l_audit_vals_rec.old_product_revision := l_old_ServiceRequest_rec.product_revision;
      l_auDit_vals_rec.product_revision     := l_service_request_rec.product_revision;
    ELSE
      l_audit_vals_rec.CHANGE_PRODUCT_REVISION_FLAG := 'Y';
      l_audit_vals_rec.OLD_product_revision := l_old_ServiceRequest_rec.product_revision;
      l_audit_vals_rec.product_revision := l_service_request_rec.product_revision;
    END IF;
    -- Component Version
    l_service_request_rec.component_version := l_sr_cross_val_out_rec.component_version;
    IF (l_service_request_rec.component_version = FND_API.G_MISS_CHAR) then
        l_service_request_rec.component_version := null;
    END IF;
    IF  (nvl(l_service_request_rec.component_version,'-999') = nvl(l_old_ServiceRequest_rec.component_version,'-999')) THEN
      l_audit_vals_rec.change_comp_ver_flag  := 'N';
      l_audit_vals_rec.old_component_version := l_old_ServiceRequest_rec.component_version;
      l_auDit_vals_rec.component_version     := l_service_request_rec.component_version;
    ELSE
      l_audit_vals_rec.CHANGE_COMP_VER_FLAG := 'Y';
      l_audit_vals_rec.OLD_component_version := l_old_ServiceRequest_rec.component_version;
      l_audit_vals_rec.component_version := l_service_request_rec.component_version;
    END IF;
    -- Subcomponent Version
    l_service_request_rec.subcomponent_version := l_sr_cross_val_out_rec.subcomponent_version;
    IF (l_service_request_rec.subcomponent_version = FND_API.G_MISS_CHAR) then
        l_service_request_rec.subcomponent_version := null;
    END IF;
    IF (nvl(l_service_request_rec.subcomponent_version,'-999') = nvl(l_old_ServiceRequest_rec.subcomponent_version,'-999')) THEN
      l_audit_vals_rec.change_subcomp_ver_flag  := 'N';
      l_audit_vals_rec.old_subcomponent_version := l_old_ServiceRequest_rec.subcomponent_version;
      l_audit_vals_rec.subcomponent_version     := l_service_request_rec.subcomponent_version;
    ELSE
      l_audit_vals_rec.CHANGE_SUBCOMP_VER_FLAG := 'Y';
      l_audit_vals_rec.OLD_subcomponent_version := l_old_ServiceRequest_rec.subcomponent_version;
      l_audit_vals_rec.subcomponent_version := l_service_request_rec.subcomponent_version;
    END IF;
      l_contract_service_id_valid := l_sr_cross_val_out_rec.contract_service_id_valid;

      END IF;  -- IF ( p_validation_level > FND_API.G_VALID_LEVEL_NONE )
   -- Validate service request contacts
   -- This procedure should always be called before get_default_contract
   -- because it needs primary contact info
   IF l_sr_related_data.old_disallow_request_update <> 'Y'
   THEN
     CS_SRCONTACT_PKG.process
     ( p_mode            => 'UPDATE'
     , p_incident_id     => p_request_id
     , p_caller_type     => l_service_request_rec.caller_type
     , p_customer_id     => l_service_request_rec.customer_id
     , p_validation_mode => p_validation_level
     , p_contact_tbl     => p_contacts
     , x_contact_tbl     => l_processed_contacts
     , x_old_contact_tbl => l_old_contacts
     , x_primary_party_id         => l_sr_related_data.primary_party_id
     , x_primary_contact_point_id => l_sr_related_data.primary_contact_point_id
     , x_return_status   => l_return_status
     );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF; -- request update is allowed
   -- End of SR contact validation
    -- Logic to populate default contract based on default contract SLA indicator
    IF (l_contract_service_id_valid <> 'Y')
    THEN
      IF (p_default_contract_sla_ind <> 'Y' OR
          (p_service_request_rec.contract_service_id IS NOT NULL AND
           p_service_request_rec.contract_service_id <> FND_API.G_MISS_NUM)
         )
      THEN
        FND_MESSAGE.set_name ('CS', 'CS_SR_CONTRACT_INVALID');
        FND_MESSAGE.set_token('API_NAME', 'CS_SERVICEREQUEST_UTIL.contracts_cross_val' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  /***************************************************************
    This is a tempopary solution for Depot Repair team to get the site_use_id
    if the site_id is passed from the SR form and the validation level is none
    **********************************************/
IF ( p_validation_level = FND_API.G_VALID_LEVEL_NONE ) THEN
  IF ( nvl(p_service_request_rec.bill_to_site_id,-99) <> nvl(l_old_ServiceRequest_rec.bill_to_site_id,-99))
  AND p_service_request_rec.bill_to_site_id <> FND_API.G_MISS_NUM THEN

    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => 'Get bill to site use id',
        p_parameter_name      => 'Bill_To Site ',
        p_bill_to_site_id     => p_service_request_rec.bill_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.bill_to_party_id,
        p_site_use_type       => 'BILL_TO',
        x_site_use_id         => l_service_request_rec.bill_to_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The defaulted value of parameter bill_to_site_use_id :'
      || l_service_request_rec.bill_to_site_use_id
      );
    END IF;
  ELSIF  (p_service_request_rec.bill_to_site_id = FND_API.G_MISS_NUM) OR
     (NVL(p_service_request_rec.bill_to_site_id, -99) = NVL(l_old_ServiceRequest_rec.bill_to_site_id, -99))  THEN
      l_service_request_rec.bill_to_site_use_id := l_old_ServiceRequest_rec.bill_to_site_use_id;
      l_service_request_rec.bill_to_site_id := l_old_ServiceRequest_rec.bill_to_site_id;
  ELSIF  (p_service_request_rec.bill_to_site_id IS NULL ) THEN
          l_service_request_rec.bill_to_site_use_id :=NULL;
  END IF;

  IF ( nvl(p_service_request_rec.ship_to_site_id,-99) <> nvl(l_old_ServiceRequest_rec.ship_to_site_id,-99))
  AND p_service_request_rec.ship_to_site_id <> FND_API.G_MISS_NUM THEN

    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => 'Get ship to site use id',
        p_parameter_name      => 'Ship_To Site ',
        p_bill_to_site_id     => p_service_request_rec.ship_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.ship_to_party_id,
        p_site_use_type       => 'SHIP_TO',
        x_site_use_id         => l_service_request_rec.ship_to_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The defaulted value of parameter ship_to_site_use_id :'
      || l_service_request_rec.ship_to_site_use_id
      );
    END IF;
  ELSIF  (p_service_request_rec.ship_to_site_id = FND_API.G_MISS_NUM) OR
     (NVL(p_service_request_rec.ship_to_site_id, -99) = NVL(l_old_ServiceRequest_rec.ship_to_site_id, -99))  THEN
      l_service_request_rec.ship_to_site_use_id := l_old_ServiceRequest_rec.ship_to_site_use_id;
      l_service_request_rec.ship_to_site_id := l_old_ServiceRequest_rec.ship_to_site_id;
  ELSIF  (p_service_request_rec.ship_to_site_id IS NULL ) THEN
          l_service_request_rec.ship_to_site_use_id :=NULL;
  END IF;

  IF (nvl(p_service_request_rec.install_site_id,-99)<> nvl(l_old_ServiceRequest_rec.install_site_id,-99))
  AND p_service_request_rec.install_site_id <> FND_API.G_MISS_NUM THEN
      l_service_request_rec.install_site_use_id:=
                                          p_service_request_rec.install_site_id;
  ELSIF  (p_service_request_rec.install_site_id = FND_API.G_MISS_NUM) OR
     (NVL(p_service_request_rec.install_site_id, -99) = NVL(l_old_ServiceRequest_rec.install_site_id, -99))  THEN
      l_service_request_rec.install_site_use_id := l_old_ServiceRequest_rec.install_site_use_id;
      l_service_request_rec.install_site_id := l_old_ServiceRequest_rec.install_site_id;
  ELSIF  (p_service_request_rec.install_site_id IS NULL ) THEN
          l_service_request_rec.install_site_use_id :=NULL;
  END IF;
END IF;

/********************************************************************
Changes for depot reapi finished, need to remove all this for 115.10
***********************************************************************/


   --------UWQ for 11.5.6 Enhancement --------
   -- at this point during update p_Service_request_rec may have g_miss_num for
   -- severity_id but l_service_request_rec will have valid value for severity_id
   -- as this would have been populated by update_sr_validation procedure
   -- so i am using l_service_request_rec instead of p_service_request_rec
   l_imp_level := Get_Importance_Level(l_service_request_rec.severity_id);
   l_imp_level_old := Get_Old_Importance_level(p_request_id);
   l_old_owner_id := Get_Owner_id(p_request_id);

     --select the l_title from jtf_objects_vl
     l_title := Get_Title('SR');

    IF (l_service_request_rec.last_update_channel in ('PHONE', 'AGENT')  AND
        (l_imp_level_old <> 1 OR l_imp_level_old = 1) AND
        l_imp_level=1 AND
        l_service_request_rec.owner_id IS NOT NULL AND
        l_service_request_rec.owner_id <> l_old_owner_id AND
        l_service_request_rec.owner_id <> FND_API.G_MISS_NUM) THEN
        l_uwq_body2 := Get_Message(p_uwq_msg_notification);
        l_send_uwq_notification := TRUE;
     ELSIF (l_service_request_rec.last_update_channel in ('PHONE', 'AGENT')  AND
            l_imp_level_old <>1 AND
            l_imp_level=1 AND
            l_service_request_rec.owner_id IS NOT NULL AND
            l_service_request_rec.owner_id = l_old_owner_id AND
            l_service_request_rec.owner_id <> FND_API.G_MISS_NUM)
        OR  (l_service_request_rec.last_update_channel = 'WEB' AND
             (l_imp_level =1 OR l_imp_level =2) AND
             l_service_request_rec.owner_id IS NOT NULL AND
             l_service_request_rec.owner_id <> FND_API.G_MISS_NUM)
     THEN
            l_uwq_body2 := Get_Message(p_uwq_upd_notification);
            l_send_uwq_notification := TRUE;
     END IF;

      l_uwq_body := l_title ||' '|| l_old_ServiceRequest_rec.incident_number ||'
 '|| l_uwq_body2 ||' '||to_char(SYSDATE,'MM/DD/YYYY HH24:MI:SS'); --with time;

    IF l_send_uwq_notification THEN
         IEU_MSG_PRODUCER_PUB.Send_Plain_text_Msg (
          p_api_version      => 1.0,
          p_init_msg_list    => fnd_api.g_false,
          p_commit           => fnd_api.g_false,
          p_application_id   => 170,
          p_resource_id      => l_service_request_rec.owner_id,
          p_resource_type    => l_service_request_rec.resource_type,
          p_title            => l_title,
          p_body             => l_uwq_body,
          p_workitem_obj_code=> 'SR',
          p_workitem_pk_id   => p_request_id,
          x_message_id       => l_msg_id,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data );
    END IF;

   /* Added call to get_status_flag for enh 2655115, to get the status flag
      based on the closed flag by shijain date 27th nov 2002 */

-- for the bug 3050727
   --   l_status_flag:= get_status_flag ( l_service_request_rec.status_id);


  --*************************************************
  --Adding this code,(12th July 2000) so that workflow can call Update Service Request
  --instead of calling this Create Audit api.

  --Get the workflow process name associted to the service request type
  --IF called by workflow then do this :

/****************************************
   commenting out code; this is no longer needed as the WF will directly do
   an update on the SR's workflow_process_id and not call the SR Update API.

  IF (FND_API.To_Boolean(p_called_by_workflow) = TRUE) THEN
    SELECT workflow INTO l_workflow_process_name
    FROM  cs_incident_types_b
    WHERE incident_type_id = l_service_request_rec.type_id
    AND   incident_subtype = G_SR_SUBTYPE
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
    AND     TRUNC(NVL(end_date_active, SYSDATE));
    ---Build the workflow process item key.
    l_wf_process_itemkey  := l_old_ServiceRequest_rec.incident_number  || '-' || TO_CHAR(p_workflow_process_id) ;

    --  Changed for audit l_change_flags_rec.new_workflow   := FND_API.G_TRUE; --- check for audit
    l_audit_vals_rec.new_workflow_flag   := 'Y'; --- check for audit

    --Call Upadte SR without incrementing the object version number(only for lauch workflow)
    --Put this code because from the form side, if record was queried
    --with object version as 2 and then Launch workflow was called with
    --Update  Sr then, if object version is incremented to 3 , then
    --cannot update any other attributes displayed on the Sr form, since
    --SR form had already locked the record with object version as 2.

    UPDATE cs_incidents_all_b
    SET workflow_process_id  = p_workflow_process_id
    WHERE ROWID = l_old_ServiceRequest_rec.ROW_ID   ;

  ELSE
commenting out code; this is no longer needed as the WF will directly do
an update on the SR's workflow_process_id and not call the SR Update API.
***********************************************/

       -- Code Changes for 11.5.10 Auto Close SR project
       -- For bug 3332985
 IF l_sr_related_data.old_close_flag = 'N' AND
    l_sr_related_data.close_flag     = 'Y'
 THEN
   -- it means an open service request is being close, so check if SR can be closed
   -- and then close all SR child entities
   --
   -- This validation happens irrespective of ERES flag
   IF ( p_validate_sr_closure = 'Y' OR p_validate_sr_closure = 'y') THEN
      CS_SR_STATUS_PROPAGATION_PKG.VALIDATE_SR_CLOSURE(
              p_api_version        => p_api_version,
              p_init_msg_list      => fnd_api.g_false ,
              p_commit             => FND_API.G_FALSE,
              p_service_request_id => p_request_id,
              p_user_id            => l_service_request_rec.last_updated_by,
              p_resp_appl_id       => p_resp_appl_id,
              p_login_id           => l_service_request_rec.last_update_login,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count ,
              x_msg_data           => l_msg_data);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;
   IF l_start_eres_flag = 'N'
   THEN
     -- Child entities will be close only for Non ERES flow.
     -- For ERES flow child entities may get closed if ERES returns NO_ACTION
     -- or in separate transaction when ERES approval comes in.
     IF (p_auto_close_child_entities='Y' OR p_auto_close_child_entities='y') THEN
       CS_SR_STATUS_PROPAGATION_PKG.CLOSE_SR_CHILDREN
       ( p_api_version         => p_api_version
       , p_init_msg_list       => fnd_api.g_false
       , p_commit              => FND_API.G_FALSE
       , p_validation_required => 'N'
       , p_action_required     => 'Y'
       , p_service_request_id  => p_request_id
       , p_user_id             => l_service_request_rec.last_updated_by
       , p_resp_appl_id        => p_resp_appl_id
       , p_login_id            => l_service_request_rec.last_update_login
       , x_return_status       => l_return_status
       , x_msg_count           => l_msg_count
       , x_msg_data            => l_msg_data
       );
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;
   END IF;  -- l_start_eres_flag = 'N' condition
 END IF;  -- if old_close_flag ='N' and close_flag = 'Y' condition
   -- This is to be executed only for ERES update. For non eres updates
   -- this procedure is called from servicerequest_cross_val procedure.
   IF l_start_eres_flag = 'Y'
   THEN
     CS_SERVICEREQUEST_UTIL.task_restrict_close_cross_val
     ( p_incident_id   => p_request_id
     , p_status_id     => l_sr_related_data.target_status_id
     , x_return_status => l_return_status
     );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   -- End of  Code Changes for 11.5.10 Auto Close SR project

   -- Replace old code with get_reacted_resolved_dates
   -- if eres is being processed i.e. l_start_eres_flag = 'Y' then that intermediate status
   -- cannot have resolved, responded flags as 'Y'. so no need to attempt to default
   -- resolved and responded by dates.
   IF l_start_eres_flag = 'N'
   THEN
     CS_SERVICEREQUEST_UTIL.get_reacted_resolved_dates
     ( p_incident_status_id         => l_service_request_rec.status_id
     , p_old_incident_status_id     => l_old_servicerequest_rec.incident_status_id
     , p_old_incident_resolved_date => l_old_servicerequest_rec.incident_resolved_date
     , p_old_inc_responded_by_date  => l_old_servicerequest_rec.inc_responded_by_date
     , x_inc_responded_by_date      => l_service_request_rec.inc_responded_by_date
     , x_incident_resolved_date     => l_service_request_rec.incident_resolved_date
     , x_return_status              => l_return_status
     );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF; -- l_start_eres_flag = 'N'

   IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
   THEN
     FND_LOG.String
     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
     , 'The defaulted value of parameter inc_responded_by_date :'
     || l_service_request_rec.inc_responded_by_date
     );
     FND_LOG.String
     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
     , 'The defaulted value of parameter incident_resolved_date :'
     || l_service_request_rec.incident_resolved_date
     );
   END IF;

  -- End of usability changes .


  -- Code Changes for setting unassigned_indicator
  /* l_service_request should be used not the p_service_request. if values are not changed
     then p_service rec will have g_miss_num only and it will cause wrong value for unassigned ind
     l_service rec will have the values going to database. so it is the correct rec to be used
  smisra 11/30/2004
  ********************************************************************************************/
        IF (l_service_request_rec.owner_id  <> FND_API.G_MISS_NUM  AND
            l_service_request_rec.owner_id IS NOT NULL ) AND
           (l_service_request_rec.owner_group_id  <> FND_API.G_MISS_NUM  AND
            l_service_request_rec.owner_group_id IS NOT NULL ) THEN
            l_unassigned_indicator := 3 ;
        ELSIF (l_service_request_rec.owner_id  <> FND_API.G_MISS_NUM  AND
            l_service_request_rec.owner_id IS  NOT NULL ) AND
           (l_service_request_rec.owner_group_id  = FND_API.G_MISS_NUM  OR
            l_service_request_rec.owner_group_id IS NULL ) THEN
            l_unassigned_indicator := 1 ;
        ELSIF (l_service_request_rec.owner_id  = FND_API.G_MISS_NUM  OR
            l_service_request_rec.owner_id IS  NULL ) AND
           (l_service_request_rec.owner_group_id  <> FND_API.G_MISS_NUM  AND
            l_service_request_rec.owner_group_id IS NOT NULL ) THEN
            l_unassigned_indicator := 2 ;
        ELSE
            l_unassigned_indicator := 0 ;
        END IF;

      -- Fix to bug # 2520816.
      -- Setting the value for l_contra_id and l_contract_number to the existing values
      -- in the db, if they have not been passed to the update API, or have not been
      -- assigned values thru the 'validate_contract_id' and 'validate_contract_service_id'
      -- procedures.
-- Start of changes by aneemuch, 16-Oct-2003
-- To fix bug 3137011, Update_servicerequest api causes contracts column to null values

      --if ( l_contra_id = FND_API.G_MISS_NUM ) THEN
      --   l_contra_id := l_old_servicerequest_rec.contract_id;
      --end if;
      --if ( l_contract_number = FND_API.G_MISS_CHAR ) THEN
      --   l_contract_number := l_old_servicerequest_rec.contract_number;
      --end if;

      -- contracts : 3224828 - remove the call to validate_contract_Service_id
      -- These five lines are change due to default contract SLA in update
      --IF  (( l_contra_id = FND_API.G_MISS_NUM ) OR (l_contra_id IS NULL)) THEN
      --  IF p_service_request_rec.contract_service_id = FND_API.G_MISS_NUM THEN
      --     l_contra_id := l_old_servicerequest_rec.contract_id;
      --     l_contract_number := l_old_servicerequest_rec.contract_number;
      --  ELSIF p_service_request_rec.contract_service_id is null THEN

      IF  (( l_contra_id = FND_API.G_MISS_NUM ) OR (l_contra_id IS NULL)) THEN
        IF l_service_request_rec.contract_service_id = l_old_servicerequest_rec.contract_service_id THEN
           l_contra_id := l_old_servicerequest_rec.contract_id;
           l_contract_number := l_old_servicerequest_rec.contract_number;
        ELSIF l_service_request_rec.contract_service_id is null THEN
           l_contra_id := null;
           l_contract_number := NULL;
       /* ELSE
           CS_ServiceRequest_UTIL.Validate_Contract_Service_Id(
                  p_api_name         => l_api_name,
                  p_parameter_name   => 'contract_service_id',
                  p_contract_service_id => p_service_request_rec.contract_service_id,
                  x_contract_id      =>l_contra_id,
                  x_contract_number  =>l_contract_number,
                  x_return_status    => l_return_status);

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
          END IF;  */
        END IF ;
      END IF;
     -- update contract attributes in audit
     l_audit_vals_rec.old_contract_number     := l_old_ServiceRequest_rec.contract_number;
     l_audit_vals_rec.old_contract_id         := l_old_ServiceRequest_rec.contract_id;
     l_audit_vals_rec.old_contract_service_id := l_old_ServiceRequest_rec.contract_service_id;
     l_audit_vals_rec.old_coverage_type       := l_old_ServiceRequest_rec.coverage_type;
     -- New contract Values
     l_audit_vals_rec.contract_number     := l_contract_number;
     l_audit_vals_rec.contract_id         := l_contra_id;
     l_audit_vals_rec.contract_service_id := l_service_request_rec.contract_service_id;
     l_audit_vals_rec.coverage_type       := l_service_request_rec.coverage_type;
     l_audit_vals_rec.maint_organization_id     := l_service_request_rec.maint_organization_id;
     l_audit_vals_rec.old_maint_organization_id := l_old_servicerequest_rec.maint_organization_id;
     l_audit_vals_rec.inventory_item_id         := l_service_request_rec.inventory_item_id;
     l_audit_vals_rec.old_inventory_item_id     := l_old_servicerequest_rec.inventory_item_id;


      -- Assign owner, group to output record
     x_sr_update_out_rec.individual_owner := l_service_request_rec.owner_id;
     x_sr_update_out_rec.group_owner      := l_service_request_rec.owner_group_id;
     x_sr_update_out_rec.individual_type  := l_service_request_rec.resource_type;

-- end of changes by aneemuch, 16-Oct-2003
-- Assign owner, group to output record
     x_sr_update_out_rec.individual_owner := l_service_request_rec.owner_id;
     x_sr_update_out_rec.group_owner      := l_service_request_rec.owner_group_id;
     x_sr_update_out_rec.individual_type  := l_service_request_rec.resource_type;

   -- Start of change , Sanjana Rao , bug 6955756
     IF (l_service_request_rec.owner_id = FND_API.G_MISS_NUM) OR
     NVL(l_service_request_rec.owner_id,-99) = NVL(l_old_ServiceRequest_rec.incident_owner_id,-99)
    THEN
      IF (l_service_request_rec.owner_assigned_time = FND_API.G_MISS_DATE) OR
         (l_service_request_rec.owner_assigned_time IS NULL AND
         l_old_ServiceRequest_rec.owner_assigned_time IS NULL) OR
        (l_service_request_rec.owner_assigned_time = l_old_ServiceRequest_rec.owner_assigned_time)
     THEN
       l_service_request_rec.owner_assigned_time   := l_old_ServiceRequest_rec.owner_assigned_time;

     END IF;
   ELSE
     IF (l_service_request_rec.owner_assigned_time = FND_API.G_MISS_DATE) OR
      (l_service_request_rec.owner_assigned_time IS NULL AND
      l_old_ServiceRequest_rec.owner_assigned_time IS NULL) OR
     (l_service_request_rec.owner_assigned_time = l_old_ServiceRequest_rec.owner_assigned_time)
     THEN

      l_service_request_rec.owner_assigned_time   := SYSDATE;
      END IF;
    END IF;

--End of change , Sanjana Rao, bug 6955756

    ---------------------------------------------------------------------
    -- start of code for onetime address creation
    --siahmed check to see if we need to update onetime address creation
    --there is only 2 scenarios when we need to call the update service onetime address

      -------------------------------------------------------
  --siahmed start of code for creating onetime address
     --check if created by module = 'SR_ONETIME'
   /*
     SELECT count(party_site_id) into l_onetime_add_cnt
     FROM hz_party_sites
     WHERE party_site_id = l_service_request_rec.incident_location_id
     AND created_by_module = 'SR_ONETIME';
   */
    IF ((l_service_request_rec.incident_location_id IS NULL ) AND
           ((l_service_request_rec.incident_address  IS NOT null) OR
           (l_service_request_rec.incident_address2 IS NOT null) OR
           (l_service_request_rec.incident_address3 IS NOT null) OR
           (l_service_request_rec.incident_address4 IS NOT null) OR
           (l_service_request_rec.incident_city     IS NOT null) OR
           (l_service_request_rec.incident_state    IS NOT null) OR
           (l_service_request_rec.incident_postal_code IS NOT null) OR
           (l_service_request_rec.incident_county   IS NOT null) OR
           (l_service_request_rec.incident_province IS NOT null) OR
           (l_service_request_rec.incident_country  IS NOT null) OR
           (l_service_request_rec.site_name   IS NOT NULL) OR
           (l_service_request_rec.site_number IS NOT NULL) OR
           (l_service_request_rec.addressee   IS NOT NULL))) THEN
           --call create onetime address creation procedure
           CREATE_ONETIME_ADDRESS   (
             p_service_req_rec   =>  l_service_request_rec,
             x_msg_count         =>  l_msg_count,
             x_msg_data          =>  l_msg_data,
             x_return_status     =>  l_return_status_onetime,
             x_location_id       =>  l_incident_location_id
           );

           IF (l_return_status_onetime <> FND_API.G_RET_STS_SUCCESS) THEN
	   --start changes for bug 8545879
	      l_service_request_rec.incident_location_id := l_old_servicerequest_rec.incident_location_id;
	      l_service_request_rec.incident_location_type := l_old_servicerequest_rec.incident_location_type;
	      x_sr_update_out_rec.incident_location_id := l_old_servicerequest_rec.incident_location_id;
	   --end changes for bug 8545879
              FND_MESSAGE.Set_Name('CS', 'CS_SR_ONETIME_CREATE_ERROR');
              FND_MESSAGE.Set_Token('API_NAME', l_api_name||'CREATE_ONETIME_ADDRESS');
              FND_MSG_PUB.ADD;

           ELSIF (l_return_status_onetime = FND_API.G_RET_STS_SUCCESS) THEN
              --so that the new party_site_id gets stamped in the cs_incidents_all_b table
              l_service_request_rec.incident_location_id := l_incident_location_id;
              l_service_request_rec.incident_location_type := 'HZ_PARTY_SITE';
              --stamp the out rec type with the incident location_id
              x_sr_update_out_rec.incident_location_id := l_incident_location_id;

           END IF;
              --set the variables to null so that they dont get stored in the incidents table
              l_service_request_rec.incident_address  := null;
              l_service_request_rec.incident_address2 := null;
              l_service_request_rec.incident_address3 := null;
              l_service_request_rec.incident_address4 := null;
              l_service_request_rec.incident_city     := null;
              l_service_request_rec.incident_state    := null;
              l_service_request_rec.incident_postal_code := null;
              l_service_request_rec.incident_county   := null;
              l_service_request_rec.incident_province := null;
              l_service_request_rec.incident_country  := null;
	      --added for the bug fix 8563365
              l_service_request_rec.incident_addr_lines_phonetic := null;
              l_service_request_rec.incident_postal_plus4_code := null;
              --end of addition for the bug fix 8563365
          --END IF;

    ELSIF (l_service_request_rec.incident_location_id = l_old_servicerequest_rec.incident_location_id) THEN
	IF (G_ONETIME_ADD_CNT >= 1) THEN

          --call update address procedure
           UPDATE_ONETIME_ADDRESS (
             p_service_req_rec     =>  l_service_request_rec,
             x_msg_count           =>  l_msg_count,
             x_msg_data            =>  l_msg_data,
             x_return_status       =>  l_return_status_onetime
           );

           IF (l_return_status_onetime <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.Set_Name('CS', 'CS_SR_ONETIME_UPDATE_ERROR');
              FND_MESSAGE.Set_Token('API_NAME', l_api_name||'UPDATE_ONETIME_ADDRESS');
              FND_MSG_PUB.ADD;

           ELSIF (l_return_status_onetime = FND_API.G_RET_STS_SUCCESS) THEN
              l_service_request_rec.incident_location_type := 'HZ_PARTY_SITE';
           END IF;
        END IF;
              --set the variables to null so that they dont get stored in the incidents table
              l_service_request_rec.incident_address  := null;
              l_service_request_rec.incident_address2 := null;
              l_service_request_rec.incident_address3 := null;
              l_service_request_rec.incident_address4 := null;
              l_service_request_rec.incident_city     := null;
              l_service_request_rec.incident_state    := null;
              l_service_request_rec.incident_postal_code := null;
              l_service_request_rec.incident_county   := null;
              l_service_request_rec.incident_province := null;
              l_service_request_rec.incident_country  := null;
              --added for the bug fix 8563365
              l_service_request_rec.incident_addr_lines_phonetic := null;
              l_service_request_rec.incident_postal_plus4_code := null;
              --end of addition for the bug fix 8563365



      -- if old incident_location_id is not equal to new incident location id
      -- and the new incident location id of not created by SR_ONETIME then
      -- we should not update the incident location id with the new incident location id
      -- rathre we should null the incident location id in that case
      ELSIF (l_service_request_rec.incident_location_id <> l_old_servicerequest_rec.incident_location_id) THEN

	    IF (G_ONETIME_ADD_CNT >= 1) THEN
		--The current incident address shall not be made null
                --l_service_request_rec.incident_location_id := null;
		l_service_request_rec.incident_location_id := l_old_servicerequest_rec.incident_location_id;
		--Fix for bug 8594093
		l_service_request_rec.incident_location_type := l_old_servicerequest_rec.incident_location_type;
                l_service_request_rec.incident_address  := l_old_servicerequest_rec.incident_address;
                l_service_request_rec.incident_address2 := l_old_servicerequest_rec.incident_address2;
                l_service_request_rec.incident_address3 := l_old_servicerequest_rec.incident_address3;
                l_service_request_rec.incident_address4 := l_old_servicerequest_rec.incident_address4;
                l_service_request_rec.incident_city     := l_old_servicerequest_rec.incident_city;
                l_service_request_rec.incident_state    := l_old_servicerequest_rec.incident_state;
                l_service_request_rec.incident_postal_code := l_old_servicerequest_rec.incident_postal_code;
                l_service_request_rec.incident_county   := l_old_servicerequest_rec.incident_county;
                l_service_request_rec.incident_province := l_old_servicerequest_rec.incident_province;
                l_service_request_rec.incident_country  := l_old_servicerequest_rec.incident_country;
                l_service_request_rec.incident_addr_lines_phonetic := l_old_servicerequest_rec.incident_addr_lines_phonetic;
                l_service_request_rec.incident_postal_plus4_code := l_old_servicerequest_rec.incident_postal_plus4_code;
		--End of changes for bug 8594093
		FND_MESSAGE.Set_Name('CS', 'CS_SR_INVALID_INCIDENT_ADDRESS');
                FND_MESSAGE.Set_Token('API_NAME', l_api_name||'CREATE_INCIDENT_ADDRESS');
                FND_MSG_PUB.ADD;

            END IF;
      END IF;


    --end of addition by siahmed for update onetime address
    ---------------------------------------------------------------------
     ---Update for all cases.
     UPDATE cs_incidents_all_b
     SET incident_status_id             = l_service_request_rec.status_id,
	 incident_type_id               = l_service_request_rec.type_id,
         incident_urgency_id            = l_service_request_rec.urgency_id,
         incident_severity_id           = l_service_request_rec.severity_id,
         incident_owner_id              = l_service_request_rec.owner_id,
	 resource_type                  = l_service_request_rec.resource_type,
--	 resource_subtype_id            = l_service_request_rec.resource_subtype_id, For BUG 2748584
         inventory_item_id              = l_service_request_rec.inventory_item_id,
         -- removed decode for 11.5.6 enhancement
         customer_id                    = l_service_request_rec.customer_id,
	 account_id                     = l_service_request_rec.account_id,
         current_serial_number          = l_service_request_rec.current_serial_number,
         expected_resolution_date       = l_service_request_rec.exp_resolution_date,
         actual_resolution_date         = l_service_request_rec.act_resolution_date,
         customer_product_id            = l_service_request_rec.customer_product_id,
         bill_to_site_use_id            = l_service_request_rec.bill_to_site_use_id,
         bill_to_contact_id             = l_service_request_rec.bill_to_contact_id,
         ship_to_site_use_id            = l_service_request_rec.ship_to_site_use_id,
         ship_to_contact_id             = l_service_request_rec.ship_to_contact_id,
         install_site_use_id            = l_service_request_rec.install_site_use_id,
         incident_attribute_1           = l_service_request_rec.request_attribute_1,
         incident_attribute_2           = l_service_request_rec.request_attribute_2,
         incident_attribute_3           = l_service_request_rec.request_attribute_3,
         incident_attribute_4           = l_service_request_rec.request_attribute_4,
         incident_attribute_5           = l_service_request_rec.request_attribute_5,
         incident_attribute_6           = l_service_request_rec.request_attribute_6,
         incident_attribute_7           = l_service_request_rec.request_attribute_7,
         incident_attribute_8           = l_service_request_rec.request_attribute_8,
         incident_attribute_9           = l_service_request_rec.request_attribute_9,
         incident_attribute_10          = l_service_request_rec.request_attribute_10,
         incident_attribute_11          = l_service_request_rec.request_attribute_11,
         incident_attribute_12          = l_service_request_rec.request_attribute_12,
         incident_attribute_13          = l_service_request_rec.request_attribute_13,
         incident_attribute_14          = l_service_request_rec.request_attribute_14,
         incident_attribute_15          = l_service_request_rec.request_attribute_15,
         incident_context               = l_service_request_rec.request_context,
         external_attribute_1           = l_service_request_rec.external_attribute_1,
         external_attribute_2           = l_service_request_rec.external_attribute_2,
         external_attribute_3           = l_service_request_rec.external_attribute_3,
         external_attribute_4           = l_service_request_rec.external_attribute_4,
         external_attribute_5           = l_service_request_rec.external_attribute_5,
         external_attribute_6           = l_service_request_rec.external_attribute_6,
         external_attribute_7           = l_service_request_rec.external_attribute_7,
         external_attribute_8           = l_service_request_rec.external_attribute_8,
         external_attribute_9           = l_service_request_rec.external_attribute_9,
         external_attribute_10          = l_service_request_rec.external_attribute_10,
         external_attribute_11          = l_service_request_rec.external_attribute_11,
         external_attribute_12          = l_service_request_rec.external_attribute_12,
         external_attribute_13          = l_service_request_rec.external_attribute_13,
         external_attribute_14          = l_service_request_rec.external_attribute_14,
         external_attribute_15          = l_service_request_rec.external_attribute_15,
         external_context               = l_service_request_rec.external_context,
         resolution_code                = l_service_request_rec.resolution_code,
         problem_code                   = l_service_request_rec.problem_code,
         original_order_number          = l_service_request_rec.original_order_number,
         purchase_order_num             = l_service_request_rec.purchase_order_num,
         close_date                     = l_service_request_rec.closed_date,
         publish_flag                   = l_service_request_rec.publish_flag,
         obligation_date                = l_service_request_rec.obligation_date,
         qa_collection_id               = l_service_request_rec.qa_collection_plan_id,
         contract_service_id            = l_service_request_rec.contract_service_id,
         contract_id                    = l_contra_id,
         contract_number                = l_contract_number,
         project_number                 = l_service_request_rec.project_number,
         customer_po_number             = l_service_request_rec.cust_po_number,
         customer_ticket_number         = l_service_request_rec.cust_ticket_number,
         time_zone_id                   = l_service_request_rec.time_zone_id,
         time_difference                = l_service_request_rec.time_difference,
         platform_id                    = l_service_request_rec.platform_id ,
	 platform_version		= l_service_request_rec.platform_version,
	 platform_version_id		= l_service_request_rec.platform_version_id,
	 db_version			= l_service_request_rec.db_version,
         cp_component_id                = l_service_request_rec.cp_component_id,
         cp_component_version_id        = l_service_request_rec.cp_component_version_id,
         cp_subcomponent_id             = l_service_request_rec.cp_subcomponent_id,
         cp_subcomponent_version_id     = l_service_request_rec.cp_subcomponent_version_id ,
         cp_revision_id                 = l_service_request_rec.cp_revision_id ,
         inv_item_revision              = l_service_request_rec.inv_item_revision ,
         inv_component_id               = l_service_request_rec.inv_component_id ,
         inv_component_version          = l_service_request_rec.inv_component_version,
         inv_subcomponent_id            = l_service_request_rec.inv_subcomponent_id ,
         inv_subcomponent_version       = l_service_request_rec.inv_subcomponent_version,
         site_id                        = l_service_request_rec.site_id,
	 customer_site_id               = l_service_request_rec.customer_site_id,
         territory_id                   = l_service_request_rec.territory_id,
         -- Added for enhancements---11.5.6------jngeorge-----
         cust_pref_lang_id              = l_service_request_rec.cust_pref_lang_id,
         comm_pref_code                 = l_service_request_rec.comm_pref_code,
         cust_pref_lang_code            = l_service_request_rec.cust_pref_lang_code,
         last_update_channel            = l_service_request_rec.last_update_channel,
         tier                           = l_service_request_rec.tier,
         tier_version                   = l_service_request_rec.tier_version,
         operating_system               = l_service_request_rec.operating_system,
         operating_system_version       = l_service_request_rec.operating_system_version,
         DATABASE                       = l_service_request_rec.DATABASE,
         category_id                    = l_service_request_rec.category_id,
         group_type                     = l_service_request_rec.group_type,
         owner_group_id                 = l_service_request_rec.owner_group_id,
         group_territory_id             = l_service_request_rec.group_territory_id,
         owner_assigned_time            = l_service_request_rec.owner_assigned_time,
         owner_assigned_flag            = l_service_request_rec.owner_assigned_flag,
         unassigned_indicator           = l_unassigned_indicator,
         inv_platform_org_id            = l_service_request_rec.inv_platform_org_id,
         product_revision               = l_service_request_rec.product_revision,
         component_version              = l_service_request_rec.component_version,
         subcomponent_version           = l_service_request_rec.subcomponent_version,
         category_set_id                = l_service_request_rec.category_set_id,
         external_reference             = l_service_request_rec.external_reference,
         system_id                      = l_service_request_rec.system_id,
         error_code                     = l_service_request_rec.error_code,
         incident_occurred_date         = l_service_request_rec.incident_occurred_date,
         incident_resolved_date         = l_service_request_rec.incident_resolved_date,
         inc_responded_by_date          = l_service_request_rec.inc_responded_by_date,
         incident_location_id           = l_service_request_rec.incident_location_id ,
         incident_address               = l_service_request_rec.incident_address ,
         incident_city                  = l_service_request_rec.incident_city,
         incident_state                 = l_service_request_rec.incident_state,
         incident_country               = l_service_request_rec.incident_country,
         incident_province              = l_service_request_rec.incident_province ,
         incident_postal_code           = l_service_request_rec.incident_postal_code ,
         incident_county                = l_service_request_rec.incident_county,
         sr_creation_channel            = l_service_request_rec.sr_creation_channel,
         -- Added for ER# 2320056
         coverage_type                  = l_service_request_rec.coverage_type,
         -- Added for ER#2433831
         bill_to_account_id             = l_service_request_rec.bill_to_account_id,
         ship_to_account_id             = l_service_request_rec.ship_to_account_id,
         -- Added for ER#2463321
         customer_phone_id              = l_service_request_rec.customer_phone_id,
         customer_email_id              = l_service_request_rec.customer_email_id,
         -- Added for source cahnges for 1159 shijain oct 11 2002
         last_update_program_code       = l_service_request_rec.last_update_program_code,
         last_updated_by                = l_service_request_rec.last_updated_by,
         last_update_login              = l_service_request_rec.last_update_login,
         last_update_date               = l_service_request_rec.last_update_date,
         bill_to_party_id               = l_service_request_rec.bill_to_party_id,
         ship_to_party_id               = l_service_request_rec.ship_to_party_id,
         -- Conc request related fields
         program_id                     = l_service_request_rec.program_id,
         program_application_id         = l_service_request_rec.program_application_id,
         request_id                = l_service_request_rec.conc_request_id,
         program_login_id               = l_service_request_rec.program_login_id,
         -- Bill_to_site, ship_to_site
         bill_to_site_id                = l_service_request_rec.bill_to_site_id,
         ship_to_site_id                = l_service_request_rec.ship_to_site_id,
         -- Added for enh. 2655115
         -- for bug 3050727
         status_flag                    = l_service_request_rec.status_flag,
	 object_version_number          = p_object_version_number+1,
         -- Added these address columns by shijain 2002 5th dec
         incident_point_of_interest=l_service_request_rec.incident_point_of_interest,
         incident_cross_street=l_service_request_rec.incident_cross_street,
         incident_direction_qualifier=l_service_request_rec.incident_direction_qualifier,
         incident_distance_qualifier=l_service_request_rec.incident_distance_qualifier,
         incident_distance_qual_uom  =l_service_request_rec.incident_distance_qual_uom,
         incident_address2  =l_service_request_rec.incident_address2 ,
         incident_address3=l_service_request_rec.incident_address3 ,
         incident_address4=l_service_request_rec.incident_address4  ,
         incident_address_style=l_service_request_rec.incident_address_style ,
         incident_addr_lines_phonetic =l_service_request_rec.incident_addr_lines_phonetic ,
         incident_po_box_number =l_service_request_rec.incident_po_box_number ,
         incident_house_number =l_service_request_rec.incident_house_number,
         incident_street_suffix =l_service_request_rec.incident_street_suffix,
         incident_street =l_service_request_rec.incident_street,
         incident_street_number =l_service_request_rec.incident_street_number,
         incident_floor=l_service_request_rec.incident_floor,
         incident_suite =l_service_request_rec.incident_suite ,
         incident_postal_plus4_code =l_service_request_rec.incident_postal_plus4_code,
         incident_position =l_service_request_rec.incident_position ,
         incident_location_directions=l_service_request_rec.incident_location_directions,
         incident_location_description =l_service_request_rec.incident_location_description ,
         install_site_id =l_service_request_rec.install_site_id ,
         inv_organization_id= l_service_request_rec.inventory_org_id,
         -- for cmro_eam
         owning_department_id = l_service_request_rec.owning_dept_id,
         --end for cmro_eam
         -- Added for Misc ERs project of 11.5.10 --anmukher --08/26/03
         incident_location_type = l_service_request_rec.incident_location_type,
         --Added for Auditing project of 11.5.10 --anmukher --09/05/03
         incident_last_modified_date = sysdate,
         maint_organization_id = l_service_request_rec.maint_organization_id,
/* Credit Card 9358401 */
         instrument_payment_use_id  =
	                         l_service_request_rec.instrument_payment_use_id
   WHERE ROWID = l_old_ServiceRequest_rec.ROW_ID   ;
	    --for performance reason

--  END IF;

-- Start of changes by aneemuch 28-Oct-2004
-- Changes for interMedia index, need to update text_index column only when incident_type_id,
-- inventory_item_id, or summary column has changed. This is required in order to rebuild index for that
-- particular record when interMedia sync conc program is run.

   IF  l_service_request_rec.type_id <> l_old_servicerequest_rec.incident_type_id
     OR NVL(l_service_request_rec.inventory_item_id,-99) <> NVL(l_old_servicerequest_rec.inventory_item_id,-99)
     OR l_service_request_rec.summary <> l_old_servicerequest_rec.summary THEN

     UPDATE cs_incidents_all_tl
     SET    summary                     = l_service_request_rec.summary,
            resolution_summary          = l_service_request_rec.resolution_summary,
            last_update_date            = l_service_request_rec.last_update_date,
            last_updated_by             = l_service_request_rec.last_updated_by,
            last_update_login           = l_service_request_rec.last_update_login,
            source_lang                 = userenv('LANG'), --l_service_request_rec.LANGUAGE,
            text_index                  = 'A'
     WHERE incident_id                  = p_request_id
     AND   userenv('LANG') IN (LANGUAGE, source_lang);

   ELSE

     UPDATE cs_incidents_all_tl
     SET    summary                     = l_service_request_rec.summary,
            resolution_summary          = l_service_request_rec.resolution_summary,
            last_update_date            = l_service_request_rec.last_update_date,
            last_updated_by             = l_service_request_rec.last_updated_by,
            last_update_login           = l_service_request_rec.last_update_login,
            source_lang                 = userenv('LANG') --l_service_request_rec.LANGUAGE
     WHERE incident_id                  = p_request_id
     AND   userenv('LANG') IN (LANGUAGE, source_lang);
   END IF;

-- For bug 3512696 - modified to point the source lang to be updated with userenv('LANG');

--  UPDATE cs_incidents_all_tl
--  SET    summary                     = l_service_request_rec.summary,
--         resolution_summary          = l_service_request_rec.resolution_summary,
--         owner                       = l_service_request_rec.owner,
--         group_owner                 = l_service_request_rec.group_owner,
--         last_update_date            = l_service_request_rec.last_update_date,
--         last_updated_by             = l_service_request_rec.last_updated_by,
--         last_update_login           = l_service_request_rec.last_update_login,
--         source_lang                 = userenv('LANG') --l_service_request_rec.LANGUAGE
--  WHERE incident_id                  = p_request_id
--  AND   userenv('LANG') IN (LANGUAGE, source_lang);

-- End of changes by aneemuch 28-Oct-2004
-- Changes for interMedia index

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Added for 11.5.10 Auditing project --anmukher --09/15/03
  -- Added these assignments here as these values are not available in Update_SR_Validation

  /* These are not correct. if old value is null then else condition will get executed and
     wrong value will go to new value col in audit rec
     These are already set before update to cs_incidents_all_b table
     smisra: 29th nov 2004
  l_audit_vals_rec.OLD_CONTRACT_ID		:= l_old_ServiceRequest_rec.CONTRACT_ID;
  IF (l_contra_id <> FND_API.G_MISS_NUM) AND
    (l_contra_id <> l_old_ServiceRequest_rec.CONTRACT_ID) THEN
    l_audit_vals_rec.CONTRACT_ID		:= l_contra_id;
  ELSE
    l_audit_vals_rec.CONTRACT_ID		:= l_old_ServiceRequest_rec.CONTRACT_ID;
  END IF;

  l_audit_vals_rec.OLD_CONTRACT_NUMBER		:= l_old_ServiceRequest_rec.CONTRACT_NUMBER;
  IF (l_contract_number <> FND_API.G_MISS_CHAR) AND
    (l_contract_number <> l_old_ServiceRequest_rec.CONTRACT_NUMBER) THEN
    l_audit_vals_rec.CONTRACT_NUMBER		:= l_contract_number;
  ELSE
    l_audit_vals_rec.CONTRACT_NUMBER		:= l_old_ServiceRequest_rec.CONTRACT_NUMBER;
  END IF;
  *******************************************/

  l_audit_vals_rec.OLD_UNASSIGNED_INDICATOR	:= l_old_ServiceRequest_rec.UNASSIGNED_INDICATOR;
  IF (l_unassigned_indicator <> FND_API.G_MISS_NUM) AND
    (l_unassigned_indicator <> l_old_ServiceRequest_rec.unassigned_indicator) THEN
    l_audit_vals_rec.UNASSIGNED_INDICATOR		:= l_unassigned_indicator;
  ELSE
    l_audit_vals_rec.UNASSIGNED_INDICATOR		:= l_old_ServiceRequest_rec.UNASSIGNED_INDICATOR;
  END IF;



-- for the bug 3027154 - moved the create_audit_record inside the if condition
-- END IF; /* only_status_update_flag check*/


END IF; /* only_status_update_flag check */


 ---- Call to Enqueue API if it is in maintenance Mode

     FND_PROFILE.get('APPS_MAINTENANCE_MODE', l_maintenance_mode);

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The Value of profile APPS_MAINTENANCE_MODE :' || l_maintenance_mode
    );
  END IF;

     IF (l_maintenance_mode = 'MAINT' AND
         p_invocation_mode <> 'REPLAY') THEN

-- hardcoded the version 2.0 shijain nov 27 2002

      CS_ServiceRequest_ENQUEUE_PKG.EnqueueSR(
        p_init_msg_list         => fnd_api.g_false ,
        p_api_version           => 2.0,
        p_commit                => p_commit,
        p_validation_level      => p_validation_level,
        x_return_status         => l_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_request_id            => p_request_id,
        p_request_number        => l_old_ServiceRequest_rec.incident_number,
        p_audit_id              => l_audit_id,
        p_resp_appl_id          => p_resp_appl_id,
        p_resp_id               => p_resp_id,
        p_user_id               => p_user_id,
        p_login_id              => p_login_id,
        p_org_id                => p_org_id,
        p_update_desc_flex      => p_update_desc_flex,
        p_object_version_number => p_object_version_number,
        p_transaction_type      => l_transaction_type,
        p_message_rev           => l_message_revision,
        p_servicerequest        => l_service_request_rec,
        p_contacts              => l_contacts
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;

  IF (l_only_status_update_flag <> 'Y') THEN
  --
  -- Create entries in JTF_NOTES from p_notes
  --
  l_note_index := p_notes.FIRST;
  WHILE l_note_index IS NOT NULL LOOP
    /* Create JTF_NOTES */
    --l_notes_detail := DBMS_LOB.SUBSTR(p_notes(l_note_index).note_detail);


   IF ((p_notes(l_note_index).note IS NOT NULL) AND
        (p_notes(l_note_index).note <> FND_API.G_MISS_CHAR)) THEN

    l_note_status := null ;

    IF ((p_notes(l_note_index).note_status IS NULL) OR
        (p_notes(l_note_index).note_status = FND_API.G_MISS_CHAR)) THEN
        l_note_status := 'E';
    ELSE
        l_note_status := p_notes(l_note_index).note_status ;
    END IF ;

    jtf_notes_pub.create_note(
      p_api_version    => 1.0,
      p_init_msg_list  => FND_API.G_FALSE,
      p_commit         => FND_API.G_FALSE,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_source_object_id => p_request_id,
      p_source_object_code => 'SR',
      p_notes              => p_notes(l_note_index).note,
      p_notes_detail       => p_notes(l_note_index).note_detail,
      p_note_type          => p_notes(l_note_index).note_type,
      p_note_status        => l_note_status,
      p_entered_by         => p_last_updated_by,
      p_entered_date       => p_last_update_date,
      p_created_by         => p_last_updated_by,
      p_creation_date      => p_last_update_date,
      p_last_updated_by    => p_last_updated_by,
      p_last_update_date  =>  p_last_update_date,
      x_jtf_note_id        => l_note_id
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

    IF ((p_notes(l_note_index).note_context_type_01 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_01 <> FND_API.G_MISS_CHAR) AND
        (p_notes(l_note_index).note_context_type_id_01 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_id_01 <> FND_API.G_MISS_NUM)) THEN


         jtf_notes_pub.create_note_context(
           x_return_status        => x_return_status,
           p_creation_date        => p_last_update_date,         ----SYSDATE,
           p_last_updated_by      => p_last_updated_by,
           p_last_update_date     => p_last_update_date,         ------SYSDATE,
           p_jtf_note_id          => l_note_id,
           p_note_context_type    => p_notes(l_note_index).note_context_type_01,
           p_note_context_type_id => p_notes(l_note_index).note_context_type_id_01,
           x_note_context_id      => l_note_context_id
         );

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The defaulted value of parameter note_context_id :' || l_note_context_id
	    );
	  END IF;
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF;

    IF ((p_notes(l_note_index).note_context_type_02 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_02 <> FND_API.G_MISS_CHAR) AND
        (p_notes(l_note_index).note_context_type_id_02 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_id_02 <> FND_API.G_MISS_NUM)) THEN


         jtf_notes_pub.create_note_context(
           x_return_status        => x_return_status,
           p_creation_date        => p_last_update_date,
           p_last_updated_by      => p_last_updated_by,
           p_last_update_date     => p_last_update_date,
           p_jtf_note_id          => l_note_id,
           p_note_context_type    => p_notes(l_note_index).note_context_type_02,
           p_note_context_type_id => p_notes(l_note_index).note_context_type_id_02,
           x_note_context_id      => l_note_context_id
         );

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The defaulted value of parameter note_context_id :' || l_note_context_id
	    );
	  END IF;
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF;

    IF ((p_notes(l_note_index).note_context_type_03 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_03 <> FND_API.G_MISS_CHAR) AND
        (p_notes(l_note_index).note_context_type_id_03 IS NOT NULL) AND
        (p_notes(l_note_index).note_context_type_id_03 <> FND_API.G_MISS_NUM)) THEN

         jtf_notes_pub.create_note_context(
           x_return_status        => x_return_status,
           p_creation_date        => p_last_update_date,
           p_last_updated_by      => p_last_updated_by,
           p_last_update_date     => p_last_update_date,
           p_jtf_note_id          => l_note_id,
           p_note_context_type    => p_notes(l_note_index).note_context_type_03,
           p_note_context_type_id => p_notes(l_note_index).note_context_type_id_03,
           x_note_context_id      => l_note_context_id
         );

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The defaulted value of parameter note_context_id :' || l_note_context_id
	    );
	  END IF;
	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF;
    l_note_index := p_notes.NEXT(l_note_index);
  END LOOP;

  -- Launching the workflow (HOOK)
  IF (JTF_USR_HKS.Ok_To_Execute('CS_ServiceRequest_PVT', 'Update_ServiceRequest',
                                'W', 'W')) THEN

     IF (cs_servicerequest_cuhk.Ok_To_Launch_Workflow
                                  (p_request_id => p_request_id,
                                   p_service_request_rec=>l_service_request_rec)) THEN

       l_bind_data_id := JTF_USR_HKS.Get_bind_data_id ;
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'USER_ID', p_last_updated_by, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'RESP_ID', p_resp_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'RESP_APPL_ID', p_resp_appl_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_ID', p_request_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_DATE', l_old_servicerequest_rec.incident_date, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_TYPE', l_service_request_rec.type_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_STATUS', l_service_request_rec.status_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_SEVERITY', l_service_request_rec.severity_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_URGENCY', l_service_request_rec.urgency_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'OWNER_ID', l_service_request_rec.owner_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_SUMMARY', l_service_request_rec.summary, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'REQUEST_CUSTOMER', l_service_request_rec.customer_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'INVENTORY_ITEM_ID', l_service_request_rec.inventory_item_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'CUSTOMER_PRODUCT_ID', l_service_request_rec.customer_product_id, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'PROBLEM_CODE', l_service_request_rec.problem_code, 'W', 'T');
       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'EXPECTED_RESOLUTION_DATE', l_service_request_rec.exp_resolution_date, 'W', 'T');


       -- Before the call to WorkFlow Hook, generate a unique item key using the workflow sequence
       SELECT cs_wf_process_id_s.NEXTVAL INTO l_workflow_item_key FROM dual;

       JTF_USR_HKS.WrkflowLaunch(p_wf_item_name => 'SERVEREQ',
                                 p_wf_item_process_name => 'CALL_SUPPORT',
                                 p_wf_item_key => 'SR' || TO_CHAR(l_workflow_item_key),
                                 p_bind_data_id => l_bind_data_id,
                                 x_return_code => l_return_status);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   END IF ;
  END IF ;
 END IF; /* only status update flag check */


  --
  -- Make the post processing call to the user hooks
  --
  -- Post call to the Customer Type User Hook
  -- hardcoded the version 2.0 shijain nov 27 2002

  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                               'Update_ServiceRequest',
                               'A', 'C')  THEN
    cs_servicerequest_cuhk.Update_ServiceRequest_Post
    ( p_api_version         => 2.0,
      p_init_msg_list       => fnd_api.g_false ,
      p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_invocation_mode        =>   p_invocation_mode,
    p_service_request_rec    =>  l_service_request_rec,
    p_update_desc_flex       =>  p_update_desc_flex,
    p_notes                  =>  p_notes,
    p_contacts               =>  p_contacts,
    p_audit_comments         =>  p_audit_comments,
    p_called_by_workflow     =>  p_called_by_workflow,
    p_workflow_process_id    =>  p_workflow_process_id,
    x_workflow_process_id    =>  x_sr_update_out_rec.workflow_process_id,
    x_interaction_id         =>  x_sr_update_out_rec.interaction_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'A', 'V')  THEN

-- hardcoded the version 2.0 shijain nov 27 2002

    cs_servicerequest_vuhk.Update_ServiceRequest_Post
    ( p_api_version         => 2.0,
      p_init_msg_list       => fnd_api.g_false ,
      p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_service_request_rec    =>  l_service_request_rec,
    p_update_desc_flex       =>  p_update_desc_flex,
    p_notes                  =>  p_notes,
    p_contacts               =>  p_contacts,
    p_audit_comments         =>  p_audit_comments,
    p_called_by_workflow     =>  p_called_by_workflow,
    p_workflow_process_id    =>  p_workflow_process_id,
    x_workflow_process_id    =>  x_sr_update_out_rec.workflow_process_id,
    x_interaction_id         =>  x_sr_update_out_rec.interaction_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Post call to the Internal Type User Hook
  -- commented out by siahmed to fix bug 9494021 and moved after the contact creation
 /*   cs_servicerequest_iuhk.Update_ServiceRequest_Post( x_return_status=>l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 */

  IF (l_only_status_update_flag <> 'Y') THEN
  -- ------------------------------------------------------
  -- Insert a record into the calls table if the caller is
  -- not a workflow process
  -- ------------------------------------------------------
  IF NOT FND_API.To_Boolean(p_called_by_workflow) THEN
    IF (l_service_request_rec.parent_interaction_id IS NULL) THEN
      /* CREATE INTERACTION */ /* l_interaction_id := */
      NULL;
    END IF;
    x_sr_update_out_rec.interaction_id := l_interaction_id;

    --
    -- Create INTERACTION_ACTIVITY
    --

    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
       RAISE fnd_api.g_exc_error;
    ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;    /* called by workflow */
  END IF; /* only status update flag check */


  -- Standard call for message generation
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'M', 'M')  THEN

     IF (cs_servicerequest_cuhk.Ok_To_Generate_Msg(p_request_id => p_request_id,
                                                   p_service_request_rec=>l_service_request_rec)) THEN

       l_bind_data_id := JTF_USR_HKS.Get_bind_data_id;

       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'incident_id', p_request_id, 'S', 'N');

       JTF_USR_HKS.generate_message(p_prod_code => 'CS',
                                 p_bus_obj_code => 'SR',
                                 p_action_code => 'U',
                                 p_bind_data_id => l_bind_data_id,
                                 x_return_code => l_return_status);


       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
  END IF;

/***************************************************
 commented for bug 2857350, moved after calling the business events

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;
comments ended for bug 2857350
***********************************************************/


--   END IF; -- IF (l_dummy > p_object_version_number )


    -- Added this call for Misc ER: Owner auto assignment changes

  IF (l_only_status_update_flag <> 'Y')
  THEN
    IF l_start_eres_flag = 'Y'
    THEN
      CS_ERES_INT_PKG.start_approval_process
      ( p_incident_id => p_request_id
      , p_incident_type_id => l_service_request_rec.type_id
      , p_incident_status_id => l_sr_related_data.intermediate_status_id
      , p_qa_collection_id => l_service_request_rec.qa_collection_plan_id
      , x_approval_status  => l_approval_status
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_approval_status = 'NO_ACTION'
      THEN
        -- validated orginal target status
        CS_ServiceRequest_UTIL.Validate_Updated_Status
        ( p_api_name                 => 'CS_SERVICEREQUEST_PVT.update_servicerequest'
        , p_parameter_name           => 'p_status_id'
        , p_resp_id                  =>  p_resp_id
        , p_new_status_id            => l_sr_related_data.target_status_id
        , p_old_status_id            => l_old_servicerequest_rec.incident_status_id
        , p_subtype                  => G_SR_SUBTYPE
        , p_type_id                  => l_service_request_rec.type_id
	   , p_old_type_id              => l_old_servicerequest_rec.incident_type_id
        , p_close_flag               => l_sr_related_data.close_flag
        , p_disallow_request_update  => l_sr_related_data.disallow_request_update
        , p_disallow_owner_update    => l_sr_related_data.disallow_owner_update
        , p_disallow_product_update  => l_sr_related_data.disallow_product_update
        , x_return_status  => l_return_status
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- target status is valid at this point.
        --
        -- Now get responded and resolved dates
        CS_SERVICEREQUEST_UTIL.get_reacted_resolved_dates
        ( p_incident_status_id         => l_sr_related_data.target_status_id
        , p_old_incident_status_id     => l_old_servicerequest_rec.incident_status_id
        , p_old_incident_resolved_date => l_old_servicerequest_rec.incident_resolved_date
        , p_old_inc_responded_by_date  => l_old_servicerequest_rec.inc_responded_by_date
        , x_inc_responded_by_date      => l_service_request_rec.inc_responded_by_date
        , x_incident_resolved_date     => l_service_request_rec.incident_resolved_date
        , x_return_status              => l_return_status
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	   IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	   THEN
	     FND_LOG.String
	     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	     , 'The defaulted value of parameter inc_responded_by_date :'
	     || l_service_request_rec.inc_responded_by_date
	     );
	     FND_LOG.String
	     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	     , 'The defaulted value of parameter incident_resolved_date :'
	     || l_service_request_rec.incident_resolved_date
	     );
	   END IF;
	IF NVL(l_sr_related_data.close_flag,'N') = 'Y'
        THEN
           l_service_request_rec.status_flag := 'C';
           IF l_service_request_rec.closed_date IS NULL
           THEN
             l_service_request_rec.closed_date := NVL(l_old_servicerequest_rec.close_date,SYSDATE);
           END IF;
        ELSE
           l_service_request_rec.status_flag := 'O' ;
           l_service_request_rec.closed_date := NULL;
        END IF;
        -- Now update service request record with new value for
        --   1. new status
        --   2. incident responded date
        --   3. incident resolved date
        --   4. Close date
        l_service_request_rec.status_id := l_sr_related_data.target_status_id;
        UPDATE cs_incidents_all_b
        SET    incident_status_id     = l_service_request_rec.status_id
        ,      inc_responded_by_date  = l_service_request_rec.inc_responded_by_date
        ,      incident_resolved_date = l_service_request_rec.incident_resolved_date
        ,      status_flag            = l_service_request_rec.status_flag
        ,      close_date             = l_service_request_rec.closed_date
        WHERE  incident_id = p_request_id;
        -- if close flag for target status is Y then close SR child entities and workflow
      END IF; -- l_approval_status = NO_ACTION
    END IF; -- l_start_eres_flag = 'Y'
    x_sr_update_out_rec.status_id         := l_service_request_rec.status_id;
    x_sr_update_out_rec.close_date        := l_service_request_rec.closed_date;
    x_sr_update_out_rec.resolved_on_date  := l_service_request_rec.incident_resolved_date;
    x_sr_update_out_rec.responded_on_date := l_service_request_rec.inc_responded_by_date;
    -- Create audit record
    l_audit_vals_rec.entity_activity_code 	  := 'U';
    l_audit_vals_rec.updated_entity_code	  := 'SR_HEADER';
    l_audit_vals_rec.updated_entity_id	          := p_request_id;
    l_audit_vals_rec.incident_last_modified_date  := l_service_request_rec.last_update_date ;
    l_audit_vals_rec.incident_status_id           := l_service_request_rec.status_id     ;
    --
    l_audit_vals_rec.incident_resolved_date       := l_service_request_rec.incident_resolved_date;
    l_audit_vals_rec.old_incident_resolved_date   := l_old_ServiceRequest_rec.incident_resolved_date;
    --
    l_audit_vals_rec.inc_responded_by_date        := l_service_request_rec.inc_responded_by_date;
    l_audit_vals_rec.old_inc_responded_by_date    := l_old_ServiceRequest_rec.inc_responded_by_date;
    --
    l_audit_vals_rec.close_date                   := l_service_request_rec.closed_date          ;
    l_audit_vals_rec.old_close_date               := l_old_ServiceRequest_rec.close_date        ;
    --
    l_audit_vals_rec.status_flag                  := l_service_request_rec.status_flag          ;
    l_audit_vals_rec.old_status_flag              := l_old_ServiceRequest_rec.status_flag       ;
    IF l_service_request_rec.status_flag = l_old_servicerequest_rec.status_flag
    THEN
      l_audit_vals_rec.change_status_flag := 'N';
    ELSE
      l_audit_vals_rec.change_status_flag := 'Y';
    END IF;
    l_audit_vals_rec.incident_country           := l_service_request_rec.incident_country         ;
    l_audit_vals_rec.old_incident_country       := l_old_servicerequest_rec.incident_country      ;
    --
    l_audit_vals_rec.incident_location_id       := l_service_request_rec.incident_location_id     ;
    l_audit_vals_rec.old_incident_location_id   := l_old_servicerequest_rec.incident_location_id  ;
    --
    l_audit_vals_rec.incident_location_type     := l_service_request_rec.incident_location_type   ;
    l_audit_vals_rec.old_incident_location_type := l_old_servicerequest_rec.incident_location_type;
    --
    IF NVL(l_service_request_rec.owner_id,-99) = NVL(l_old_ServiceRequest_rec.incident_owner_id,-99)
    THEN
      IF (l_service_request_rec.owner_assigned_time = FND_API.G_MISS_DATE) OR
         (l_service_request_rec.owner_assigned_time IS NULL AND
          l_old_ServiceRequest_rec.owner_assigned_time IS NULL) OR
         (l_service_request_rec.owner_assigned_time = l_old_ServiceRequest_rec.owner_assigned_time)
      THEN
      --commented by Sanjana Rao, bug 6955756
      -- l_service_request_rec.owner_assigned_time   := l_old_ServiceRequest_rec.owner_assigned_time;
        -- For audit record
        l_audit_vals_rec.change_assigned_time_flag  := 'N';
        l_audit_vals_rec.old_owner_assigned_time    := l_old_ServiceRequest_rec.owner_assigned_time;
        --2993526
        l_audit_vals_rec.owner_assigned_time        := l_old_ServiceRequest_rec.owner_assigned_time;
      ELSE
        -- For audit record
        l_audit_vals_rec.change_ASSIGNED_TIME_FLAG  := 'Y';
        l_audit_vals_rec.OLD_OWNER_ASSIGNED_TIME    := l_old_ServiceRequest_rec.owner_assigned_time;
        --2993526 ... passed value should be stamped
        l_audit_vals_rec.OWNER_ASSIGNED_TIME        := l_service_request_rec.owner_assigned_time;
      END IF;
      -- for audit record added by shijain
      l_audit_vals_rec.change_incident_owner_flag := 'N';
    ELSE
      IF (l_service_request_rec.owner_assigned_time = FND_API.G_MISS_DATE) OR
       (l_service_request_rec.owner_assigned_time IS NULL AND
        l_old_ServiceRequest_rec.owner_assigned_time IS NULL) OR
       (l_service_request_rec.owner_assigned_time = l_old_ServiceRequest_rec.owner_assigned_time)
      THEN
        --2993526

      --commented by Sanjana Rao, bug 6955756
      --  l_service_request_rec.owner_assigned_time   := SYSDATE;

        -- For audit record

        l_audit_vals_rec.change_assigned_time_flag  := 'Y' ;
        l_audit_vals_rec.old_owner_assigned_time    := l_old_ServiceRequest_rec.owner_assigned_time;
        l_audit_vals_rec.owner_assigned_time        := SYSDATE;
      ELSE
        --2993526
        -- For audit record
        l_audit_vals_rec.change_ASSIGNED_TIME_FLAG  := 'Y';
        l_audit_vals_rec.OLD_OWNER_ASSIGNED_TIME    := l_old_ServiceRequest_rec.owner_assigned_time;
        --2993526
        l_audit_vals_rec.OWNER_ASSIGNED_TIME        := l_service_request_rec.owner_assigned_time;
      END IF;
      -- For audit record
      l_audit_vals_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
    END IF;
    l_audit_vals_rec.OLD_INCIDENT_OWNER_ID      := l_old_ServiceRequest_rec.incident_owner_id;
    l_audit_vals_rec.INCIDENT_OWNER_ID          := l_service_request_rec.owner_id;

    -- end for 2993526
    --- Added code for bug# 1966184
    IF NVL(l_service_request_rec.group_type,-99) = NVL(l_old_ServiceRequest_rec.group_type,-99)
    THEN
      l_audit_vals_rec.change_group_type_flag := 'N';
    ELSE
      l_audit_vals_rec.change_group_type_FLAG := 'Y';
    END IF;
    l_audit_vals_rec.OLD_group_type := l_old_ServiceRequest_rec.group_type;
    l_audit_vals_rec.group_type     := l_service_request_rec.group_type;
    -- Audit Resource Type
    IF NVL(l_service_request_rec.resource_type,-99) = NVL(l_old_ServiceRequest_rec.resource_type,-99)
    THEN
      l_audit_vals_rec.change_resource_type_flag := 'N';
    ELSE
      l_audit_vals_rec.change_resource_type_FLAG := 'Y';
    END IF;
    l_audit_vals_rec.old_resource_type         := l_old_ServiceRequest_rec.resource_type;
    l_audit_vals_rec.resource_type             := l_service_request_rec.resource_type;

    -----Added for enhancements 11.5.6-------jngeorge-----08/03/01
    ----Added code for bug# 1966169
    IF NVL(l_service_request_rec.owner_group_id,-99) = NVL(l_old_ServiceRequest_rec.owner_group_id,-99)
    THEN
      l_audit_vals_rec.change_group_flag := 'N';
    ELSE
      ---- Added for Enh# 2216664
      -- For audit record
      l_audit_vals_rec.change_group_FLAG := 'Y';
    END IF;
    l_audit_vals_rec.old_group_id      := l_old_ServiceRequest_rec.owner_group_id;
    l_audit_vals_rec.group_id          := l_service_request_rec.owner_group_id;
    --
    -- Territory Audit
    --
    IF NVL(l_service_request_rec.territory_id,-99) = NVL(l_old_ServiceRequest_rec.territory_id,-99)
    THEN
      l_audit_vals_rec.change_territory_id_flag := 'N';
    ELSE
      ---- Added for Enh# 2216664
      -- For audit record
      l_audit_vals_rec.change_territory_id_FLAG := 'Y';
    END IF;
    l_audit_vals_rec.old_territory_id      := l_old_ServiceRequest_rec.territory_id;
    l_audit_vals_rec.territory_id          := l_service_request_rec.territory_id;
    --End of audit changes for Group, owner and Group Type
    -- Added for Auditing project of 11.5.10 --anmukher --09/05/03 l_old_ServiceRequest_rec
    --
    IF NVL(l_service_request_rec.site_id,-99) = NVL(l_old_ServiceRequest_rec.site_id,-99)
    THEN
      l_audit_vals_rec.change_site_flag := 'N';
    ELSE
      l_audit_vals_rec.change_site_FLAG := 'Y';
    END IF;
    l_audit_vals_rec.old_site_id        := l_old_ServiceRequest_rec.site_id;
    l_audit_vals_rec.site_id            := l_service_request_rec.site_id;

   --siahmed added for disabling audit when invocation_mode is of replay
   IF (p_invocation_mode <> 'REPLAY' ) THEN
    CS_ServiceRequest_PVT.Create_Audit_Record
    ( p_api_version         => 2.0
    , x_return_status       => l_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
    , p_request_id          => p_request_id
    , p_audit_id            => p_audit_id
    , p_audit_vals_rec      => l_audit_vals_rec
    , p_user_id             => l_service_request_rec.last_updated_by
    , p_wf_process_name     => l_workflow_process_name
    , p_wf_process_itemkey  => l_wf_process_itemkey
    , p_login_id            => l_service_request_rec.last_update_login
    , p_last_update_date    => l_service_request_rec.last_update_date
    , p_creation_date       => l_service_request_rec.last_update_date
    , p_comments            => p_audit_comments
    , x_audit_id            => l_audit_id
    );
   END IF; -- end of addition by siahmed for invocation_mode high avaialibility project
    --
    -- Create entries in CS_HZ_SR_CONTACT_POINTS from p_contacts
    CS_SRCONTACT_PKG.create_update
    ( p_incident_id     => p_request_id
    , p_invocation_mode => p_invocation_mode
    , p_sr_update_date  => l_service_request_rec.last_update_date
    , p_sr_updated_by   => l_service_request_rec.last_updated_by
    , p_sr_update_login => l_service_request_rec.last_update_login
    , p_contact_tbl     => l_processed_contacts
    , p_old_contact_tbl => l_old_contacts
    , x_return_status   => l_return_status
    );

    --siahmed added for the post hook fix after the contact creation
    --bug fix 9494021
   cs_servicerequest_iuhk.Update_ServiceRequest_Post( x_return_status=>l_return_status);
   --end of addition siahmed

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_start_eres_flag = 'Y' AND
       l_approval_status = 'NO_ACTION'
    THEN
        IF NVL(l_sr_related_data.close_flag,'N') = 'Y'
        THEN
          -- Close workflow processing
          -- check if old status was closed on Not
          CS_SERVICEREQUEST_UTIL.get_status_details
          ( p_status_id                  => l_old_servicerequest_rec.incident_status_id
          , x_close_flag                 => l_sr_related_data.old_close_flag
          , x_disallow_request_update    => l_sr_related_data.old_disallow_request_update
          , x_disallow_agent_dispatch    => l_sr_related_data.old_disallow_owner_update
          , x_disallow_product_update    => l_sr_related_data.old_disallow_product_update
          , x_pending_approval_flag      => l_sr_related_data.old_pending_approval_flag
          , x_intermediate_status_id     => l_sr_related_data.old_intermediate_status_id
          , x_approval_action_status_id  => l_sr_related_data.old_approval_action_status_id
          , x_rejection_action_status_id => l_sr_related_data.old_rejection_action_status_id
          , x_return_status              => l_return_status
          );
          --
          IF l_sr_related_data.old_close_flag           <> 'Y' AND
             l_sr_related_data.abort_workflow_close_flag = 'Y' AND
             CS_Workflow_PKG.Is_Servereq_Item_Active
             ( p_request_number  => l_old_ServiceRequest_rec.incident_number
             , p_wf_process_id   => l_old_ServiceRequest_rec.workflow_process_id
             )  = 'Y'
          THEN
               CS_Workflow_PKG.Abort_Servereq_Workflow
                  (p_request_number  => l_old_ServiceRequest_rec.incident_number,
                   p_wf_process_id   => l_old_ServiceRequest_rec.workflow_process_id,
                   p_user_id         => p_last_updated_by);
          END IF;
          IF ( p_validate_sr_closure = 'Y' OR p_validate_sr_closure = 'y') THEN
            CS_SR_STATUS_PROPAGATION_PKG.VALIDATE_SR_CLOSURE
            ( p_api_version        => p_api_version
            , p_init_msg_list      => fnd_api.g_false
            , p_commit             => p_commit
            , p_service_request_id => p_request_id
            , p_user_id            => l_service_request_rec.last_updated_by
            , p_resp_appl_id       =>  p_resp_appl_id
            , p_login_id           => l_service_request_rec.last_update_login
            , x_return_status      => l_return_status
            , x_msg_count          => l_msg_count
            , x_msg_data           => l_msg_data
            );
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
            THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (p_auto_close_child_entities='Y' OR p_auto_close_child_entities='y')
            THEN
              CS_SR_STATUS_PROPAGATION_PKG.CLOSE_SR_CHILDREN
              ( p_api_version         => p_api_version
              , p_init_msg_list       => fnd_api.g_false
              , p_commit              => p_commit
              , p_validation_required =>'N'
              , p_action_required     => 'Y'
              , p_service_request_id  => p_request_id
              , p_user_id             => l_service_request_rec.last_updated_by
              , p_resp_appl_id        =>  p_resp_appl_id
              , p_login_id            => l_service_request_rec.last_update_login
              , x_return_status       => l_return_status
              , x_msg_count           => l_msg_count
              , x_msg_data            => l_msg_data
              );
              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
              THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF; -- for auto_close-child = 'Y'
          END IF; ------ p_validate_sr_closeure = 'Y'
        END IF; -------- l_sr_related_data.close_flag = 'Y'
    END IF; -- l_start_eres_flag = 'Y'
    --
    -- Change task address is incident address is changed.

    IF p_validation_level >  FND_API.G_VALID_LEVEL_NONE
    THEN

      IF NVL(l_service_request_rec.incident_location_id,-1)  <>
         NVL(l_old_servicerequest_rec.incident_location_id,-1) OR
         NVL(l_service_request_rec.incident_location_type,'-') <>
         NVL(l_old_servicerequest_rec.incident_location_type,'-')
      THEN

        CS_ServiceRequest_UTIL.Verify_LocUpdate_For_FSTasks
         (p_incident_id   => p_request_id,
          x_return_status => x_return_status );


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF ;

        CS_servicerequest_util.update_task_address
        ( p_incident_id   => p_request_id
        , p_location_type => l_service_request_rec.incident_location_type
        , p_location_id   => l_service_request_rec.incident_location_id
        , p_old_location_id   => l_old_servicerequest_rec.incident_location_id  -- bug 8947959
        , x_return_status => x_return_status
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;
  END IF; -- l_only_status_update_flag <> 'Y'
   --- Added for HA Enhancement

   IF (p_invocation_mode <> 'REPLAY') THEN
   --AND (FND_API.To_Boolean(p_called_by_workflow) = FALSE) THEN
      -- Raise BES Event that the SR is updated. Before business events, a WF process
      -- was kicked off if the following conditions were met: if l_autolaunch_wf_flag
      -- is 'Y' AND resource_type = 'RS_EMPLOYEE' AND owner_id IS NOT NULL and the
      -- status of the SR is not 'CLOSE' and there is'nt an active WF tied to this SR.
      -- After the introduction of business event, the SR API calls the CS BES wrapper
      -- API and this wrapper API raises the needed business events, in this case -
      -- SR Updated, after checking the required conditions.
      -- The wrapper API will also check if a Contact was added or the SR was re-assigned
      -- and raise those evens as well if true.

      -- Initialize and populate the old rec type with the SR Old values.


    --siahmed added by siahmed for post hook
      initialize_rec ( p_sr_record          => l_old_sr_rec );

      l_old_sr_rec.type_id                  := l_old_servicerequest_rec.incident_type_id;
      l_old_sr_rec.status_id                := l_old_servicerequest_rec.incident_status_id;
      l_old_sr_rec.severity_id              := l_old_servicerequest_rec.incident_severity_id;
      l_old_sr_rec.urgency_id               := l_old_servicerequest_rec.incident_urgency_id;
      l_old_sr_rec.owner_id                 := l_old_servicerequest_rec.incident_owner_id;
      l_old_sr_rec.owner_group_id           := l_old_servicerequest_rec.owner_group_id;
      l_old_sr_rec.customer_id              := l_old_servicerequest_rec.customer_id;
      l_old_sr_rec.customer_product_id      := l_old_servicerequest_rec.customer_product_id;
      l_old_sr_rec.inventory_item_id        := l_old_servicerequest_rec.inventory_item_id;
      l_old_sr_rec.problem_code             := l_old_servicerequest_rec.problem_code;
      --Added summary as a fix for bug#2809232
      l_old_sr_rec.summary                  := l_old_servicerequest_rec.summary;
      l_old_sr_rec.exp_resolution_date      := l_old_servicerequest_rec.expected_resolution_date;
      l_old_sr_rec.install_site_id          := l_old_servicerequest_rec.install_site_id;
      l_old_sr_rec.bill_to_site_id          := l_old_servicerequest_rec.bill_to_site_id;
      l_old_sr_rec.bill_to_contact_id       := l_old_servicerequest_rec.bill_to_contact_id;
      l_old_sr_rec.ship_to_site_id          := l_old_servicerequest_rec.ship_to_site_id;
      l_old_sr_rec.ship_to_contact_id       := l_old_servicerequest_rec.ship_to_contact_id;
      l_old_sr_rec.resolution_code          := l_old_servicerequest_rec.resolution_code;
      l_old_sr_rec.contract_service_id      := l_old_servicerequest_rec.contract_service_id;
      l_old_sr_rec.sr_creation_channel      := l_old_servicerequest_rec.sr_creation_channel;
      l_old_sr_rec.last_update_channel      := l_old_servicerequest_rec.last_update_channel;
      l_old_sr_rec.last_update_program_code := l_old_servicerequest_rec.last_update_program_code;

       -- added wf process id to be passed to the BES event, so that it does'nt raise another
      -- event if there is a wf process id already that is active.


      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
         -- These 4 parameters added for bug #2798269
         p_api_version           => p_api_version,
         p_init_msg_list         => fnd_api.g_false ,
         p_commit                => p_commit,
         p_validation_level      => p_validation_level,
         p_event_code            => 'UPDATE_SERVICE_REQUEST',
         p_incident_number       => l_old_ServiceRequest_rec.incident_number,
         p_user_id               => l_service_request_rec.last_updated_by,
         p_resp_id               => p_resp_id,
         p_resp_appl_id          => p_resp_appl_id,
	 p_old_sr_rec            => l_old_sr_rec,
	 p_new_sr_rec            => l_service_request_rec, -- using l_ser...coz this is the
							   -- rec. type used in the insert.
	 p_contacts_table        => p_contacts,
         p_link_rec              => NULL,  -- using default value
         p_wf_process_id         => p_workflow_process_id,  -- value of the WF
                          -- process id if the update API is invoked from a WF.
         p_owner_id		 => NULL,  -- using default value
         p_wf_manual_launch	 => 'N' ,  -- using default value
         x_wf_process_id         => l_workflow_process_id,
         x_return_status         => lx_return_status,
         x_msg_count             => lx_msg_count,
         x_msg_data              => lx_msg_data );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         -- do nothing in this API. The BES wrapper API will have to trap this
         -- situation and send a notification to the SR owner that the BES has
         -- not been raised. If the BES API return back a failure status, it
         -- means only that the BES raise event has failed, and has nothing to
         -- do with the update of the SR.
         --null;
	 -- Added for bug 8849523.
	 --If the subscription action type ON ERROR is set to STOP and ROLLBACK, then if
	 --an error is raised that should be propagated to the calling application.
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
      x_sr_update_out_rec.workflow_process_id  := l_workflow_process_id ;
   END IF;   -- IF (p_invocation_mode <> 'REPLAY')
   --
   -- end of Raise service request events.
   --
        CS_SR_WORKITEM_PVT.Update_Workitem(
                p_api_version           => 1.0,
                p_init_msg_list         => fnd_api.g_false  ,
                p_commit                => p_commit       ,
                p_incident_id           => p_request_id,
                p_old_sr_rec            => l_old_ServiceRequest_rec,
                p_new_sr_rec            => l_service_request_rec,
                p_user_id               => l_service_request_rec.last_updated_by,
                p_resp_appl_id          => p_resp_appl_id ,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
         );
      END IF;

  CLOSE l_ServiceRequest_csr;
/**************Commit moved for bug 2857350**************************/
 -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   /*resetting the parameter value shijain 4th dec 2002*/
   g_restrict_ib:=NULL;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN DestUpdated THEN
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    IF (p_invocation_mode = 'REPLAY' ) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    FND_MESSAGE.SET_NAME('CS','CS_SR_DESTINATION_UPDATED');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN NoUpdate THEN
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('CS','CS_SR_LESSER_OBJ_VERSION');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN TargUpdated THEN
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MESSAGE.SET_NAME('CS','CS_SR_HA_NO_REPLAY');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN SR_Lock_Row THEN
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

--- For BUG # 2933250
  WHEN invalid_install_site THEN
  	ROLLBACK TO Update_ServiceRequest_PVT;
  	x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('CS','CS_SR_INVALID_INSTALL_SITE');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN OTHERS THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );


END Update_ServiceRequest;


-- -------------------------------------------------------------------
-- Update_Status
-- -------------------------------------------------------------------

--p_org_id             IN   NUMBER   DEFAULT NULL,

-- -------- -------- -----------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 07/11/05 smisra   Rel 12.0 ERES changes
--                   call get_status_details procedure for parameter p_status_id
--                   if this status has intermediated status id as NOT NULL then
--                   called update_servicerequest procedure. This is needed
--                   for ERES processing and avoiding duplicate coding in this
--                   procedure.
-- 07/15/05 smisra   Bug 4489746 modified sql statement for cs_incident_types_b
--                   and removed condition on start and end active dates so that
--                   API does not give error for those types that become end
--                   dated
--                   Passed UPDATE_OLD to validate_type call because we need to
--                   just check user's access to SR
-- 07/21/05 smisra   Bug 3215462
--                   Add a call to CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT
-- 10/11/05 smisra   Bug 4666784
--                   called validate_sr_closure and close_sr_children only
--                   if close flag associated with status is 'Y'
-- 10/14/05 smisra   fixed Bug 4674131
--                   based on status id flags set response and resolved dates
-- 04/25/06 spusegao Modofied to check if the existing SR status is an intermediate status with
--                   disallow_request_update flag = 'Y'. If yes then disallow any update to
--                   the service request.
-- -------- -------- -----------------------------------------------------------
PROCEDURE Update_Status
  ( p_api_version                   IN   NUMBER,
    p_init_msg_list                 IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                        IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_resp_id                       IN   NUMBER,
    p_validation_level              IN   NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status                OUT   NOCOPY VARCHAR2,
    x_msg_count                    OUT   NOCOPY NUMBER,
    x_msg_data                     OUT   NOCOPY VARCHAR2,
    p_request_id                    IN   NUMBER,
    p_object_version_number         IN   NUMBER,
    p_status_id                     IN   NUMBER,
    p_closed_date                   IN   DATE     DEFAULT fnd_api.g_miss_date,
    p_last_updated_by               IN   NUMBER,
    p_last_update_login             IN   NUMBER   DEFAULT NULL,
    p_last_update_date              IN   DATE,
    p_audit_comments                IN   VARCHAR2 DEFAULT NULL,
    p_called_by_workflow            IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id           IN   NUMBER   DEFAULT NULL,
    p_comments                      IN   VARCHAR2 DEFAULT NULL,
    p_public_comment_flag           IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_parent_interaction_id         IN   NUMBER   DEFAULT NULL,
    p_validate_sr_closure           IN   VARCHAR2 Default 'N',
    p_auto_close_child_entities     IN   VARCHAR2 Default 'N',
    x_interaction_id               OUT   NOCOPY NUMBER
  )
  IS
     l_api_name          CONSTANT VARCHAR2(30) := 'Update_Status';
     l_api_version  CONSTANT NUMBER       := 2.0;
     l_api_name_full     CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
     l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
     l_return_status     VARCHAR2(1);
     l_orig_status_id    NUMBER;
     l_closed_flag  VARCHAR2(1);
     l_orig_closed_date  DATE ;
     l_disallow_request_update  VARCHAR2(1);
     l_disallow_owner_update  VARCHAR2(1);
     l_disallow_product_update   VARCHAR2(1);
     l_audit_id                NUMBER;
     l_creation_date           DATE;

     l_closed_date  DATE;
     l_audit_vals_rec		   sr_audit_rec_type;

     l_autolaunch_workflow_flag   VARCHAR2(1);
     l_abort_workflow_close_flag  VARCHAR2(1);
     l_workflow_process_name      VARCHAR2(30);
     l_workflow_process_id        NUMBER;

     -- Added for enh. 2655115
     l_status_flag                VARCHAR2(1);

     --Fixed bug#2775580, getting all the columns in the cursor.

/* ****************
   l_old_ServiceRequest_rec is now changed to type sr_oldvalues_rec_type .

   Replacing the select list of columns with a select * so that the
   subtype defined in the spec can be used to pass the old SR values as
   a parameter to other procedures

* *****************/

     CURSOR L_SERVICEREQUEST_CSR IS
     SELECT *
     from   cs_incidents_all_vl
     where  incident_id = p_request_id
     and    object_version_number = p_object_version_number
     for    update nowait;

 -- The rec type was changed to sr_oldvalues_rec_type as the
 -- workitem API (Misc ER owner Auto Assginment )needed a record type
 -- with old values , also the API validations needed the oldvalues_rec .

     l_ServiceRequest_rec   sr_oldvalues_rec_type;
     l_new_sr_rec           service_request_rec_type;
     l_old_sr_rec           service_request_rec_type;

   -- Local variable to store business usage for security validation
   l_business_usage       VARCHAR2(30);

   -- Local variable to store attribute if security is enabled for self service resps.
   l_ss_sr_type_restrict   VARCHAR2(10);

   -- Local variable to get the return status of validate type for security check
   lx_return_status              VARCHAR2(3);

   l_old_cmro_flag               VARCHAR2(3);
   l_old_maintenance_flag        VARCHAR2(3);

   -- Added for Auditing --anmukher --10/15/03
   lx_audit_id			 NUMBER;

l_sr_related_data       RELATED_DATA_TYPE;
l_sr_update_out_rec	sr_update_out_rec_type;
l_notes                 notes_table;
l_contacts              contacts_table;
l_inc_responded_by_date  DATE;
l_incident_resolved_date  DATE;
BEGIN

    -- ---------------------------------------
    -- Standard API stuff
    -- ---------------------------------------

    -- Establish save point
    SAVEPOINT Update_Status_PVT;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                            p_api_version,
                            l_api_name,
                            G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if requested
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_last_updated_by:' || p_last_updated_by
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_audit_comments:' || P_audit_comments
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_object_version_number:' || P_object_version_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_last_update_login:' || p_last_update_login
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_last_update_date:' || p_last_update_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_status_id:' || P_status_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_parent_interaction_id:' || p_parent_interaction_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Closed_date:' || P_Closed_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_request_id:' || p_request_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_comments:' || p_comments
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Public_Comment_Flag:' || P_Public_Comment_Flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Called_by_workflow:' || P_Called_by_workflow
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Workflow_process_id:' || P_Workflow_process_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Validate_SR_Closure:' || P_Validate_SR_Closure
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Auto_Close_Child_Entities:' || P_Auto_Close_Child_Entities
    );

  END IF;

    -- Initialize the New Audit Record ******
    Initialize_audit_rec(
    p_sr_audit_record         => l_audit_vals_rec) ;

    -- Initialize return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize the new record and assign the required values for
    -- workitem call

    initialize_rec ( p_sr_record    => l_new_sr_rec );
    initialize_rec ( p_sr_record    => l_old_sr_rec );

    l_new_sr_rec.status_id := p_status_id ;
    l_new_sr_rec.closed_date:= p_closed_date;
    l_new_sr_rec.public_comment_flag := p_public_comment_flag;
    l_new_sr_rec.parent_interaction_id:= p_parent_interaction_id;

    -- ----------------------------------------
    -- Open cursor for update
    -- ----------------------------------------
    OPEN  l_ServiceRequest_csr;
    FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;
    IF (l_ServiceRequest_csr%NOTFOUND) THEN

      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                     ( p_token_an     =>  l_api_name_full,
                       p_token_v      =>  TO_CHAR(p_request_id),
                       p_token_p      =>  'p_request_id',
                       p_table_name   => G_TABLE_NAME,
                       p_column_name  => 'REQUEST_ID');

      RAISE FND_API.G_EXC_ERROR;

    END IF;
    -- --------------------------------------------------------
    -- If the new status is the same as old, there's no need
    -- to continue
    -- --------------------------------------------------------
	-- for bug 3640344 - pkesani
    IF (p_status_id = l_ServiceRequest_rec.incident_status_id
	    OR p_status_id = FND_API.G_MISS_NUM) THEN

    -- abhgauta - Fix for Bug 6042520
    -- Display the Warning that SR Status has not changed, only if SR Status's Disallow Update is unchecked

    IF (l_sr_related_data.disallow_request_update <> 'Y') THEN

      CS_ServiceRequest_UTIL.Add_Same_Val_Update_Msg
                    ( p_token_an     =>  l_api_name_full,
                      p_token_p      =>  'p_status_id' ,
                      p_table_name   => G_TABLE_NAME,
                      p_column_name  => 'INCIDENT_STATUS_ID');

      CLOSE l_ServiceRequest_csr;
      RETURN;
    END IF;
    END IF;

    -- -------------------------------------
    -- Perform validation when necessary
    -- -------------------------------------
    IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN

      CS_ServiceRequest_UTIL.Validate_Who_Info(
                p_api_name              => l_api_name_full,
          	p_parameter_name_usr    => 'p_last_updated_by',
          	p_parameter_name_login  => 'p_last_update_login',
                p_user_id               => p_last_updated_by,
                p_login_id              => p_last_update_login,
                x_return_status         => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Service security validation
      -- Validate if the current responsibility has access to the SR type being update.
      -- Invoke the VALIDATE_TYPE procedure that has the logic to check for security
      -- access

      -- Get the business usage of the responsibility that is attempting to create
      -- the SR.
      get_business_usage (
         p_responsibility_id      => p_resp_id,
         p_application_id         => fnd_global.resp_appl_id,
         x_business_usage         => l_business_usage );

      -- Get indicator of self service security enabled or not
      if ( l_business_usage = 'SELF_SERVICE' ) then
         get_ss_sec_enabled (
	    x_ss_sr_type_restrict => l_ss_sr_type_restrict );
      end if;

      -- For bug 3370562 - pass resp_id an appl_id
      -- validate security in update; first against old sr type
      cs_servicerequest_util.validate_type (
         p_parameter_name       => NULL,
         p_type_id   	        => l_servicerequest_rec.incident_type_id,
         p_subtype  	        => G_SR_SUBTYPE,
         p_status_id            => l_servicerequest_rec.incident_status_id, -- not used
         p_resp_id              => p_resp_id,
         p_resp_appl_id         => fnd_global.resp_appl_id,
         p_business_usage       => l_business_usage,
         p_ss_srtype_restrict   => l_ss_sr_type_restrict,
         p_operation            => 'UPDATE_OLD',
         x_return_status        => lx_return_status,
         x_cmro_flag            => l_old_cmro_flag,
         x_maintenance_flag     => l_old_maintenance_flag );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- security violation; responsibility does not have access to SR Type
         -- being created. Stop and raise error.
         RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;   -- IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN

    -- Get the details of the existing status of SR

    CS_SERVICEREQUEST_UTIL.get_status_details
       ( p_status_id                  => l_servicerequest_rec.incident_status_id
       , x_close_flag                 => l_sr_related_data.old_close_flag
       , x_disallow_request_update    => l_sr_related_data.old_disallow_request_update
       , x_disallow_agent_dispatch    => l_sr_related_data.old_disallow_owner_update
       , x_disallow_product_update    => l_sr_related_data.old_disallow_product_update
       , x_pending_approval_flag      => l_sr_related_data.old_pending_approval_flag
       , x_intermediate_status_id     => l_sr_related_data.old_intermediate_status_id
       , x_approval_action_status_id  => l_sr_related_data.old_approval_action_status_id
       , x_rejection_action_status_id => l_sr_related_data.old_rejection_action_status_id
       , x_return_status              => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

         IF (l_sr_related_data.old_pending_approval_flag = 'Y') AND
            (l_sr_related_data.old_disallow_request_update = 'Y') THEN
            FND_MESSAGE.set_name('CS','CS_ERES_SR_FROZEN_STATUS');
            FND_MSG_PUB.ADD;
            --FND_MESSAGE.set_name('CS','CS_SR_INTERMEDIATE_STATUS');
            --FND_MESSAGE.set_token('API_NAME','CS_SERVICEREQUEST_PVT.update_status');
            --FND_MESSAGE.set_token('STATUS_ID',l_servicerequest_rec.incident_status_id);
            --FND_MSG_PUB.ADD_DETAIL(p_associated_column1=>'CS_INCIDENTS_ALL_B.incident_status_id');
            RAISE FND_API.G_EXC_ERROR;
         END IF; -- l_pending approval flag is Y
      END IF; -- if after get_status_details call

    -- Get the details of the new status
    CS_SERVICEREQUEST_UTIL.get_status_details
    ( p_status_id                  => p_status_id
    , x_close_flag                 => l_sr_related_data.close_flag
    , x_disallow_request_update    => l_sr_related_data.disallow_request_update
    , x_disallow_agent_dispatch    => l_sr_related_data.disallow_owner_update
    , x_disallow_product_update    => l_sr_related_data.disallow_product_update
    , x_pending_approval_flag      => l_sr_related_data.pending_approval_flag
    , x_intermediate_status_id     => l_sr_related_data.intermediate_status_id
    , x_approval_action_status_id  => l_sr_related_data.approval_action_status_id
    , x_rejection_action_status_id => l_sr_related_data.rejection_action_status_id
    , x_return_status              => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
/*
      IF l_sr_related_data.pending_approval_flag = 'Y' THEN
        FND_MESSAGE.set_name ('CS', 'CS_SR_INTERMEDIATE_STATUS');
        FND_MESSAGE.set_token
        ( 'API_NAME'
        , 'CS_SERVICEREQUEST_PVT.update_status'
        );
        FND_MESSAGE.set_token('STATUS_ID',p_status_id);
        FND_MSG_PUB.ADD_DETAIL
        ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.incident_status_id'
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF; -- l_pending approval flag is Y
*/
      IF l_sr_related_data.intermediate_status_id IS NOT NULL
      THEN

        CS_ServiceRequest_PVT.Update_ServiceRequest
        ( p_api_version               => 4.0
        , p_init_msg_list	      => p_init_msg_list
        , p_commit		      => p_commit
        , p_validation_level          => p_validation_level
        , x_return_status	      => x_return_status
        , x_msg_count	              => x_msg_count
        , x_msg_data	              => x_msg_data
        , p_request_id	              => p_request_id
        , p_audit_id	              => NULL
        , p_object_version_number     => p_object_version_number
        , p_resp_id                   => p_resp_id
        , p_last_updated_by	      => p_last_updated_by
        , p_last_update_login         => p_last_update_login
        , p_last_update_date          => p_last_update_date
        , p_service_request_rec       => l_new_sr_rec
        , p_notes                     => l_notes
        , p_contacts                  => l_contacts
        , p_called_by_workflow        => p_called_by_workflow
        , p_workflow_process_id       => p_workflow_process_id
        , p_validate_sr_closure       => p_validate_sr_closure
        , p_auto_close_child_entities => p_auto_close_child_entities
        , x_sr_update_out_rec         => l_sr_update_out_rec
        );

        RETURN;
      END IF; -- intermediated status id is not null
    END IF; -- if after get_status_details call
    -- ------------------------------------------------------------------
    -- We ALWAYS have to validate the status because we don't know if the
    -- status is a "closed" status, and we need this information in order
    -- to set the closed_date variable accordingly
    -- ------------------------------------------------------------------
    CS_ServiceRequest_UTIL.Validate_Updated_Status(
          p_api_name         => l_api_name_full,
          p_parameter_name   => 'p_status_id',
          p_resp_id          => p_resp_id  ,
          p_new_status_id    => p_status_id,
          p_old_status_id    => l_ServiceRequest_rec.incident_status_id,
          p_subtype          => G_SR_SUBTYPE,
          p_type_id          => l_ServiceRequest_rec.incident_type_id,
          p_old_type_id      => l_ServiceRequest_rec.incident_type_id,
          p_close_flag       => l_closed_flag,
          p_disallow_request_update  => l_disallow_request_update,
          p_disallow_owner_update    => l_disallow_owner_update,
          p_disallow_product_update  => l_disallow_product_update,
          x_return_status    => l_return_status );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- ------------------------------------------------------------------
    -- Cannot close the request by setting the status to a "closed"
    -- status when there is an active workflow process in progress.
    -- Unless this API itself was called from a workflow process.
    -- ------------------------------------------------------------------
    IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN

      --Get the abort workflow on close flag from cs_incident_types

      BEGIN
	  -- Initialize the return status.
       l_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Verify the type ID against the database.

	  SELECT autolaunch_workflow_flag,
                 abort_workflow_close_flag,
                 workflow
           INTO  l_autolaunch_workflow_flag,
                 l_abort_workflow_close_flag,
                 l_workflow_process_name
	  FROM   cs_incident_types_b
	  WHERE  incident_type_id = l_ServiceRequest_rec.incident_type_id
    	  AND    incident_subtype = G_SR_SUBTYPE
          ;

      EXCEPTION

	   WHEN NO_DATA_FOUND THEN
	       l_return_status := FND_API.G_RET_STS_ERROR;
		  CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                         ( p_token_an     => l_api_name_full,
			   p_token_v      => TO_CHAR(l_ServiceRequest_rec.incident_type_id),
			   p_token_p      => 'p_type_id' ,
                           p_table_name   => G_TABLE_NAME,
                           p_column_name => 'INCIDENT_TYPE_ID');

			    RAISE FND_API.G_EXC_ERROR;
      END ;

     --Call Abort workflow, if the status is being changed to CLOSE and the abort workflow on close
      IF (l_abort_workflow_close_flag = 'Y') AND (l_closed_flag = 'Y') THEN

	   IF (CS_Workflow_PKG.Is_Servereq_Item_Active
		 (p_request_number  => l_ServiceRequest_rec.incident_number,
                  p_wf_process_id   => l_ServiceRequest_rec.workflow_process_id )  = 'Y') THEN

           CS_Workflow_PUB.Cancel_Servereq_Workflow
            ( p_api_version     => 1.0,
            p_return_status   => l_return_status,
            p_msg_count       => x_msg_count,
            p_msg_data        => x_msg_data,
            p_request_number  => l_ServiceRequest_rec.incident_number,
            p_wf_process_id   => l_ServiceRequest_rec.workflow_process_id,
            p_user_id         => p_last_updated_by
            );
           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
      END IF;

     END IF;

    -- ------------------------------------------------------------------
    -- Validate and set the closed date.  If the status is not a closed
    -- status, set the closed date to NULL (and give a warning if the
    -- closed date was passed in).  If the status is a closed status,
    -- then validate the closed date if it was passed in.  If not,
    -- default sysdate into the closed date.
    -- ------------------------------------------------------------------
	-- for bug 3640344 - pkesani

    IF (l_closed_flag = 'Y') THEN
      IF (p_closed_date = FND_API.G_MISS_DATE OR p_closed_date IS NULL) THEN
        IF (l_ServiceRequest_rec.close_date IS NULL) THEN
          l_closed_date := SYSDATE;
        ELSE
          l_closed_date := l_ServiceRequest_rec.close_date;
        END IF;
      ELSE
        l_closed_date := p_closed_date;
     IF (p_closed_date IS NOT NULL) THEN

          CS_ServiceRequest_UTIL.Validate_Closed_Date(
          p_api_name       => G_PKG_NAME||'.'||l_api_name,
          p_parameter_name => 'p_closed_date',
          p_closed_date    => l_closed_date,
          p_request_date   => l_ServiceRequest_rec.incident_date,
          x_return_status  => l_return_status );

        END IF;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    ELSE
      l_closed_date := NULL;

      IF (p_closed_date = FND_API.G_MISS_DATE) OR
         (p_closed_date IS NULL) THEN
        NULL;
      ELSE
        CS_ServiceRequest_UTIL.Add_Param_Ignored_MSg
                          ( p_token_an     =>  l_api_name_full,
                            p_token_ip     =>  'p_closed_date',
                            p_table_name   =>  G_TABLE_NAME,
                            p_column_name  =>  'CLOSED_DATE');
      END IF;
    END IF;


--- If the status is updated to close status then,check to see if the
--- SR has any open tasks with restrict flag set to 'Y', If yes, return
---  error ( bug # 3512003).

    IF (l_closed_flag = 'Y') THEN
      CS_ServiceRequest_UTIL.TASK_RESTRICT_CLOSE_CROSS_VAL (
         p_incident_id           => p_request_id,
         p_status_id             => p_status_id,
         x_return_status         => l_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;


	--  ----------------------------------------------
    --  Code Changes for 11.5.10 Auto Close SR project
    --  Restrict closure if SR children cant be closed.
    -- ----------------------------------------------

 -- For bug 3332985
  IF ( p_validate_sr_closure = 'Y'  OR p_validate_sr_closure = 'y') THEN
      CS_SR_STATUS_PROPAGATION_PKG.VALIDATE_SR_CLOSURE(
              p_api_version        => p_api_version,
              p_init_msg_list      => fnd_api.g_false ,
              p_commit             => p_commit,
              p_service_request_id => p_request_id,
              p_user_id            => p_last_updated_by,
              p_resp_appl_id       => p_resp_id,
              p_login_id           => p_last_update_login,
              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count ,
              x_msg_data           => x_msg_data);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       IF (p_auto_close_child_entities='Y' OR p_auto_close_child_entities='y')  THEN

         CS_SR_STATUS_PROPAGATION_PKG.CLOSE_SR_CHILDREN(
              p_api_version         => p_api_version,
              p_init_msg_list       => fnd_api.g_false ,
              p_commit              => p_commit,
              p_validation_required =>'N',
              p_action_required     => 'Y',
              p_service_request_id  => p_request_id,
              p_user_id             => p_last_updated_by,
              p_resp_appl_id        =>  p_resp_id,
              p_login_id            => p_last_update_login,
              x_return_status       => l_return_status,
              x_msg_count           => x_msg_count ,
              x_msg_data            => x_msg_data);
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
     END IF;
  END IF;
    END IF;

    CS_SERVICEREQUEST_UTIL.get_reacted_resolved_dates
    ( p_incident_status_id         => p_status_id
    , p_old_incident_status_id     => l_servicerequest_rec.incident_status_id
    , p_old_incident_resolved_date => l_servicerequest_rec.incident_resolved_date
    , p_old_inc_responded_by_date  => l_servicerequest_rec.inc_responded_by_date
    , x_inc_responded_by_date      => l_inc_responded_by_date
    , x_incident_resolved_date     => l_incident_resolved_date
    , x_return_status              => l_return_status
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --added by sanjana ra for bug 8507917
   IF l_inc_responded_by_date IS NULL THEN
     l_inc_responded_by_date:=l_servicerequest_rec.inc_responded_by_date;
    END IF;
    IF l_incident_resolved_date IS NULL THEN
          l_incident_resolved_date:=l_servicerequest_rec.incident_resolved_date;
    END IF;
   --end of addition by sanjana rao

    -- ----------------------------------------------
    -- Update the status and insert the audit record
    -- ----------------------------------------------

    l_orig_status_id := l_ServiceRequest_rec.incident_status_id;
    l_orig_closed_date := l_ServiceRequest_rec.close_date ;

   /* Added call to get_status_flag for enh 2655115, to get the status flag
      based on the closed flag by shijain date 27th nov 2002*/

   l_status_flag:= get_status_flag ( p_status_id);

    -- Update CS_INCIDENTS table
    -- for the bug 3027154 - wrong date in the SR Log
    UPDATE cs_incidents_all_b
       SET incident_status_id = p_status_id,
        close_date            = l_closed_date,
        inc_responded_by_date = l_inc_responded_by_date,
        incident_resolved_date= l_incident_resolved_date,
        last_updated_by       = p_last_updated_by,
        last_update_date      = SYSDATE,
        last_update_login     = p_last_update_login,
        -- Added for enh. 2655115
        status_flag           = l_status_flag,
        object_version_number = p_object_version_number+1
     --Fixed bug#2775580,changed the where clause from current of to
     --checking the incident_id
     WHERE incident_id = p_request_id;

    CLOSE l_ServiceRequest_csr;

    -- ------------------------------------------------------
    -- Insert a record into the audit table
    -- ------------------------------------------------------

    --Fixed bug#2775580,added these statements to populate values in all the
    --columns with changed flag as N, except status_id and status_flag which are
    --the only columns which will be changed by calling this procedure.

-- Commented out this code since call to SR Child Audit API has been added
-- for audit record creation
-- anmukher --10/15/03
-- Removed the commented code which was used for the audit record assignment while calling the old audit api call.
-- spusegao -- 03/23/2004

   CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
  (P_incident_id           => p_request_id,
   P_updated_entity_code   => 'SR_HEADER',
   p_updated_entity_id     => p_request_id,
   p_entity_update_date    => SYSDATE,
   p_entity_activity_code  => 'U' ,
   p_status_id		   => p_status_id,
   p_old_status_id         => l_orig_status_id,
   p_closed_date	   => l_closed_date,
   p_old_closed_date       => l_orig_closed_date,
   p_owner_status_upd_flag => 'STATUS',
   p_user_id               => p_last_updated_by,
   p_old_inc_responded_by_date => l_servicerequest_rec.inc_responded_by_date,
   p_old_incident_resolved_date=> l_servicerequest_rec.incident_resolved_date,
   x_audit_id              => lx_audit_id,
   x_return_status         => lx_return_status,
   x_msg_count             => x_msg_count ,
   x_msg_data              => x_msg_data );

    IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- ------------------------------------------------------
    -- Insert a record into the calls table if the caller is
    -- not a workflow process
    -- ------------------------------------------------------
    IF NOT FND_API.To_Boolean(p_called_by_workflow) THEN
      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;     /* called by workflow */

      l_old_sr_rec.type_id                  := l_servicerequest_rec.incident_type_id;
      l_old_sr_rec.status_id                := l_servicerequest_rec.incident_status_id;
      l_old_sr_rec.severity_id              := l_servicerequest_rec.incident_severity_id;
      l_old_sr_rec.urgency_id               := l_servicerequest_rec.incident_urgency_id;
      l_old_sr_rec.owner_id                 := l_servicerequest_rec.incident_owner_id;
      l_old_sr_rec.owner_group_id           := l_servicerequest_rec.owner_group_id;
      l_old_sr_rec.customer_id              := l_servicerequest_rec.customer_id;
      l_old_sr_rec.customer_product_id      := l_servicerequest_rec.customer_product_id;
      l_old_sr_rec.inventory_item_id        := l_servicerequest_rec.inventory_item_id;
      l_old_sr_rec.problem_code             := l_servicerequest_rec.problem_code;
      l_old_sr_rec.summary                  := l_servicerequest_rec.summary;
      l_old_sr_rec.exp_resolution_date      := l_servicerequest_rec.expected_resolution_date;
      l_old_sr_rec.install_site_id          := l_servicerequest_rec.install_site_id;
      l_old_sr_rec.bill_to_site_id          := l_servicerequest_rec.bill_to_site_id;
      l_old_sr_rec.bill_to_contact_id       := l_servicerequest_rec.bill_to_contact_id;
      l_old_sr_rec.ship_to_site_id          := l_servicerequest_rec.ship_to_site_id;
      l_old_sr_rec.ship_to_contact_id       := l_servicerequest_rec.ship_to_contact_id;
      l_old_sr_rec.resolution_code          := l_servicerequest_rec.resolution_code;
      l_old_sr_rec.contract_service_id      := l_servicerequest_rec.contract_service_id;
      l_old_sr_rec.sr_creation_channel      := l_servicerequest_rec.sr_creation_channel;
      l_old_sr_rec.last_update_channel      := l_servicerequest_rec.last_update_channel;
      l_old_sr_rec.last_update_program_code := l_servicerequest_rec.last_update_program_code;

      l_new_sr_rec             := l_old_sr_rec ;
      l_new_sr_rec.status_id   := p_status_id  ;
      l_new_sr_rec.closed_date:= l_closed_date;

      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
         p_api_version           => p_api_version,
         p_init_msg_list         => fnd_api.g_false ,
         p_commit                => p_commit,
         p_validation_level      => p_validation_level,
         p_event_code            => 'UPDATE_SERVICE_REQUEST',
         p_incident_number       => l_ServiceRequest_rec.incident_number,
         p_user_id               => p_last_updated_by,
         p_resp_id               => p_resp_id,
         p_resp_appl_id          => NULL,
         p_old_sr_rec            => l_old_sr_rec,
         p_new_sr_rec            => l_new_sr_rec,
         p_contacts_table        => l_contacts,
         p_link_rec              => NULL,  -- using default value
         p_wf_process_id         => p_workflow_process_id,
         p_owner_id              => NULL,  -- using default value
         p_wf_manual_launch      => 'N' ,  -- using default value
         x_wf_process_id         => l_workflow_process_id,
         x_return_status         => lx_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         -- do nothing in this API. The BES wrapper API will have to trap this
         -- situation and send a notification to the SR owner that the BES has
         -- not been raised. If the BES API return back a failure status, it
         -- means only that the BES raise event has failed, and has nothing to
         -- do with the update of the SR.
         null;
      end if;
    -- Added this call for Misc ER: Owner auto assignment changes

        CS_SR_WORKITEM_PVT.Update_Workitem(
                p_api_version           => 1.0,
                p_init_msg_list         => fnd_api.g_false  ,
                p_commit                => p_commit       ,
                p_incident_id           => p_request_id,
                p_old_sr_rec            => l_ServiceRequest_rec,
                p_new_sr_rec            => l_new_sr_rec,
                p_user_id               => p_last_updated_by,
                p_resp_appl_id          => p_resp_id ,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
         );
      END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                      p_data  => x_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Status_PVT;
      IF (l_ServiceRequest_csr%ISOPEN) THEN
        CLOSE l_ServiceRequest_csr;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                        p_data      => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Status_PVT;
      IF (l_ServiceRequest_csr%ISOPEN) THEN
        CLOSE l_ServiceRequest_csr;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                        p_data      => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO Update_Status_PVT;
      IF (l_ServiceRequest_csr%ISOPEN) THEN
        CLOSE l_ServiceRequest_csr;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                        l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                        p_data       => x_msg_data );

END Update_Status;

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name      Desc
-- -------- --------- ----------------------------------------------------------
-- 03/25/05 smisra    Bug 4028675
--                    Modified this procedure to determine unassigned indicator
--                    and updated SR table with the same
-- 05/27/05 smisra    Bug 4227769
--                    removed update to cs_incidents_all_tl table because it
--                    was updating only obsolete columns owner and group owner.
-- 07/11/05 smisra    called get_status_detail for SR status and if disallow
--                    request update is Y then raise error
-- 07/11/05 smisra    Bug 4489746
--                    Passed UPDATE_OLD to validate_type call because we need to
--                    just check user's access to SR
-- 07/20/05 smisra    if parameter p_owner_group_id is passed as g_miss_num,
--                    then g_miss_num is updated into database. to aviod this,
--                    added a new variable l_owner_group_id. set this using
--                    p_owner_group_id, if p_owner_group_id is g_miss_num then
--                    set l_owner_group_id as value from Sr record.
--                    Used l_owner_group_id in owner validation and further
--                    processing.
-- 07/21/05 smisra    Bug 3215462
--                    Add a call to CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT
-- 12/30/05 smisra    Bug 4773215
--                    Passed x_resource_type and x_support_site_id to
--                    validate owner call
--                    Updated incident table with derived value of resource type
--                    Passed derived value of resource type to audit procedure
-- -----------------------------------------------------------------------------
PROCEDURE Update_Owner
  ( p_api_version        IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit             IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level   IN   NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status      OUT  NOCOPY VARCHAR2,
    x_msg_count          OUT  NOCOPY NUMBER,
    x_msg_data           OUT  NOCOPY VARCHAR2,
    p_request_id         IN   NUMBER,
    p_object_version_number   IN    NUMBER,
    p_resp_id            IN   NUMBER   DEFAULT NULL,
    p_resp_appl_id       IN   NUMBER   DEFAULT NULL,
    p_owner_id           IN   NUMBER,
    p_owner_group_id     IN   NUMBER,
    p_resource_type      IN   VARCHAR2,
    p_last_updated_by    IN   NUMBER,
    p_last_update_login  IN   NUMBER   DEFAULT NULL,
    p_last_update_date   IN   DATE,
    p_audit_comments     IN   VARCHAR2 DEFAULT NULL,
    p_called_by_workflow IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id     IN   NUMBER   DEFAULT NULL,
    p_comments                IN   VARCHAR2 DEFAULT NULL,
    p_public_comment_flag     IN   VARCHAR2 DEFAULT fnd_api.g_false,
    p_parent_interaction_id   IN   NUMBER   DEFAULT NULL,
    x_interaction_id          OUT  NOCOPY NUMBER
  )
  IS
     l_api_name          CONSTANT VARCHAR2(30) := 'Update_Owner';
     l_api_version       CONSTANT NUMBER       := 2.0;
     l_api_name_full     CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
     l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
     l_return_status        VARCHAR2(1);
     l_orig_owner_id        NUMBER;
     l_orig_owner_group_id  NUMBER;
     l_orig_group_type      VARCHAR2(30);
     l_orig_resource_type   VARCHAR2(30);
     l_audit_vals_rec	    sr_audit_rec_type;
     l_msg_id               NUMBER;
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(2000);

     p_audit_id             NUMBER;

     -- Added for bug 2725543
     l_group_name           VARCHAR2(60);

/* ****************
   l_old_ServiceRequest_rec is now changed to type sr_oldvalues_rec_type .

   Replacing the select list of columns with a select * so that the
   subtype defined in the spec can be used to pass the old SR values as
   a parameter to other procedures

* *****************/

     CURSOR L_SERVICEREQUEST_CSR IS
     SELECT *
     from   cs_incidents_all_vl
     where  incident_id = p_request_id
     and    object_version_number = p_object_version_number
     for    update of incident_owner_id nowait;

 -- This rec type was changed to sr_oldvalues_rec_type as the
 -- workitem API (Misc ER owner Auto Assginment )needed a record type
 -- with old values , also the API validations needed the oldvalues_rec .

    --  l_ServiceRequest_rec      l_ServiceRequest_csr%ROWTYPE;
     l_ServiceRequest_rec    sr_oldvalues_rec_type;
     l_new_sr_rec            service_request_rec_type;
     l_old_sr_rec            service_request_rec_type;

     l_owner_name              VARCHAR2(240);
	 l_owner_id                NUMBER;
     l_org_id                  NUMBER;
     l_audit_id                NUMBER;

   -- Local variable to store business usage for security validation
   l_business_usage       VARCHAR2(30);

   -- Local variable to store attribute if security is enabled for self service resps.
   l_ss_sr_type_restrict   VARCHAR2(10);

   -- Local variable to get the return status of validate type for security check
   lx_return_status              VARCHAR2(3);

   l_old_cmro_flag               VARCHAR2(3);
   l_old_maintenance_flag        VARCHAR2(3);

   -- Added for Auditing --anmukher --10/15/03
   lx_audit_id			 NUMBER;
l_unasgn_ind                  NUMBER;
l_sr_related_data             RELATED_DATA_TYPE;
l_owner_group_id              jtf_rs_groups_b.group_id % TYPE;
l_workflow_process_id         NUMBER;
l_contacts                    contacts_table;
l_resource_type               cs_incidents_all_b.resource_type   % TYPE;
l_support_site_id             cs_incidents_all_b.site_id % TYPE;

BEGIN

    -- ---------------------------------------
    -- Standard API stuff
    -- ---------------------------------------
    -- Establish savepoint
    SAVEPOINT Update_Owner_PVT;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if requested
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_audit_comments:' || P_audit_comments
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_object_version_number:' || P_object_version_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_last_updated_by:' || p_last_updated_by
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_last_update_login:' || p_last_update_login
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_last_update_date:' || p_last_update_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_owner_id:' || P_owner_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_owner_group_id:' || P_owner_group_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Resource_Type:' || P_Resource_Type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_request_id:' || p_request_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_parent_interaction_id:' || p_parent_interaction_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Public_Comment_Flag:' || P_Public_Comment_Flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Called_by_workflow:' || P_Called_by_workflow
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Workflow_process_id:' || P_Workflow_process_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_audit_comments:' || P_audit_comments
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_Comments:' || P_Comments
    );

  END IF;

  -- Initialize the New Audit Record ******
     Initialize_audit_rec(
                        p_sr_audit_record  => l_audit_vals_rec) ;
  -- Initialize the new record and assign the required values for
  -- workitem call

     initialize_rec ( p_sr_record    => l_new_sr_rec );

     l_new_sr_rec.owner_id := p_owner_id ;
     l_new_sr_rec.resource_type := p_resource_type;
     l_new_sr_rec.public_comment_flag := p_public_comment_flag;
     l_new_sr_rec.parent_interaction_id:= p_parent_interaction_id;


    -- ----------------------------------------
    -- Open cursor for update
    -- ----------------------------------------
    -- Fetch the record for update
    OPEN  l_ServiceRequest_csr;
    FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;
    IF (l_ServiceRequest_csr%NOTFOUND) THEN

        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                               p_token_an     => l_api_name_full,
                               p_token_v      => TO_CHAR(p_request_id),
                               p_token_p      => 'p_request_id',
                               p_table_name   => G_TABLE_NAME,
                               p_column_name  => 'REQUEST_ID' );

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_owner_group_id = FND_API.G_MISS_NUM
    THEN
       l_owner_group_id := l_servicerequest_rec.owner_group_id;
    ELSE
       l_owner_group_id := p_owner_group_id;
    END IF;
    l_new_sr_rec.owner_group_id:= l_owner_group_id;
    -- --------------------------------------------------------
    -- If the new owner is the same as old, there's no need
    -- to continue
    -- --------------------------------------------------------
    IF ((p_owner_id = l_ServiceRequest_rec.incident_owner_id) AND
        (l_owner_group_id = l_ServiceRequest_rec.owner_group_id) ) THEN

        CS_ServiceRequest_UTIL.Add_Same_Val_Update_Msg(
                               p_token_an     =>  l_api_name_full,
                               p_token_p      =>  'p_owner_id/p_owner_group_id',
                               p_table_name   =>  G_TABLE_NAME,
                               p_column_name  =>  'OWNER_GROUP_ID');

        CLOSE l_ServiceRequest_csr;
        RETURN;
    END IF;

    -- -------------------------------------
    -- Perform validation when necessary
    -- -------------------------------------
    IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
       CS_ServiceRequest_UTIL.Validate_Who_Info(
                              p_api_name              => l_api_name_full,
                              p_parameter_name_usr    => 'p_last_updated_by',
                              p_parameter_name_login  => 'p_last_update_login',
                              p_user_id               => p_last_updated_by,
                              p_login_id              => p_last_update_login,
                              x_return_status         => l_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

               RAISE FND_API.G_EXC_ERROR;
        END IF;

      -- Service security validation
      -- Validate if the current responsibility has access to the SR being update.
      -- Invoke the VALIDATE_TYPE procedure that has the logic to check for security
      -- access

      -- Get the business usage of the responsibility that is attempting to create
      -- the SR.
      get_business_usage (
         p_responsibility_id      => p_resp_id,
         p_application_id         => fnd_global.resp_appl_id,
         x_business_usage         => l_business_usage );

      -- Get indicator of self service security enabled or not
      if ( l_business_usage = 'SELF_SERVICE' ) then
         get_ss_sec_enabled (
	    x_ss_sr_type_restrict => l_ss_sr_type_restrict );
      end if;

      -- For bug 3370562 - pass resp_id an appl_id
      -- validate security in update; first against old sr type
      cs_servicerequest_util.validate_type (
         p_parameter_name       => NULL,
         p_type_id   	        => l_servicerequest_rec.incident_type_id,
         p_subtype  	        => G_SR_SUBTYPE,
         p_status_id            => l_servicerequest_rec.incident_status_id, -- not used
         p_resp_id              => p_resp_id,
         p_resp_appl_id         => fnd_global.resp_appl_id,
         p_business_usage       => l_business_usage,
         p_ss_srtype_restrict   => l_ss_sr_type_restrict,
         p_operation            => 'UPDATE_OLD',
         x_return_status        => lx_return_status,
         x_cmro_flag            => l_old_cmro_flag,
         x_maintenance_flag     => l_old_maintenance_flag );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- security violation; responsibility does not have access to SR Type
         -- being created. Stop and raise error.
         RAISE FND_API.G_EXC_ERROR;
      end if;
      CS_SERVICEREQUEST_UTIL.get_status_details
      ( p_status_id                  => l_servicerequest_rec.incident_status_id
      , x_close_flag                 => l_sr_related_data.close_flag
      , x_disallow_request_update    => l_sr_related_data.disallow_request_update
      , x_disallow_agent_dispatch    => l_sr_related_data.disallow_owner_update
      , x_disallow_product_update    => l_sr_related_data.disallow_product_update
      , x_pending_approval_flag      => l_sr_related_data.pending_approval_flag
      , x_intermediate_status_id     => l_sr_related_data.intermediate_status_id
      , x_approval_action_status_id  => l_sr_related_data.approval_action_status_id
      , x_rejection_action_status_id => l_sr_related_data.rejection_action_status_id
      , x_return_status              => l_return_status
      );
      IF l_sr_related_data.disallow_request_update = 'Y'
      THEN
        FND_MESSAGE.set_name('CS', 'CS_API_SR_ONLY_STATUS_UPDATED');
        FND_MESSAGE.set_token('API_NAME', l_api_name_full);
        FND_MSG_PUB.add_detail
        ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.INCIDENT_OWNER_ID'
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --
      -- Can't update the owner when there's an active workflow process
      --
        IF (l_ServiceRequest_rec.workflow_process_id IS NOT NULL) AND
            CS_Workflow_PKG.Is_Servereq_Item_Active
               ( p_request_number  => l_ServiceRequest_rec.incident_number,
                 p_wf_process_id   => l_ServiceRequest_rec.workflow_process_id)
            = 'Y'
        AND ((FND_API.To_Boolean(p_called_by_workflow) = FALSE)
        OR   (l_ServiceRequest_rec.incident_owner_id IS NOT NULL
        AND   p_owner_id IS NULL)
        OR   (l_ServiceRequest_rec.owner_group_id <> l_owner_group_id)
        OR   (NOT (l_ServiceRequest_rec.workflow_process_id=p_workflow_process_id)))
        THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('CS', 'CS_API_SR_OWNER_READONLY');
                   FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                   FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
        END IF;

    --Commented this code after moving it to CS_SR_AUDIT_CHILD API
    --in CS_SR_CHILD_AUDIT package. This API will be calling the Child
    -- Audit API henceforth for audit record creation.
    -- anmukher --10/16/03
      /* Made changes by shijain for bug 2747616*/
/*
      l_orig_owner_id       := l_ServiceRequest_rec.incident_owner_id;
      l_orig_owner_group_id := l_ServiceRequest_rec.owner_group_id;
      l_orig_group_type     := l_ServiceRequest_rec.group_type;
      l_orig_resource_type  := l_ServiceRequest_rec.resource_type;

      IF ((p_owner_id IS NOT NULL
         AND l_orig_owner_id IS NULL)
         OR (p_owner_id IS NULL
         AND l_orig_owner_id IS NOT NULL)
         OR (p_owner_id IS NOT NULL
         AND l_orig_owner_id IS NOT NULL
         AND p_owner_id <> l_orig_owner_id)) THEN

             l_audit_vals_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
             l_audit_vals_rec.OLD_INCIDENT_OWNER_ID      := l_orig_owner_id;
             l_audit_vals_rec.INCIDENT_OWNER_ID          := p_owner_id;
      ELSE
             l_audit_vals_rec.CHANGE_INCIDENT_OWNER_FLAG := 'N';
             l_audit_vals_rec.OLD_INCIDENT_OWNER_ID      := l_orig_owner_id;
             l_audit_vals_rec.INCIDENT_OWNER_ID          := l_orig_owner_id;
      END IF;

      IF ((p_owner_group_id IS NOT NULL
         AND l_orig_owner_group_id IS NULL)
         OR (p_owner_group_id IS NULL
         AND l_orig_owner_group_id IS NOT NULL)
         OR (p_owner_group_id IS NOT NULL
         AND l_orig_owner_group_id IS NOT NULL
         AND p_owner_group_id <> l_orig_owner_group_id)) THEN

             l_audit_vals_rec.change_group_flag := 'Y';
             l_audit_vals_rec.old_group_id      := l_orig_owner_group_id ;
             l_audit_vals_rec.group_id          := p_owner_group_id ;
      ELSE
             l_audit_vals_rec.change_group_flag := 'N';
             l_audit_vals_rec.old_group_id      := l_orig_owner_group_id ;
             l_audit_vals_rec.group_id          := l_orig_owner_group_id ;
      END IF;

      IF (p_owner_group_id IS NOT NULL AND p_owner_group_id<>FND_API.G_MISS_NUM)
      THEN
             l_audit_vals_rec.group_type:='RS_GROUP';
      ELSE
             l_audit_vals_rec.group_type:=NULL;
      END IF;

      IF ((l_audit_vals_rec.group_type IS NOT NULL
          AND l_audit_vals_rec.old_group_type IS NULL)
          OR (l_audit_vals_rec.group_type IS NULL
          AND l_audit_vals_rec.old_group_type IS NOT NULL))
      THEN
             l_audit_vals_rec.change_group_type_flag   := 'Y';
             l_audit_vals_rec.old_group_type           := l_orig_group_type ;
      ELSE
             l_audit_vals_rec.change_group_type_flag   := 'N';
             l_audit_vals_rec.old_group_type           := l_orig_group_type ;
             l_audit_vals_rec.group_type               := l_orig_group_type ;
      END IF;

      IF ((p_resource_type IS NOT NULL
         AND l_orig_resource_type IS NULL)
         OR (p_resource_type IS NULL
         AND l_orig_resource_type IS NOT NULL)
         OR (p_resource_type IS NOT NULL
         AND l_orig_resource_type IS NOT NULL
         AND p_resource_type <> l_orig_resource_type)) THEN

             l_audit_vals_rec.change_resource_type_flag   := 'Y';
             l_audit_vals_rec.old_resource_type      := l_orig_resource_type ;
             l_audit_vals_rec.resource_type          := p_resource_type ;
      ELSE
             l_audit_vals_rec.change_resource_type_flag   := 'N';
             l_audit_vals_rec.old_resource_type      := l_orig_resource_type ;
             l_audit_vals_rec.resource_type          := l_orig_resource_type ;
      END IF;
*/

      -- Added for bug 2725543
        IF (p_owner_group_id <> FND_API.G_MISS_NUM) THEN
              CS_ServiceRequest_UTIL.Validate_Group_Id
                ( p_api_name       => l_api_name_full,
                  p_parameter_name => 'p_owner_group_id',
                  p_group_type     => 'RS_GROUP',
                  p_owner_group_id => p_owner_group_id,
                  x_group_name     => l_group_name,
                  x_return_status  => l_return_status
                 );

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
         END IF;

         CS_ServiceRequest_UTIL.Validate_Owner
         ( p_api_name         => l_api_name_full
         , p_parameter_name   => 'p_owner_id'
         , p_owner_id         => p_owner_id
         , p_group_type       => 'RS_GROUP'
         , p_owner_group_id   => l_owner_group_id
         , p_org_id           => l_org_id
         , p_incident_type_id => l_ServiceRequest_rec.incident_type_id  -- new for 11.5.10
         , x_owner_name       => l_owner_name
         , x_owner_id         => l_owner_id
         , x_resource_type    => l_resource_type
         , x_support_site_id  => l_support_site_id
         , x_return_status    => l_return_status
         );

        IF (l_owner_id IS NULL)
        THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    -- Get unassigned_indicator
    l_unasgn_ind := CS_SERVICEREQUEST_UTIL.get_unassigned_indicator(p_owner_id, l_owner_group_id);
    -- ----------------------------------------------
    -- Update the owner and insert the audit record
    -- ----------------------------------------------
    -- Update CS_INCIDENTS table

    UPDATE cs_incidents_all_b
       SET incident_owner_id     = p_owner_id,
           owner_group_id        = l_owner_group_id,
           resource_type         = l_resource_type,
           last_updated_by       = p_last_updated_by,
           last_update_date      = p_last_update_date,
           last_update_login     = p_last_update_login,
           unassigned_indicator  = l_unasgn_ind,
           object_version_number = p_object_version_number+1
    WHERE incident_id = p_request_id ;

  CLOSE l_ServiceRequest_csr;
    -- ------------------------------------------------------
    -- Insert a record into the audit table --- check for audit
    -- ------------------------------------------------------
   --added this code on dec 14th, so that workflow can call this api
   --and the audit will work accordingly
   --Since this is update owner, all the other atributes will not be updated,
   --hence just use the values sitting in the db as the current values for log.
   --Put this field value in the audit table, dont set flag

-- Commented out this code since a call to CS_SR_AUDIT_CHILD API is being added
-- anmukher -- 10/15/03
-- Removed the commented code used to populate the audit record structure which was used by the old call to
-- the audit API. This call is replaced by the new call to the new child audit API.

   -- Added call to Child Audit API for audit record creation
   --anmukher --10/15/03

      l_orig_owner_id       := l_ServiceRequest_rec.incident_owner_id;
      l_orig_owner_group_id := l_ServiceRequest_rec.owner_group_id;
      l_orig_resource_type  := l_ServiceRequest_rec.resource_type ;

   CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
  (P_incident_id           => p_request_id,
   P_updated_entity_code   => 'SR_HEADER',
   p_updated_entity_id     => p_request_id,
   p_entity_update_date    => p_last_update_date, -- sysdate
   p_entity_activity_code  => 'U' ,
   p_owner_id		   => p_owner_id,
   p_old_owner_id	   => l_orig_owner_id,
   p_owner_group_id	   => l_owner_group_id,
   p_old_owner_group_id	   => l_orig_owner_group_id,
   p_resource_type	   => l_resource_type,
   p_old_resource_type	   => l_orig_resource_type,
   p_owner_status_upd_flag => 'OWNER',
   p_useR_id               => p_last_updated_by,
   x_audit_id              => lx_audit_id,
   x_return_status         => lx_return_status,
   x_msg_count             => x_msg_count ,
   x_msg_data              => x_msg_data );

    IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- ------------------------------------------------------
    -- Insert a record into the calls table if the caller is
    -- not a workflow process
    -- ------------------------------------------------------
    IF NOT FND_API.To_Boolean(p_called_by_workflow) THEN
      IF (p_parent_interaction_id IS NULL) THEN
        /* CREATE INTERACTION */ /* l_interaction_id := */
        NULL;
      END IF;

      --
      -- Create INTERACTION_ACTIVITY
      --

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;   /* called by workflow */

      l_old_sr_rec.type_id                  := l_servicerequest_rec.incident_type_id;
      l_old_sr_rec.status_id                := l_servicerequest_rec.incident_status_id;
      l_old_sr_rec.severity_id              := l_servicerequest_rec.incident_severity_id;
      l_old_sr_rec.urgency_id               := l_servicerequest_rec.incident_urgency_id;
      l_old_sr_rec.owner_id                 := l_servicerequest_rec.incident_owner_id;
      l_old_sr_rec.owner_group_id           := l_servicerequest_rec.owner_group_id;
      l_old_sr_rec.customer_id              := l_servicerequest_rec.customer_id;
      l_old_sr_rec.customer_product_id      := l_servicerequest_rec.customer_product_id;
      l_old_sr_rec.inventory_item_id        := l_servicerequest_rec.inventory_item_id;
      l_old_sr_rec.problem_code             := l_servicerequest_rec.problem_code;
      l_old_sr_rec.summary                  := l_servicerequest_rec.summary;
      l_old_sr_rec.exp_resolution_date      := l_servicerequest_rec.expected_resolution_date;
      l_old_sr_rec.install_site_id          := l_servicerequest_rec.install_site_id;
      l_old_sr_rec.bill_to_site_id          := l_servicerequest_rec.bill_to_site_id;
      l_old_sr_rec.bill_to_contact_id       := l_servicerequest_rec.bill_to_contact_id;
      l_old_sr_rec.ship_to_site_id          := l_servicerequest_rec.ship_to_site_id;
      l_old_sr_rec.ship_to_contact_id       := l_servicerequest_rec.ship_to_contact_id;
      l_old_sr_rec.resolution_code          := l_servicerequest_rec.resolution_code;
      l_old_sr_rec.contract_service_id      := l_servicerequest_rec.contract_service_id;
      l_old_sr_rec.sr_creation_channel      := l_servicerequest_rec.sr_creation_channel;
      l_old_sr_rec.last_update_channel      := l_servicerequest_rec.last_update_channel;
      l_old_sr_rec.last_update_program_code := l_servicerequest_rec.last_update_program_code;

      l_new_sr_rec                := l_old_sr_rec    ;
      l_new_sr_rec.owner_id       := p_owner_id      ;
      l_new_sr_rec.resource_type  := p_resource_type ;
      l_new_sr_rec.owner_group_id := l_owner_group_id;

      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
         p_api_version           => p_api_version,
         p_init_msg_list         => fnd_api.g_false ,
         p_commit                => p_commit,
         p_validation_level      => p_validation_level,
         p_event_code            => 'UPDATE_SERVICE_REQUEST',
         p_incident_number       => l_ServiceRequest_rec.incident_number,
         p_user_id               => p_last_updated_by,
         p_resp_id               => p_resp_id,
         p_resp_appl_id          => p_resp_appl_id,
         p_old_sr_rec            => l_old_sr_rec,
         p_new_sr_rec            => l_new_sr_rec,
         p_contacts_table        => l_contacts,
         p_link_rec              => NULL,  -- using default value
         p_wf_process_id         => p_workflow_process_id,
         p_owner_id              => NULL,  -- using default value
         p_wf_manual_launch      => 'N' ,  -- using default value
         x_wf_process_id         => l_workflow_process_id,
         x_return_status         => lx_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data );

      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         -- do nothing in this API. The BES wrapper API will have to trap this
         -- situation and send a notification to the SR owner that the BES has
         -- not been raised. If the BES API return back a failure status, it
         -- means only that the BES raise event has failed, and has nothing to
         -- do with the update of the SR.
         null;
      end if;

     -- Added this call for Misc ER: Owner auto assignment changes

        CS_SR_WORKITEM_PVT.Update_Workitem(
                p_api_version           => 1.0,
                p_init_msg_list         => fnd_api.g_false  ,
                p_commit                => p_commit       ,
                p_incident_id           => p_request_id,
                p_old_sr_rec            => l_ServiceRequest_rec,
                p_new_sr_rec            => l_new_sr_rec,
                p_user_id               => p_last_updated_by,
                p_resp_appl_id          => p_resp_id ,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
         );
       END IF;


    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                      p_data  => x_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Owner_PVT;

      IF (l_ServiceRequest_csr%ISOPEN) THEN
          CLOSE l_ServiceRequest_csr;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                                 p_data   => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Owner_PVT;

      IF (l_ServiceRequest_csr%ISOPEN) THEN
          CLOSE l_ServiceRequest_csr;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                                 p_data   => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO Update_Owner_PVT;

      IF (l_ServiceRequest_csr%ISOPEN) THEN
          CLOSE l_ServiceRequest_csr;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                                 p_data   => x_msg_data );

END Update_Owner;

-- -------------------------------------------------------------------
-- Create_Audit_Record
-- -------------------------------------------------------------------
  PROCEDURE Create_Audit_Record (
          p_api_version         IN NUMBER,
          p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit              IN VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status       OUT NOCOPY VARCHAR2,
          x_msg_count           OUT NOCOPY NUMBER,
          x_msg_data            OUT NOCOPY VARCHAR2,
          p_request_id          IN NUMBER,
          p_audit_id            IN NUMBER,
          p_audit_vals_rec      IN sr_audit_rec_type,
          p_action_id           IN NUMBER   DEFAULT FND_API.G_MISS_NUM,
          p_wf_process_name     IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
          p_wf_process_itemkey  IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
          p_user_id             IN NUMBER,
          p_login_id            IN NUMBER   DEFAULT NULL,
          p_last_update_date    IN DATE,
          p_creation_date       IN DATE,
          p_comments            IN VARCHAR2 DEFAULT NULL,
          x_audit_id            OUT NOCOPY NUMBER
     ) IS
    l_api_name   		CONSTANT VARCHAR2(30) := 'Create_Audit_Record';
    l_api_version 		CONSTANT NUMBER       := 2.0;
    l_audit_id             	NUMBER;
    l_incident_audit_id 	NUMBER;
    l_audit_vals_rec		sr_audit_rec_type := p_audit_vals_rec;

  BEGIN
    -- Establish savepoint
    SAVEPOINT Create_Audit_Record_PVT;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                            p_api_version,
                            l_api_name,
                            G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if requested
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Added code for bug# 1874546------jngeorge ------07/18/01
    -- Check if owner has changed
    IF (p_audit_vals_rec.change_incident_owner_flag = 'Y' ) THEN
      IF (l_audit_vals_rec.old_resource_type = l_audit_vals_rec.resource_type ) THEN
         l_audit_vals_rec.change_resource_type_flag  :='N';
      END IF;
    END IF;

    IF (p_audit_vals_rec.create_manual_action = 'Y') THEN
	IF (p_action_id <> FND_API.G_MISS_NUM) THEN
		l_audit_vals_rec.action_id := p_action_id;
	END IF;
    END IF;

    -- Check for new workflow
    IF (p_audit_vals_rec.new_workflow_flag = 'Y') THEN
	IF (p_wf_process_name <> FND_API.G_MISS_CHAR) THEN
      		l_audit_vals_rec.workflow_process_name := p_wf_process_name;
	END IF;

	IF (p_wf_process_itemkey <> FND_API.G_MISS_CHAR) THEN
      		l_audit_vals_rec.workflow_process_itemkey := p_wf_process_itemkey;
	END IF;
    END IF;

    --------Added code for bug# 1874546------jngeorge ------07/18/01
    IF (p_audit_vals_rec.change_resource_type_flag = 'Y') AND
       (p_audit_vals_rec.old_resource_type <> p_audit_vals_rec.resource_type) THEN
      l_audit_vals_rec.old_resource_type := p_audit_Vals_rec.old_resource_type;
      l_audit_vals_rec.resource_type     := p_audit_Vals_rec.resource_type;
    ELSE
      IF (p_audit_vals_rec.change_incident_owner_flag = 'N' ) THEN
        l_audit_vals_rec.resource_type     := p_audit_Vals_rec.resource_type;
      END IF;
    END IF;

   IF (p_audit_id IS NOT NULL AND
       p_audit_id <> FND_API.G_MISS_NUM) THEN
     l_audit_id := p_audit_id;
   ELSE
     SELECT cs_incidents_audit_s1.NEXTVAL INTO l_audit_id  FROM dual;
     x_audit_id := l_audit_id;
   END IF;

    INSERT INTO cs_incidents_audit_b (
                incident_audit_id            ,
                incident_id                  ,
                last_update_date             ,
                last_updated_by              ,
                creation_date                ,
                created_by                   ,
                last_update_login            ,
                creation_time                ,
                incident_status_id           ,
                old_incident_status_id       ,
                change_incident_status_flag  ,
                incident_type_id             ,
                old_incident_type_id         ,
                change_incident_type_flag    ,
                incident_urgency_id          ,
                old_incident_urgency_id      ,
                change_incident_urgency_flag ,
                incident_severity_id         ,
                old_incident_severity_id     ,
                change_incident_severity_flag,
                incident_owner_id            ,
                old_incident_owner_id        ,
                change_incident_owner_flag   ,
                create_manual_action         ,
                action_id                    ,
                expected_resolution_date     ,
                old_expected_resolution_date ,
                change_resolution_flag       ,
                new_workflow_flag            ,
                workflow_process_name        ,
                workflow_process_itemkey     ,
                group_id,
                old_group_id,
	        change_group_flag,
                group_type,
                old_group_type,
                change_group_type_flag,
                inv_platform_org_id,
                old_inv_platform_org_id,
                change_platform_org_id_flag,
                owner_assigned_time,
                old_owner_assigned_time,
                change_assigned_time_flag,
	        obligation_date,
	        old_obligation_date,
	        change_obligation_flag,
		site_id,
		old_site_id,
		change_site_flag,
		bill_to_contact_id,
		old_bill_to_contact_id,
		change_bill_to_flag,
		ship_to_contact_id,
		old_ship_to_contact_id,
		change_ship_to_flag,
		close_date,
		old_close_date,
		change_close_date_flag,
		customer_product_id,
		old_customer_product_id,
		change_customer_product_flag,
		platform_id,
		old_platform_id,
		change_platform_id_flag,
                product_revision,
                old_product_revision,
                change_product_revision_flag,
                component_version,
                old_component_version,
                change_comp_ver_flag,
                subcomponent_version,
                old_subcomponent_version,
                change_subcomp_ver_flag,
		cp_component_id,
		old_cp_component_id,
		change_cp_component_id_flag,
		cp_component_version_id,
		old_cp_component_version_id,
		change_cp_comp_ver_id_flag,
		cp_subcomponent_id,
		old_cp_subcomponent_id,
		change_cp_subcomponent_id_flag,
		cp_subcomponent_version_id,
		old_cp_subcomponent_version_id,
		change_cp_subcomp_ver_id_flag,
		cp_revision_id,
		old_cp_revision_id,
		change_cp_revision_id_flag,
 		inv_item_revision,
 		old_inv_item_revision,
 		change_inv_item_revision,
 		inv_component_id,
 		old_inv_component_id,
 		change_inv_component_id,
		inv_component_version,
 		old_inv_component_version,
 		change_inv_component_version,
		inv_subcomponent_id,
 		old_inv_subcomponent_id,
 		change_inv_subcomponent_id,
		inv_subcomponent_version,
 		old_inv_subcomponent_version,
 		change_inv_subcomp_version,
		territory_id,
		old_territory_id,
		change_territory_id_flag,
		resource_type,
		old_resource_type,
		change_resource_type_flag,
         	object_version_number,
		audit_field,
                inventory_item_id ,
                old_inventory_item_id,
                change_inventory_item_flag,
                inv_organization_id,
                old_inv_organization_id,
                change_inv_organization_flag,
                status_flag ,
                old_status_flag ,
                change_status_flag ,
                incident_date,
                old_incident_date,
                change_incident_date_flag,
                platform_version_id,
                old_platform_version_id,
                change_plat_ver_id_flag,
                language_id,
                old_language_id,
                change_language_id_flag,
           --   primary_contact_id ,
           --   change_primary_contact_flag ,
           --   old_primary_contact_id,
                -- Added new audit columns for 11.5.10 Auditing project --anmukher --09/10/03
                UPGRADE_FLAG_FOR_CREATE                  ,
                OLD_INCIDENT_NUMBER                      ,
                INCIDENT_NUMBER                          ,
                OLD_CUSTOMER_ID                          ,
                CUSTOMER_ID                              ,
                OLD_BILL_TO_SITE_USE_ID                  ,
                BILL_TO_SITE_USE_ID                      ,
                OLD_EMPLOYEE_ID                          ,
                EMPLOYEE_ID                              ,
                OLD_SHIP_TO_SITE_USE_ID                  ,
                SHIP_TO_SITE_USE_ID                      ,
                OLD_PROBLEM_CODE                         ,
                PROBLEM_CODE                             ,
                OLD_ACTUAL_RESOLUTION_DATE               ,
                ACTUAL_RESOLUTION_DATE                   ,
                OLD_INSTALL_SITE_USE_ID                  ,
                INSTALL_SITE_USE_ID                      ,
                OLD_CURRENT_SERIAL_NUMBER                ,
                CURRENT_SERIAL_NUMBER                    ,
                OLD_SYSTEM_ID                            ,
                SYSTEM_ID                                ,
                OLD_INCIDENT_ATTRIBUTE_1                 ,
                INCIDENT_ATTRIBUTE_1                     ,
                OLD_INCIDENT_ATTRIBUTE_2                 ,
                INCIDENT_ATTRIBUTE_2                     ,
                OLD_INCIDENT_ATTRIBUTE_3                 ,
                INCIDENT_ATTRIBUTE_3                     ,
                OLD_INCIDENT_ATTRIBUTE_4                 ,
                INCIDENT_ATTRIBUTE_4                     ,
                OLD_INCIDENT_ATTRIBUTE_5                 ,
                INCIDENT_ATTRIBUTE_5                     ,
                OLD_INCIDENT_ATTRIBUTE_6                 ,
                INCIDENT_ATTRIBUTE_6                     ,
                OLD_INCIDENT_ATTRIBUTE_7                 ,
                INCIDENT_ATTRIBUTE_7                     ,
                OLD_INCIDENT_ATTRIBUTE_8                 ,
                INCIDENT_ATTRIBUTE_8                     ,
                OLD_INCIDENT_ATTRIBUTE_9                 ,
                INCIDENT_ATTRIBUTE_9                     ,
                OLD_INCIDENT_ATTRIBUTE_10                ,
                INCIDENT_ATTRIBUTE_10                    ,
                OLD_INCIDENT_ATTRIBUTE_11                ,
                INCIDENT_ATTRIBUTE_11                    ,
                OLD_INCIDENT_ATTRIBUTE_12                ,
                INCIDENT_ATTRIBUTE_12                    ,
                OLD_INCIDENT_ATTRIBUTE_13                ,
                INCIDENT_ATTRIBUTE_13                    ,
                OLD_INCIDENT_ATTRIBUTE_14                ,
                INCIDENT_ATTRIBUTE_14                    ,
                OLD_INCIDENT_ATTRIBUTE_15                ,
                INCIDENT_ATTRIBUTE_15                    ,
                OLD_INCIDENT_CONTEXT                     ,
                INCIDENT_CONTEXT                         ,
                OLD_RESOLUTION_CODE                      ,
                RESOLUTION_CODE                          ,
                OLD_ORIGINAL_ORDER_NUMBER                ,
                ORIGINAL_ORDER_NUMBER                    ,
                OLD_ORG_ID                               ,
                ORG_ID                                   ,
                OLD_PURCHASE_ORDER_NUMBER                ,
                PURCHASE_ORDER_NUMBER                    ,
                OLD_PUBLISH_FLAG                         ,
                PUBLISH_FLAG                             ,
                OLD_QA_COLLECTION_ID                     ,
                QA_COLLECTION_ID                         ,
                OLD_CONTRACT_ID                          ,
                CONTRACT_ID                              ,
                OLD_CONTRACT_NUMBER                      ,
                CONTRACT_NUMBER                          ,
                OLD_CONTRACT_SERVICE_ID                  ,
                CONTRACT_SERVICE_ID                      ,
                OLD_TIME_ZONE_ID                         ,
                TIME_ZONE_ID                             ,
                OLD_ACCOUNT_ID                           ,
                ACCOUNT_ID                               ,
                OLD_TIME_DIFFERENCE                      ,
                TIME_DIFFERENCE                          ,
                OLD_CUSTOMER_PO_NUMBER                   ,
                CUSTOMER_PO_NUMBER                       ,
                OLD_CUSTOMER_TICKET_NUMBER               ,
                CUSTOMER_TICKET_NUMBER                   ,
                OLD_CUSTOMER_SITE_ID                     ,
                CUSTOMER_SITE_ID                         ,
                OLD_CALLER_TYPE                          ,
                CALLER_TYPE                              ,
--                OLD_OBJECT_VERSION_NUMBER                ,
                OLD_SECURITY_GROUP_ID                    ,
                OLD_ORIG_SYSTEM_REFERENCE                ,
                ORIG_SYSTEM_REFERENCE                    ,
                OLD_ORIG_SYSTEM_REFERENCE_ID             ,
                ORIG_SYSTEM_REFERENCE_ID                 ,
                REQUEST_ID                           ,
                PROGRAM_APPLICATION_ID               ,
                PROGRAM_ID                           ,
                PROGRAM_UPDATE_DATE                  ,
                OLD_PROJECT_NUMBER                       ,
                PROJECT_NUMBER                           ,
                OLD_PLATFORM_VERSION                     ,
                PLATFORM_VERSION                         ,
                OLD_DB_VERSION                           ,
                DB_VERSION                               ,
                OLD_CUST_PREF_LANG_ID                    ,
		CUST_PREF_LANG_ID                        ,
                OLD_TIER                                 ,
                TIER                                     ,
                OLD_CATEGORY_ID                          ,
                CATEGORY_ID                              ,
                OLD_OPERATING_SYSTEM                     ,
                OPERATING_SYSTEM                         ,
                OLD_OPERATING_SYSTEM_VERSION             ,
                OPERATING_SYSTEM_VERSION                 ,
                OLD_DATABASE                             ,
                DATABASE                                 ,
                OLD_GROUP_TERRITORY_ID                   ,
                GROUP_TERRITORY_ID                       ,
                OLD_COMM_PREF_CODE                       ,
                COMM_PREF_CODE                           ,
                OLD_LAST_UPDATE_CHANNEL                  ,
                LAST_UPDATE_CHANNEL                      ,
                OLD_CUST_PREF_LANG_CODE                  ,
                CUST_PREF_LANG_CODE                      ,
                OLD_ERROR_CODE                           ,
                ERROR_CODE                               ,
                OLD_CATEGORY_SET_ID                      ,
                CATEGORY_SET_ID                          ,
                OLD_EXTERNAL_REFERENCE                   ,
                EXTERNAL_REFERENCE                       ,
                OLD_INCIDENT_OCCURRED_DATE               ,
                INCIDENT_OCCURRED_DATE                   ,
                OLD_INCIDENT_RESOLVED_DATE               ,
                INCIDENT_RESOLVED_DATE                   ,
                OLD_INC_RESPONDED_BY_DATE                ,
                INC_RESPONDED_BY_DATE                    ,
                OLD_INCIDENT_LOCATION_ID                 ,
                INCIDENT_LOCATION_ID                     ,
                OLD_INCIDENT_ADDRESS                     ,
                INCIDENT_ADDRESS                         ,
                OLD_INCIDENT_CITY                        ,
                INCIDENT_CITY                            ,
                OLD_INCIDENT_STATE                       ,
                INCIDENT_STATE                           ,
                OLD_INCIDENT_COUNTRY                     ,
                INCIDENT_COUNTRY                         ,
                OLD_INCIDENT_PROVINCE                    ,
                INCIDENT_PROVINCE                        ,
                OLD_INCIDENT_POSTAL_CODE                 ,
                INCIDENT_POSTAL_CODE                     ,
                OLD_INCIDENT_COUNTY                      ,
                INCIDENT_COUNTY                          ,
                OLD_SR_CREATION_CHANNEL                  ,
                SR_CREATION_CHANNEL                      ,
                OLD_DEF_DEFECT_ID                        ,
                DEF_DEFECT_ID                            ,
                OLD_DEF_DEFECT_ID2                       ,
                DEF_DEFECT_ID2                           ,
                OLD_EXTERNAL_ATTRIBUTE_1                 ,
                EXTERNAL_ATTRIBUTE_1                     ,
                OLD_EXTERNAL_ATTRIBUTE_2                 ,
                EXTERNAL_ATTRIBUTE_2                     ,
                OLD_EXTERNAL_ATTRIBUTE_3                 ,
                EXTERNAL_ATTRIBUTE_3                     ,
                OLD_EXTERNAL_ATTRIBUTE_4                 ,
                EXTERNAL_ATTRIBUTE_4                     ,
                OLD_EXTERNAL_ATTRIBUTE_5                 ,
                EXTERNAL_ATTRIBUTE_5                     ,
                OLD_EXTERNAL_ATTRIBUTE_6                 ,
                EXTERNAL_ATTRIBUTE_6                     ,
                OLD_EXTERNAL_ATTRIBUTE_7                 ,
                EXTERNAL_ATTRIBUTE_7                     ,
                OLD_EXTERNAL_ATTRIBUTE_8                 ,
                EXTERNAL_ATTRIBUTE_8                     ,
                OLD_EXTERNAL_ATTRIBUTE_9                 ,
                EXTERNAL_ATTRIBUTE_9                     ,
                OLD_EXTERNAL_ATTRIBUTE_10                ,
                EXTERNAL_ATTRIBUTE_10                    ,
                OLD_EXTERNAL_ATTRIBUTE_11                ,
                EXTERNAL_ATTRIBUTE_11                    ,
                OLD_EXTERNAL_ATTRIBUTE_12                ,
                EXTERNAL_ATTRIBUTE_12                    ,
                OLD_EXTERNAL_ATTRIBUTE_13                ,
                EXTERNAL_ATTRIBUTE_13                    ,
                OLD_EXTERNAL_ATTRIBUTE_14                ,
                EXTERNAL_ATTRIBUTE_14                    ,
                OLD_EXTERNAL_ATTRIBUTE_15                ,
                EXTERNAL_ATTRIBUTE_15                    ,
                OLD_EXTERNAL_CONTEXT                     ,
                EXTERNAL_CONTEXT                         ,
                OLD_LAST_UPDATE_PROGRAM_CODE             ,
                LAST_UPDATE_PROGRAM_CODE                 ,
                OLD_CREATION_PROGRAM_CODE		 ,
                CREATION_PROGRAM_CODE                    ,
                OLD_COVERAGE_TYPE                        ,
                COVERAGE_TYPE                            ,
                OLD_BILL_TO_ACCOUNT_ID                   ,
                BILL_TO_ACCOUNT_ID                       ,
                OLD_SHIP_TO_ACCOUNT_ID                   ,
                SHIP_TO_ACCOUNT_ID                       ,
                OLD_CUSTOMER_EMAIL_ID                    ,
                CUSTOMER_EMAIL_ID                        ,
                OLD_CUSTOMER_PHONE_ID                    ,
                CUSTOMER_PHONE_ID                        ,
                OLD_BILL_TO_PARTY_ID                     ,
                BILL_TO_PARTY_ID                         ,
                OLD_SHIP_TO_PARTY_ID                     ,
                SHIP_TO_PARTY_ID                         ,
                OLD_BILL_TO_SITE_ID                      ,
                BILL_TO_SITE_ID                          ,
                OLD_SHIP_TO_SITE_ID                      ,
                SHIP_TO_SITE_ID                          ,
                OLD_PROGRAM_LOGIN_ID                     ,
                PROGRAM_LOGIN_ID                         ,
                OLD_INCIDENT_POINT_OF_INTEREST           ,
                INCIDENT_POINT_OF_INTEREST               ,
                OLD_INCIDENT_CROSS_STREET                ,
                INCIDENT_CROSS_STREET                    ,
                OLD_INCIDENT_DIRECTION_QUALIF            ,
                INCIDENT_DIRECTION_QUALIF                ,
                OLD_INCIDENT_DISTANCE_QUALIF             ,
                INCIDENT_DISTANCE_QUALIF                 ,
                OLD_INCIDENT_DISTANCE_QUAL_UOM           ,
                INCIDENT_DISTANCE_QUAL_UOM               ,
                OLD_INCIDENT_ADDRESS2                    ,
                INCIDENT_ADDRESS2                        ,
                OLD_INCIDENT_ADDRESS3                    ,
                INCIDENT_ADDRESS3                        ,
                OLD_INCIDENT_ADDRESS4                    ,
                INCIDENT_ADDRESS4                        ,
                OLD_INCIDENT_ADDRESS_STYLE               ,
                INCIDENT_ADDRESS_STYLE                   ,
                OLD_INCIDENT_ADDR_LNS_PHONETIC           ,
                INCIDENT_ADDR_LNS_PHONETIC               ,
                OLD_INCIDENT_PO_BOX_NUMBER               ,
                INCIDENT_PO_BOX_NUMBER                   ,
                OLD_INCIDENT_HOUSE_NUMBER                ,
                INCIDENT_HOUSE_NUMBER                    ,
                OLD_INCIDENT_STREET_SUFFIX               ,
                INCIDENT_STREET_SUFFIX                  ,
                OLD_INCIDENT_STREET                      ,
                INCIDENT_STREET                          ,
                OLD_INCIDENT_STREET_NUMBER               ,
                INCIDENT_STREET_NUMBER                   ,
                OLD_INCIDENT_FLOOR                       ,
                INCIDENT_FLOOR                           ,
                OLD_INCIDENT_SUITE                       ,
                INCIDENT_SUITE                           ,
                OLD_INCIDENT_POSTAL_PLUS4_CODE           ,
                INCIDENT_POSTAL_PLUS4_CODE               ,
                OLD_INCIDENT_POSITION                    ,
                INCIDENT_POSITION                        ,
                OLD_INCIDENT_LOC_DIRECTIONS              ,
                INCIDENT_LOC_DIRECTIONS                  ,
                OLD_INCIDENT_LOC_DESCRIPTION             ,
                INCIDENT_LOC_DESCRIPTION                 ,
                OLD_INSTALL_SITE_ID                      ,
                INSTALL_SITE_ID                          ,
                INCIDENT_LAST_MODIFIED_DATE              ,
                UPDATED_ENTITY_CODE                      ,
                UPDATED_ENTITY_ID                        ,
                ENTITY_ACTIVITY_CODE                     ,
                OLD_TIER_VERSION                         ,
                TIER_VERSION                             ,
                --anmukher --09/12/03
                OLD_INC_OBJECT_VERSION_NUMBER            ,
 		INC_OBJECT_VERSION_NUMBER                ,
 		OLD_INC_REQUEST_ID                       ,
 		INC_REQUEST_ID                           ,
 		OLD_INC_PROGRAM_APPLICATION_ID           ,
 		INC_PROGRAM_APPLICATION_ID               ,
 		OLD_INC_PROGRAM_ID                       ,
 		INC_PROGRAM_ID                           ,
 		OLD_INC_PROGRAM_UPDATE_DATE              ,
 		INC_PROGRAM_UPDATE_DATE                  ,
		OLD_OWNING_DEPARTMENT_ID                 ,
 		OWNING_DEPARTMENT_ID                     ,
 		OLD_INCIDENT_LOCATION_TYPE               ,
 		INCIDENT_LOCATION_TYPE                   ,
 		OLD_UNASSIGNED_INDICATOR                 ,
 		UNASSIGNED_INDICATOR                     ,
		OLD_MAINT_ORGANIZATION_ID                ,
		MAINT_ORGANIZATION_ID
    )
    VALUES(
                l_audit_id,
                p_request_id,
                p_last_update_date,
                p_user_id,
                p_last_update_date,
                p_user_id,
                P_login_id,
                TO_CHAR(p_creation_date,'HH24:MI:SS'),
                l_audit_vals_rec.incident_status_id           ,
                l_audit_vals_rec.old_incident_status_id       ,
                l_audit_vals_rec.change_incident_status_flag  ,
                l_audit_vals_rec.incident_type_id             ,
                l_audit_vals_rec.old_incident_type_id         ,
                l_audit_vals_rec.change_incident_type_flag    ,
                l_audit_vals_rec.incident_urgency_id          ,
                l_audit_vals_rec.old_incident_urgency_id      ,
                l_audit_vals_rec.change_incident_urgency_flag ,
                l_audit_vals_rec.incident_severity_id         ,
                l_audit_vals_rec.old_incident_severity_id     ,
                l_audit_vals_rec.change_incident_severity_flag,
                l_audit_vals_rec.incident_owner_id            ,
                l_audit_vals_rec.old_incident_owner_id        ,
                l_audit_vals_rec.change_incident_owner_flag   ,
                l_audit_vals_rec.create_manual_action         ,
                l_audit_vals_rec.action_id                    ,
                l_audit_vals_rec.expected_resolution_date     ,
                l_audit_vals_rec.old_expected_resolution_date ,
                l_audit_vals_rec.change_resolution_flag       ,
                l_audit_vals_rec.new_workflow_flag            ,
                l_audit_vals_rec.workflow_process_name        ,
                l_audit_vals_rec.workflow_process_itemkey     ,
		l_audit_vals_rec.group_id,
		l_audit_vals_rec.old_group_id,
		l_audit_vals_rec.change_group_flag,
                l_audit_vals_rec.group_type,
                l_audit_vals_rec.old_group_type,
                l_audit_vals_rec.change_group_type_flag,
                l_audit_vals_rec.inv_platform_org_id,
                l_audit_vals_rec.old_inv_platform_org_id,
                l_audit_vals_rec.change_platform_org_id_flag,
                l_audit_vals_rec.owner_assigned_time,
                l_audit_vals_rec.old_owner_assigned_time,
                l_audit_vals_rec.change_assigned_time_flag,
		l_audit_vals_rec.obligation_date,
		l_audit_vals_rec.old_obligation_date,
		l_audit_vals_rec.change_obligation_flag,
		l_audit_vals_rec.site_id,
		l_audit_vals_rec.old_site_id,
		l_audit_vals_rec.change_site_flag,
		l_audit_vals_rec.bill_to_contact_id,
		l_audit_vals_rec.old_bill_to_contact_id,
		l_audit_vals_rec.change_bill_to_flag,
		l_audit_vals_rec.ship_to_contact_id,
		l_audit_vals_rec.old_ship_to_contact_id,
		l_audit_vals_rec.change_ship_to_flag,
		l_audit_vals_rec.close_date,
		l_audit_vals_rec.old_close_date,
		l_audit_vals_rec.change_close_date_flag,
		l_audit_vals_rec.customer_product_id,
		l_audit_vals_rec.old_customer_product_id,
		l_audit_vals_rec.change_customer_product_flag,
		l_audit_vals_rec.platform_id,
		l_audit_vals_rec.old_platform_id,
		l_audit_vals_rec.change_platform_id_flag,
                l_audit_vals_rec.product_revision,
                l_audit_vals_rec.old_product_revision,
                l_audit_vals_rec.change_product_revision_flag,
                l_audit_vals_rec.component_version,	-- cp component versions
                l_audit_vals_rec.old_component_version,
                l_audit_vals_rec.change_comp_ver_flag,
                l_audit_vals_rec.subcomponent_version,
                l_audit_vals_rec.old_subcomponent_version,
                l_audit_vals_rec.change_subcomp_ver_flag,
		l_audit_vals_rec.cp_component_id,
		l_audit_vals_rec.old_cp_component_id,
		l_audit_vals_rec.change_cp_component_id_flag,
		l_audit_vals_rec.cp_component_version_id,
		l_audit_vals_rec.old_cp_component_version_id,
		l_audit_vals_rec.change_cp_comp_ver_id_flag,
		l_audit_vals_rec.cp_subcomponent_id,
		l_audit_vals_rec.old_cp_subcomponent_id,
		l_audit_vals_rec.change_cp_subcomponent_id_flag,
		l_audit_vals_rec.cp_subcomponent_version_id,
		l_audit_vals_rec.old_cp_subcomponent_version_id,
		l_audit_vals_rec.change_cp_subcomp_ver_id_flag,
		l_audit_vals_rec.cp_revision_id,
		l_audit_vals_rec.old_cp_revision_id,
		l_audit_vals_rec.change_cp_revision_id_flag,
 		l_audit_vals_rec.inv_item_revision,
 		l_audit_vals_rec.old_inv_item_revision,
 		l_audit_vals_rec.change_inv_item_revision,
 		l_audit_vals_rec.inv_component_id,
 		l_audit_vals_rec.old_inv_component_id,
 		l_audit_vals_rec.change_inv_component_id,
		l_audit_vals_rec.inv_component_version,
 		l_audit_vals_rec.old_inv_component_version,
 		l_audit_vals_rec.change_inv_component_version,
		l_audit_vals_rec.inv_subcomponent_id,
 		l_audit_vals_rec.old_inv_subcomponent_id,
 		l_audit_vals_rec.change_inv_subcomponent_id,
		l_audit_vals_rec.inv_subcomponent_version,
 		l_audit_vals_rec.old_inv_subcomponent_version,
 		l_audit_vals_rec.change_inv_subcomp_version,
		l_audit_vals_rec.territory_id,
		l_audit_vals_rec.old_territory_id,
		l_audit_vals_rec.change_territory_id_flag,
		l_audit_vals_rec.resource_type,
		l_audit_vals_rec.old_resource_type,
		l_audit_vals_rec.change_resource_type_flag,
		1,
		'',
                l_audit_vals_rec.inventory_item_id  ,
                l_audit_vals_rec.old_inventory_item_id,
                l_audit_vals_rec.change_inventory_item_flag,
                l_audit_vals_rec.inv_organization_id,
                l_audit_vals_rec.old_inv_organization_id,
                l_audit_vals_rec.change_inv_organization_flag,
                l_audit_vals_rec.status_flag,
                l_audit_vals_rec.old_status_flag,
                l_audit_vals_rec.change_status_flag,
                l_audit_vals_rec.incident_date,
                l_audit_vals_rec.old_incident_date,
                l_audit_vals_rec.change_incident_date_flag,
                l_audit_vals_rec.platform_version_id,
                l_audit_vals_rec.old_platform_version_id,
                l_audit_vals_rec.change_plat_ver_id_flag,
                l_audit_vals_rec.language_id,
                l_audit_vals_rec.old_language_id,
                l_audit_vals_rec.change_language_id_flag,
                --l_audit_vals_rec.primary_contact_id,
                --l_audit_vals_rec.change_primary_contact_flag,
                --l_audit_vals_rec.old_primary_contact_id,
                -- Added new audit columns for 11.5.10 Auditing project --anmukher --09/10/03
                l_audit_vals_rec.UPGRADE_FLAG_FOR_CREATE                  ,
                l_audit_vals_rec.OLD_INCIDENT_NUMBER                      ,
                l_audit_vals_rec.INCIDENT_NUMBER                          ,
                l_audit_vals_rec.OLD_CUSTOMER_ID                          ,
                l_audit_vals_rec.CUSTOMER_ID                              ,
                l_audit_vals_rec.OLD_BILL_TO_SITE_USE_ID                  ,
                l_audit_vals_rec.BILL_TO_SITE_USE_ID                      ,
                l_audit_vals_rec.OLD_EMPLOYEE_ID                          ,
                l_audit_vals_rec.EMPLOYEE_ID                              ,
                l_audit_vals_rec.OLD_SHIP_TO_SITE_USE_ID                  ,
                l_audit_vals_rec.SHIP_TO_SITE_USE_ID                      ,
                l_audit_vals_rec.OLD_PROBLEM_CODE                         ,
                l_audit_vals_rec.PROBLEM_CODE                             ,
                l_audit_vals_rec.OLD_ACTUAL_RESOLUTION_DATE               ,
                l_audit_vals_rec.ACTUAL_RESOLUTION_DATE                   ,
                l_audit_vals_rec.OLD_INSTALL_SITE_USE_ID                  ,
                l_audit_vals_rec.INSTALL_SITE_USE_ID                      ,
                l_audit_vals_rec.OLD_CURRENT_SERIAL_NUMBER                ,
                l_audit_vals_rec.CURRENT_SERIAL_NUMBER                    ,
                l_audit_vals_rec.OLD_SYSTEM_ID                            ,
                l_audit_vals_rec.SYSTEM_ID                                ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_1                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_2                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_2                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_3                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_3                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_4                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_4                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_5                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_5                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_6                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_6                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_7                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_7                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_8                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_8                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_9                 ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_9                     ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_10                ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_10                    ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_11                ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_11                    ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_12                ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_12                    ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_13                ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_13                    ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_14                ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_14                    ,
                l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_15                ,
                l_audit_vals_rec.INCIDENT_ATTRIBUTE_15                    ,
                l_audit_vals_rec.OLD_INCIDENT_CONTEXT                     ,
                l_audit_vals_rec.INCIDENT_CONTEXT                         ,
                l_audit_vals_rec.OLD_RESOLUTION_CODE                      ,
                l_audit_vals_rec.RESOLUTION_CODE                          ,
                l_audit_vals_rec.OLD_ORIGINAL_ORDER_NUMBER                ,
                l_audit_vals_rec.ORIGINAL_ORDER_NUMBER                    ,
                l_audit_vals_rec.OLD_ORG_ID                               ,
                l_audit_vals_rec.ORG_ID                                   ,
                l_audit_vals_rec.OLD_PURCHASE_ORDER_NUMBER                ,
                l_audit_vals_rec.PURCHASE_ORDER_NUMBER                    ,
                l_audit_vals_rec.OLD_PUBLISH_FLAG                         ,
                l_audit_vals_rec.PUBLISH_FLAG                             ,
                l_audit_vals_rec.OLD_QA_COLLECTION_ID                     ,
                l_audit_vals_rec.QA_COLLECTION_ID                         ,
                l_audit_vals_rec.OLD_CONTRACT_ID                          ,
                l_audit_vals_rec.CONTRACT_ID                              ,
                l_audit_vals_rec.OLD_CONTRACT_NUMBER                      ,
                l_audit_vals_rec.CONTRACT_NUMBER                          ,
                l_audit_vals_rec.OLD_CONTRACT_SERVICE_ID                  ,
                l_audit_vals_rec.CONTRACT_SERVICE_ID                      ,
                l_audit_vals_rec.OLD_TIME_ZONE_ID                         ,
                l_audit_vals_rec.TIME_ZONE_ID                             ,
                l_audit_vals_rec.OLD_ACCOUNT_ID                           ,
                l_audit_vals_rec.ACCOUNT_ID                               ,
                l_audit_vals_rec.OLD_TIME_DIFFERENCE                      ,
                l_audit_vals_rec.TIME_DIFFERENCE                          ,
                l_audit_vals_rec.OLD_CUSTOMER_PO_NUMBER                   ,
                l_audit_vals_rec.CUSTOMER_PO_NUMBER                       ,
                l_audit_vals_rec.OLD_CUSTOMER_TICKET_NUMBER               ,
                l_audit_vals_rec.CUSTOMER_TICKET_NUMBER                   ,
                l_audit_vals_rec.OLD_CUSTOMER_SITE_ID                     ,
                l_audit_vals_rec.CUSTOMER_SITE_ID                         ,
                l_audit_vals_rec.OLD_CALLER_TYPE                          ,
                l_audit_vals_rec.CALLER_TYPE                              ,
--                l_audit_vals_rec.OLD_OBJECT_VERSION_NUMBER                ,
                l_audit_vals_rec.OLD_SECURITY_GROUP_ID                    ,
                l_audit_vals_rec.OLD_ORIG_SYSTEM_REFERENCE                ,
                l_audit_vals_rec.ORIG_SYSTEM_REFERENCE                    ,
                l_audit_vals_rec.OLD_ORIG_SYSTEM_REFERENCE_ID             ,
                l_audit_vals_rec.ORIG_SYSTEM_REFERENCE_ID                 ,
                l_audit_vals_rec.REQUEST_ID                           ,
                l_audit_vals_rec.PROGRAM_APPLICATION_ID               ,
                l_audit_vals_rec.PROGRAM_ID                           ,
                l_audit_vals_rec.PROGRAM_UPDATE_DATE                  ,
                l_audit_vals_rec.OLD_PROJECT_NUMBER                       ,
                l_audit_vals_rec.PROJECT_NUMBER                           ,
                l_audit_vals_rec.OLD_PLATFORM_VERSION                     ,
                l_audit_vals_rec.PLATFORM_VERSION                         ,
                l_audit_vals_rec.OLD_DB_VERSION                           ,
                l_audit_vals_rec.DB_VERSION                               ,
                l_audit_vals_rec.OLD_CUST_PREF_LANG_ID                    ,
                l_audit_vals_rec.CUST_PREF_LANG_ID                        ,
                l_audit_vals_rec.OLD_TIER                                 ,
                l_audit_vals_rec.TIER                                     ,
                l_audit_vals_rec.OLD_CATEGORY_ID                          ,
                l_audit_vals_rec.CATEGORY_ID                              ,
                l_audit_vals_rec.OLD_OPERATING_SYSTEM                     ,
                l_audit_vals_rec.OPERATING_SYSTEM                         ,
                l_audit_vals_rec.OLD_OPERATING_SYSTEM_VERSION             ,
                l_audit_vals_rec.OPERATING_SYSTEM_VERSION                 ,
                l_audit_vals_rec.OLD_DATABASE                             ,
                l_audit_vals_rec.DATABASE                                 ,
                l_audit_vals_rec.OLD_GROUP_TERRITORY_ID                   ,
                l_audit_vals_rec.GROUP_TERRITORY_ID                       ,
                l_audit_vals_rec.OLD_COMM_PREF_CODE                       ,
                l_audit_vals_rec.COMM_PREF_CODE                           ,
                l_audit_vals_rec.OLD_LAST_UPDATE_CHANNEL                  ,
                l_audit_vals_rec.LAST_UPDATE_CHANNEL                      ,
                l_audit_vals_rec.OLD_CUST_PREF_LANG_CODE                  ,
                l_audit_vals_rec.CUST_PREF_LANG_CODE                      ,
                l_audit_vals_rec.OLD_ERROR_CODE                           ,
                l_audit_vals_rec.ERROR_CODE                               ,
                l_audit_vals_rec.OLD_CATEGORY_SET_ID                      ,
                l_audit_vals_rec.CATEGORY_SET_ID                          ,
                l_audit_vals_rec.OLD_EXTERNAL_REFERENCE                   ,
                l_audit_vals_rec.EXTERNAL_REFERENCE                       ,
                l_audit_vals_rec.OLD_INCIDENT_OCCURRED_DATE               ,
                l_audit_vals_rec.INCIDENT_OCCURRED_DATE                   ,
                l_audit_vals_rec.OLD_INCIDENT_RESOLVED_DATE               ,
                l_audit_vals_rec.INCIDENT_RESOLVED_DATE                   ,
                l_audit_vals_rec.OLD_INC_RESPONDED_BY_DATE                ,
                l_audit_vals_rec.INC_RESPONDED_BY_DATE                    ,
                l_audit_vals_rec.OLD_INCIDENT_LOCATION_ID                 ,
                l_audit_vals_rec.INCIDENT_LOCATION_ID                     ,
                l_audit_vals_rec.OLD_INCIDENT_ADDRESS                     ,
                l_audit_vals_rec.INCIDENT_ADDRESS                         ,
                l_audit_vals_rec.OLD_INCIDENT_CITY                        ,
                l_audit_vals_rec.INCIDENT_CITY                            ,
                l_audit_vals_rec.OLD_INCIDENT_STATE                       ,
                l_audit_vals_rec.INCIDENT_STATE                           ,
                l_audit_vals_rec.OLD_INCIDENT_COUNTRY                     ,
                l_audit_vals_rec.INCIDENT_COUNTRY                         ,
                l_audit_vals_rec.OLD_INCIDENT_PROVINCE                    ,
                l_audit_vals_rec.INCIDENT_PROVINCE                        ,
                l_audit_vals_rec.OLD_INCIDENT_POSTAL_CODE                 ,
                l_audit_vals_rec.INCIDENT_POSTAL_CODE                     ,
                l_audit_vals_rec.OLD_INCIDENT_COUNTY                      ,
                l_audit_vals_rec.INCIDENT_COUNTY                          ,
                l_audit_vals_rec.OLD_SR_CREATION_CHANNEL                  ,
                l_audit_vals_rec.SR_CREATION_CHANNEL                      ,
                l_audit_vals_rec.OLD_DEF_DEFECT_ID                        ,
                l_audit_vals_rec.DEF_DEFECT_ID                            ,
                l_audit_vals_rec.OLD_DEF_DEFECT_ID2                       ,
                l_audit_vals_rec.DEF_DEFECT_ID2                           ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_1                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_2                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_2                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_3                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_3                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_4                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_4                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_5                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_5                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_6                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_6                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_7                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_7                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_8                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_8                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_9                 ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_9                     ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_10                ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_10                    ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_11                ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_11                    ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_12                ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_12                    ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_13                ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_13                    ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_14                ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_14                    ,
                l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_15                ,
                l_audit_vals_rec.EXTERNAL_ATTRIBUTE_15                    ,
                l_audit_vals_rec.OLD_EXTERNAL_CONTEXT                     ,
                l_audit_vals_rec.EXTERNAL_CONTEXT                         ,
                l_audit_vals_rec.OLD_LAST_UPDATE_PROGRAM_CODE             ,
                l_audit_vals_rec.LAST_UPDATE_PROGRAM_CODE                 ,
                l_audit_vals_rec.OLD_CREATION_PROGRAM_CODE           ,
                l_audit_vals_rec.CREATION_PROGRAM_CODE               ,
                l_audit_vals_rec.OLD_COVERAGE_TYPE                        ,
                l_audit_vals_rec.COVERAGE_TYPE                            ,
                l_audit_vals_rec.OLD_BILL_TO_ACCOUNT_ID                   ,
                l_audit_vals_rec.BILL_TO_ACCOUNT_ID                       ,
                l_audit_vals_rec.OLD_SHIP_TO_ACCOUNT_ID                   ,
                l_audit_vals_rec.SHIP_TO_ACCOUNT_ID                       ,
                l_audit_vals_rec.OLD_CUSTOMER_EMAIL_ID                    ,
                l_audit_vals_rec.CUSTOMER_EMAIL_ID                        ,
                l_audit_vals_rec.OLD_CUSTOMER_PHONE_ID                    ,
                l_audit_vals_rec.CUSTOMER_PHONE_ID                        ,
                l_audit_vals_rec.OLD_BILL_TO_PARTY_ID                     ,
                l_audit_vals_rec.BILL_TO_PARTY_ID                         ,
                l_audit_vals_rec.OLD_SHIP_TO_PARTY_ID                     ,
                l_audit_vals_rec.SHIP_TO_PARTY_ID                         ,
                l_audit_vals_rec.OLD_BILL_TO_SITE_ID                      ,
                l_audit_vals_rec.BILL_TO_SITE_ID                          ,
                l_audit_vals_rec.OLD_SHIP_TO_SITE_ID                      ,
                l_audit_vals_rec.SHIP_TO_SITE_ID                          ,
                l_audit_vals_rec.OLD_PROGRAM_LOGIN_ID                     ,
                l_audit_vals_rec.PROGRAM_LOGIN_ID                         ,
                l_audit_vals_rec.OLD_INCIDENT_POINT_OF_INTEREST           ,
                l_audit_vals_rec.INCIDENT_POINT_OF_INTEREST               ,
                l_audit_vals_rec.OLD_INCIDENT_CROSS_STREET                ,
                l_audit_vals_rec.INCIDENT_CROSS_STREET                    ,
                l_audit_vals_rec.OLD_INCIDENT_DIRECTION_QUALIF            ,
                l_audit_vals_rec.INCIDENT_DIRECTION_QUALIF                ,
                l_audit_vals_rec.OLD_INCIDENT_DISTANCE_QUALIF             ,
                l_audit_vals_rec.INCIDENT_DISTANCE_QUALIF                 ,
                l_audit_vals_rec.OLD_INCIDENT_DISTANCE_QUAL_UOM           ,
                l_audit_vals_rec.INCIDENT_DISTANCE_QUAL_UOM               ,
                l_audit_vals_rec.OLD_INCIDENT_ADDRESS2                    ,
                l_audit_vals_rec.INCIDENT_ADDRESS2                        ,
                l_audit_vals_rec.OLD_INCIDENT_ADDRESS3                    ,
                l_audit_vals_rec.INCIDENT_ADDRESS3                        ,
                l_audit_vals_rec.OLD_INCIDENT_ADDRESS4                    ,
                l_audit_vals_rec.INCIDENT_ADDRESS4                        ,
                l_audit_vals_rec.OLD_INCIDENT_ADDRESS_STYLE               ,
                l_audit_vals_rec.INCIDENT_ADDRESS_STYLE                   ,
                l_audit_vals_rec.OLD_INCIDENT_ADDR_LNS_PHONETIC           ,
                l_audit_vals_rec.INCIDENT_ADDR_LNS_PHONETIC               ,
                l_audit_vals_rec.OLD_INCIDENT_PO_BOX_NUMBER               ,
                l_audit_vals_rec.INCIDENT_PO_BOX_NUMBER                   ,
                l_audit_vals_rec.OLD_INCIDENT_HOUSE_NUMBER                ,
                l_audit_vals_rec.INCIDENT_HOUSE_NUMBER                    ,
                l_audit_vals_rec.OLD_INCIDENT_STREET_SUFFIX               ,
                l_audit_vals_rec.INCIDENT_STREET_SUFFIX                  ,
                l_audit_vals_rec.OLD_INCIDENT_STREET                      ,
                l_audit_vals_rec.INCIDENT_STREET                          ,
                l_audit_vals_rec.OLD_INCIDENT_STREET_NUMBER               ,
                l_audit_vals_rec.INCIDENT_STREET_NUMBER                   ,
                l_audit_vals_rec.OLD_INCIDENT_FLOOR                       ,
                l_audit_vals_rec.INCIDENT_FLOOR                           ,
                l_audit_vals_rec.OLD_INCIDENT_SUITE                       ,
                l_audit_vals_rec.INCIDENT_SUITE                           ,
                l_audit_vals_rec.OLD_INCIDENT_POSTAL_PLUS4_CODE           ,
                l_audit_vals_rec.INCIDENT_POSTAL_PLUS4_CODE               ,
                l_audit_vals_rec.OLD_INCIDENT_POSITION                    ,
                l_audit_vals_rec.INCIDENT_POSITION                        ,
                l_audit_vals_rec.OLD_INCIDENT_LOC_DIRECTIONS              ,
                l_audit_vals_rec.INCIDENT_LOC_DIRECTIONS                  ,
                l_audit_vals_rec.OLD_INCIDENT_LOC_DESCRIPTION             ,
                l_audit_vals_rec.INCIDENT_LOC_DESCRIPTION                 ,
                l_audit_vals_rec.OLD_INSTALL_SITE_ID                      ,
                l_audit_vals_rec.INSTALL_SITE_ID                          ,
                l_audit_vals_rec.INCIDENT_LAST_MODIFIED_DATE              ,
                l_audit_vals_rec.UPDATED_ENTITY_CODE                      ,
                l_audit_vals_rec.UPDATED_ENTITY_ID                        ,
                l_audit_vals_rec.ENTITY_ACTIVITY_CODE                     ,
                l_audit_vals_rec.OLD_TIER_VERSION                         ,
                l_audit_vals_rec.TIER_VERSION                             ,
                --anmukher --09/12/03
                l_audit_vals_rec.OLD_INC_OBJECT_VERSION_NUMBER            ,
 		l_audit_vals_rec.INC_OBJECT_VERSION_NUMBER                ,
 		l_audit_vals_rec.OLD_INC_REQUEST_ID                       ,
 		l_audit_vals_rec.INC_REQUEST_ID                           ,
 		l_audit_vals_rec.OLD_INC_PROGRAM_APPLICATION_ID           ,
 		l_audit_vals_rec.INC_PROGRAM_APPLICATION_ID               ,
 		l_audit_vals_rec.OLD_INC_PROGRAM_ID                       ,
 		l_audit_vals_rec.INC_PROGRAM_ID                           ,
 		l_audit_vals_rec.OLD_INC_PROGRAM_UPDATE_DATE              ,
 		l_audit_vals_rec.INC_PROGRAM_UPDATE_DATE                  ,
		l_audit_vals_rec.OLD_OWNING_DEPARTMENT_ID                 ,
 		l_audit_vals_rec.OWNING_DEPARTMENT_ID                     ,
 		l_audit_vals_rec.OLD_INCIDENT_LOCATION_TYPE               ,
 		l_audit_vals_rec.INCIDENT_LOCATION_TYPE                   ,
 		l_audit_vals_rec.OLD_UNASSIGNED_INDICATOR                 ,
 		l_audit_vals_rec.UNASSIGNED_INDICATOR                     ,
 		l_audit_vals_rec.OLD_MAINT_ORGANIZATION_ID                ,
 		l_audit_vals_rec.MAINT_ORGANIZATION_ID
                )
            RETURNING incident_audit_id INTO l_Incident_Audit_Id;

   INSERT INTO cs_incidents_audit_tl (
        incident_audit_id,
        incident_id,
        LANGUAGE,
        source_lang,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        change_description
    ) SELECT
        l_incident_audit_id,
        p_request_id,
        L.LANGUAGE_CODE,
        USERENV('LANG'),
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id,
        p_comments
      FROM FND_LANGUAGES L
      WHERE l.installed_flag IN ('I', 'B')
      AND NOT EXISTS
      (SELECT NULL
       FROM cs_incidents_audit_tl t
       WHERE t.incident_audit_id = l_incident_audit_id
       AND t.LANGUAGE = l.language_code
     ) ;

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                               p_data  => x_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Audit_Record_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                 p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Audit_Record_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                 p_data  => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO Create_Audit_Record_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count     => x_msg_count,
                                 p_data      => x_msg_data );

  END Create_Audit_Record;
--------------------------------------------------------------------------
-- Validate_ServiceRequest_Record
--------------------------------------------------------------------------

-- Modification History
-- Date     Name     Desc
-- -------  -------- -----------------------------------------------------------
-- 02/28/05 smisra   Bug 4083288 passed category_set_id to
--                   validate_category_id procedure.
-- 03/25/05 smisra   Bug 4239975 Modified call to validate_current_serial_number
--                   Now it is called only if both customer product and current
--                   serial number are not null and not G_MISS_XXX
-- 05/05/05 smisra   Added validation for maint_organization_id
-- 06/07/05 smisra   Added p_maint_organization_id to util.validate_product call
--                   Removed p_maintenance_flag parameter from
--                   validate_inventory_org call
-- 07/20/05 smisra   bug 3900208
--                   changed the value of parameter p_parameter_name to
--                   p_product_revision from component_version so that error
--                   message is appropriate.
-- 08/01/05 smisra   EAM-IB01AUG
--                   passed addtional parameter p_inv_org_master_org_flag to
--                   validate_maint_organization_id,
--                   validate_customer_product_id and validate_inventory_org_id
-- 08/03/05 smisra   Passed maint_organization_id to validate_owning_dept
--                   procedure
--                   Passed l_inv_org_master_org_flag to validate_product
-- 08/11/05 smisra   Called validate_owning_dept only in Create Mode. in updated
--                   more it is called from servicerequest_cross_val
-- 12/14/05 smisra   removed call to validate_inc_location_id. Now it is called
--                   from vltd_sr_rec
-- 12/23/05 smisra   Bug 4894942
--                   Removed call to validate_contract_service_id and
--                   contracts_cross_val. This code is now executed from
--                   vldt_sr_rec
-- 12/30/05 smisra   Bug 4773215
--                   Removed call to validate resource type and site_id because
--                   these are now derived based on resource id
-- 06/06/06 spusegao Bug # 4773215
--                   Modified the check for value in profile option CS_PUBLISH_FLAG_UPDATE
--                   This check will not allow creation of service request only if the profile
--                   option is set to NULL.
-- 06/13/06 spusegao Modified fix big 5278488
--                       1. Reverted the changes made in Validate_ServiceRequest_Record.
-- 07/11/06 spusegao Modified to fix bug # 5361090.
--                   Added call to Validate_Platform_id procedure to validate platform_id.
-- 09/20/06 spusegao Modified to not validate the publish_flag in the CREATE p_sr_mode.
--------------------------------------------------------------------------------
PROCEDURE Validate_ServiceRequest_Record
( p_api_name        		IN   VARCHAR2,
  p_service_request_rec  	IN                Request_Validation_Rec_Type,
  p_request_date    		IN   DATE         := FND_API.G_MISS_DATE,
  p_org_id          		IN   NUMBER       := NULL,
  p_resp_appl_id    		IN   NUMBER       := NULL,
  p_resp_id         		IN   NUMBER       := NULL,
  p_user_id         		IN   NUMBER       := NULL,
  p_operation       		IN   VARCHAR2     := NULL,
  p_close_flag      		OUT NOCOPY VARCHAR2,
  p_disallow_request_update 	OUT NOCOPY VARCHAR2,
  p_disallow_owner_update  	OUT NOCOPY VARCHAR2,
  p_disallow_product_update  	OUT NOCOPY VARCHAR2,
  p_employee_name   	 OUT  NOCOPY VARCHAR2,
  p_inventory_item_id    OUT  NOCOPY NUMBER,
  p_contract_id          OUT  NOCOPY NUMBER,
  p_contract_number      OUT  NOCOPY VARCHAR2,
  x_bill_to_site_id      OUT NOCOPY NUMBER,
  x_ship_to_site_id      OUT NOCOPY NUMBER,
  x_bill_to_site_use_id  OUT NOCOPY NUMBER,
  x_ship_to_site_use_id  OUT NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2,
  x_group_name           OUT  NOCOPY VARCHAR2,
  x_owner_name           OUT  NOCOPY VARCHAR2,
  x_product_revision        OUT NOCOPY VARCHAR2,
  x_component_version       OUT NOCOPY VARCHAR2,
  x_subcomponent_version    OUT NOCOPY VARCHAR2,
  -- for cmro
  p_cmro_flag             IN  VARCHAR2,
  p_maintenance_flag      IN  VARCHAR2,
  p_sr_mode               IN  VARCHAR2
)
IS
  l_return_status   	VARCHAR2(1);
  l_can_update      	VARCHAR2(1);
  l_cp_customer_id  	NUMBER    := NULL;
  l_customer_id         NUMBER    ;
  l_bill_to_customer_id NUMBER    := NULL;
  l_ship_to_customer_id NUMBER    := NULL;
  l_install_customer_id NUMBER    := NULL;
  l_owner_name          VARCHAR2(240); -- dummy variable
  l_contract_number     VARCHAR2(120);
  l_contract_id         NUMBER  := NULL;
  l_contra_id           NUMBER  := NULL;
  l_customer_type       VARCHAR2(30);
  x_owner_id            NUMBER;
  lx_cmro_flag          VARCHAR2(10);  -- new for 11.5.10
  lx_maintenance_flag   VARCHAR2(10);  -- new for 11.5.10
  -- contracts : 3224828 for 11.5.10
  l_busi_proc_id        NUMBER;
  lx_return_status   	VARCHAR2(3);
  l_old_type_id         NUMBER;

l_maint_organization_id cs_incidents_all_b.maint_organization_id % TYPE;
l_inv_org_master_org_flag VARCHAR2(1);
l_serial_controlled_flag  VARCHAR2(3);

BEGIN

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Assign value to l_customer_id based on caller type

  IF (p_service_request_rec.caller_type = 'ORGANIZATION') THEN
    l_customer_id := p_service_request_rec.customer_id ;
  ELSIF (p_service_request_rec.caller_type = 'PERSON' ) THEN
    l_customer_id := p_service_request_rec.customer_id ;--Added for Bug 2167129
  END IF;

  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'step val sr rec #1');
  -- Validate all non-missing attributes

  /***** dj api cleanup
  -- commenting out call to validate type as this is done as the first step in
  -- both the create and update procedures
  IF FND_API.To_Boolean(p_service_request_rec.validate_type) THEN
    IF FND_API.To_Boolean(p_service_request_rec.status_id_change) THEN
       -- dj api cleanup
       CS_ServiceRequest_UTIL.Validate_Type (
	p_parameter_name      => 'p_type_id',
        p_type_id             => p_service_request_rec.type_id,
        p_subtype             => G_SR_SUBTYPE,
        P_status_id           => p_service_request_rec.updated_status_id,
        p_resp_id             => p_resp_id,
	p_resp_appl_id        => NVL(p_resp_appl_id,fnd_global.resp_appl_id) -- new for 11.5.10
	p_business_usage      => NULL, -- new for 11.5.10
	p_ss_srtype_restrict  => NULL, -- new for 11.5.10
        p_operation           => p_operation,
        x_return_status       => l_return_status,
	x_cmro_flag           => lx_cmro_flag,  -- new for 11.5.10
	x_maintenance_flag    => lx_maintenance_flag );  -- new for 11.5.10

    ELSE
      CS_ServiceRequest_UTIL.Validate_Type (
	  p_parameter_name => 'p_type_id',
          p_type_id        => p_service_request_rec.type_id,
          p_subtype        => G_SR_SUBTYPE,
          P_status_id      => p_service_request_rec.status_id,
          p_resp_id        => p_resp_id,
	  p_resp_appl_id        => NVL(p_resp_appl_id,fnd_global.resp_appl_id) -- new for 11.5.10
	  p_business_usage      => NULL, -- new for 11.5.10
	  p_ss_srtype_restrict  => NULL, -- new for 11.5.10
          p_operation      => p_operation,
          x_return_status  => l_return_status,
	  x_cmro_flag           => lx_cmro_flag,  -- new for 11.5.10
	x_maintenance_flag    => lx_maintenance_flag );  -- new for 11.5.10
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

  END IF;

  end comment of type ********/

  IF FND_API.To_Boolean(p_service_request_rec.validate_status) THEN
    CS_ServiceRequest_UTIL.Validate_Status
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_status_id',
        p_status_id      => p_service_request_rec.status_id,
        p_subtype        => G_SR_SUBTYPE,
        p_type_id        => p_service_request_rec.type_id,
	   p_resp_id        => p_resp_id,
        p_close_flag     => p_close_flag,
	   p_operation      => p_sr_mode,
        x_return_status  => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF FND_API.To_Boolean(p_service_request_rec.validate_updated_status) THEN

     IF p_service_request_rec.old_type_id <> FND_API.G_MISS_NUM AND
	   p_service_request_rec.old_type_id IS NOT NULL THEN
	   l_old_type_id := p_service_request_rec.old_type_id;
	ELSE
	   l_old_type_id := p_service_request_rec.type_id;
	END IF ;

    CS_ServiceRequest_UTIL.Validate_Updated_Status
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_status_id',
        p_resp_id        =>  p_resp_id  ,
        p_new_status_id  => p_service_request_rec.updated_status_id,
        p_old_status_id  => p_service_request_rec.status_id,
        p_subtype        => G_SR_SUBTYPE,
        p_type_id        => p_service_request_rec.type_id,
	   p_old_type_id    => l_old_type_id,
        p_close_flag     => p_close_flag,
        p_disallow_request_update  => p_disallow_request_update,
        p_disallow_owner_update    => p_disallow_owner_update,
        p_disallow_product_update  => p_disallow_product_update,
        x_return_status  => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'step val sr rec #3');

  IF (p_service_request_rec.severity_id <> FND_API.G_MISS_NUM) THEN

    CS_ServiceRequest_UTIL.Validate_Severity
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_severity_id',
        p_severity_id    => p_service_request_rec.severity_id,
        p_subtype        => G_SR_SUBTYPE,
        x_return_status  => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'step val sr rec #4');

  IF (p_service_request_rec.urgency_id <> FND_API.G_MISS_NUM) THEN

    CS_ServiceRequest_UTIL.Validate_Urgency
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_urgency_id',
        p_urgency_id     => p_service_request_rec.urgency_id,
        x_return_status  => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- For bug 3635269
  -- Validate SR_CREATION_CHANNEL

    IF (p_service_request_rec.sr_creation_channel <> FND_API.G_MISS_CHAR ) THEN

          CS_ServiceRequest_UTIL.Validate_SR_Channel(
          p_api_name              => p_api_name,
          p_parameter_name        => 'p_sr_creation_channel',
          p_sr_creation_channel   => p_service_request_rec.sr_creation_channel,
          x_return_status         => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
    END IF;

  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'step val sr rec #6');

  IF (p_service_request_rec.publish_flag <> FND_API.G_MISS_CHAR) AND
      p_sr_mode <> 'CREATE' THEN

    FND_PROFILE.Get('INC_PUBLISH_FLAG_UPDATE', l_can_update) ;

    IF ((l_can_update = 'N' ) OR (l_can_update IS NULL)) THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('CS', 'CS_API_SR_CANT_CHANGE_PUBLISH');
        FND_MESSAGE.Set_Token('API_NAME', p_api_name);
        FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF FND_API.To_Boolean(p_service_request_rec.validate_customer) THEN

    CS_ServiceRequest_UTIL.Validate_Customer
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_customer_id',
	p_caller_type    => p_service_request_rec.caller_type,    --Bug 3666089
        p_customer_id    => p_service_request_rec.customer_id,
        x_return_status  => l_return_status
      );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.contact_id <> FND_API.G_MISS_NUM) THEN
    CS_ServiceRequest_UTIL.Validate_Customer_Contact
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'p_contact_id',
        p_customer_contact_id => p_service_request_rec.contact_id,
        p_customer_id         => p_service_request_rec.customer_id,
        p_org_id              => p_org_id,
        p_customer_type       => p_service_request_rec.caller_type,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF FND_API.To_Boolean(p_service_request_rec.validate_employee) THEN
    CS_ServiceRequest_UTIL.Validate_Employee
      (   p_api_name          => p_api_name,
          p_parameter_name    => 'p_employee_id',
          p_employee_id       => p_service_request_rec.employee_id,
          p_org_id            => p_org_id,
          p_employee_name     => p_employee_name,
          x_return_status     => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    -- If employee_id is passed, use the CP owning customer to verify the
    -- RMA, bill to site, and ship to site information.

    -- l_cp_customer_id has null value in this case..
       l_customer_id := l_cp_customer_id ;

  END IF;

   -- For bug 2743507 , moving the call to validate inv org id before
   -- the validation of inv item id.

  IF (p_service_request_rec.inventory_org_id <> FND_API.G_MISS_NUM) THEN
    CS_ServiceRequest_UTIL.Validate_Inventory_Org
    ( p_api_name          => p_api_name,
      p_parameter_name    => 'Inventory Organization',
      p_inv_org_id        => p_service_request_rec.inventory_org_id,
      x_inv_org_master_org_flag => l_inv_org_master_org_flag,
      x_return_status     => l_return_status
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- validate maintenance organization id
  IF (p_service_request_rec.maint_organization_id <> FND_API.G_MISS_NUM AND
      p_service_request_rec.maint_organization_id IS NOT NULL )
  THEN
    CS_SERVICEREQUEST_UTIL.validate_maint_organization_id
    ( p_maint_organization_id => p_service_request_rec.maint_organization_id
    , p_inventory_org_id      => p_service_request_rec.inventory_org_id
    , p_inv_org_master_org_flag => l_inv_org_master_org_flag
    , x_return_status         => l_return_status
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF ;
  END IF ;
  --

  IF (p_service_request_rec.inventory_item_id <> FND_API.G_MISS_NUM)
     AND (p_sr_mode = 'CREATE') THEN
    IF ((p_service_request_rec.inventory_org_id = FND_API.G_MISS_NUM) OR
        (p_service_request_rec.inventory_org_id IS NULL)) THEN

      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                       ( p_token_an     => p_api_name,
                         p_token_np     => 'p_inventory_org_id',
                         p_table_name   => G_TABLE_NAME,
                         p_column_name  => 'INV_ORGANIZATION_ID');

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    CS_ServiceRequest_UTIL.Validate_Product
      ( p_api_name          => p_api_name,
        p_parameter_name    => 'p_inventory_item_id',
        p_inventory_item_id => p_service_request_rec.inventory_item_id,
        p_inventory_org_id  => p_service_request_rec.inventory_org_id,
        x_return_status     => l_return_status,
        p_maintenance_flag  => p_maintenance_flag,
        p_maint_organization_id => p_service_request_rec.maint_organization_id,
        p_inv_org_master_org_flag => l_inv_org_master_org_flag
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

 /* For bug 3340433
    Moved validate_customer_product before other validations that
    uses inventory item id */



    p_inventory_item_id := p_service_request_rec.inventory_item_id;

    IF (p_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM)
     AND (p_sr_mode = 'CREATE') THEN
    IF ((p_service_request_rec.inventory_org_id = FND_API.G_MISS_NUM) OR
        (p_service_request_rec.inventory_org_id IS NULL)) THEN

      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                     ( p_token_an    => p_api_name,
                       p_token_np    => 'p_inventory_org_id',
                       p_table_name  => G_TABLE_NAME,
                       p_column_name => 'INV_ORGANIZATION_ID');

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    IF p_service_request_rec.maint_organization_id = FND_API.G_MISS_NUM
    THEN
      l_maint_organization_id := NULL;
    ELSE
      l_maint_organization_id := p_service_request_rec.maint_organization_id;
    ENd IF;
    CS_ServiceRequest_UTIL.Validate_Customer_Product_id
        (p_customer_product_id => p_service_request_rec.customer_product_id,
        p_customer_id         => p_service_request_rec.customer_id,
        p_inventory_item_id   => p_inventory_item_id,
        p_inventory_org_id    => p_service_request_rec.inventory_org_id,
        p_maint_organization_id=> l_maint_organization_id,
        p_inv_org_master_org_flag => l_inv_org_master_org_flag,
        x_return_status       => l_return_status
      );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    -- For bug 3340433
    IF (nvl(p_service_request_rec.inventory_item_id,-99) <> FND_API.G_MISS_NUM) then
	      If (p_service_request_rec.inventory_item_id <> p_inventory_item_id) then
                     --Raise an ignore message;
		      CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		             p_token_an	=>  p_api_name,
		             p_token_ip	=>  'p_inventory_item_id' );
              End if;
    END IF;

  END IF;

  /* For bug 3340433
     Passing p_inventory_item_id intead of
     p_service_request_rec.inventory_item_id */

  -- if customer product is NULL then current serial can be free format. 3/25/05 smisra
  IF (p_service_request_rec.current_serial_number <> FND_API.G_MISS_CHAR) AND
     (p_service_request_rec.customer_product_id   <> FND_API.G_MISS_NUM)
     AND (p_sr_mode = 'CREATE') THEN

    CS_ServiceRequest_UTIL.Validate_Current_Serial
        ( p_api_name              => p_api_name,
	  p_parameter_name        => 'p_current_serial_number',
          p_inventory_item_id     => p_inventory_item_id,
	  p_inventory_org_id      => p_service_request_rec.inventory_org_id,
	  p_customer_product_id   =>  p_service_request_rec.customer_product_id,
	  p_customer_id           =>  p_service_request_rec.customer_id,
	  p_current_serial_number => p_service_request_rec.current_serial_number,
	  x_return_status         => l_return_status
		  );
	 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      	  x_return_status := FND_API.G_RET_STS_ERROR;
	   RETURN;
      END IF;
  END IF;


-- for cmro_eam

  IF p_service_request_rec.owning_dept_id <> FND_API.G_MISS_NUM AND
     p_sr_mode = 'CREATE'
  THEN
    CS_ServiceRequest_UTIL.Validate_Owning_department
    ( p_api_name         => p_api_name
    , p_parameter_name   => 'Owning Department'
    , p_inv_org_id       => p_service_request_rec.maint_organization_id
    , p_owning_dept_id   => p_service_request_rec.owning_dept_id
    , p_maintenance_flag => p_maintenance_flag
    , x_return_status    => l_return_status
    );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

-- end of cmro_eam

  IF (p_service_request_rec.problem_code <> FND_API.G_MISS_CHAR)
      AND (p_sr_mode = 'CREATE') THEN

    CS_ServiceRequest_UTIL.Validate_Problem_Code
      ( p_api_name          => p_api_name,
        p_parameter_name    => 'p_problem_code',
        p_problem_code      => p_service_request_rec.problem_code,
        p_incident_type_id  => p_service_request_rec.type_id,
        p_inventory_item_id => p_inventory_item_id,
	p_inventory_org_id  => p_service_request_rec.inventory_org_id,
	p_category_id       => p_service_request_rec.category_id,
        x_return_status     => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

-----------Added for enhancement ---11.5.6----jngeorge-----07/20/01
-----------Validation is required for Cust_Pref_Lang_Id,Comm_Pref_Code and
-----------Category_Id.

  IF (p_service_request_rec.cust_pref_lang_code <> FND_API.G_MISS_CHAR) THEN
    CS_ServiceRequest_UTIL.Validate_Cust_Pref_Lang_Code
      ( p_api_name             => p_api_name,
        p_parameter_name       => 'p_cust_pref_lang_code',
        p_cust_pref_lang_code  => p_service_request_rec.cust_pref_lang_code,
        x_return_status        => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.category_set_id <> FND_API.G_MISS_NUM)
     AND (p_sr_mode = 'CREATE') THEN
    CS_ServiceRequest_UTIL.Validate_Category_Set_Id
      ( p_api_name           => p_api_name,
        p_parameter_name     => 'p_category_set_id',
        p_category_id        => p_service_request_rec.category_id,
        p_category_set_id    => p_service_request_rec.category_set_id,
        p_inventory_item_id  => p_inventory_item_id,
	p_inventory_org_id   => p_service_request_rec.inventory_org_id,
        x_return_status      => l_return_status
      );
    /* added inv org id parameter for Bug 2661668/2648017 */
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.external_reference <> FND_API.G_MISS_CHAR)
     AND (p_sr_mode = 'CREATE') THEN
     -- For bug 3746983
     CS_ServiceRequest_UTIL.Validate_External_Reference
        ( p_api_name             => p_api_name,
          p_parameter_name       => 'p_external_reference',
          p_external_reference   => p_service_request_rec.external_reference,
          p_customer_product_id  => p_service_request_rec.customer_product_id,
	  p_inventory_item_id    => p_inventory_item_id,
	  p_inventory_org_id     => p_service_request_rec.inventory_org_id,
	  p_customer_id          => p_service_request_rec.customer_id,
          x_return_status        => l_return_status
        );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     END IF;
  END IF;

  IF (p_service_request_rec.system_id <> FND_API.G_MISS_NUM) THEN
    CS_ServiceRequest_UTIL.Validate_System_Id
      ( p_api_name          => p_api_name,
        p_parameter_name    => 'p_system_id',
        p_system_id         => p_service_request_rec.system_id,
        x_return_status     => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.comm_pref_code <> FND_API.G_MISS_CHAR) THEN
    CS_ServiceRequest_UTIL.Validate_Comm_Pref_Code
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_comm_pref_code',
        p_comm_pref_code  => p_service_request_rec.comm_pref_code,
        x_return_status  => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.category_id <> FND_API.G_MISS_NUM AND
      (p_service_request_rec.category_set_id = FND_API.G_MISS_NUM OR
       p_service_request_rec.category_set_id IS NULL) )
	  AND (p_sr_mode = 'CREATE')  THEN
    CS_ServiceRequest_UTIL.Validate_Category_Id
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_category_id',
        p_category_id    => p_service_request_rec.category_id,
        p_category_set_id=> p_service_request_rec.category_set_id,
        x_return_status  => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.group_type <> FND_API.G_MISS_CHAR) THEN
    CS_ServiceRequest_UTIL.Validate_Group_Type
      ( p_api_name         => p_api_name,
        p_parameter_name   => 'p_group_type',
        p_group_type       => p_service_request_rec.group_type,
        --p_resource_type  => p_service_request_rec.resource_type,
        x_return_status    => l_return_status
      );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.owner_group_id <> FND_API.G_MISS_NUM) THEN
    CS_ServiceRequest_UTIL.Validate_Group_Id
      ( p_api_name       => p_api_name,
        p_parameter_name => 'p_owner_group_id',
        p_group_type     => p_service_request_rec.group_type,
        p_owner_group_id => p_service_request_rec.owner_group_id,
        x_group_name     => x_group_name,
        x_return_status  => l_return_status
      );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.exp_resolution_date <> FND_API.G_MISS_DATE) THEN
    CS_ServiceRequest_UTIL.Validate_Exp_Resolution_Date
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'p_exp_resolution_date',
        p_exp_resolution_date => p_service_request_rec.exp_resolution_date,
        p_request_date        => p_request_date,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- IF FND_API.To_Boolean(p_service_request_rec.validate_bill_to_party) THEN
  -- Added one more parameter as customer_type to get the bill_to_customer_type
  -- which will be used in validate_bill_to_ship_to_ct
  -- Getting the value of l_customer_type from header caller_type
  -- done by shijain

     l_customer_type:= p_service_request_rec.caller_type;

  IF (p_service_request_rec.bill_to_party_id <> FND_API.G_MISS_NUM) THEN
    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Party
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Bill_To Party',
        p_bill_to_party_id    => p_service_request_rec.bill_to_party_id,
        p_customer_id         => p_service_request_rec.customer_id,
        x_customer_type       => l_customer_type,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

/******************************************************************
Commented now but should be uncommented for 11.5.10
  IF (FND_API.To_Boolean(p_service_request_rec.validate_bill_to_site) OR
     (p_service_request_rec.bill_to_site_id <> FND_API.G_MISS_NUM))  THEN

    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Bill_To Site ',
        p_bill_to_site_id     => p_service_request_rec.bill_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.bill_to_party_id,
	p_site_use_type	      => 'BILL_TO',
        x_site_use_id         => x_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;
Commented now but should be uncommented for 11.5.10
*****************************************************************/

    IF  (p_service_request_rec.bill_to_Contact_id <> FND_API.G_MISS_NUM)
	  AND (p_sr_mode = 'CREATE') THEN
	    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Ct
	      ( p_api_name            => p_api_name,
		p_parameter_name      => 'Bill_To Contact',
		p_bill_to_contact_id  => p_service_request_rec.bill_to_contact_id,
		p_bill_to_party_id    => p_service_request_rec.bill_to_party_id ,
		p_customer_type       => l_customer_type ,
		x_return_status       => l_return_status
	      );
	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      RETURN;
	    END IF;
     END IF;

  -- Validate the Ship_To_Party - Use the validate_bill_to_party procedure
  -- IF FND_API.To_Boolean(p_service_request_rec.validate_bill_to_party) THEN
  -- Added one more parameter as customer_type to get the bill_to_customer_type
  -- which will be used in validate_bill_to_ship_to_ct
  -- Getting the value of l_customer_type from header caller_type
  -- done by shijain

      l_customer_type:= p_service_request_rec.caller_type;

  IF (p_service_request_rec.ship_to_party_id <> FND_API.G_MISS_NUM) THEN
    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Party
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Ship_To Party',
        p_bill_to_party_id    => p_service_request_rec.ship_to_party_id,
        p_customer_id         => p_service_request_rec.customer_id,
        x_customer_type       => l_customer_type,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

/******************************************************************
Should be uncommented for 115.10
  -- Validate the Ship_To_Site  - Use the validate_bill_to_site  procedure itself

  IF (FND_API.To_Boolean(p_service_request_rec.validate_ship_to_site) OR
     (p_service_request_rec.ship_to_site_id <> FND_API.G_MISS_NUM)) THEN

    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Ship_To Site ',
        p_bill_to_site_id     => p_service_request_rec.ship_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.ship_to_party_id,
	p_site_use_type	      => 'SHIP_TO',
        x_site_use_id         => x_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;
Should be uncommented for 11.5.10
********************************************************************/

  -- Validate the Ship_To_Contact  - Use the validate_bill_to_Contact  procedure itself

     IF  (p_service_request_rec.ship_to_Contact_id <> FND_API.G_MISS_NUM)
	  AND (p_sr_mode = 'CREATE') THEN
	    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Ct
	  (     p_api_name            => p_api_name,
		p_parameter_name      => 'Ship_To Contact',
		p_bill_to_contact_id  => p_service_request_rec.ship_to_contact_id,
		p_bill_to_party_id    => p_service_request_rec.ship_to_party_id ,
		p_customer_type       => l_customer_type ,
		x_return_status       => l_return_status
	      );
	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      RETURN;
	    END IF;
      END IF;

  --Code added to validate install site
  --IF FND_API.To_Boolean(p_service_request_rec.validate_install_site) THEN
  IF ( p_service_request_rec.install_site_id <> FND_API.G_MISS_NUM  AND
       p_service_request_rec.install_site_id IS NOT NULL)  THEN
        CS_ServiceRequest_UTIL.Validate_Install_Site (
                p_parameter_name      => 'Install Site',
                p_install_site_id     => p_service_request_rec.install_site_id,
                p_customer_id         => l_customer_id,
                x_return_status       => l_return_status
           );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF ( p_service_request_rec.install_site_use_id <> FND_API.G_MISS_NUM AND
       p_service_request_rec.install_site_use_id IS NOT NULL)  THEN
         CS_ServiceRequest_UTIL.Validate_Install_Site (
                   p_parameter_name      => 'Install Site Use',
                   p_install_site_id     => p_service_request_rec.install_site_use_id,
                   p_customer_id         => l_customer_id,
                   x_return_status       => l_return_status
          );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

 IF (  ( p_service_request_rec.ship_to_site_id <> FND_API.G_MISS_NUM  AND
         p_service_request_rec.ship_to_site_id IS NOT NULL ) AND
       ( p_service_request_rec.ship_to_site_use_id  <> FND_API.G_MISS_NUM AND
         p_service_request_rec.ship_to_site_use_id  IS NOT NULL ) AND
	   ( p_sr_mode = 'CREATE') ) THEN

    CS_ServiceRequest_UTIL.Validate_Site_Site_Use
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Ship_To Site and/or Site Use ',
        p_site_id             => p_service_request_rec.ship_to_site_id,
        p_site_use_id         => p_service_request_rec.ship_to_site_use_id,
        p_party_id            => p_service_request_rec.ship_to_party_id,
        p_site_use_type       => 'SHIP_TO',
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  ELSIF ( ( p_service_request_rec.ship_to_site_use_id <> FND_API.G_MISS_NUM AND
            p_service_request_rec.ship_to_site_use_id IS NOT NULL )  AND
          ( p_service_request_rec.ship_to_site_id IS NULL  OR
            p_service_request_rec.ship_to_site_id = FND_API.G_MISS_NUM ) AND
		  ( p_sr_mode = 'CREATE') ) THEN

      CS_ServiceRequest_UTIL.Validate_Bill_Ship_Site_Use
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Ship_To Site Use ',
        p_site_use_id         => p_service_request_rec.ship_to_site_use_id,
        p_party_id            => p_service_request_rec.ship_to_party_id,
        p_site_use_type       => 'SHIP_TO',
        x_site_id             => x_ship_to_site_id,
        x_return_status       => l_return_status
       );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  ELSIF ( ( p_service_request_rec.ship_to_site_id <> FND_API.G_MISS_NUM AND
            p_service_request_rec.ship_to_site_id IS NOT NULL )  AND
          ( p_service_request_rec.ship_to_site_use_id IS NULL  OR
            p_service_request_rec.ship_to_site_use_id = FND_API.G_MISS_NUM ) AND
          ( p_sr_mode = 'CREATE') ) THEN

    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Ship_To Site ',
        p_bill_to_site_id     => p_service_request_rec.ship_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.ship_to_party_id,
        p_site_use_type       => 'SHIP_TO',
        x_site_use_id         => x_ship_to_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;


 IF (  ( p_service_request_rec.bill_to_site_id <> FND_API.G_MISS_NUM  AND
         p_service_request_rec.bill_to_site_id IS NOT NULL ) AND
       ( p_service_request_rec.bill_to_site_use_id  <> FND_API.G_MISS_NUM AND
         p_service_request_rec.bill_to_site_use_id  IS NOT NULL ) AND
       ( p_sr_mode = 'CREATE') ) THEN

    CS_ServiceRequest_UTIL.Validate_Site_Site_Use
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Bill_to Site and/or Site Use ',
        p_site_id             => p_service_request_rec.bill_to_site_id,
        p_site_use_id         => p_service_request_rec.bill_to_site_use_id,
        p_party_id            => p_service_request_rec.bill_to_party_id,
        p_site_use_type       => 'BILL_TO',
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  ELSIF ( ( p_service_request_rec.bill_to_site_use_id <> FND_API.G_MISS_NUM AND
            p_service_request_rec.bill_to_site_use_id IS NOT NULL )  AND
          ( p_service_request_rec.bill_to_site_id IS NULL  OR
            p_service_request_rec.bill_to_site_id = FND_API.G_MISS_NUM ) AND
          ( p_sr_mode = 'CREATE') ) THEN

      CS_ServiceRequest_UTIL.Validate_Bill_Ship_Site_Use
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Bill_to Site Use ',
        p_site_use_id         => p_service_request_rec.bill_to_site_use_id,
        p_party_id            => p_service_request_rec.bill_to_party_id,
        p_site_use_type       => 'BILL_TO',
        x_site_id             => x_bill_to_site_id,
        x_return_status       => l_return_status
       );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

  ELSIF ( ( p_service_request_rec.bill_to_site_id <> FND_API.G_MISS_NUM AND
            p_service_request_rec.bill_to_site_id IS NOT NULL )  AND
          ( p_service_request_rec.bill_to_site_use_id IS NULL  OR
            p_service_request_rec.bill_to_site_use_id = FND_API.G_MISS_NUM ) AND
          ( p_sr_mode = 'CREATE') ) THEN
    CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'Bill_to Site ',
        p_bill_to_site_id     => p_service_request_rec.bill_to_site_id,
        p_bill_to_party_id    => p_service_request_rec.bill_to_party_id,
        p_site_use_type       => 'BILL_TO',
        x_site_use_id         => x_bill_to_site_use_id,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.resolution_code <> FND_API.G_MISS_CHAR)
     AND (p_sr_mode = 'CREATE')  THEN

     cs_servicerequest_util.resolution_code_cross_val (
        p_parameter_name          => 'p_resolution_code',
        p_resolution_code         => p_service_request_rec.resolution_code,
        p_problem_code            => p_service_request_rec.problem_code,
        p_incident_type_id        => p_service_request_rec.type_id,
        p_category_id             => p_service_request_rec.category_id,
        p_inventory_item_id       => p_inventory_item_id,
        p_inventory_org_id        => p_service_request_rec.inventory_org_id,
        x_return_status           => l_return_status  );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.act_resolution_date <> FND_API.G_MISS_DATE) THEN
    CS_ServiceRequest_UTIL.Validate_Act_Resolution_Date
      ( p_api_name            => p_api_name,
        p_parameter_name      => 'p_act_resolution_date',
        p_act_resolution_date => p_service_request_rec.act_resolution_date,
        p_request_date        => p_request_date,
        x_return_status       => l_return_status
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.current_contact_time_diff <> FND_API.G_MISS_NUM) THEN
    IF ((p_service_request_rec.current_contact_time_diff < -24) OR
        (p_service_request_rec.current_contact_time_diff > 24)) THEN

      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                   ( p_token_an    =>  'p_api_name',
                     p_token_v     =>  TO_CHAR(p_service_request_rec.current_contact_time_diff),
                     p_token_p     =>  'p_contact_time_diff',
                     p_table_name  => G_TABLE_NAME ,
                     p_column_name => 'CURRENT_CONTACT_TIME_DIFF');

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  IF (p_service_request_rec.rep_by_time_difference <> FND_API.G_MISS_NUM) THEN
    IF ((p_service_request_rec.rep_by_time_difference < -24) OR
        (p_service_request_rec.rep_by_time_difference > 24)) THEN

      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                  ( p_token_an     =>  'p_api_name',
                    p_token_v      =>  TO_CHAR(p_service_request_rec.rep_by_time_difference),
                    p_token_p      =>  'p_represented_by_time_diff',
                    p_table_name   => G_TABLE_NAME ,
                    p_column_name  => 'REP_BY_TIME_DIFFERENCE' );

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

    --
    -- Validate contract id 04/16/01
    --
    IF (p_service_request_rec.contract_id <> FND_API.G_MISS_NUM) AND
        (p_service_request_rec.contract_id IS NOT NULL) AND
        (p_service_request_rec.contract_service_id IS NULL OR
         p_service_request_rec.contract_service_id = FND_API.G_MISS_NUM) THEN

        CS_ServiceRequest_UTIL.Validate_Contract_Id(
          p_api_name         => p_api_name,
          p_parameter_name   => 'p_contract_id',
          p_contract_id      => p_service_request_rec.contract_id,
	  x_contract_number  => p_contract_number,
          x_return_status    => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

      IF (p_service_request_rec.contract_id IS NOT NULL) AND
         (p_service_request_rec.contract_id <> FND_API.G_MISS_NUM) THEN
         p_contract_id := p_service_request_rec.contract_id;
      END IF;
    END IF;


--04/16/01
    --
    -- Validate Account Id
    --
    IF (p_service_request_rec.account_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.account_id IS NOT NULL) THEN

       IF (p_service_request_rec.caller_type = 'ORGANIZATION') THEN

          --p_org_id           => p_org_id,

          CS_ServiceRequest_UTIL.Validate_Account_Id(
          p_api_name         => p_api_name,
          p_parameter_name   => 'p_account_id',
          p_account_id       => p_service_request_rec.account_id,
          p_customer_id      => p_service_request_rec.customer_id,
          x_return_status    => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
         END IF;
      ELSIF (p_service_request_rec.caller_type = 'PERSON') THEN

          CS_ServiceRequest_UTIL.Validate_Account_Id(
          p_api_name            => p_api_name,
          p_parameter_name      => 'p_account_id',
          p_account_id 		=> p_service_request_rec.account_id,
          p_customer_id         => p_service_request_rec.customer_id,
          x_return_status       => l_return_status);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
          END IF;
     ELSE
           NULL;
     END IF;
  END IF;

    --
    -- Validate Platform Id
    --

    IF (p_service_request_rec.platform_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.platform_id IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_Platform_Id(
          p_api_name               => p_api_name,
          p_parameter_name         => 'p_platform_id',
          p_platform_id            => p_service_request_rec.platform_id,
          p_organization_id        => p_service_request_rec.inv_platform_org_id,
          x_serial_controlled_flag => l_serial_controlled_flag,
          x_return_status          => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
       END IF;
   END IF;

   IF (NVL(l_serial_controlled_flag,'N') = 'Y' AND
       (p_service_request_rec.platform_version <> FND_API.G_MISS_CHAR AND
        p_service_request_rec.platform_version is NOT NULL)
      ) OR
      (
       p_service_request_rec.platform_version_id <> FND_API.G_MISS_NUM AND
       p_service_request_rec.platform_version_id is NOT NULL AND
       p_service_request_rec.platform_version <> FND_API.G_MISS_CHAR AND
       p_service_request_rec.platform_version is NOT NULL
      )THEN
       CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                   ( p_token_an    => p_api_name,
                     p_token_v     => p_service_request_rec.platform_version,
                     p_token_p     => 'p_platform_version',
                     p_table_name  => G_TABLE_NAME ,
                     p_column_name => 'PLATFORM_VERSION');

       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;
    --
    -- Validate Platform Version Id
    --
    IF (p_service_request_rec.platform_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.platform_id IS NOT NULL) AND
       (p_service_request_rec.platform_version_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.platform_version_id IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_Platform_Version_Id(
          p_api_name             => p_api_name,
          p_parameter_name       => 'p_platform_Version_id',
          p_platform_id          => p_service_request_rec.platform_id,
          p_organization_id      => p_service_request_rec.inv_platform_org_id,
          p_platform_version_id  => p_service_request_rec.platform_Version_id,
          x_return_status        => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
       END IF;
   END IF;



   -- Validate Territory Id
   --
    IF (p_service_request_rec.territory_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.territory_id IS NOT NULL) THEN

          CS_ServiceRequest_UTIL.Validate_Territory_Id(
          p_api_name         => p_api_name,
          p_parameter_name   => 'p_territory_id',
          p_territory_id     => p_service_request_rec.territory_id,
          p_owner_id         => p_service_request_rec.owner_id,
          x_return_status    => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
        END IF;
    END IF;

   --Validate all the CP Fields only if customer_product_id is specified. If not, then
   --validate the Inv Fields.

   IF (p_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM AND
         p_service_request_rec.customer_product_id  IS NOT NULL) THEN

    IF (p_service_request_rec.cp_component_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.cp_component_id IS NOT NULL)
      AND (p_sr_mode = 'CREATE') THEN

        CS_ServiceRequest_UTIL.Validate_CP_Comp_Id(
          p_api_name             => p_api_name,
          p_parameter_name       => 'p_cp_component_id',
          p_cp_component_id      =>  p_service_request_rec.cp_component_id,
          p_customer_product_id  => p_service_request_rec.customer_product_id,
          p_org_id               => p_org_id,
          x_return_status        => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

      IF (p_service_request_rec.inv_component_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.inv_component_id IS NOT NULL) THEN

       CS_ServiceRequest_UTIL.INV_COMPONENT_CROSS_VAL (
         p_parameter_name       => 'Inventory component',
         p_cp_component_id      => p_service_request_rec.cp_component_id,
         p_inv_component_id     => p_service_request_rec.inv_component_id,
         x_return_status        => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

      END IF;


     END IF;


    --
    -- Validate Product Revision
    --
  x_product_revision := p_service_request_rec.product_revision;
    --IF (p_service_request_rec.product_revision <> FND_API.G_MISS_CHAR)
    IF (p_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.customer_product_id IS NOT NULL)
      AND (p_sr_mode = 'CREATE') THEN

        CS_ServiceRequest_UTIL.Validate_Product_Version(
          p_parameter_name        => 'p_product_revision',
          p_product_version       =>  x_product_revision,
          p_instance_id           =>  p_service_request_rec.customer_product_id,
	  p_inventory_org_id      =>  p_service_request_rec.inventory_org_id,
          x_return_status         =>  l_return_status);
        /***
        CS_ServiceRequest_UTIL.Validate_Product_Revision(
          p_api_name             => p_api_name,
          p_parameter_name       => 'p_product_revision',
          p_product_revision     =>  p_service_request_rec.product_revision,
          p_customer_product_id  => p_service_request_rec.customer_product_id,
          p_inventory_org_id     => p_service_request_rec.inventory_org_id,
          p_inventory_item_id    => p_inventory_item_id,
          x_return_status        => l_return_status);
        ******************************************/

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
     END IF;
  -- END IF;

    --
    -- Validate CP Component Version
    --
  --IF (p_service_request_rec.component_version <> FND_API.G_MISS_CHAR AND
  --    p_service_request_rec.component_version IS NOT NULL)
  --  AND (p_sr_mode = 'CREATE') THEN

  --    -- For 3337848
  --    CS_ServiceRequest_UTIL.Validate_Component_Version(
  --      p_api_name              => p_api_name,
  --      p_parameter_name        => 'p_component_version',
  --      p_component_version     =>  p_service_request_rec.component_version,
  --      p_cp_component_id       => p_service_request_rec.cp_component_id,
  --      p_customer_product_id   => p_service_request_rec.customer_product_id,
  --      p_inventory_org_id      =>  p_service_request_rec.inventory_org_id,
  --      x_return_status         => l_return_status);

  --  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  --    x_return_status := FND_API.G_RET_STS_ERROR;
  --    RETURN;
  --  END IF;
  -- END IF;
  x_component_version := p_service_request_rec.component_version;
    IF (p_service_request_rec.cp_component_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.cp_component_id IS NOT NULL)
      AND (p_sr_mode = 'CREATE') THEN

        -- For 3337848
        CS_ServiceRequest_UTIL.Validate_Product_Version(
          p_parameter_name        => 'p_component_version',
          p_product_version       =>  x_component_version,
          p_instance_id           =>  p_service_request_rec.cp_component_id,
	  p_inventory_org_id      =>  p_service_request_rec.inventory_org_id,
          x_return_status         =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF;

    -- Validate CP Sub Component Id
    --
    IF (p_service_request_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.cp_subcomponent_id IS NOT NULL)
      AND (p_sr_mode = 'CREATE') THEN

       CS_ServiceRequest_UTIL.Validate_CP_SubComp_Id(
          p_api_name               => p_api_name,
          p_parameter_name         => 'p_cp_subcomponent_id',
          p_cp_subcomponent_id     => p_service_request_rec.cp_subcomponent_id,
          p_cp_component_id        => p_service_request_rec.cp_component_id,
          p_customer_product_id    => p_service_request_rec.customer_product_id,
          p_org_id                 => p_org_id,
          x_return_status          => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

      -- For bug 3324210
      IF (p_service_request_rec.inv_subcomponent_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.inv_subcomponent_id IS NOT NULL) THEN

         CS_ServiceRequest_UTIL.INV_SUBCOMPONENT_CROSS_VAL (
         p_parameter_name       => 'inv subcomponent',
         p_inv_subcomponent_id  => p_service_request_rec.inv_subcomponent_id,
         p_cp_subcomponent_id   => p_service_request_rec.cp_subcomponent_id,
         x_return_status        => l_return_status );


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

      END IF;
     END IF ;


    --
    -- Validate CP Subcomponent Version
    --
  --IF (p_service_request_rec.subcomponent_version <> FND_API.G_MISS_CHAR AND
  --    p_service_request_rec.subcomponent_version IS NOT NULL)
  --  AND (p_sr_mode = 'CREATE') THEN

       -- For bug 3337848
  --    CS_ServiceRequest_UTIL.Validate_Subcomponent_Version(
  --      p_api_name                 => p_api_name,
  --      p_parameter_name           => 'p_subcomponent_version',
  --      p_subcomponent_version     =>  p_service_request_rec.subcomponent_version,
  --      p_cp_component_id          => p_service_request_rec.cp_component_id,
  --      p_cp_subcomponent_id       => p_service_request_rec.cp_subcomponent_id,
  --      p_customer_product_id      => p_service_request_rec.customer_product_id,
  --      p_inventory_org_id         =>  p_service_request_rec.inventory_org_id,
  --      x_return_status            => l_return_status);

  --  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  --    x_return_status := FND_API.G_RET_STS_ERROR;
  --    RETURN;
  --  END IF;

  --END IF;
  --END IF;
    x_subcomponent_version := p_service_request_rec.subcomponent_version;
    IF (p_service_request_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.cp_subcomponent_id IS NOT NULL)
      AND (p_sr_mode = 'CREATE') THEN

       -- For bug 3337848
        CS_ServiceRequest_UTIL.Validate_Product_Version(
          p_parameter_name      => 'p_subcomponent_version',
          p_product_version     =>  x_subcomponent_version,
          p_instance_id         => p_service_request_rec.cp_subcomponent_id,
	  p_inventory_org_id    =>  p_service_request_rec.inventory_org_id,
          x_return_status       => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

    END IF;
-----------------------------------

  ELSE
    -- customer_product_id is not specified, so validate the INV fields

    -- Validate INV ITEM REVISION
    --
    IF (p_service_request_rec.inv_item_revision <> FND_API.G_MISS_CHAR )
	    AND (p_sr_mode = 'CREATE') THEN

        CS_ServiceRequest_UTIL.Validate_Inv_Item_Rev(
          p_api_name           => p_api_name,
          p_parameter_name     => 'p_inv_item_revision',
          p_inv_item_revision  => p_service_request_rec.inv_item_revision,
          p_inventory_item_id  => p_inventory_item_id,
          p_inventory_org_id   => p_service_request_rec.inventory_org_id,
          x_return_status      => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF;

    ---- Validate INV COMP ID
    --

    IF (p_service_request_rec.inv_component_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.inv_component_id IS NOT NULL)
        AND (p_sr_mode = 'CREATE') THEN

        CS_ServiceRequest_UTIL.Validate_Inv_Comp_Id(
          p_api_name          => p_api_name,
          p_parameter_name    => 'p_inv_component_id',
          p_inventory_org_id  => p_service_request_rec.inventory_org_id,
          p_inv_component_id  => p_service_request_rec.inv_component_id,
          p_inventory_item_id => p_inventory_item_id,
          x_return_status     => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF;

    -- Validate INV COMP VER
    --
    IF (p_service_request_rec.inv_component_version <> FND_API.G_MISS_CHAR AND
        p_service_request_rec.inv_component_version  IS NOT NULL)
      AND (p_sr_mode = 'CREATE') THEN

        CS_ServiceRequest_UTIL.Validate_Inv_Comp_Ver(
          p_api_name                => p_api_name,
          p_parameter_name          => 'p_inv_component_version',
          p_inventory_org_id        => p_service_request_rec.inventory_org_id,
          p_inv_component_id        => p_service_request_rec.inv_component_id,
          p_inv_component_version   => p_service_request_rec.inv_component_version,
          x_return_status           => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF;


    -- Validate INV SUBCOMP ID
    --
    IF (p_sr_mode = 'CREATE' AND
        p_service_request_rec.inv_subcomponent_id <> FND_API.G_MISS_NUM AND
        p_service_request_rec.inv_subcomponent_id IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_Inv_SubComp_Id(
          p_api_name            => p_api_name,
          p_parameter_name      => 'p_inv_subcomponent_id',
          p_inventory_org_id    => p_service_request_rec.inventory_org_id,
          p_inv_subcomponent_id => p_service_request_rec.inv_subcomponent_id,
          p_inv_component_id    =>p_service_request_rec.inv_component_id,
          x_return_status       => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

    END IF;

    -- Validate INV SUBCOMP VER
    --
    IF (p_service_request_rec.inv_subcomponent_version <> FND_API.G_MISS_CHAR AND
        p_service_request_rec.inv_subcomponent_version IS NOT NULL)
      AND (p_sr_mode = 'CREATE') THEN

        CS_ServiceRequest_UTIL.Validate_Inv_SubComp_Ver(
          p_api_name                 => p_api_name,
          p_parameter_name           => 'p_inv_subcomponent_version',
          p_inventory_org_id         => p_service_request_rec.inventory_org_id,
          p_inv_subcomponent_id      =>p_service_request_rec.inv_subcomponent_id,
          p_inv_subcomponent_version => p_service_request_rec.inv_subcomponent_version,
          x_return_status            => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF;

  END IF;  /* IF customer_product_id is specified condition*/

  -- Added for Enh# 1830701
  -- Validate INC REPORTED DATE
  --
  IF (p_request_date <> FND_API.G_MISS_DATE AND
      p_request_date IS NOT NULL) AND
     (p_service_request_rec.incident_occurred_date <> FND_API.G_MISS_DATE AND
      p_service_request_rec.incident_occurred_date IS NOT NULL) THEN

      CS_ServiceRequest_UTIL.Validate_Inc_Reported_Date(
        p_api_name                 => p_api_name,
        p_parameter_name           => 'p_incident_date',
        p_request_date             => p_request_date,
        p_inc_occurred_date        => p_service_request_rec.incident_occurred_date,
        x_return_status            => l_return_status );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- Validate INC OCCURRED DATE
  --
  IF (p_service_request_rec.incident_occurred_date <> FND_API.G_MISS_DATE AND
      p_service_request_rec.incident_occurred_date IS NOT NULL) AND
     (p_request_date <> FND_API.G_MISS_DATE AND
      p_request_date IS NOT NULL) THEN

      CS_ServiceRequest_UTIL.Validate_Inc_Occurred_Date(
        p_api_name                 => p_api_name,
        p_parameter_name           => 'p_incident_occurred_date',
        p_inc_occurred_date        => p_service_request_rec.incident_occurred_date,
        p_request_date             => p_request_date,
        x_return_status            => l_return_status );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- Validate INC RESOLVED DATE
  --
  IF (p_service_request_rec.incident_resolved_date <> FND_API.G_MISS_DATE AND
      p_service_request_rec.incident_resolved_date IS NOT NULL) THEN

      CS_ServiceRequest_UTIL.Validate_Inc_Resolved_Date(
        p_api_name                 => p_api_name,
        p_parameter_name           => 'p_incident_resolved_date',
        p_inc_resolved_date        => p_service_request_rec.incident_resolved_date,
        p_request_date             => p_request_date,
        x_return_status            => l_return_status );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- Validate INC RESPONDED BY DATE
  --
  IF (p_service_request_rec.inc_responded_by_date <> FND_API.G_MISS_DATE AND
      p_service_request_rec.inc_responded_by_date IS NOT NULL) THEN

      CS_ServiceRequest_UTIL.Validate_Inc_Responded_Date(
        p_api_name                 => p_api_name,
        p_parameter_name           => 'p_inc_responded_by_date',
        p_inc_responded_by_date    => p_service_request_rec.inc_responded_by_date,
        p_request_date             => p_request_date,
        x_return_status            => l_return_status );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- Added for Enh# 222054
  -- Validate INCIDENT LOCATION ID
  -- KP Incident Locaton should be valid for the customer product, if it's passed.
  --  9/19 changes

  /* Bug 4386870 smisra 12/13/05
  this code is moved to vldt_sr_rec procedure
  IF (p_service_request_rec.incident_location_id <> FND_API.G_MISS_NUM AND
      p_service_request_rec.incident_location_id IS NOT NULL)
       THEN
        CS_ServiceRequest_UTIL.Validate_Inc_Location_Id(
         p_api_name                 => p_api_name,
         p_parameter_name           => 'p_incident_location_id',
         p_incident_location_type   => p_service_request_rec.incident_location_type,
         p_incident_location_id     => p_service_request_rec.incident_location_id,
         x_return_status            => l_return_status );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;
  */

  -- Validate INCIDENT COUNTRY
  --
  IF (p_service_request_rec.incident_country <> FND_API.G_MISS_CHAR AND
      p_service_request_rec.incident_country IS NOT NULL) THEN

      CS_ServiceRequest_UTIL.Validate_Incident_Country(
        p_api_name                 => p_api_name,
        p_parameter_name           => 'p_incident_country',
        p_incident_country         => p_service_request_rec.incident_country,
        x_return_status            => l_return_status );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  -- Added For ER# 2433831
  -- Validate Bill To Account

  IF (p_service_request_rec.bill_to_account_id <> FND_API.G_MISS_NUM AND
      p_service_request_rec.bill_to_account_id IS NOT NULL)
	  AND (p_sr_mode = 'CREATE') THEN

      CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Acct
           ( p_api_name            => p_api_name,
             p_parameter_name      => 'Bill_To Account',
             p_account_id  	   => p_service_request_rec.bill_to_account_id,
             p_party_id    	   => p_service_request_rec.bill_to_party_id,
             x_return_status       => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF ;
   END IF ;

  -- Added For ER# 2433831
  -- Validate Ship To Account

  -- Use the Same Procedure bill_to_account_id
  IF (p_service_request_rec.ship_to_account_id <> FND_API.G_MISS_NUM AND
      p_service_request_rec.ship_to_account_id IS NOT NULL)
	  AND (p_sr_mode = 'CREATE') THEN

      CS_ServiceRequest_UTIL.Validate_bill_To_Ship_To_Acct
           ( p_api_name            => p_api_name,
             p_parameter_name      => 'Ship_To Account',
             p_account_id  	   => p_service_request_rec.ship_to_account_id,
             p_party_id 	   => p_service_request_rec.ship_to_party_id,
             x_return_status       => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF ;
   END IF ;

  -- Added for ER# 2463321
  -- Validate Customer's Non Primary Phone Id

  IF (p_service_request_rec.customer_phone_id <> FND_API.G_MISS_NUM AND
      p_service_request_rec.customer_phone_id IS NOT NULL ) THEN

         CS_ServiceRequest_UTIL.Validate_Per_Contact_Point_Id
                ( p_api_name           => p_api_name,
                  p_parameter_name     => 'p_contact_point_id',
                  p_contact_point_type => 'PHONE',
                  p_contact_point_id   => p_service_request_rec.customer_phone_id,
                  p_party_id           => l_customer_id ,
                  x_return_status      => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF ;

  END IF ;

  -- Added for ER# 2463321
  -- Validate Customer's Non Primary Email Id

  IF (p_service_request_rec.customer_email_id <> FND_API.G_MISS_NUM AND
      p_service_request_rec.customer_email_id IS NOT NULL ) THEN

         CS_ServiceRequest_UTIL.Validate_Per_Contact_Point_Id
                ( p_api_name           => p_api_name,
                  p_parameter_name     => 'p_contact_point_id',
                  p_contact_point_type => 'EMAIL',
                  p_contact_point_id   => p_service_request_rec.customer_email_id,
                  p_party_id           => l_customer_id ,
                  x_return_status      => l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF ;

  END IF ;

END Validate_ServiceRequest_Record;

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name      Desc
-- -------- --------- ----------------------------------------------------------
-- 02/28/05 smisra    Bug 4083288 Defaulted category_set_id if it is not
--                    passed and category id is passed.
-- 05/05/05 smisra    Rel 12 changes. Replaced validation of p_org_id based on
--                    profile 'ORG_ID' with new validation based on
--                    hr_all_operating_units.
--                    copied maint_organization_id col to validation record.
-- 05/13/05 smisra    Removed the code that set customer product related
--                    parameters to null for EAM SRs
-- 05/27/05 smisra    Bug 4227769
--                    removed the code that sets obsolete col group_owner and
--                    owner (_tl table columns)
-- 07/15/05 smisra    Bug 4489746
--                    removed start and end active dates from query on
--                    cs_incident_types. Validate type will take care of
--                    date effectivity check.
-- 07/15/05 smisra    Bug 4398562
--                    moved the code that sets group_type and
--                    change_group_type_flag after call to SR auto assignment
-- 07/15/05 smisra    Bug 3875584
--                    passed p_mode='CREATE' to validate_owner procedure. This
--                    of p_mode will force validate_owner procedure to give
--                    warning in case of invalid owner.
-- 07/21/05 smisra    moved the  code that sets expected resolution and
--                    obligation dates in audit record from this procedure
--                    to create service request just before call to
--                    create audit rec procedure.
--                    This was needed because call to get contract may
--                    set these dates.
-- 11/16/05 smisra    Removed assignment of coverage_type to audit record
--                    coverage type may be determined based on contract service
--                    id in create service request procedure after call to
--                    create_sr_validation. Now this assignment is done in
--                    create_servicerequest just before the call to
--                    create_audit.
-- 12/14/05 smisra    set incident_country to null if incident_location_id is
--                    passed
--                    moved the code setting incident_country, inc_location_id
--                    and incident_location_type attribute of audit record to
--                    create_servicerequest just before call to create audit
-- 12/23/05 smisra    bug 4894942
--                    Removed call to Assignment manager API. now it is called
--                    from vldt_sr_rec
--                    Removed the code to set following audit record attribute
--                    a. resource_type
--                    b. group_type
--                    c. incident_owner_id
--                    d. group_owner_id
--                    e. owner_assigned_time
--                    f. territory_id
--                    These attribute are now set in create_servicerequest
--                    procedure just before the call to create audit
-- 12/30/05 smisra    Bug 4773215, 4869065
--                    Removed the call to validate resource id.
--                    Now this validation will be performed from vldt_sr_rec
--                    Moved the code to set site cols of audit record to
--                    create_servicerequest procedure just before call to
--                    create audit
-- 04/18/06 spusegao  Modified to validate service_request_rec.created_by and
--                    service_request_rec.last_updateD_by parameter values.
-- 06/13/06 spusegao  Modified ver 120.36 to fix big 5278488
--                     1. Modified Create_SR_Validation to default the publish_flag
--                        to 'N' if not passed.
-- 09/14/06 spusegao  Modified version 120.42 to comment out following code line
--                     --l_service_request_val_rec.publish_flag    := l_service_request_rec.publish_flag;
--                    For bug # 5517017.
-- 04/24/07 romehrot Bug Fix : 5501340 Added the code to pass the system_id
-- -----------------------------------------------------------------------------
PROCEDURE Create_SR_Validation(
  p_api_name              IN      VARCHAR2,
  p_service_request_rec   IN      service_request_rec_type,
  p_contacts              IN      contacts_table,
  p_resp_id               IN      NUMBER     DEFAULT NULL,
  p_resp_appl_id          IN      NUMBER     DEFAULT NULL,
  p_user_id               IN      NUMBER,
  p_login_id              IN      NUMBER     DEFAULT NULL,
  p_org_id                IN      NUMBER     DEFAULT NULL,
  p_request_id            IN      NUMBER     DEFAULT NULL,
  p_request_number        IN      VARCHAR2   DEFAULT NULL,
  p_validation_level      IN      NUMBER     DEFAULT fnd_api.g_valid_level_full,
  p_commit                IN      VARCHAR2   DEFAULT fnd_api.g_false,
  x_msg_count             OUT     NOCOPY NUMBER,
  x_msg_data              OUT     NOCOPY VARCHAR2,
  x_return_status         OUT     NOCOPY VARCHAR2,
  x_contra_id             OUT     NOCOPY NUMBER,
  x_contract_number       OUT     NOCOPY VARCHAR2,
  x_owner_assigned_flag   OUT     NOCOPY VARCHAR2,
  x_req_id                OUT     NOCOPY NUMBER,
  x_request_id            OUT     NOCOPY NUMBER,
  x_req_num               OUT     NOCOPY VARCHAR2,
  x_request_number        OUT     NOCOPY VARCHAR2,
  x_autolaunch_wkf_flag   OUT     NOCOPY VARCHAR2,
  x_abort_wkf_close_flag  OUT     NOCOPY VARCHAR2,
  x_wkf_process_name      OUT     NOCOPY VARCHAR2,
  x_audit_vals_rec        OUT     NOCOPY sr_audit_rec_type,
  x_service_request_rec   OUT     NOCOPY service_request_rec_type,
  -- for cmro
  p_cmro_flag             IN     VARCHAR2,
  p_maintenance_flag      IN     VARCHAR2,
  p_auto_assign           IN     VARCHAR2 := 'N'
 ) AS

     l_api_name                   CONSTANT VARCHAR2(30)    := 'Create_SR_Validation';
     l_api_version                CONSTANT NUMBER          := 2.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
     l_return_status              VARCHAR2(1);
     l_service_request_val_rec    Request_Validation_Rec_Type;
     l_service_request_rec        service_request_rec_type DEFAULT p_service_request_rec;
     --
     l_close_flag                 VARCHAR2(1);
     l_autolaunch_workflow_flag   VARCHAR2(1);
     l_abort_workflow_close_flag  VARCHAR2(1);
     l_workflow_process_name      VARCHAR2(30);

     l_workflow_process_id        NUMBER;
     l_contra_id                  NUMBER;

     l_cp_item_id                 NUMBER;
     l_inventory_org_id           NUMBER ;

     l_request_id                 NUMBER         := p_request_id;
     l_request_number             VARCHAR2(64)   := p_request_number;
     l_req_id                     NUMBER;
     l_req_num                    VARCHAR2(64);
     l_temp_id                    NUMBER;
     l_temp_num                   VARCHAR2(64);
     l_sysdate                    DATE           := SYSDATE;

     --
     l_note_index                 BINARY_INTEGER;
     l_note_id                    NUMBER;
     l_note_context_id            NUMBER;
     l_notes_detail               VARCHAR2(32767);
     l_contact_index              BINARY_INTEGER;

     l_jtf_note_id                NUMBER ;

     l_interaction_id             NUMBER;
     l_employee_name              VARCHAR2(240);
     l_bill_to_customer_id        NUMBER;
     l_bill_to_location_id        NUMBER;
     l_ship_to_customer_id        NUMBER;
     l_ship_to_location_id        NUMBER;
     l_install_customer_id        NUMBER;
     l_install_location_id        NUMBER;

     l_primary_contact_id         NUMBER  := NULL;

     l_bind_data_id               NUMBER;

     l_primary_contact_found      VARCHAR2(1) := 'N' ;
     l_contacts_passed            VARCHAR2(1) :=  'N';
     l_owner_assigned_flag        VARCHAR2(1) := 'N';

     l_disallow_request_update VARCHAR2(1);
     l_disallow_owner_update VARCHAR2(1);
     l_disallow_product_update VARCHAR2(1);

     -- For Workflow Hook
     l_workflow_item_key         NUMBER;

     l_test  NUMBER;

     l_org_id    NUMBER;

     l_profile_org_id   NUMBER  ;

     l_msg_id   NUMBER;
     l_msg_count    NUMBER;
     l_msg_data   VARCHAR2(2000);
     --Fixed bug#2802393, changed length from 40 to 2000
     l_uwq_body1 VARCHAR2(2000)   :=  'has been assigned to you on';
     l_uwq_body2 VARCHAR2(120)   :=  TO_CHAR(SYSDATE,'MM-DD-YYYY');
     l_uwq_body3 VARCHAR2(120)   :=  TO_CHAR(SYSDATE,'HH24:MI');
     --Fixed bug#2802393, changed length from 255 to 2500
     l_uwq_body  VARCHAR2(2500);

     l_contract_number   VARCHAR2(120) ;
     l_contract_id       NUMBER;
     l_group_name        VARCHAR2(60);
     l_owner_name        VARCHAR2(360);
     l_owner_id          jtf_rs_resource_extns.resource_id % TYPE;
     l_operation         VARCHAR2(300):='created';
     l_bill_to_site_id           NUMBER;
     l_ship_to_site_id           NUMBER;
     l_bill_to_site_use_id       NUMBER;
     l_ship_to_site_use_id       NUMBER;
     l_auto_assign_level fnd_profile_option_values.profile_option_value % type;
     l_asgn_owner_id     cs_incidents_all_b.incident_owner_id % type;
     l_asgn_group_id     cs_incidents_all_b.owner_group_id    % type;
     l_asgn_owner_type   cs_incidents_all_b.resource_type     % type;
     l_territory_id      number;
     l_orig_group_type_null varchar2(1) := 'N';
     l_responded_flag    cs_incident_statuses_b.responded_flag % type;
     l_resolved_flag     cs_incident_statuses_b.resolved_flag  % type;
BEGIN

  -- Initialize the New Auit Record
  Initialize_audit_rec(
  p_sr_audit_record         =>           x_audit_vals_rec) ;

  --
  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #1');

  -- Check if the mandatory parameters are specified. If not, return error.

  IF (l_service_request_rec.type_id = FND_API.G_MISS_NUM  OR
      l_service_request_rec.type_id  IS NULL) THEN

      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                        (p_token_an    => l_api_name_full,
                         p_token_np    => 'SR Type',
                         p_table_name  => G_TABLE_NAME,
                         p_column_name => 'INCIDENT_TYPE_ID');

      RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF (l_service_request_rec.status_id = FND_API.G_MISS_NUM  OR
      l_service_request_rec.status_id  IS NULL) THEN

      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                        (p_token_an    => l_api_name_full,
                         p_token_np    => 'SR Status',
                         p_table_name  => G_TABLE_NAME,
                         p_column_name => 'INCIDENT_STATUS_ID');

      RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF (l_service_request_rec.severity_id = FND_API.G_MISS_NUM  OR
      l_service_request_rec.severity_id  IS NULL) THEN

      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                        (p_token_an    => l_api_name_full,
                         p_token_np    => 'SR Severity',
                         p_table_name  => G_TABLE_NAME,
                         p_column_name => 'SEVERITY_ID');

      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Request Date is a reqd field, so check if passed, else return error
  IF (l_service_request_rec.request_date = FND_API.G_MISS_DATE OR
    l_service_request_rec.request_date IS NULL) THEN

    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                      (p_token_an    => l_api_name_full,
                       p_token_np    => 'SR Request Date',
                       p_table_name  => G_TABLE_NAME,
                       p_column_name => 'REQUEST_DATE');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Summary is a reqd field, so check if passed, else return error
  IF (l_service_request_rec.summary = FND_API.G_MISS_CHAR OR
      l_service_request_rec.summary IS NULL) THEN

    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                      (p_token_an    => l_api_name_full,
                       p_token_np    => 'SR Summary',
                       p_table_name  => G_TABLE_NAME,
                       p_column_name => 'SUMMARY');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- for cmro_eam

   IF (p_maintenance_flag = 'Y' OR p_maintenance_flag = 'y') THEN
        IF (l_service_request_rec.inventory_org_id = FND_API.G_MISS_NUM) THEN
                CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(l_api_name_full, 'Inventory Org ID');
                RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_service_request_rec.inventory_org_id IS NULL) THEN
                CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'Inventory Org ID');
                RAISE FND_API.G_EXC_ERROR;
        END IF;
   END IF;
   -- end of cmro_eam

  -- Added all the 8 checks for bug#2800884
  -- bill_to_party_id is a reqd field if bill_to_account_id
  -- is passed, so check if passed, else return error
  IF ((l_service_request_rec.bill_to_account_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.bill_to_account_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.bill_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.bill_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','bill_to_account_id');
                  fnd_message.set_token ('PARENT_PARAM','bill_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- bill_to_party_id is a reqd field if bill_to_contact_id is passed,so check
  -- if passed, else return error
  IF ((l_service_request_rec.bill_to_contact_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.bill_to_contact_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.bill_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.bill_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','bill_to_contact_id');
                  fnd_message.set_token ('PARENT_PARAM','bill_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- bill_to_party_id is a reqd field if bill_to_site_id is passed, so check
  -- if passed, else return error
  IF ((l_service_request_rec.bill_to_site_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.bill_to_site_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.bill_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.bill_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','bill_to_site_id');
                  fnd_message.set_token ('PARENT_PARAM','bill_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- bill_to_party_id is a reqd field if bill_to_site_use_id is passed,
  -- so check if passed, else return error
  IF ((l_service_request_rec.bill_to_site_use_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.bill_to_site_use_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.bill_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.bill_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','bill_to_site_use_id');
                  fnd_message.set_token ('PARENT_PARAM','bill_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- ship_to_party_id is a reqd field if ship_to_account_id
  -- is passed, so check if passed, else return error
  IF ((l_service_request_rec.ship_to_account_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.ship_to_account_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.ship_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.ship_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','ship_to_account_id');
                  fnd_message.set_token ('PARENT_PARAM','ship_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- ship_to_party_id is a reqd field if ship_to_contact_id is passed,so check
  -- if passed, else return error
  IF ((l_service_request_rec.ship_to_contact_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.ship_to_contact_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.ship_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.ship_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','ship_to_contact_id');
                  fnd_message.set_token ('PARENT_PARAM','ship_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- ship_to_party_id is a reqd field if ship_to_site_id is passed, so check
  -- if passed, else return error
  IF ((l_service_request_rec.ship_to_site_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.ship_to_site_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.ship_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.ship_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','ship_to_site_id');
                  fnd_message.set_token ('PARENT_PARAM','ship_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- ship_to_party_id is a reqd field if ship_to_site_use_id is passed,
  -- so check if passed, else return error
  IF ((l_service_request_rec.ship_to_site_use_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.ship_to_site_use_id IS NOT NULL))
  THEN
     IF (l_service_request_rec.ship_to_party_id = FND_API.G_MISS_NUM OR
         l_service_request_rec.ship_to_party_id IS NULL) THEN

                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','ship_to_site_use_id');
                  fnd_message.set_token ('PARENT_PARAM','ship_to_party_id');
                  fnd_msg_pub.ADD;

                  RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- Added this code for source changes for 11.5.9 by shijain dated oct 11 2002
  -- this code is to check if the creation_program_code is passed and is not
  -- null as this is a mandatory parameter.

  IF (l_service_request_rec.creation_program_code = FND_API.G_MISS_CHAR  OR
      l_service_request_rec.creation_program_code  IS NULL) THEN

      /*Commented this code for backward compatibility, that if someone
        passes a creation program code as NULL or G_MISS_CHAR, we are supporting
        it now and defaulting it to UNKNOWN
        CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                        (p_token_an    => l_api_name_full,
                         p_token_np    => 'SR Creation Program Code',
                         p_table_name  => G_TABLE_NAME,
                         p_column_name => 'CREATION_PROGRAM_CODE');

       RAISE FND_API.G_EXC_ERROR;
       */
       l_service_request_rec.creation_program_code:='UNKNOWN';
  END IF;

/* Commented it for bug 2725543,getting the group_name and resource_name
   from the validation procedures itself.
  -- Added for Enh# 2216664
  -- Added If conditions for Bug# 2297626
  -- For populating the owner in TL table
     IF (l_service_request_rec.owner_id IS NOT NULL AND
        l_service_request_rec.owner_id <> FND_API.G_MISS_NUM) THEN

        SELECT resource_name
          INTO l_service_request_rec.owner
          FROM jtf_rs_resource_extns_tl
         WHERE resource_id = l_service_request_rec.owner_id
           AND LANGUAGE =  USERENV('LANG');
     END IF;

  -- For populating the group_owner in TL table
     IF (l_service_request_rec.owner_group_id IS NOT NULL AND
         l_service_request_rec.owner_group_id <> FND_API.G_MISS_NUM) THEN
       IF l_service_request_rec.group_type = 'RS_GROUP' THEN

          SELECT group_name INTO l_service_request_rec.group_owner
          FROM jtf_rs_groups_tl
          WHERE group_id =l_service_request_rec.owner_group_id
          AND LANGUAGE = USERENV('LANG');

       ELSIF (l_service_request_rec.group_type = 'RS_TEAM') THEN

          SELECT team_name INTO l_service_request_rec.group_owner
          FROM jtf_rs_teams_tl
          WHERE team_id =l_service_request_rec.owner_group_id
          AND LANGUAGE = USERENV('LANG');

       END IF;
     END IF;
*/

  -- Check if any records are passed in the contacts table.
  -- If so, get the primary contact id.
  -- Only one record with primary flag set to Y must be passed.

  l_contact_index := p_contacts.FIRST;

  -- Flag to indicate records have been passed
  IF (l_contact_index IS NULL) THEN
    l_contacts_passed := 'N';
  ELSE
    l_contacts_passed := 'Y';
  END IF;

  IF (l_service_request_rec.caller_type = 'ORGANIZATION') THEN
    IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
      --
      -- customer_id/company_number is mandatory
      -- customer_firstname etc. ignored
      --
         IF ((l_service_request_rec.customer_id = FND_API.G_MISS_NUM OR
                 l_service_request_rec.customer_id IS NULL )AND
                 (l_service_request_rec.customer_number = FND_API.G_MISS_CHAR OR
                  l_service_request_rec.customer_number IS NULL)) THEN

                --AND(l_service_request_rec.customer_company_name = FND_API.G_MISS_CHAR OR
                -- l_service_request_rec.customer_company_name IS NULL)

             CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                               (p_token_an    => l_api_name_full,
                                p_token_np     => 'SR Customer',
                                p_table_name  => null,
                                p_column_name => 'CUSTOMER_COMPANY_NAME');

             RAISE FND_API.G_EXC_ERROR;
         END IF;

     IF (l_service_request_rec.customer_id <> FND_API.G_MISS_NUM AND
                l_service_request_rec.customer_id IS NOT NULL )   THEN

        l_service_request_val_rec.validate_customer := FND_API.G_TRUE;
        l_service_request_val_rec.customer_id       := l_service_request_rec.customer_id;
        x_service_request_rec.customer_id := l_service_request_rec.customer_id;

     ELSE
          --Customer Id is not passed, but customer number may be passed
          --Retrieve the customer_id from the customer_number
          CS_ServiceRequest_UTIL.Convert_Customer_To_ID(
                 p_api_name=>l_api_name,
                 p_parameter_name_nb=>'l_service_request_rec.customer_number',
                 p_parameter_name_n=> 'Customer_Name',
                 p_customer_number=>l_service_request_rec.customer_number,
                 -- Made changes for bug#2859360, getting the value of
                 -- customer id in l_service_request_rec.customer_id
                 p_customer_id    => l_service_request_rec.customer_id,
                 x_return_status => l_return_status);

       --Check return status
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

       l_service_request_val_rec.validate_customer := FND_API.G_TRUE;
       -- Made changes for bug#2859360, uncommented this call
       l_service_request_val_rec.customer_id       := l_service_request_rec.customer_id;
     END IF;

    --Need the first flag cause contacts table is made mandatory now, when caller type is ORG
    --If records are passed in the contacts table, at least one record with primary flag
    --set to Y must be passed

    -- Check if the table is passed with records.

   END IF;

  ELSIF (l_service_request_rec.caller_type = 'PERSON') THEN
    IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
      --
      -- customer ignored
      -- at least one contact with primary flag=Y should be specified in the contacts table.

--    END IF;
--    raise error if customer_id is not passed . bug #3299567
     IF ((l_service_request_rec.customer_id = FND_API.G_MISS_NUM OR
          l_service_request_rec.customer_id IS NULL              )) THEN

			 CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'SR Customer');
             RAISE FND_API.G_EXC_ERROR;

        END IF;

    END IF;


  ELSE
    -- caller type passed is not valid

    CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                      ( p_token_an =>  l_api_name_full,
                        p_token_v  =>  l_service_request_rec.caller_type,
                        p_token_p  =>  'p_caller_type',
                        p_table_name  => G_TABLE_NAME ,
                        p_column_name => 'CALLER_TYPE' );

   RAISE FND_API.G_EXC_ERROR;
  END IF;

  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #2');
  --
  /*11.5.10 Misc ER added logic to handle usability related changes*/

  -- For bug 3512501 - added begin..exception
  begin
  SELECT  responded_flag,resolved_flag
  INTO l_responded_flag,l_resolved_flag
  FROM  cs_incident_statuses_vl
  WHERE incident_status_id=l_service_request_rec.status_id ;
  exception
    when no_data_found then
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      p_token_v     => TO_CHAR(l_service_request_rec.status_id),
			      p_token_p     => 'p_status_id',
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'INCIDENT_STATUS_ID' );
     RAISE FND_API.G_EXC_ERROR;
    end;

  IF ((l_responded_flag='Y') OR (l_resolved_flag ='Y')) THEN
     IF((l_responded_flag='Y' ) AND (l_service_request_rec.inc_responded_by_date is NULL OR
       l_service_request_rec.inc_responded_by_date= FND_API.G_MISS_DATE ))THEN
       l_service_request_rec.inc_responded_by_date := SYSDATE;
     END IF;

     IF((l_resolved_flag ='Y' ) AND (l_service_request_rec.incident_resolved_date is NULL
        OR l_service_request_rec.incident_resolved_date = FND_API.G_MISS_DATE ))THEN
        l_service_request_rec.incident_resolved_date := SYSDATE;
      END IF;
  END IF;

  -- ----------------------------------------------------------------------
  -- Apply business-rule validation to all required and passed parameters
  -- if validation level is set.
  -- ----------------------------------------------------------------------
  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
    --
    -- Check for uniqueness of request_id/request_number
    --
    IF (p_request_id IS NOT NULL) THEN

         -- Check if the request id passed is unique
      DECLARE
        l_test          NUMBER;
      BEGIN
        SELECT incident_id
         INTO l_test
         FROM cs_incidents_all_b
        WHERE incident_id = p_request_id;

        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                          ( p_token_an    =>  l_api_name_full,
                            p_token_v     =>  p_request_id,
                            p_token_p     =>  'p_request_id' ,
                            p_table_name  => G_TABLE_NAME ,
                            p_column_name => 'INCIDENT_ID');

        RAISE FND_API.G_EXC_ERROR;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

    END IF;


    IF (p_request_number IS NOT NULL) THEN

         --Check if the request number passed is unique
      DECLARE
        l_test          VARCHAR2(250);
      BEGIN
        SELECT incident_number
        INTO l_test
        FROM cs_incidents_all_b
        WHERE incident_number = p_request_number;

        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                          ( p_token_an    => l_api_name_full,
                            p_token_v     => p_request_number,
                            p_token_p     => 'p_request_number',
                            p_table_name  => G_TABLE_NAME,
                            p_column_name => 'INCIDENT_NUMBER' );

        RAISE FND_API.G_EXC_ERROR;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;


    END IF;

   -- replaced validation of org_id with the procedure call below and set local variable
   -- to p_org_id
   IF p_org_id IS NOT NULL
   THEN
     CS_SERVICEREQUEST_UTIL.validate_org_id
     ( p_org_id        => p_org_id
     , x_return_status => l_return_status
     );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   l_org_id := p_org_id;


    --
    -- Validate the user and login id's
    --
    CS_ServiceRequest_UTIL.Validate_Who_Info
      ( p_api_name             => l_api_name_full,
        p_parameter_name_usr   => 'p_user_id',
        p_parameter_name_login => 'p_login_id',
        p_user_id              => p_user_id,
        p_login_id             => p_login_id,
        x_return_status        => l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate the created_by added for bug #5153581
    --
    IF l_service_request_rec.created_by IS NOT NULL AND
       l_service_request_rec.created_by <> FND_API.G_Miss_NUM THEN

         CS_ServiceRequest_UTIL.Validate_Who_Info
           ( p_api_name             => l_api_name_full,
             p_parameter_name_usr   => 'p_created_by',
             p_parameter_name_login => NULL,
             p_user_id              => l_service_request_rec.created_by,
             p_login_id             => NULL,
             x_return_status        => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

    END IF ;

    -- Validate the updated_by added for bug #5153581
    --
      IF l_service_request_rec.last_updated_by IS NOT NULL AND
         l_service_request_rec.last_updated_by <> FND_API.G_Miss_NUM THEN

         CS_ServiceRequest_UTIL.Validate_Who_Info
           ( p_api_name             => l_api_name_full,
             p_parameter_name_usr   => 'p_last_updated_by',
             p_parameter_name_login => NULL,
             p_user_id              => l_service_request_rec.last_updated_by,
             p_login_id             => NULL,
             x_return_status        => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF ;

    --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #2.1');


    --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #2.2');

    --
    -- Type, status, severity, resource_type, owner and publish flag are always validated
    -- Urgency, problem code, expected resolution date, resolution code, and
    -- actual resolution date are validated if passed (not NULL)
    --
    l_service_request_val_rec.validate_type   := FND_API.G_TRUE;
    l_service_request_val_rec.validate_status := FND_API.G_TRUE;
    l_service_request_val_rec.type_id         := l_service_request_rec.type_id;
    l_service_request_val_rec.status_id       := l_service_request_rec.status_id;
    l_service_request_val_rec.severity_id     := l_service_request_rec.severity_id;
    --l_service_request_val_rec.resource_type   := l_service_request_rec.resource_type;
    --l_service_request_val_rec.owner_id        := l_service_request_rec.owner_id;
    --l_service_request_val_rec.publish_flag    := l_service_request_rec.publish_flag;

    IF (l_service_request_rec.urgency_id IS NOT NULL
       AND l_service_request_rec.urgency_id <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.urgency_id          := l_service_request_rec.urgency_id;
    END IF;

    IF (l_service_request_rec.resource_type IS NOT NULL
       AND l_service_request_rec.resource_type <> FND_API.G_MISS_CHAR) THEN
      l_service_request_val_rec.resource_type := l_service_request_rec.resource_type;
    END IF;

---
    IF (l_service_request_rec.owner_id IS NOT NULL
       AND l_service_request_rec.owner_id <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.owner_id := l_service_request_rec.owner_id;
    END IF;

       IF (l_service_request_rec.customer_id <> FND_API.G_MISS_NUM AND
                l_service_request_rec.customer_id IS NOT NULL  )THEN
          l_service_request_val_rec.validate_customer := FND_API.G_TRUE;
           l_service_request_val_rec.customer_id   := l_service_request_rec.customer_id;
       END IF;

    IF (l_service_request_rec.problem_code IS NOT NULL
     AND l_service_request_rec.problem_code <> FND_API.G_MISS_CHAR) THEN
      l_service_request_val_rec.problem_code        := l_service_request_rec.problem_code;
    END IF;

---Added for bug 5278488 (FP For Bug # 5192499) spusegao 06/13/06

    If ( l_service_request_rec.publish_flag = FND_API.G_MISS_CHAR) Then
        l_service_request_rec.publish_flag := 'N' ;
        l_service_request_val_rec.publish_flag := FND_API.G_MISS_CHAR ;
    End If ;

-----Added for enhancement 1803588--11.5.6 ---jngeorge ----07/20/01
    IF (l_service_request_rec.cust_pref_lang_id IS NOT NULL
     AND l_service_request_rec.cust_pref_lang_id <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.cust_pref_lang_id := l_service_request_rec.cust_pref_lang_id;
    END IF;

-----Added for enhancement 1806657--11.5.6 ---jngeorge ----07/20/01
    IF (l_service_request_rec.comm_pref_code IS NOT NULL
     AND l_service_request_rec.comm_pref_code <> FND_API.G_MISS_CHAR) THEN
      l_service_request_val_rec.comm_pref_code := l_service_request_rec.comm_pref_code;
    END IF;

---------
    IF (l_service_request_rec.exp_resolution_date IS NOT NULL
     AND l_service_request_rec.exp_resolution_date <> FND_API.G_MISS_DATE) THEN
      l_service_request_val_rec.exp_resolution_date := l_service_request_rec.exp_resolution_date;
    END IF;

    IF (l_service_request_rec.resolution_code IS NOT NULL
     AND l_service_request_rec.resolution_code <> FND_API.G_MISS_CHAR)  THEN
      l_service_request_val_rec.resolution_code     := l_service_request_rec.resolution_code;
    END IF;

    IF (l_service_request_rec.act_resolution_date IS NOT NULL
     AND l_service_request_rec.act_resolution_date <> FND_API.G_MISS_DATE) THEN
      l_service_request_val_rec.act_resolution_date := l_service_request_rec.act_resolution_date;
    END IF;

  --- Added for Enh# 1830701
    l_service_request_val_rec.request_date := l_service_request_rec.request_date;

    IF (l_service_request_rec.incident_occurred_date IS NOT NULL
     AND l_service_request_rec.incident_occurred_date <> FND_API.G_MISS_DATE) THEN
      l_service_request_val_rec.incident_occurred_date := l_service_request_rec.incident_occurred_date;
    END IF;

    IF (l_service_request_rec.incident_resolved_date IS NOT NULL
     AND l_service_request_rec.incident_resolved_date <> FND_API.G_MISS_DATE) THEN
      l_service_request_val_rec.incident_resolved_date := l_service_request_rec.incident_resolved_date;
    END IF;

    IF (l_service_request_rec.inc_responded_by_date IS NOT NULL
     AND l_service_request_rec.inc_responded_by_date <> FND_API.G_MISS_DATE) THEN
      l_service_request_val_rec.inc_responded_by_date := l_service_request_rec.inc_responded_by_date;
    END IF;

  --- Added for Enh# 1830701
    IF (l_service_request_rec.incident_location_id IS NOT NULL
     AND l_service_request_rec.incident_location_id <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.incident_location_id := l_service_request_rec.incident_location_id;
      -- Bug 4386870 12/12/05 smisra
      -- if incident location is passed then ignore passed value of incident country
      -- incident country will be derived based on location
      l_service_request_rec.incident_country := null;
    ELSE
      -- Bug 3420335
      -- if location id is null then location type too should be null.
      l_service_request_rec.incident_location_type := null;
    END IF;

    IF (l_service_request_rec.incident_country IS NOT NULL
     AND l_service_request_rec.incident_country <> FND_API.G_MISS_CHAR) THEN
      l_service_request_val_rec.incident_country := l_service_request_rec.incident_country;
    END IF;

    --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #2.3');

    IF (nvl(l_service_request_rec.bill_to_site_id,-99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.validate_bill_to_site := FND_API.G_TRUE;
      l_service_request_val_rec.bill_to_site_id := l_service_request_rec.bill_to_site_id;
    END IF;

    IF (nvl(l_service_request_rec.bill_to_site_use_id, -99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.bill_to_site_use_id := l_service_request_rec.bill_to_site_use_id;
    END IF;

    IF (nvl(l_service_request_rec.bill_to_contact_id, -99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.bill_to_contact_id := l_service_request_rec.bill_to_contact_id;
    END IF;

    IF (nvl(l_service_request_rec.bill_to_party_id, -99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.bill_to_party_id := l_service_request_rec.bill_to_party_id;
    END IF;

    --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #2.4');

    IF (nvl(l_service_request_rec.ship_to_site_id, -99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.validate_ship_to_site := FND_API.G_TRUE;
      l_service_request_val_rec.ship_to_site_id := l_service_request_rec.ship_to_site_id;
    END IF;

    IF (nvl(l_service_request_rec.ship_to_site_use_id, -99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.ship_to_site_use_id := l_service_request_rec.ship_to_site_use_id;
    END IF;

    IF (nvl(l_service_request_rec.ship_to_contact_id,-99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.ship_to_contact_id := l_service_request_rec.ship_to_contact_id;
    END IF;


    IF (nvl(l_service_request_rec.ship_to_party_id,-99) <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.ship_to_party_id := l_service_request_rec.ship_to_party_id;
    END IF;

    --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #2.5');

    IF ( l_service_request_rec.install_site_id <> FND_API.G_MISS_NUM ) THEN
      l_service_request_val_rec.validate_install_site := FND_API.G_TRUE;
      l_service_request_val_rec.install_site_id := l_service_request_rec.install_site_id;
    ELSE
      l_service_request_val_rec.install_site_id := null;
    END IF;

    IF ( l_service_request_rec.install_site_use_id  <> FND_API.G_MISS_NUM) THEN
      l_service_request_val_rec.validate_install_site := FND_API.G_TRUE;
      l_service_request_val_rec.install_site_use_id := l_service_request_rec.install_site_use_id;
    END IF;

    ---************************
    --Assign all the fields to be validated
    IF (l_service_request_rec.contract_service_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.contract_service_id IS NOT NULL) THEN
      l_service_request_val_rec.contract_service_id := l_service_request_rec.contract_service_id;
    END IF;

    IF (l_service_request_rec.contract_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.contract_id IS NOT NULL) THEN
      l_service_request_val_rec.contract_id := l_service_request_rec.contract_id;
    END IF;

    IF (l_service_request_rec.project_number <> FND_API.G_MISS_CHAR AND
        l_service_request_rec.project_number IS NOT NULL) THEN
      l_service_request_val_rec.project_number := l_service_request_rec.project_number;
    END IF;

    --Caller_type and primary_contact_id is needed for account_id validation
    l_service_request_val_rec.caller_type := l_service_request_rec.caller_type;
    l_service_request_val_rec.primary_contact_id := l_primary_contact_id;

    IF (l_service_request_rec.account_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.account_id IS NOT NULL) THEN
      l_service_request_val_rec.account_id := l_service_request_rec.account_id;
    ELSE
      l_service_request_val_rec.account_id := null;

    END IF;

    IF (l_service_request_rec.platform_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.platform_id IS NOT NULL) THEN
      l_service_request_val_rec.platform_id := l_service_request_rec.platform_id;
    END IF;

    IF (l_service_request_rec.platform_version_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.platform_version_id IS NOT NULL) THEN
      l_service_request_val_rec.platform_version_id := l_service_request_rec.platform_version_id;
    END IF;

    IF (l_service_request_rec.inv_platform_org_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.inv_platform_org_id IS NOT NULL) THEN
      l_service_request_val_rec.inv_platform_org_id := l_service_request_rec.inv_platform_org_id;
    END IF;

    IF (l_service_request_rec.platform_version <> FND_API.G_MISS_CHAR AND
        l_service_request_rec.platform_version IS NOT NULL) THEN
        l_service_request_val_rec.platform_version := l_service_request_rec.platform_version;
    END IF;

    IF (l_service_request_rec.territory_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.territory_id IS NOT NULL) THEN
      l_service_request_val_rec.territory_id := l_service_request_rec.territory_id;
    END IF;


    IF (l_service_request_rec.site_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.site_id IS NOT NULL) THEN
      l_service_request_val_rec.site_id := l_service_request_rec.site_id;
    END IF;

    IF (l_service_request_rec.customer_product_id  <> FND_API.G_MISS_NUM AND
        l_service_request_rec.customer_product_id  IS NOT NULL) THEN
      l_service_request_val_rec.customer_product_id  := l_service_request_rec.customer_product_id ;
    ELSE
      l_service_request_val_rec.customer_product_id  := null ;
    END IF;

/* Start : 5501340 */
    IF (l_service_request_rec.system_id  <> FND_API.G_MISS_NUM AND
        l_service_request_rec.system_id  IS NOT NULL) THEN
      l_service_request_val_rec.system_id  := l_service_request_rec.system_id ;
    ELSE
      l_service_request_val_rec.system_id  := null ;
    END IF;
/* End : 5501340 */

   IF (l_service_request_rec.current_serial_number  <> FND_API.G_MISS_CHAR AND
                  l_service_request_rec.current_serial_number  IS NOT NULL) THEN
      l_service_request_val_rec.current_serial_number  := l_service_request_rec.current_serial_number  ;
  END IF;


   IF (l_service_request_rec.group_territory_id  <> FND_API.G_MISS_NUM AND
       l_service_request_rec.group_territory_id  IS NOT NULL) THEN
      l_service_request_val_rec.group_territory_id  := l_service_request_rec.group_territory_id  ;
  END IF;
-----------Added for Enhancements 11.5.6----------

--   IF (l_service_request_rec.product_revision  <> FND_API.G_MISS_CHAR AND
--       l_service_request_rec.product_revision  IS NOT NULL) THEN
      l_service_request_val_rec.product_revision  := l_service_request_rec.product_revision  ;
--  END IF;

-- IF (l_service_request_rec.component_version  <> FND_API.G_MISS_CHAR AND
--     l_service_request_rec.component_version  IS NOT NULL) THEN
      l_service_request_val_rec.component_version  := l_service_request_rec.component_version  ;
--END IF;

-- IF (l_service_request_rec.subcomponent_version  <> FND_API.G_MISS_CHAR AND
--     l_service_request_rec.subcomponent_version  IS NOT NULL) THEN
      l_service_request_val_rec.subcomponent_version  := l_service_request_rec.subcomponent_version  ;
--END IF;
-----------------------------------------

    -- If inventory org id is passed in, assign it to the validate rec
    IF (l_service_request_rec.inventory_org_id  <> FND_API.G_MISS_NUM AND
          l_service_request_rec.inventory_org_id  IS NOT NULL) THEN
     l_service_request_val_rec.inventory_org_id  := l_service_request_rec.inventory_org_id ;
    ELSE
     l_service_request_val_rec.inventory_org_id  := null ;
    END IF;

    -- If inventory item id is passed in, assign it to the validate rec
    IF (l_service_request_rec.inventory_item_id  <> FND_API.G_MISS_NUM AND
        l_service_request_rec.inventory_item_id  IS NOT NULL) THEN
        l_service_request_val_rec.inventory_item_id  := l_service_request_rec.inventory_item_id ;
    ELSE
        l_service_request_val_rec.inventory_item_id  := null;
    END IF;

    IF (l_service_request_rec.cp_component_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.cp_component_id IS NOT NULL) THEN
      l_service_request_val_rec.cp_component_id  := l_service_request_rec.cp_component_id ;
    END IF;

    IF (l_service_request_rec.cp_component_version_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.cp_component_version_id IS NOT NULL) THEN
      l_service_request_val_rec.cp_component_version_id  := l_service_request_rec.cp_component_version_id ;
    END IF;

    IF (l_service_request_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.cp_subcomponent_id IS NOT NULL) THEN
      l_service_request_val_rec.cp_subcomponent_id   := l_service_request_rec.cp_subcomponent_id  ;
    END IF;

    IF (l_service_request_rec.cp_subcomponent_version_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.cp_subcomponent_version_id IS NOT NULL) THEN
      l_service_request_val_rec.cp_subcomponent_version_id   := l_service_request_rec.cp_subcomponent_version_id  ;
    END IF;


    IF (l_service_request_rec.cp_revision_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.cp_revision_id IS NOT NULL) THEN
      l_service_request_val_rec.cp_revision_id   := l_service_request_rec.cp_revision_id ;
    END IF;

    IF (l_service_request_rec.inv_item_revision <> FND_API.G_MISS_CHAR AND
        l_service_request_rec.inv_item_revision IS NOT NULL) THEN
      l_service_request_val_rec.inv_item_revision    := l_service_request_rec.inv_item_revision  ;
    END IF;

    IF (l_service_request_rec.inv_component_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.inv_component_id IS NOT NULL) THEN
      l_service_request_val_rec.inv_component_id   := l_service_request_rec.inv_component_id ;
    END IF;

    IF (l_service_request_rec.inv_component_version <> FND_API.G_MISS_CHAR AND
        l_service_request_rec.inv_component_version  IS NOT NULL) THEN
      l_service_request_val_rec.inv_component_version    := l_service_request_rec.inv_component_version ;
    END IF;

    IF (l_service_request_rec.inv_subcomponent_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.inv_subcomponent_id IS NOT NULL) THEN
      l_service_request_val_rec.inv_subcomponent_id    := l_service_request_rec.inv_subcomponent_id ;
    END IF;

   IF (l_service_request_rec.inv_subcomponent_version <> FND_API.G_MISS_CHAR AND

        l_service_request_rec.inv_subcomponent_version IS NOT NULL) THEN
      l_service_request_val_rec.inv_subcomponent_version    := l_service_request_rec.inv_subcomponent_version ;
   END IF;

   --  Added bill_to_account_id         - ER# 2433831

   IF (l_service_request_rec.bill_to_account_id <> FND_API.G_MISS_NUM AND
       l_service_request_rec.bill_to_account_id IS NOT NULL) THEN
       l_service_request_val_rec.bill_to_account_id := l_service_request_rec.bill_to_account_id ;
   END IF;

   --  Added ship_to_account_id         - ER# 2433831

   IF (l_service_request_rec.ship_to_account_id <> FND_API.G_MISS_NUM AND
       l_service_request_rec.ship_to_account_id IS NOT NULL) THEN
       l_service_request_val_rec.ship_to_account_id := l_service_request_rec.ship_to_account_id ;
   END IF;

   --  Added customer_phone_id   - ER# 2463321

   IF (l_service_request_rec.customer_phone_id <> FND_API.G_MISS_NUM AND
       l_service_request_rec.customer_phone_id IS NOT NULL) THEN
       l_service_request_val_rec.customer_phone_id := l_service_request_rec.customer_phone_id ;
   END IF;

   --  Added customer_email_id   - ER# 2463321

   IF (l_service_request_rec.customer_email_id <> FND_API.G_MISS_NUM AND
       l_service_request_rec.customer_email_id IS NOT NULL) THEN
       l_service_request_val_rec.customer_email_id := l_service_request_rec.customer_email_id ;
   END IF;

   --Made changes for bug #2786844
   IF (l_service_request_rec.external_reference <> FND_API.G_MISS_CHAR AND
       l_service_request_rec.external_reference IS NOT NULL) THEN
       l_service_request_val_rec.external_reference := l_service_request_rec.external_reference ;
   END IF;

   -- for cmro_eam
   IF (l_service_request_rec.owning_dept_id <> FND_API.G_MISS_NUM AND
       l_service_request_rec.owning_dept_id IS NOT NULL) THEN
       l_service_request_val_rec.owning_dept_id := l_service_request_rec.owning_dept_id ;
   END IF;

   -- end of cmro_eam

   -- Added incident location type for Misc ERs project of 11.5.10 --anmukher --08/25/03
   IF (l_service_request_rec.incident_location_type IS NOT NULL
     AND l_service_request_rec.incident_location_type <> FND_API.G_MISS_CHAR) THEN
      l_service_request_val_rec.incident_location_type := l_service_request_rec.incident_location_type;
   END IF;

   -- Added to fix issue in bug # 3288806.
   IF ((l_service_request_rec.category_id IS NOT NULL) AND (l_service_request_rec.category_id <> FND_API.G_MISS_NUM)) THEN
       l_service_request_val_rec.category_id := l_service_request_rec.category_id ;
       IF (l_service_request_rec.category_set_id = FND_API.G_MISS_NUM) THEN
         l_service_request_rec.category_set_id := FND_PROFILE.value('CS_SR_DEFAULT_CATEGORY_SET');
       END IF;
       l_service_request_val_rec.category_set_id := l_service_request_rec.category_set_id ;
   END IF ;

   -- Added to fix issue in bug # 3288806.
   IF ((l_service_request_rec.category_set_id IS NOT NULL) AND (l_service_request_rec.category_set_id <> FND_API.G_MISS_NUM)) THEN
       l_service_request_val_rec.category_set_id := l_service_request_rec.category_set_id ;
   END IF ;
   IF (l_service_request_rec.group_type  <> FND_API.G_MISS_CHAR AND
       l_service_request_rec.group_type  IS NOT NULL) THEN
      l_service_request_val_rec.group_type  := l_service_request_rec.group_type;
  END IF;

   IF (l_service_request_rec.owner_group_id  <> FND_API.G_MISS_NUM AND
       l_service_request_rec.owner_group_id  IS NOT NULL) THEN
      l_service_request_val_rec.owner_group_id  := l_service_request_rec.owner_group_id  ;
  END IF;

   -- Added for bug 3635269

  IF (l_service_request_rec.sr_creation_channel  <> FND_API.G_MISS_CHAR AND
       l_service_request_rec.sr_creation_channel  IS NOT NULL) THEN
      l_service_request_val_rec.sr_creation_channel  := l_service_request_rec.sr_creation_channel  ;
  END IF;

  -- <bug5224245>
  IF (l_service_request_rec.system_id  <> FND_API.G_MISS_NUM AND
      l_service_request_rec.system_id IS NOT NULL) THEN
      l_service_request_val_rec.system_id  := l_service_request_rec.system_id;
  END IF;
  -- </bug5224245>

  -- there is no need to check if maint_org is equal to FND_API.G_MISS_NUM or not.
  -- val rec always have it's value as G_MISS_NUM. so it might replace G_MISS_NUM
  -- with G_MISS_NUM. No need to check for NULL too because validate_SR_record
  -- checks for null value too before calling any validation
  l_service_request_val_rec.maint_organization_id  :=
    l_service_request_rec.maint_organization_id;

    -- --------------------------------------------------------------------
    -- Validate all non-missing attributes by calling the utility procedure.
    -- --------------------------------------------------------------------
    Validate_ServiceRequest_Record
      (   p_api_name                => l_api_name_full,
          p_service_request_rec     => l_service_request_val_rec,
          p_request_date            => l_service_request_rec.request_date,
          p_org_id                  => l_org_id,
          p_resp_appl_id            => p_resp_appl_id,
          p_resp_id                 => p_resp_id,
          p_user_id                 => p_user_id,
          p_operation               => l_operation,
          p_close_flag              => l_close_flag,
          p_disallow_request_update => l_disallow_request_update,
          p_disallow_owner_update   => l_disallow_owner_update,
          p_disallow_product_update => l_disallow_product_update,
          p_employee_name           => l_employee_name,
          p_inventory_item_id       => l_cp_item_id,
          p_contract_id             => x_contra_id,
          p_contract_number         => x_contract_number,
          x_bill_to_site_id         => l_bill_to_site_id,
          x_ship_to_site_id         => l_ship_to_site_id,
          x_bill_to_site_use_id     => l_bill_to_site_use_id,
          x_ship_to_site_use_id     => l_ship_to_site_use_id,
          x_return_status           => x_return_status,
          x_group_name              => l_group_name,
          x_owner_name              => l_owner_name,
          x_product_revision        => l_service_request_rec.product_revision ,
          x_component_version       => l_service_request_rec.component_version,
          x_subcomponent_version    => l_service_request_rec.subcomponent_version,
 	   -- cmro_eam
          p_cmro_flag               => p_cmro_flag,
          p_maintenance_flag        => p_maintenance_flag,
		  p_sr_mode                 => 'CREATE'
      );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Done the changes for bug 2725543

    IF l_ship_to_site_id <> FND_API.G_MISS_NUM THEN
         l_service_request_rec.ship_to_site_id := l_ship_to_site_id;
    END IF;
    IF l_ship_to_site_use_id <> FND_API.G_MISS_NUM THEN
         l_service_request_rec.ship_to_site_use_id := l_ship_to_site_use_id;
    END IF;

    IF l_bill_to_site_id <> FND_API.G_MISS_NUM THEN
         l_service_request_rec.bill_to_site_id := l_bill_to_site_id;
    END IF;
    IF l_bill_to_site_use_id <> FND_API.G_MISS_NUM THEN
         l_service_request_rec.bill_to_site_use_id := l_bill_to_site_use_id;
    END IF;

    --cs_sERviceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #2.7');

    --
    -- If customer product ID is passed in and validated, use the inventory
    -- item ID retrieved from the CS_CUSTOMER_PRODUCTS_ALL table.
    --
    -- If customer_product_id is specified then the inventory item id
    -- specified in the record type is always overwritten by the inventory item
    -- id value in the
    -- CS_CUSTOMER_PRODUCTS_ALL for that customer_product_id
    IF (l_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM) THEN
      l_service_request_rec.inventory_item_id := l_cp_item_id;
    END IF;


    -- --------------------------------------------------------------------
    -- Validate the closed date if the status is a "closed" status, meaning
    -- that if the CLOSE_FLAG of the status is 'Y'. If not, ignore the
    -- closed date.  If it is a closed status, and the close date is not
    -- passed in, use the system date as the default close date.
    -- --------------------------------------------------------------------
    IF (l_close_flag = 'Y') THEN
      IF ((l_service_request_rec.closed_date = FND_API.G_MISS_DATE) OR
          (l_service_request_rec.closed_date IS NULL)) THEN
        l_service_request_rec.closed_date := SYSDATE;
      ELSIF (l_service_request_rec.closed_date IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_Closed_Date
          ( p_api_name       => l_api_name_full,
            p_parameter_name => 'p_closed_date',
            p_closed_date    => l_service_request_rec.closed_date,
            p_request_date   => l_service_request_rec.request_date,
            x_return_status  => l_return_status
          );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    ELSE
      IF ((l_service_request_rec.closed_date <> FND_API.G_MISS_DATE) AND
          (l_service_request_rec.closed_date IS NOT NULL)) THEN

        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg
                          (p_token_an    => l_api_name_full,
                           p_token_ip     => 'p_closed_date',
                           p_table_name  => G_TABLE_NAME,
                           p_column_name => 'CLOSED_DATE');
      END IF;
      l_service_request_rec.closed_date := NULL;
    END IF;

    -- Validate SR_CREATION_CHANNEL
    -- For bug 3635269
  /*  IF (l_service_request_rec.sr_creation_channel <> FND_API.G_MISS_CHAR AND
        l_service_request_rec.sr_creation_channel IS NOT NULL) THEN

          CS_ServiceRequest_UTIL.Validate_SR_Channel(
          p_api_name         => l_api_name_full,
          p_parameter_name   => 'p_sr_creation_channel',
          p_sr_creation_channel   => l_service_request_rec.sr_creation_channel,
          x_return_status    => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;  */



  END IF; /* IF p_validation_level >= FND_API.G_VALID_LEVEL_NONE THEN */

  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #3');

  --
  -- The request_id needs to be generated here because it is needed when
  -- inserting records into CS_HZ_SR_CONTACT_POINTS
  -- This generation is done here because the earlier check to see if
  -- request id is unique is done only if validation level is set.
  --Commenting this because , selecting from dual is not supported anymore
  --because of performance reasons.

  --CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'step #4');

   -- -------------------------------------------------------------
   --  Check if the passsed type_id has AutoLaunch Workflow flag set to 'Y'.
   --  If so, we need to call the workflow lauch API. We need to do this irrespective
   --  of the validation level set
   -- -------------------------------------------------------------

   BEGIN
     -- Initialize the return status.
     l_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Verify the type ID against the database.
     -- Done here cause, these flags need to get their values
     SELECT autolaunch_workflow_flag, abort_workflow_close_flag, workflow
     INTO   x_autolaunch_wkf_flag, x_abort_wkf_close_flag, x_wkf_process_name
     FROM   cs_incident_types_b
     WHERE  incident_type_id = l_service_request_rec.type_id
     AND    incident_subtype = G_SR_SUBTYPE
     ;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                        ( p_token_an    => l_api_name_full,
                          p_token_v     => TO_CHAR(l_service_request_rec.type_id),
                          p_token_p     => 'p_type_id',
                          p_table_name  => G_TABLE_NAME ,
                          p_column_name => 'INCIDENT_TYPE_ID');

       RAISE FND_API.G_EXC_ERROR;

   END ;

-- for the bug 3050727
l_service_request_rec.status_flag := get_status_flag(l_service_request_rec.status_id);
--- AUDIT

 IF (l_service_request_rec.urgency_id = FND_API.G_MISS_NUM) OR
     (l_service_request_rec.urgency_id IS NULL) THEN
    x_audit_vals_rec.change_incident_urgency_flag := 'N';
  ELSE
    x_audit_vals_rec.change_incident_urgency_FLAG := 'Y';
    x_audit_vals_rec.incident_urgency_id        := l_service_request_rec.urgency_id;
  END IF;


/*  IF (l_service_request_rec.owner_group_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.owner_group_id IS NULL) THEN
    x_audit_vals_rec.change_owner_group_id_flag := 'N';
  ELSE
    x_audit_vals_rec.change_owner_group_id_FLAG := 'Y';
    x_audit_vals_rec.owner_group_id        := l_service_request_rec.owner_group_id;
  END IF;
*/

  IF (l_service_request_rec.product_revision = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.product_revision IS NULL) THEN
    x_audit_vals_rec.change_product_revision_flag := 'N';
  ELSE
    x_audit_vals_rec.change_product_revision_FLAG := 'Y';
    x_audit_vals_rec.product_revision        := l_service_request_rec.product_revision;
  END IF;

  IF (l_service_request_rec.component_version = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.component_version IS NULL) THEN
    x_audit_vals_rec.CHANGE_COMP_VER_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_COMP_VER_FLAG := 'Y';
    x_audit_vals_rec.component_version        := l_service_request_rec.component_version;
  END IF;

  IF (l_service_request_rec.subcomponent_version = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.subcomponent_version IS NULL) THEN
    x_audit_vals_rec.CHANGE_SUBCOMP_VER_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_SUBCOMP_VER_FLAG := 'Y';
    x_audit_vals_rec.subcomponent_version       := l_service_request_rec.subcomponent_version;
  END IF;

  IF (l_service_request_rec.platform_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.platform_id IS NULL) THEN
    x_audit_vals_rec.change_platform_id_flag := 'N';
  ELSE
    x_audit_vals_rec.change_platform_id_FLAG := 'Y';
    x_audit_vals_rec.platform_id        := l_service_request_rec.platform_id;
  END IF;

  IF (l_service_request_rec.customer_product_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.customer_product_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'Y';
    x_audit_vals_rec.customer_product_id        := l_service_request_rec.customer_product_id;
  END IF;

  IF (l_service_request_rec.cp_component_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.cp_component_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'Y';
    x_audit_vals_rec.cp_component_id        := l_service_request_rec.cp_component_id;
  END IF;

  IF (l_service_request_rec.cp_component_version_id  = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.cp_component_version_id  IS NULL) THEN
    x_audit_vals_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'Y';
    x_audit_vals_rec.cp_component_version_id        := l_service_request_rec.cp_component_version_id;
  END IF;

  IF (l_service_request_rec.cp_subcomponent_id  = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.cp_subcomponent_id  IS NULL) THEN
    x_audit_vals_rec.change_cp_subcomponent_id_flag := 'N';
  ELSE
    x_audit_vals_rec.change_cp_subcomponent_id_FLAG := 'Y';
    x_audit_vals_rec.cp_subcomponent_id        := l_service_request_rec.cp_subcomponent_id;
  END IF;

  IF (l_service_request_rec.cp_subcomponent_version_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.cp_subcomponent_version_id  IS NULL) THEN
    x_audit_vals_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'Y';
    x_audit_vals_rec.cp_subcomponent_version_id        := l_service_request_rec.cp_subcomponent_version_id;
  END IF;

  IF (l_service_request_rec.cp_revision_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.cp_revision_id  IS NULL) THEN
    x_audit_vals_rec.change_cp_revision_id_flag := 'N';
  ELSE
    x_audit_vals_rec.change_cp_revision_id_FLAG := 'Y';
    x_audit_vals_rec.cp_revision_id        := l_service_request_rec.cp_revision_id;
  END IF;

  IF (l_service_request_rec.inv_item_revision = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.inv_item_revision  IS NULL) THEN
    x_audit_vals_rec.change_inv_item_revision := 'N';
  ELSE
    x_audit_vals_rec.change_inv_item_revision := 'Y';
    x_audit_vals_rec.inv_item_revision        := l_service_request_rec.inv_item_revision;
  END IF;

  IF (l_service_request_rec.inv_component_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.inv_component_id IS NULL) THEN
    x_audit_vals_rec.change_inv_component_id := 'N';
  ELSE
    x_audit_vals_rec.change_inv_component_id := 'Y';
    x_audit_vals_rec.inv_component_id        := l_service_request_rec.inv_component_id;
  END IF;

  IF (l_service_request_rec.inv_component_version = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.inv_component_version  IS NULL) THEN
    x_audit_vals_rec.change_inv_component_version := 'N';
  ELSE
    x_audit_vals_rec.change_inv_component_version := 'Y';
    x_audit_vals_rec.inv_component_version        := l_service_request_rec.inv_component_version;
  END IF;

  IF (l_service_request_rec.inv_subcomponent_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.inv_subcomponent_id IS NULL) THEN
    x_audit_vals_rec.change_inv_subcomponent_id := 'N';
  ELSE
    x_audit_vals_rec.change_inv_subcomponent_id := 'Y';
    x_audit_vals_rec.inv_subcomponent_id        := l_service_request_rec.inv_subcomponent_id;
  END IF;

  IF (l_service_request_rec.inv_subcomponent_version = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.inv_subcomponent_version  IS NULL) THEN
    x_audit_vals_rec.CHANGE_INV_SUBCOMP_VERSION := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_INV_SUBCOMP_VERSION := 'Y';
    x_audit_vals_rec.inv_subcomponent_version        := l_service_request_rec.inv_subcomponent_version;
  END IF;

  IF (l_service_request_rec.inventory_item_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.inventory_item_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_INVENTORY_ITEM_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_INVENTORY_ITEM_FLAG := 'Y';
    x_audit_vals_rec.inventory_item_id        := l_service_request_rec.inventory_item_id;
  END IF;

  IF (l_service_request_rec.inv_platform_org_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.inv_platform_org_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'Y';
    x_audit_vals_rec.inv_platform_org_id        := l_service_request_rec.inv_platform_org_id;
  END IF;

  /* move to create_serevicerequest just before call to create audit rec 7/21/05 smisra
  This was need because these dates returned by get_contract were not stamped on audit rec
  IF (l_service_request_rec.exp_resolution_date = FND_API.G_MISS_DATE) OR
    (l_service_request_rec.exp_resolution_date IS NULL) THEN
    x_audit_vals_rec.CHANGE_RESOLUTION_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_RESOLUTION_FLAG := 'Y';
    x_audit_vals_rec.EXPECTED_RESOLUTION_DATE        := l_service_request_rec.exp_resolution_date;
  END IF;

  IF (l_service_request_rec.obligation_date = FND_API.G_MISS_DATE) OR
    (l_service_request_rec.obligation_date IS NULL) THEN
    x_audit_vals_rec.CHANGE_OBLIGATION_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_OBLIGATION_FLAG := 'Y';
    x_audit_vals_rec.obligation_date        := l_service_request_rec.obligation_date;
  END IF;
  ************************************************************************************/

  IF (l_service_request_rec.territory_id = FND_API.G_MISS_NUM) OR
     (l_service_request_rec.territory_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_TERRITORY_ID_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_TERRITORY_ID_FLAG := 'Y';
    x_audit_vals_rec.territory_id        := l_service_request_rec.territory_id;
  END IF;

  IF (l_service_request_rec.bill_to_contact_id = FND_API.G_MISS_NUM ) OR
     (l_service_request_rec.bill_to_contact_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_BILL_TO_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_BILL_TO_FLAG := 'Y';
    x_audit_vals_rec.bill_to_contact_id        := l_service_request_rec.bill_to_contact_id;
  END IF;

  IF (l_service_request_rec.ship_to_contact_id = FND_API.G_MISS_NUM ) OR
     (l_service_request_rec.ship_to_contact_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_SHIP_TO_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_SHIP_TO_FLAG := 'Y';
    x_audit_vals_rec.ship_to_contact_id        := l_service_request_rec.ship_to_contact_id;
  END IF;

  IF (l_service_request_rec.status_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.status_id IS NULL) THEN
    x_audit_vals_rec.change_incident_status_flag := 'N';
  ELSE
    x_audit_vals_rec.change_incident_status_flag := 'Y';
    x_audit_vals_rec.incident_status_id        := l_service_request_rec.status_id;
  END IF;

 -- Added following block of code to populate the close date audit columns on SR creation in close status.
 -- spusegao 04/05/2004

  IF NVL(l_close_flag,'N') = 'Y' THEN
     x_audit_vals_rec.close_date := l_service_request_rec.closed_date ;
     x_audit_vals_rec.old_close_date := null;
     x_audit_vals_rec.change_close_date_flag := 'Y';
  ELSE
     x_audit_vals_rec.close_date := null;
     x_audit_vals_rec.old_close_date := null;
     x_audit_vals_rec.change_close_date_flag := 'N' ;
  END IF ;

    IF (l_service_request_rec.TYPE_ID = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.TYPE_ID IS NULL) THEN
    x_audit_vals_rec.CHANGE_INCIDENT_TYPE_FLAG := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_INCIDENT_TYPE_FLAG := 'Y';
    x_audit_vals_rec.INCIDENT_TYPE_ID        := l_service_request_rec.TYPE_ID;
  END IF;

  IF (l_service_request_rec.SEVERITY_ID  = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.SEVERITY_ID  IS NULL) THEN
    x_audit_vals_rec.CHANGE_INCIDENT_SEVERITY_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_INCIDENT_SEVERITY_FLAG  := 'Y';
    x_audit_vals_rec.INCIDENT_SEVERITY_ID         := l_service_request_rec.SEVERITY_ID ;
  END IF;

  IF (l_service_request_rec.REQUEST_DATE = FND_API.G_MISS_DATE) OR
    (l_service_request_rec.REQUEST_DATE IS NULL) THEN
    x_audit_vals_rec.CHANGE_INCIDENT_DATE_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_INCIDENT_DATE_FLAG  := 'Y';
    x_audit_vals_rec.INCIDENT_DATE        := l_service_request_rec.REQUEST_DATE;
  END IF;

  IF (l_service_request_rec.PLATFORM_VERSION_ID = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.PLATFORM_VERSION_ID IS NULL) THEN
    x_audit_vals_rec.CHANGE_PLAT_VER_ID_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_PLAT_VER_ID_FLAG  := 'Y';
    x_audit_vals_rec.PLATFORM_VERSION_ID        := l_service_request_rec.PLATFORM_VERSION_ID;
  END IF;

  IF (l_service_request_rec.LANGUAGE_ID = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.LANGUAGE_ID IS NULL) THEN
    x_audit_vals_rec.CHANGE_LANGUAGE_ID_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_LANGUAGE_ID_FLAG  := 'Y';
    x_audit_vals_rec.LANGUAGE_ID        := l_service_request_rec.LANGUAGE_ID;
  END IF;


  IF (l_service_request_rec.inventory_org_id = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.inventory_org_id IS NULL) THEN
    x_audit_vals_rec.CHANGE_INV_ORGANIZATION_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_INV_ORGANIZATION_FLAG  := 'Y';
    x_audit_vals_rec.INV_ORGANIZATION_ID        := l_service_request_rec.inventory_org_id;
  END IF;

  IF (l_service_request_rec.STATUS_FLAG = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.STATUS_FLAG IS NULL) THEN
    x_audit_vals_rec.CHANGE_STATUS_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_STATUS_FLAG  := 'Y';
    x_audit_vals_rec.STATUS_FLAG        := l_service_request_rec.STATUS_FLAG;
  END IF;

  --- BUG 3640344 -  pkesani

  IF (l_service_request_rec.closed_date = FND_API.G_MISS_DATE) OR
    (l_service_request_rec.closed_date IS NULL) THEN
    x_audit_vals_rec.CHANGE_CLOSE_DATE_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_CLOSE_DATE_FLAG  := 'Y';
    x_audit_vals_rec.CLOSE_DATE        := l_service_request_rec.closed_date;
  END IF;

  IF (l_service_request_rec.PRIMARY_CONTACT_ID = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.PRIMARY_CONTACT_ID IS NULL) THEN
    x_audit_vals_rec.CHANGE_PRIMARY_CONTACT_FLAG  := 'N';
  ELSE
    x_audit_vals_rec.CHANGE_PRIMARY_CONTACT_FLAG  := 'Y';
    x_audit_vals_rec.PRIMARY_CONTACT_ID        := l_service_request_rec.PRIMARY_CONTACT_ID;
  END IF;

  -- Added for Auditing project of 11.5.10 --anmukher --09/03/03

  IF (l_service_request_rec.CUSTOMER_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CUSTOMER_ID IS NOT NULL) THEN
    x_audit_vals_rec.CUSTOMER_ID		:= l_service_request_rec.CUSTOMER_ID;
  END IF;

  IF (l_service_request_rec.BILL_TO_SITE_USE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.BILL_TO_SITE_USE_ID IS NOT NULL) THEN
    x_audit_vals_rec.BILL_TO_SITE_USE_ID	:= l_service_request_rec.BILL_TO_SITE_USE_ID;
  END IF;

  IF (l_service_request_rec.EMPLOYEE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.EMPLOYEE_ID IS NOT NULL) THEN
    x_audit_vals_rec.EMPLOYEE_ID		:= l_service_request_rec.EMPLOYEE_ID;
  END IF;

  IF (l_service_request_rec.SHIP_TO_SITE_USE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.SHIP_TO_SITE_USE_ID IS NOT NULL) THEN
    x_audit_vals_rec.SHIP_TO_SITE_USE_ID	:= l_service_request_rec.SHIP_TO_SITE_USE_ID;
  END IF;

  IF (l_service_request_rec.PROBLEM_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.PROBLEM_CODE IS NOT NULL) THEN
    x_audit_vals_rec.PROBLEM_CODE		:= l_service_request_rec.PROBLEM_CODE;
  END IF;

  IF (l_service_request_rec.ACT_RESOLUTION_DATE <> FND_API.G_MISS_DATE) AND
    (l_service_request_rec.ACT_RESOLUTION_DATE IS NOT NULL) THEN
    x_audit_vals_rec.ACTUAL_RESOLUTION_DATE	:= l_service_request_rec.ACT_RESOLUTION_DATE;
  END IF;

  IF (l_service_request_rec.INSTALL_SITE_USE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.INSTALL_SITE_USE_ID IS NOT NULL) THEN
    x_audit_vals_rec.INSTALL_SITE_USE_ID	:= l_service_request_rec.INSTALL_SITE_USE_ID;
  END IF;

  IF (l_service_request_rec.CURRENT_SERIAL_NUMBER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.CURRENT_SERIAL_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.CURRENT_SERIAL_NUMBER	:= l_service_request_rec.CURRENT_SERIAL_NUMBER;
  END IF;

  IF (l_service_request_rec.SYSTEM_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.SYSTEM_ID IS NOT NULL) THEN
    x_audit_vals_rec.SYSTEM_ID			:= l_service_request_rec.SYSTEM_ID;
  END IF;

--01/23/04 request and external context were not processed for g_miss_char
  IF (l_service_request_rec.REQUEST_ATTRIBUTE_1 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_1 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_1	:= l_service_request_rec.REQUEST_ATTRIBUTE_1;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_2 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_2 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_2	:= l_service_request_rec.REQUEST_ATTRIBUTE_2;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_3 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_3 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_3	:= l_service_request_rec.REQUEST_ATTRIBUTE_3;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_4 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_4 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_4	:= l_service_request_rec.REQUEST_ATTRIBUTE_4;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_5 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_5 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_5	:= l_service_request_rec.REQUEST_ATTRIBUTE_5;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_6 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_6 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_6	:= l_service_request_rec.REQUEST_ATTRIBUTE_6;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_7 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_7 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_7	:= l_service_request_rec.REQUEST_ATTRIBUTE_7;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_8 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_8 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_8	:= l_service_request_rec.REQUEST_ATTRIBUTE_8;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_9 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_9 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_9	:= l_service_request_rec.REQUEST_ATTRIBUTE_9;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_10 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_10 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_10	:= l_service_request_rec.REQUEST_ATTRIBUTE_10;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_11 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_11 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_11	:= l_service_request_rec.REQUEST_ATTRIBUTE_11;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_12 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_12 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_12	:= l_service_request_rec.REQUEST_ATTRIBUTE_12;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_13 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_13 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_13	:= l_service_request_rec.REQUEST_ATTRIBUTE_13;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_14 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_14 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_14	:= l_service_request_rec.REQUEST_ATTRIBUTE_14;
  END IF;

  IF (l_service_request_rec.REQUEST_ATTRIBUTE_15 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_ATTRIBUTE_15 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_15	:= l_service_request_rec.REQUEST_ATTRIBUTE_15;
  END IF;

  IF (l_service_request_rec.REQUEST_CONTEXT <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.REQUEST_CONTEXT IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_CONTEXT		:= l_service_request_rec.REQUEST_CONTEXT;
  END IF;

  IF (l_service_request_rec.RESOLUTION_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.RESOLUTION_CODE IS NOT NULL) THEN
    x_audit_vals_rec.RESOLUTION_CODE		:= l_service_request_rec.RESOLUTION_CODE;
  END IF;

  IF (l_service_request_rec.ORIGINAL_ORDER_NUMBER <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.ORIGINAL_ORDER_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.ORIGINAL_ORDER_NUMBER	:= l_service_request_rec.ORIGINAL_ORDER_NUMBER;
  END IF;

  /* Could not populate this column as no equivalent column was found in l_service_request_rec */
  /*
  IF (l_service_request_rec.ORIGINAL_ORDER_NUMBER <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.ORIGINAL_ORDER_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.ORG_ID			:= l_service_request_rec.ORIGINAL_ORDER_NUMBER;
  END IF;
  */

  IF (l_service_request_rec.PURCHASE_ORDER_NUM <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.PURCHASE_ORDER_NUM IS NOT NULL) THEN
    x_audit_vals_rec.PURCHASE_ORDER_NUMBER	:= l_service_request_rec.PURCHASE_ORDER_NUM;
  END IF;

  IF (l_service_request_rec.PUBLISH_FLAG <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.PUBLISH_FLAG IS NOT NULL) THEN
    x_audit_vals_rec.PUBLISH_FLAG		:= l_service_request_rec.PUBLISH_FLAG;
  END IF;

  IF (l_service_request_rec.QA_COLLECTION_PLAN_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.QA_COLLECTION_PLAN_ID IS NOT NULL) THEN
    x_audit_vals_rec.QA_COLLECTION_ID		:= l_service_request_rec.QA_COLLECTION_PLAN_ID;
  END IF;

  IF (l_service_request_rec.CONTRACT_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CONTRACT_ID IS NOT NULL) THEN
    x_audit_vals_rec.CONTRACT_ID		:= l_service_request_rec.CONTRACT_ID;
  END IF;

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (l_service_request_rec.CONTRACT_ID <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.CONTRACT_ID IS NOT NULL) THEN
    x_audit_vals_rec.CONTRACT_NUMBER		:= l_service_request_rec.CONTRACT_ID;
  END IF;
  */

  IF (l_service_request_rec.CONTRACT_SERVICE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CONTRACT_SERVICE_ID IS NOT NULL) THEN
    x_audit_vals_rec.CONTRACT_SERVICE_ID	:= l_service_request_rec.CONTRACT_SERVICE_ID;
  END IF;

  IF (l_service_request_rec.TIME_ZONE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.TIME_ZONE_ID IS NOT NULL) THEN
    x_audit_vals_rec.TIME_ZONE_ID		:= l_service_request_rec.TIME_ZONE_ID;
  END IF;

  IF (l_service_request_rec.ACCOUNT_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.ACCOUNT_ID IS NOT NULL) THEN
    x_audit_vals_rec.ACCOUNT_ID			:= l_service_request_rec.ACCOUNT_ID;
  END IF;

  IF (l_service_request_rec.TIME_DIFFERENCE <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.TIME_DIFFERENCE IS NOT NULL) THEN
    x_audit_vals_rec.TIME_DIFFERENCE		:= l_service_request_rec.TIME_DIFFERENCE;
  END IF;

  IF (l_service_request_rec.CUST_PO_NUMBER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.CUST_PO_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.CUSTOMER_PO_NUMBER		:= l_service_request_rec.CUST_PO_NUMBER;
  END IF;

  IF (l_service_request_rec.CUST_TICKET_NUMBER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.CUST_TICKET_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.CUSTOMER_TICKET_NUMBER	:= l_service_request_rec.CUST_TICKET_NUMBER;
  END IF;

  IF (l_service_request_rec.CUSTOMER_SITE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CUSTOMER_SITE_ID IS NOT NULL) THEN
    x_audit_vals_rec.CUSTOMER_SITE_ID		:= l_service_request_rec.CUSTOMER_SITE_ID;
  END IF;

  IF (l_service_request_rec.CALLER_TYPE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.CALLER_TYPE IS NOT NULL) THEN
    x_audit_vals_rec.CALLER_TYPE		:= l_service_request_rec.CALLER_TYPE;
  END IF;

  IF (l_service_request_rec.PROJECT_NUMBER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.PROJECT_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.PROJECT_NUMBER		:= l_service_request_rec.PROJECT_NUMBER;
  END IF;

  IF (l_service_request_rec.PLATFORM_VERSION <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.PLATFORM_VERSION IS NOT NULL) THEN
    x_audit_vals_rec.PLATFORM_VERSION		:= l_service_request_rec.PLATFORM_VERSION;
  END IF;

  IF (l_service_request_rec.DB_VERSION <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.DB_VERSION IS NOT NULL) THEN
    x_audit_vals_rec.DB_VERSION			:= l_service_request_rec.DB_VERSION;
  END IF;

  IF (l_service_request_rec.DB_VERSION <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.DB_VERSION IS NOT NULL) THEN
    x_audit_vals_rec.DB_VERSION			:= l_service_request_rec.DB_VERSION;
  END IF;

  IF (l_service_request_rec.CUST_PREF_LANG_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CUST_PREF_LANG_ID IS NOT NULL) THEN
    x_audit_vals_rec.CUST_PREF_LANG_ID		:= l_service_request_rec.CUST_PREF_LANG_ID;
  END IF;

  IF (l_service_request_rec.TIER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.TIER IS NOT NULL) THEN
    x_audit_vals_rec.TIER			:= l_service_request_rec.TIER;
  END IF;

  IF (l_service_request_rec.CATEGORY_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CATEGORY_ID IS NOT NULL) THEN
    x_audit_vals_rec.CATEGORY_ID		:= l_service_request_rec.CATEGORY_ID;
  END IF;

  IF (l_service_request_rec.OPERATING_SYSTEM <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.OPERATING_SYSTEM IS NOT NULL) THEN
    x_audit_vals_rec.OPERATING_SYSTEM		:= l_service_request_rec.OPERATING_SYSTEM;
  END IF;

  IF (l_service_request_rec.OPERATING_SYSTEM_VERSION <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.OPERATING_SYSTEM_VERSION IS NOT NULL) THEN
    x_audit_vals_rec.OPERATING_SYSTEM_VERSION	:= l_service_request_rec.OPERATING_SYSTEM_VERSION;
  END IF;

  IF (l_service_request_rec.DATABASE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.DATABASE IS NOT NULL) THEN
    x_audit_vals_rec.DATABASE			:= l_service_request_rec.DATABASE;
  END IF;

  IF (l_service_request_rec.GROUP_TERRITORY_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.GROUP_TERRITORY_ID IS NOT NULL) THEN
    x_audit_vals_rec.GROUP_TERRITORY_ID		:= l_service_request_rec.GROUP_TERRITORY_ID;
  END IF;

  IF (l_service_request_rec.COMM_PREF_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.COMM_PREF_CODE IS NOT NULL) THEN
    x_audit_vals_rec.COMM_PREF_CODE		:= l_service_request_rec.COMM_PREF_CODE;
  END IF;

  IF (l_service_request_rec.LAST_UPDATE_CHANNEL <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.LAST_UPDATE_CHANNEL IS NOT NULL) THEN
    x_audit_vals_rec.LAST_UPDATE_CHANNEL	:= l_service_request_rec.LAST_UPDATE_CHANNEL;
  END IF;

  IF (l_service_request_rec.CUST_PREF_LANG_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.CUST_PREF_LANG_CODE IS NOT NULL) THEN
    x_audit_vals_rec.CUST_PREF_LANG_CODE	:= l_service_request_rec.CUST_PREF_LANG_CODE;
  END IF;

  IF (l_service_request_rec.ERROR_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.ERROR_CODE IS NOT NULL) THEN
    x_audit_vals_rec.ERROR_CODE			:= l_service_request_rec.ERROR_CODE;
  END IF;

  IF (l_service_request_rec.CATEGORY_SET_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CATEGORY_SET_ID IS NOT NULL) THEN
    x_audit_vals_rec.CATEGORY_SET_ID		:= l_service_request_rec.CATEGORY_SET_ID;
  END IF;

  IF (l_service_request_rec.EXTERNAL_REFERENCE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_REFERENCE IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_REFERENCE		:= l_service_request_rec.EXTERNAL_REFERENCE;
  END IF;

  IF (l_service_request_rec.INCIDENT_OCCURRED_DATE <> FND_API.G_MISS_DATE) AND
    (l_service_request_rec.INCIDENT_OCCURRED_DATE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_OCCURRED_DATE	:= l_service_request_rec.INCIDENT_OCCURRED_DATE;
  END IF;

  IF (l_service_request_rec.INCIDENT_RESOLVED_DATE <> FND_API.G_MISS_DATE) AND
    (l_service_request_rec.INCIDENT_RESOLVED_DATE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_RESOLVED_DATE	:= l_service_request_rec.INCIDENT_RESOLVED_DATE;
  END IF;

  IF (l_service_request_rec.INC_RESPONDED_BY_DATE <> FND_API.G_MISS_DATE) AND
    (l_service_request_rec.INC_RESPONDED_BY_DATE IS NOT NULL) THEN
    x_audit_vals_rec.INC_RESPONDED_BY_DATE	:= l_service_request_rec.INC_RESPONDED_BY_DATE;
  END IF;

  /* 12/13/05 smisra
  moved to create_servicerequest just before call to create audit
  IF (l_service_request_rec.INCIDENT_LOCATION_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.INCIDENT_LOCATION_ID IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_LOCATION_ID	:= l_service_request_rec.INCIDENT_LOCATION_ID;
  END IF;
  ****/

  IF (l_service_request_rec.INCIDENT_ADDRESS <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_ADDRESS IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS		:= l_service_request_rec.INCIDENT_ADDRESS;
  END IF;

  IF (l_service_request_rec.INCIDENT_CITY <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_CITY IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_CITY		:= l_service_request_rec.INCIDENT_CITY;
  END IF;

  IF (l_service_request_rec.INCIDENT_STATE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_STATE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_STATE		:= l_service_request_rec.INCIDENT_STATE;
  END IF;

  /* 12/13/05 smisra
  moved to create_servicerequest just before call to create audit
  IF (l_service_request_rec.INCIDENT_COUNTRY <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_COUNTRY IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_COUNTRY		:= l_service_request_rec.INCIDENT_COUNTRY;
  END IF;
  ***/

  IF (l_service_request_rec.INCIDENT_PROVINCE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_PROVINCE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_PROVINCE		:= l_service_request_rec.INCIDENT_PROVINCE;
  END IF;

  IF (l_service_request_rec.INCIDENT_POSTAL_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_POSTAL_CODE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_POSTAL_CODE	:= l_service_request_rec.INCIDENT_POSTAL_CODE;
  END IF;

  IF (l_service_request_rec.INCIDENT_COUNTY <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_COUNTY IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_COUNTY		:= l_service_request_rec.INCIDENT_COUNTY;
  END IF;

  IF (l_service_request_rec.SR_CREATION_CHANNEL <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.SR_CREATION_CHANNEL IS NOT NULL) THEN
    x_audit_vals_rec.SR_CREATION_CHANNEL	:= l_service_request_rec.SR_CREATION_CHANNEL;
  END IF;

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (l_service_request_rec. <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec. IS NOT NULL) THEN
    x_audit_vals_rec.DEF_DEFECT_ID		:= l_service_request_rec.;
  END IF;
  */

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (l_service_request_rec. <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec. IS NOT NULL) THEN
    x_audit_vals_rec.DEF_DEFECT_ID2		:= l_service_request_rec.;
  END IF;
  */

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_1 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_1 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_1	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_2 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_2 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_2	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_2;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_3 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_3 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_3	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_3;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_4 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_4 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_4	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_4;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_5 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_5 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_5	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_5;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_6 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_6 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_6	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_6;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_7 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_7 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_7	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_7;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_8 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_8 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_8	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_8;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_9 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_9 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_9	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_9;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_10 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_10 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_10	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_10;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_11 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_11 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_11	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_11;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_12 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_12 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_12	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_12;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_13 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_13 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_13	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_13;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_14 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_14 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_14	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_14;
  END IF;

  IF (l_service_request_rec.EXTERNAL_ATTRIBUTE_15 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_ATTRIBUTE_15 IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_15	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_15;
  END IF;

  IF (l_service_request_rec.EXTERNAL_CONTEXT <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.EXTERNAL_CONTEXT IS NOT NULL) THEN
    x_audit_vals_rec.EXTERNAL_CONTEXT		:= l_service_request_rec.EXTERNAL_CONTEXT;
  END IF;

  IF (l_service_request_rec.LAST_UPDATE_PROGRAM_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.LAST_UPDATE_PROGRAM_CODE IS NOT NULL) THEN
    x_audit_vals_rec.LAST_UPDATE_PROGRAM_CODE	:= l_service_request_rec.LAST_UPDATE_PROGRAM_CODE;
  END IF;

  IF (l_service_request_rec.CREATION_PROGRAM_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.CREATION_PROGRAM_CODE IS NOT NULL) THEN
    x_audit_vals_rec.CREATION_PROGRAM_CODE	:= l_service_request_rec.CREATION_PROGRAM_CODE;
  END IF;

  /****
  16th Nov 2005 smisra:
  coverage type is determined based on contract service id after
  call to create SR Validation.
  so moving this code to just before audit creation call
  --
  IF (l_service_request_rec.COVERAGE_TYPE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.COVERAGE_TYPE IS NOT NULL) THEN
    x_audit_vals_rec.COVERAGE_TYPE		:= l_service_request_rec.COVERAGE_TYPE;
  END IF;
  *******************************************************************************/

  IF (l_service_request_rec.BILL_TO_ACCOUNT_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.BILL_TO_ACCOUNT_ID IS NOT NULL) THEN
    x_audit_vals_rec.BILL_TO_ACCOUNT_ID		:= l_service_request_rec.BILL_TO_ACCOUNT_ID;
  END IF;

  IF (l_service_request_rec.SHIP_TO_ACCOUNT_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.SHIP_TO_ACCOUNT_ID IS NOT NULL) THEN
    x_audit_vals_rec.SHIP_TO_ACCOUNT_ID		:= l_service_request_rec.SHIP_TO_ACCOUNT_ID;
  END IF;

  IF (l_service_request_rec.CUSTOMER_EMAIL_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CUSTOMER_EMAIL_ID IS NOT NULL) THEN
    x_audit_vals_rec.CUSTOMER_EMAIL_ID		:= l_service_request_rec.CUSTOMER_EMAIL_ID;
  END IF;

  IF (l_service_request_rec.CUSTOMER_PHONE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.CUSTOMER_PHONE_ID IS NOT NULL) THEN
    x_audit_vals_rec.CUSTOMER_PHONE_ID		:= l_service_request_rec.CUSTOMER_PHONE_ID;
  END IF;

  IF (l_service_request_rec.BILL_TO_PARTY_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.BILL_TO_PARTY_ID IS NOT NULL) THEN
    x_audit_vals_rec.BILL_TO_PARTY_ID		:= l_service_request_rec.BILL_TO_PARTY_ID;
  END IF;

  IF (l_service_request_rec.SHIP_TO_PARTY_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.SHIP_TO_PARTY_ID IS NOT NULL) THEN
    x_audit_vals_rec.SHIP_TO_PARTY_ID		:= l_service_request_rec.SHIP_TO_PARTY_ID;
  END IF;

  IF (l_service_request_rec.BILL_TO_SITE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.BILL_TO_SITE_ID IS NOT NULL) THEN
    x_audit_vals_rec.BILL_TO_SITE_ID		:= l_service_request_rec.BILL_TO_SITE_ID;
  END IF;

  IF (l_service_request_rec.SHIP_TO_SITE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.SHIP_TO_SITE_ID IS NOT NULL) THEN
    x_audit_vals_rec.SHIP_TO_SITE_ID		:= l_service_request_rec.SHIP_TO_SITE_ID;
  END IF;

  IF (l_service_request_rec.PROGRAM_LOGIN_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.PROGRAM_LOGIN_ID IS NOT NULL) THEN
    x_audit_vals_rec.PROGRAM_LOGIN_ID		:= l_service_request_rec.PROGRAM_LOGIN_ID;
  END IF;

  IF (l_service_request_rec.INCIDENT_POINT_OF_INTEREST <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_POINT_OF_INTEREST IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_POINT_OF_INTEREST	:= l_service_request_rec.INCIDENT_POINT_OF_INTEREST;
  END IF;

  IF (l_service_request_rec.INCIDENT_CROSS_STREET <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_CROSS_STREET IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_CROSS_STREET	:= l_service_request_rec.INCIDENT_CROSS_STREET;
  END IF;

  IF (l_service_request_rec.incident_direction_qualifier <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.incident_direction_qualifier IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_DIRECTION_QUALIF	:= l_service_request_rec.incident_direction_qualifier;
  END IF;

  IF (l_service_request_rec.incident_distance_qualifier <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.incident_distance_qualifier IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_DISTANCE_QUALIF	:= l_service_request_rec.incident_distance_qualifier;
  END IF;

  IF (l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_DISTANCE_QUAL_UOM	:= l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM;
  END IF;

  IF (l_service_request_rec.INCIDENT_ADDRESS2 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_ADDRESS2 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS2		:= l_service_request_rec.INCIDENT_ADDRESS2;
  END IF;

  IF (l_service_request_rec.INCIDENT_ADDRESS3 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_ADDRESS3 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS3		:= l_service_request_rec.INCIDENT_ADDRESS3;
  END IF;

  IF (l_service_request_rec.INCIDENT_ADDRESS4 <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_ADDRESS4 IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS4		:= l_service_request_rec.INCIDENT_ADDRESS4;
  END IF;

  IF (l_service_request_rec.INCIDENT_ADDRESS_STYLE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_ADDRESS_STYLE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS_STYLE	:= l_service_request_rec.INCIDENT_ADDRESS_STYLE;
  END IF;

  IF (l_service_request_rec.incident_addr_lines_phonetic <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.incident_addr_lines_phonetic IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_ADDR_LNS_PHONETIC	:= l_service_request_rec.incident_addr_lines_phonetic;
  END IF;

  IF (l_service_request_rec.INCIDENT_PO_BOX_NUMBER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_PO_BOX_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_PO_BOX_NUMBER	:= l_service_request_rec.INCIDENT_PO_BOX_NUMBER;
  END IF;

  IF (l_service_request_rec.INCIDENT_HOUSE_NUMBER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_HOUSE_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_HOUSE_NUMBER	:= l_service_request_rec.INCIDENT_HOUSE_NUMBER;
  END IF;

  IF (l_service_request_rec.INCIDENT_STREET_SUFFIX <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_STREET_SUFFIX IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_STREET_SUFFIX	:= l_service_request_rec.INCIDENT_STREET_SUFFIX;
  END IF;

  IF (l_service_request_rec.INCIDENT_STREET <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_STREET IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_STREET		:= l_service_request_rec.INCIDENT_STREET;
  END IF;

  IF (l_service_request_rec.INCIDENT_STREET_NUMBER <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_STREET_NUMBER IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_STREET_NUMBER	:= l_service_request_rec.INCIDENT_STREET_NUMBER;
  END IF;

  IF (l_service_request_rec.INCIDENT_FLOOR <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_FLOOR IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_FLOOR		:= l_service_request_rec.INCIDENT_FLOOR;
  END IF;

  IF (l_service_request_rec.INCIDENT_SUITE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_SUITE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_SUITE		:= l_service_request_rec.INCIDENT_SUITE;
  END IF;

  IF (l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_POSTAL_PLUS4_CODE	:= l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE;
  END IF;

  IF (l_service_request_rec.INCIDENT_POSITION <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.INCIDENT_POSITION IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_POSITION		:= l_service_request_rec.INCIDENT_POSITION;
  END IF;

  IF (l_service_request_rec.incident_location_directions <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.incident_location_directions IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_LOC_DIRECTIONS	:= l_service_request_rec.incident_location_directions;
  END IF;

  IF (l_service_request_rec.incident_location_description <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.incident_location_description IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_LOC_DESCRIPTION	:= l_service_request_rec.incident_location_description;
  END IF;

  IF (l_service_request_rec.INSTALL_SITE_ID <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.INSTALL_SITE_ID IS NOT NULL) THEN
    x_audit_vals_rec.INSTALL_SITE_ID		:= l_service_request_rec.INSTALL_SITE_ID;
  END IF;

  IF (l_service_request_rec.TIER_VERSION <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.TIER_VERSION IS NOT NULL) THEN
    x_audit_vals_rec.TIER_VERSION		:= l_service_request_rec.TIER_VERSION;
  END IF;


  --anmukher --09/12/03

  x_audit_vals_rec.INC_OBJECT_VERSION_NUMBER	:= 1;

  IF (l_service_request_rec.conc_request_id <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.conc_request_id IS NOT NULL) THEN
    x_audit_vals_rec.INC_REQUEST_ID		:= l_service_request_rec.conc_request_id;
  END IF;

  IF (l_service_request_rec.program_application_id <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.program_application_id IS NOT NULL) THEN
    x_audit_vals_rec.INC_PROGRAM_APPLICATION_ID	:= l_service_request_rec.program_application_id;
  END IF;

  IF (l_service_request_rec.program_id <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.program_id IS NOT NULL) THEN
    x_audit_vals_rec.INC_PROGRAM_ID		:= l_service_request_rec.program_id;
  END IF;

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (l_service_request_rec. <> FND_API.G_MISS_DATE) AND
    (l_service_request_rec. IS NOT NULL) THEN
    x_audit_vals_rec.INC_PROGRAM_UPDATE_DATE	:= l_service_request_rec.;
  END IF;
  */

  IF (l_service_request_rec.owning_dept_id <> FND_API.G_MISS_NUM) AND
    (l_service_request_rec.owning_dept_id IS NOT NULL) THEN
    x_audit_vals_rec.OWNING_DEPARTMENT_ID	:= l_service_request_rec.owning_dept_id;
  END IF;

  /* 12/13/05 smisra
  moved to create_servicerequest just before call to create audit
  IF (l_service_request_rec.incident_location_type <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec.incident_location_type IS NOT NULL) THEN
    x_audit_vals_rec.INCIDENT_LOCATION_TYPE	:= l_service_request_rec.incident_location_type;
  END IF;
  ******/

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (l_service_request_rec. <> FND_API.G_MISS_CHAR) AND
    (l_service_request_rec. IS NOT NULL) THEN
    x_audit_vals_rec.UNASSIGNED_INDICATOR	:= l_service_request_rec.;
  END IF;
  */


---- AUDIT

  --All the ids should be assigned NULL value before insert into the database
  --This  has to be done here cause the earlier checks are done only if
  --validation level is set.

  IF (l_service_request_rec.urgency_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.urgency_id := NULL;
  END IF;

  IF (l_service_request_rec.employee_id IS NOT NULL ) THEN
    l_service_request_rec.employee_id := NULL;
  END IF;

  IF (l_service_request_rec.owner_group_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.owner_group_id := NULL;
  END IF;

---- made null if not passed, since the mandatory check is no longer in use
---- Enhancements 11.5.6
  IF (l_service_request_rec.owner_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.owner_id := NULL;
  END IF;

  IF (l_service_request_rec.product_revision = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.product_revision := NULL;
  END IF;

  IF (l_service_request_rec.component_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.component_version := NULL;
  END IF;

  IF (l_service_request_rec.subcomponent_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.subcomponent_version := NULL;
  END IF;
-----------
  IF (l_service_request_rec.platform_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.platform_id := NULL;
  END IF;

  IF (l_service_request_rec.platform_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.platform_version := NULL;
  END IF;

  IF (l_service_request_rec.platform_version_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.platform_version_id := NULL;
  END IF;

  IF (l_service_request_rec.inv_platform_org_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.inv_platform_org_id := NULL;
  END IF;

  IF (l_service_request_rec.db_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.db_version := NULL;
  END IF;

  IF (l_service_request_rec.customer_product_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.customer_product_id := NULL;
  END IF;

  IF (l_service_request_rec.cp_component_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.cp_component_id := NULL;
  END IF;

  IF (l_service_request_rec.cp_component_version_id  = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.cp_component_version_id  := NULL;
  END IF;

  IF (l_service_request_rec.cp_subcomponent_id  = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.cp_subcomponent_id  := NULL;
  END IF;

  IF (l_service_request_rec.cp_subcomponent_version_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.cp_subcomponent_version_id  := NULL;
  END IF;

  IF (l_service_request_rec.cp_revision_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.cp_revision_id  := NULL;
  END IF;

  IF (l_service_request_rec.inv_item_revision = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.inv_item_revision  := NULL;
  END IF;

  IF (l_service_request_rec.inv_component_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.inv_component_id := NULL;
  END IF;

  IF (l_service_request_rec.inv_component_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.inv_component_version  := NULL;
  END IF;

  IF (l_service_request_rec.inv_subcomponent_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.inv_subcomponent_id := NULL;
  END IF;

  IF (l_service_request_rec.inv_subcomponent_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.inv_subcomponent_version  := NULL;
  END IF;


  IF (l_service_request_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.inventory_item_id := NULL;
  END IF;

  IF (l_service_request_rec.inventory_org_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.inventory_org_id := NULL;
  END IF;

  IF (l_service_request_rec.current_serial_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.current_serial_number := NULL;
  END IF;

  IF (l_service_request_rec.original_order_number = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.original_order_number := NULL;
  END IF;


  IF (l_service_request_rec.purchase_order_num = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.purchase_order_num := NULL;
  END IF;

  IF (l_service_request_rec.problem_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.problem_code := NULL;
  END IF;

-----------Added for enhancement 11.5.6 -----jngeorge-----07/20/01
----cust_pref_lang_id is customer preferred language
----tier and tier_versions
----operating_system and operating_system_version
----database
----category_id
----inv_platform_org_id
----comm_pref_code

  IF (l_service_request_rec.cust_pref_lang_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.cust_pref_lang_id := NULL;
  END IF;

  IF (l_service_request_rec.last_update_channel = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.last_update_channel := NULL;
  END IF;

  IF (l_service_request_rec.cust_pref_lang_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.cust_pref_lang_code := NULL;
  END IF;

  IF (l_service_request_rec.comm_pref_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.comm_pref_code := NULL;
  END IF;

  IF (l_service_request_rec.tier = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.tier := NULL;
  END IF;

  IF (l_service_request_rec.tier_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.tier_version := NULL;
  END IF;

  IF (l_service_request_rec.operating_system = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.operating_system := NULL;
  END IF;

  IF (l_service_request_rec.operating_system_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.operating_system_version := NULL;
  END IF;

  IF (l_service_request_rec.DATABASE = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.DATABASE := NULL;
  END IF;

  IF (l_service_request_rec.category_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.category_id := NULL;
  END IF;

  IF (l_service_request_rec.category_set_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.category_set_id := NULL;
  END IF;

  IF (l_service_request_rec.external_reference = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.external_reference := NULL;
  END IF;

  IF (l_service_request_rec.system_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.system_id := NULL;
  END IF;

  IF (l_service_request_rec.group_type = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.group_type := NULL;
  END IF;

  IF (l_service_request_rec.group_territory_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.group_territory_id := NULL;
  END IF;

  IF (l_service_request_rec.inv_platform_org_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.inv_platform_org_id := NULL;
  END IF;

--------------------------

  IF (l_service_request_rec.exp_resolution_date = FND_API.G_MISS_DATE) THEN
    l_service_request_rec.exp_resolution_date := NULL;
  END IF;

  IF (l_service_request_rec.resolution_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.resolution_code := NULL;
  END IF;

  IF (l_service_request_rec.act_resolution_date = FND_API.G_MISS_DATE) THEN
    l_service_request_rec.act_resolution_date := NULL;
  END IF;

  IF (l_service_request_rec.contract_service_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.contract_service_id := NULL;
  END IF;

  IF (l_service_request_rec.contract_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.contract_id := NULL;
  END IF;

  IF (l_service_request_rec.project_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.project_number := NULL;
  END IF;

  IF (l_service_request_rec.qa_collection_plan_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.qa_collection_plan_id := NULL;
  END IF;

  IF (l_service_request_rec.account_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.account_id := NULL;
  END IF;

  IF (l_service_request_rec.resource_subtype_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.resource_subtype_id := NULL;
  END IF;

  IF (l_service_request_rec.cust_po_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.cust_po_number := NULL;
  END IF;

  IF (l_service_request_rec.cust_ticket_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.cust_ticket_number := NULL;
  END IF;

  IF (l_service_request_rec.sr_creation_channel = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.sr_creation_channel := NULL;
  END IF;

  IF (l_service_request_rec.obligation_date = FND_API.G_MISS_DATE) THEN
    l_service_request_rec.obligation_date := NULL;
  END IF;

  IF (l_service_request_rec.error_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.error_code := NULL;
  END IF;

  IF (l_service_request_rec.resolution_summary = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.resolution_summary := NULL;
  END IF;

  IF (l_service_request_rec.incident_address = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.incident_address := NULL;
  END IF;

  IF (l_service_request_rec.incident_city = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.incident_city := NULL;
  END IF;

  IF (l_service_request_rec.incident_state = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.incident_state := NULL;
  END IF;

  IF (l_service_request_rec.incident_country = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.incident_country := NULL;
  END IF;

  IF (l_service_request_rec.incident_province = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.incident_province := NULL;
  END IF;

  IF (l_service_request_rec.incident_postal_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.incident_postal_code := NULL;
  END IF;

  IF (l_service_request_rec.incident_county = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.incident_county := NULL;
  END IF;


  -- Added for Enh# 1830701
  IF (l_service_request_rec.incident_occurred_date = FND_API.G_MISS_DATE) THEN
    l_service_request_rec.incident_occurred_date := NULL;
  END IF;

  IF (l_service_request_rec.incident_resolved_date = FND_API.G_MISS_DATE) THEN
    l_service_request_rec.incident_resolved_date := NULL;
  END IF;

  IF (l_service_request_rec.inc_responded_by_date = FND_API.G_MISS_DATE) THEN
    l_service_request_rec.inc_responded_by_date := NULL;
  END IF;

  -- Added for Enh# 1830701
  IF (l_service_request_rec.incident_location_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.incident_location_id := NULL;
  END IF;

  IF (l_service_request_rec.time_zone_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.time_zone_id := NULL;
  END IF;

  IF (l_service_request_rec.time_difference = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.time_difference := NULL;
  END IF;

  IF (l_service_request_rec.site_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.site_id := NULL;
  END IF;

  IF (l_service_request_rec.customer_site_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.customer_site_id := NULL;
  END IF;

  IF (l_service_request_rec.territory_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.territory_id := NULL;
  END IF;

  IF (l_service_request_rec.publish_flag = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.publish_flag := NULL;
  END IF;

  IF (l_service_request_rec.verify_cp_flag = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.verify_cp_flag := NULL;
  END IF;

  IF (l_service_request_rec.customer_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.customer_id := NULL;
  END IF;

  IF (l_service_request_rec.customer_number = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.customer_number := NULL;
  END IF;

  IF (l_service_request_rec.bill_to_site_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.bill_to_site_id := NULL;
  END IF;

  IF (l_service_request_rec.bill_to_site_use_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.bill_to_site_use_id := NULL;
  END IF;

  IF (l_service_request_rec.bill_to_party_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.bill_to_party_id := NULL;
  END IF;

  IF (l_service_request_rec.ship_to_site_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.ship_to_site_id := NULL;
  END IF;

  IF (l_service_request_rec.ship_to_site_use_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.ship_to_site_use_id := NULL;
  END IF;

  IF (l_service_request_rec.ship_to_party_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.ship_to_party_id := NULL;
  END IF;

  IF (l_service_request_rec.install_site_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.install_site_id := NULL;
  END IF;

  IF (l_service_request_rec.install_site_use_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.install_site_use_id := NULL;
  END IF;

  /*Added to check if install site is passed then the install site use id should be populated and visa versa*/
  IF ( l_service_request_rec.install_site_id IS NULL AND
       l_service_request_rec.install_site_use_id IS NOT NULL) THEN
      l_service_request_rec.install_site_id := l_service_request_rec.install_site_use_id;
  END IF;

  IF ( l_service_request_rec.install_site_use_id IS NULL AND
       l_service_request_rec.install_site_id IS NOT NULL) THEN
      l_service_request_rec.install_site_use_id := l_service_request_rec.install_site_id;
  END IF;

  IF (l_service_request_rec.bill_to_contact_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.bill_to_contact_id := NULL;
  END IF;

  IF (l_service_request_rec.ship_to_contact_id = FND_API.G_MISS_NUM ) THEN
      l_service_request_rec.ship_to_contact_id := NULL;
  END IF;

-------Bug Fix #1625002-------jngeorge--------05/29/01
  handle_missing_value(l_service_request_rec.request_context ,null);
  handle_missing_value(l_service_request_rec.external_context,null);

  IF (l_service_request_rec.request_attribute_1 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_1 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_2 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_2 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_3 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_3 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_4 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_4 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_5 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_5 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_6 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_6 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_7 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_7 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_8 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_8 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_9 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_9 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_10 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_10 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_11 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_11 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_12 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_12 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_13 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_13 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_14 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_14 := NULL;
  END IF;

  IF (l_service_request_rec.request_attribute_15 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.request_attribute_15 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_1 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_1 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_2 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_2 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_3 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_3 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_4 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_4 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_5 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_5 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_6 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_6 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_7 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_7 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_8 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_8 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_9 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_9 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_10 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_10 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_11 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_11 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_12 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_12 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_13 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_13 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_14 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_14 := NULL;
  END IF;

  IF (l_service_request_rec.external_attribute_15 = FND_API.G_MISS_CHAR ) THEN
      l_service_request_rec.external_attribute_15 := NULL;
  END IF;

  --- Added for HA, the WHO columns should be derived before inserting
  --- if passed null or has G_MISS values.

  IF (l_service_request_rec.last_update_date = FND_API.G_MISS_DATE OR
      l_service_request_rec.last_update_date IS NULL ) THEN
--      l_service_request_rec.last_update_date := SYSDATE;
      l_service_request_rec.last_update_date := l_sysdate;
  END IF;

  IF (l_service_request_rec.last_updated_by = FND_API.G_MISS_NUM OR
      l_service_request_rec.last_updated_by IS NULL ) THEN
      l_service_request_rec.last_updated_by := p_user_id;
  END IF;

  IF (l_service_request_rec.creation_date = FND_API.G_MISS_DATE OR
      l_service_request_rec.creation_date IS NULL ) THEN
--      l_service_request_rec.creation_date := SYSDATE;
      l_service_request_rec.creation_date := l_sysdate;
  END IF;

  IF (l_service_request_rec.created_by = FND_API.G_MISS_NUM OR
      l_service_request_rec.created_by IS NULL ) THEN
      l_service_request_rec.created_by := p_user_id;
  END IF;

  IF (l_service_request_rec.last_update_login = FND_API.G_MISS_NUM OR
      l_service_request_rec.last_update_login IS NULL ) THEN
      l_service_request_rec.last_update_login := p_login_id;
  END IF;

  IF (l_service_request_rec.owner_assigned_time = FND_API.G_MISS_DATE ) THEN
      l_service_request_rec.owner_assigned_time := NULL;
  END IF;
--------------jngeorge-------05/29/01

   -- Added  For   Coverage_type              - ER# 2320056

   IF (l_service_request_rec.Coverage_type= FND_API.G_MISS_CHAR ) THEN
       l_service_request_rec.Coverage_type := NULL;
   END IF;

-- If the contract service id is null then coverage type should be null
-- Added this check for 1159 by shijain dec6th 2002
   IF (l_service_request_rec.contract_service_id = FND_API.G_MISS_NUM)
   OR (l_service_request_rec.contract_service_id IS NULL)  THEN
           l_service_request_rec.coverage_type  := NULL;
   END IF;

   -- Added  For   bill_to_account_id         - ER# 2433831

   IF (l_service_request_rec.bill_to_account_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.bill_to_account_id := NULL;
   END IF;

   -- Added  For   ship_to_account_id         - ER# 2433831

   IF (l_service_request_rec.ship_to_account_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.ship_to_account_id := NULL;
   END IF;

   -- Added  For   customer_phone_id   - ER# 2463321   ---

   IF (l_service_request_rec.customer_phone_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.customer_phone_id := NULL;
   END IF;

   -- Added  For   customer_email_id   - ER# 2463321
   IF (l_service_request_rec.customer_email_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.customer_email_id := NULL;
   END IF;

   IF (l_service_request_rec.program_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.program_id := NULL;
   END IF;

   IF (l_service_request_rec.program_application_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.program_application_id := NULL;
   END IF;

   IF (l_service_request_rec.conc_request_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.conc_request_id := NULL;
   END IF;

   IF (l_service_request_rec.program_login_id  = FND_API.G_MISS_NUM ) THEN
       l_service_request_rec.program_login_id := NULL;
   END IF;

   -- Added for address fields related changes by shijain

   IF (l_service_request_rec.incident_point_of_interest  = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_point_of_interest  := NULL;
   END IF;

   IF (l_service_request_rec.incident_cross_street  = FND_API.G_MISS_CHAR) THEN
       l_service_request_rec.incident_cross_street  := NULL;
   END IF;

   IF (l_service_request_rec.incident_direction_qualifier = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_direction_qualifier   := NULL;
   END IF;

   IF (l_service_request_rec.incident_distance_qualifier = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_distance_qualifier    := NULL;
   END IF;

   IF (l_service_request_rec.incident_distance_qual_uom   = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_distance_qual_uom  := NULL;
   END IF;

   IF (l_service_request_rec.incident_address2  = FND_API.G_MISS_CHAR)  THEN
       l_service_request_rec.incident_address2    := NULL;
   END IF;

   IF (l_service_request_rec.incident_address3    = FND_API.G_MISS_CHAR)  THEN
       l_service_request_rec.incident_address3    := NULL;
   END IF;

   IF (l_service_request_rec.incident_address4    = FND_API.G_MISS_CHAR) THEN
       l_service_request_rec.incident_address4   := NULL;
   END IF;

   IF (l_service_request_rec.incident_address_style  = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_address_style    := NULL;
   END IF;

   IF (l_service_request_rec.incident_addr_lines_phonetic = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_addr_lines_phonetic   := NULL;
   END IF;

   IF (l_service_request_rec.incident_po_box_number   = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_po_box_number   := NULL;
   END IF;

   IF (l_service_request_rec.incident_house_number   = FND_API.G_MISS_CHAR) THEN
       l_service_request_rec.incident_house_number   := NULL;
   END IF;

   IF (l_service_request_rec.incident_street_suffix   = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_street_suffix   := NULL;
   END IF;

   IF (l_service_request_rec.incident_street   = FND_API.G_MISS_CHAR)  THEN
       l_service_request_rec.incident_street  := NULL;
   END IF;

   IF (l_service_request_rec.incident_street_number   = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_street_number  := NULL;
   END IF;

   IF (l_service_request_rec.incident_floor   = FND_API.G_MISS_CHAR)  THEN
       l_service_request_rec.incident_floor   := NULL;
   END IF;

   IF (l_service_request_rec.incident_suite   = FND_API.G_MISS_CHAR) THEN
       l_service_request_rec.incident_suite   := NULL;
   END IF;

   IF (l_service_request_rec.incident_postal_plus4_code   = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_postal_plus4_code   := NULL;
   END IF;

   IF (l_service_request_rec.incident_position   = FND_API.G_MISS_CHAR)  THEN
       l_service_request_rec.incident_position  := NULL;
   END IF;

   IF (l_service_request_rec.incident_location_directions = FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_location_directions := NULL;
   END IF;

   IF (l_service_request_rec.incident_location_description= FND_API.G_MISS_CHAR)
   THEN
       l_service_request_rec.incident_location_description  := NULL;
   END IF;

   IF (l_service_request_rec.install_site_id   = FND_API.G_MISS_NUM)  THEN
       l_service_request_rec.install_site_id  := NULL;
   END IF;

   -- for cmro_eam
   IF (l_service_request_rec.owning_dept_id = FND_API.G_MISS_NUM) THEN
        l_service_request_rec.owning_dept_id := NULL;
   END IF;

   IF (l_service_request_rec.owner_assigned_flag  = FND_API.G_MISS_CHAR)  THEN
       l_service_request_rec.owner_assigned_flag    := NULL;
   END IF;
   IF (l_service_request_rec.resource_type  = FND_API.G_MISS_CHAR)  THEN
       l_service_request_rec.resource_type    := NULL;
   END IF;
   IF (l_service_request_rec.maint_organization_id = FND_API.G_MISS_NUM) THEN
     l_service_request_rec.maint_organization_id := NULL;
   END IF;

   -- for cmro_eam
  -- ----------------------------------------------------------------------
  -- Perform the database operation. Generate the request ID and request
  -- number from the sequences, then insert the sequence numbers and passed
  -- in attributes into the CS_INCIDENTS_ALL table.
  -- ----------------------------------------------------------------------

/****

  If request id is not passed as a parameter to the API, then find the
  next id/number from the sequence and check whether the generated number
  already exists in the database. If it exists continue to generate the
  id/number till a unique id/number is found

*******/

 IF l_request_id IS NULL THEN
   LOOP
     SELECT cs_incidents_s.NEXTVAL INTO x_req_id FROM dual;
     BEGIN
       SELECT incident_id INTO l_temp_id FROM cs_incidents_all_b
       WHERE incident_id = x_req_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         EXIT;
       WHEN OTHERS THEN
         EXIT;
     END;
   END LOOP;
 ELSE
   x_request_id := l_request_id;
 END IF;

 IF l_request_number IS NULL THEN
   LOOP
     SELECT cs_incidents_number_s.NEXTVAL INTO x_req_num FROM dual;
     BEGIN
       SELECT incident_number INTO l_temp_num FROM cs_incidents_all_b
       WHERE incident_number = x_req_num;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         EXIT;
       WHEN OTHERS THEN
         EXIT;
     END;
   END LOOP;
 ELSE
   x_request_number := l_request_number;
 END IF;

--------Added owner_assigned_flag for the enhancements--11.5.6--
--------
--------

    IF (l_service_request_rec.owner_group_id IS NOT NULL AND
        l_service_request_rec.owner_id IS NOT NULL) OR
       (l_service_request_rec.owner_group_id IS NOT NULL AND
         l_service_request_rec.group_type = 'RS_TEAM') OR
       (l_service_request_rec.owner_group_id IS NOT NULL AND
         l_service_request_rec.group_type IS NULL) THEN
         l_service_request_rec.owner_assigned_flag := 'Y';
    ELSIF (l_service_request_rec.owner_group_id IS NULL) THEN
         l_service_request_rec.owner_assigned_flag := 'N';
    ELSE
         l_service_request_rec.owner_assigned_flag := 'N';
    END IF;

   ---- Added this code because the form is clearing the group,
   ---- when group_type is not entered.
    IF (l_service_request_rec.owner_group_id IS NOT NULL AND
        l_service_request_rec.group_type IS NULL) THEN
         l_service_request_rec.owner_group_id := NULL;
    END IF;

--*************************************************
--Added code to fix Bug# 1948054

-- dj
-- changed = to >
-- contracts : 3224828 changed to = to get the values
-- for contract_id and contract_number
IF (p_validation_level = FND_API.G_VALID_LEVEL_NONE) THEN
--IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
    --
    -- Validate contract service id
    --
    IF (l_service_request_rec.contract_service_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.contract_service_id IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_Contract_Service_Id(
          p_api_name         => l_api_name,
          p_parameter_name   => 'p_contract_service_id',
          p_contract_service_id => l_service_request_rec.contract_service_id,
          x_contract_id      =>x_contra_id,
          x_contract_number  =>x_contract_number,
          x_return_status    => x_return_status);

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
         END IF;

     END IF;
    --
    -- Validate contract id 04/16/01
    --
    IF (l_service_request_rec.contract_id <> FND_API.G_MISS_NUM) AND
        (l_service_request_rec.contract_id IS NOT NULL) AND
        (l_service_request_rec.contract_service_id IS NULL OR
        l_service_request_rec.contract_service_id <> FND_API.G_MISS_NUM) THEN

        CS_ServiceRequest_UTIL.Validate_Contract_Id(
          p_api_name         => l_api_name,
          p_parameter_name   => 'p_contract_id',
          p_contract_id => l_service_request_rec.contract_id,
                x_contract_number  => x_contract_number,
          x_return_status    => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

      x_contra_id := l_service_request_rec.contract_id;

     END IF;


END IF;

    --
    -- Validate creation program code 10/11/02 shijain - This should be done everytime
    -- irrespective of validation level - since this does not come from an LOV
	--

    IF (l_service_request_rec.creation_program_code <> FND_API.G_MISS_CHAR) AND
        (l_service_request_rec.creation_program_code IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_source_program_code(
          p_api_name             => l_api_name,
          p_parameter_name       => 'p_creation_program_code',
          p_source_program_code  => l_service_request_rec.creation_program_code,
          x_return_status        => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
   END IF;

-- Added for address by shijain 05 dec 2002
   IF (l_service_request_rec.INCIDENT_DIRECTION_QUALIFIER <> FND_API.G_MISS_CHAR) AND
        (l_service_request_rec.INCIDENT_DIRECTION_QUALIFIER IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_INC_DIRECTION_QUAL(
          p_api_name             => l_api_name,
          p_parameter_name       => 'p_INC_DIRECTION_QUAL',
          p_INC_DIRECTION_QUAL  => l_service_request_rec.INCIDENT_DIRECTION_QUALIFIER,
          x_return_status        => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
   END IF;

-- Added for address by shijain 05 dec 2002
   IF (l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM <> FND_API.G_MISS_CHAR) AND
        (l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM IS NOT NULL) THEN


        CS_ServiceRequest_UTIL.Validate_INC_DIST_QUAL_UOM(
          p_api_name             => l_api_name,
          p_parameter_name       => 'p_INC_DIST_QUAL_UOM',
          p_INC_DIST_QUAL_UOM  => l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM,
          x_return_status        => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
   END IF;
/* Credit Card 9358401 */

   IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
     IF (l_service_request_rec.instrument_payment_use_id = FND_API.G_MISS_NUM)
      THEN
        l_service_request_rec.instrument_payment_use_id := NULL;
     END IF;

     IF l_service_request_rec.instrument_payment_use_id IS NOT NULL THEN
         CS_ServiceRequest_UTIL.validate_credit_card(
          p_api_name             => l_api_name,
          p_parameter_name       => 'P_INSTRUMENT_PAYMENT_USE_ID',
          p_instrument_payment_use_id  =>
		                   l_service_request_rec.instrument_payment_use_id,
          p_bill_to_acct_id      => l_service_request_rec.bill_to_account_id,
		p_called_from          => 'I',
          x_return_status        => l_return_status);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            /* Ignoring the value but SR needs to be created*/
            l_service_request_rec.instrument_payment_use_id := NULL;
          END IF;
     END IF;/* instrument_payment_use_id IS NOT NULL*/
    END IF; /* p_validation level*/

-- Assigning the values to x_service_request_rec
x_service_request_rec := l_service_request_rec;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Create_SR_Validation;

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name      Desc
-- -------- --------- ----------------------------------------------------------
-- 02/28/05 smisra    Bug 4083288 Defaulted category_set_id if it is not
--                    passed and category id is passed and existing value of
--                    category_set_id is null.
-- 05/09/05 smisra    set maint_organization_id from old value rec if passed
--                    value is G_MISS_NUM
--                    selected maint_organization_id column in
--                    l_servicerequest_csr
-- 05/13/05 smisra    Removed the code that set customer product related
--                    parameters to null for EAM SRs
-- 05/27/05 smisra    Bug 4227769
--                    removed the code that sets obsolete col group_owner and
--                    owner (_tl table columns)
-- 06/07/05 smisra    Bug 4381751
--                    Modified condition for auto assignment call and called it
--                    only if disallow owner update is 'N' for assignment level
--                    'INDIVIDUAL'. Disallow owner update flag value will not
--                    have any impact for assignment level 'GROUP'
-- 07/11/05 smisra    ERES changes. Changed processing related to disallow
--                    request update as follows
--                    if status passed to this procedure has pending approval
--                    flag as 'Y' do not call update_status.
--                    update_status is not capable of ERES processing.
--                    If old status has pending approval flag as Y and last
--                    update program code is not ERES then raise error. Such SRs
--                    can be update only by ERES program.
-- 07/15/05 smisra    Bug 4489746
--                    removed start and end active dates from query on
--                    cs_incident_types. Validate type will take care of
--                    date effectivity check.
-- 07/20/05 smisra    replaced individual vars from get_status_details call with
--                    structure l_sr_related_data members
--
--                    Removed queries on cs_incident_statuses_b table that were
--                    present inside comments. These queries are replaced with
--                    cs_servicerequest_util.get_status_details call
--
--                    Modified condition for calling auto assignment and added
--                    one more condition of disallow_request_update flag of
--                    old status id. if this flag is Y then auto assignment
--                    is not called.
-- 10/07/05 smisra    Fixed byg 4653148
--                    Removed variable l_close_flag_temp because another
--                    variable with similar name already exists and is used
--                    widely. Replaced it with l_closed_flag_temp
-- 12/14/05 smisra    set incident_country to old value if incident_location_id
--                    is not changed and it is not null
--                    Copied incident_country to validation record only if
--                    incident location is null and country has some value
--                    moved the code setting incident_country, inc_location_id
--                    and incident_location_type attribute of audit record to
--                    create_servicerequest just before call to create audit
-- 12/23/05 smisra    bug 4894942
--                    Removed call to Assignment manager API. now it is called
--                    from vldt_sr_rec
--                    Removed the code to set following audit record attribute
--                    a. resource_type
--                    b. group_type
--                    c. incident_owner_id
--                    d. group_owner_id
--                    e. owner_assigned_time
--                    f. territory_id
--                    These attribute are now set in update_servicerequest
--                    procedure just before the call to create audit
-- 12/30/05 smisra    Bug 4869065
--                    Moved the code to set site cols of audit record to
--                    create_servicerequest procedure just before call to
--                    create audit
-- 03/01/05 spusegao  Modified to exempt from raising 'OnlyUpdStatus' exception
--                    ERES call back procedure i.e. when last_update_program_code = 'ERES'.
--
-- 04/18/06 spusegao  Modified to validate p_last_updated_by and service_request_rec.last_updateD_by parameter values.
-- -----------------------------------------------------------------------------
PROCEDURE Update_SR_Validation(
   p_api_version           IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false,
   p_service_request_rec   IN     service_request_rec_type,
   p_invocation_mode       IN     VARCHAR2 := 'NORMAL',
   p_notes                 IN     notes_table,
   p_contacts              IN     contacts_table,
   p_audit_comments        IN     VARCHAR2 DEFAULT NULL,
   p_resp_id               IN     NUMBER     DEFAULT NULL,
   p_resp_appl_id          IN     NUMBER     DEFAULT NULL,
   p_request_id            IN     NUMBER,
   p_validation_level      IN     NUMBER     DEFAULT fnd_api.g_valid_level_full,
   p_commit                IN     VARCHAR2   DEFAULT fnd_api.g_false,
   p_last_updated_by       IN     NUMBER,
   p_last_update_login     IN     NUMBER     DEFAULT NULL,
   p_last_update_date      IN     DATE,
   p_object_version_number IN     NUMBER,
   x_return_status         OUT    NOCOPY VARCHAR2,
   x_contra_id             OUT    NOCOPY NUMBER,
   x_contract_number       OUT    NOCOPY VARCHAR2,
   x_owner_assigned_flag   OUT    NOCOPY VARCHAR2,
   x_msg_count             OUT    NOCOPY NUMBER,
   x_msg_data              OUT    NOCOPY VARCHAR2,
   x_audit_vals_rec        OUT    NOCOPY sr_audit_rec_type,
   x_service_request_rec   OUT    NOCOPY service_request_rec_type,
   x_autolaunch_wkf_flag   OUT    NOCOPY VARCHAR2,
   x_abort_wkf_close_flag  OUT    NOCOPY VARCHAR2,
   x_wkf_process_name      OUT    NOCOPY VARCHAR2,
   x_workflow_process_id   OUT    NOCOPY NUMBER,
   x_interaction_id        OUT    NOCOPY NUMBER,
   p_update_desc_flex      IN     VARCHAR2   DEFAULT fnd_api.g_false,
   p_called_by_workflow    IN     VARCHAR2   DEFAULT fnd_api.g_false,
   p_workflow_process_id   IN     NUMBER   DEFAULT NULL,
   -- for cmro
  p_cmro_flag             IN     VARCHAR2,
  p_maintenance_flag      IN     VARCHAR2,
  p_auto_assign           IN     VARCHAR2 := 'N'
  )

IS
     l_api_name         CONSTANT VARCHAR2(30)    := 'Update_SR_Validation';
     l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
     l_return_status             VARCHAR2(1);
     l_cp_inventory_item_id      NUMBER;
     l_close_flag                VARCHAR2(1);
     l_service_request_rec       service_request_rec_type DEFAULT p_service_request_rec;
     l_contra_id                 NUMBER;
     l_contract_number           VARCHAR2(120) ;

     l_group_name        VARCHAR2(60);
     l_owner_name        VARCHAR2(360);
     l_owner_id          jtf_rs_resource_extns.resource_id % TYPE;
     l_operation         VARCHAR2(300):= 'updated' ;
     l_temp_close_flag  VARCHAR2(1);

     OnlyUpdStatus               EXCEPTION;

     CURSOR l_ServiceRequest_csr IS
     SELECT
            B.ROWID ROW_ID,
            B.INCIDENT_ID ,
            B.LAST_UPDATE_DATE ,
            B.LAST_UPDATED_BY ,
            B.CREATION_DATE ,
            B.CREATED_BY ,
            B.LAST_UPDATE_LOGIN ,
            B.INCIDENT_NUMBER ,
            B.INCIDENT_DATE ,
            B.INCIDENT_STATUS_ID ,
            B.INCIDENT_TYPE_ID ,
            B.INCIDENT_URGENCY_ID ,
            B.INCIDENT_SEVERITY_ID ,
            B.INCIDENT_OWNER_ID ,
            B.RESOURCE_TYPE ,
            B.RESOURCE_SUBTYPE_ID ,
            B.INVENTORY_ITEM_ID ,
            B.CUSTOMER_ID ,
            B.CUSTOMER_NUMBER ,
            B.ACCOUNT_ID ,
            B.BILL_TO_SITE_USE_ID ,
            B.PURCHASE_ORDER_NUM ,
            B.EMPLOYEE_ID ,
            B.FILED_BY_EMPLOYEE_FLAG ,
            B.SHIP_TO_SITE_USE_ID ,
            B.PROBLEM_CODE ,
            B.EXPECTED_RESOLUTION_DATE ,
            B.ACTUAL_RESOLUTION_DATE ,
            B.CUSTOMER_PRODUCT_ID ,
            B.BILL_TO_CONTACT_ID ,
            B.SHIP_TO_CONTACT_ID ,
            B.CURRENT_SERIAL_NUMBER ,
            B.PRODUCT_REVISION ,
            B.COMPONENT_VERSION,
            B.SUBCOMPONENT_VERSION,
            B.INCIDENT_ATTRIBUTE_1 ,
            B.INCIDENT_ATTRIBUTE_2 ,
            B.INCIDENT_ATTRIBUTE_3 ,
            B.INCIDENT_ATTRIBUTE_4 ,
            B.INCIDENT_ATTRIBUTE_5 ,
            B.INCIDENT_ATTRIBUTE_6 ,
            B.INCIDENT_ATTRIBUTE_7 ,
            B.INCIDENT_ATTRIBUTE_8 ,
            B.INCIDENT_ATTRIBUTE_9 ,
            B.INCIDENT_ATTRIBUTE_10 ,
            B.INCIDENT_ATTRIBUTE_11 ,
            B.INCIDENT_ATTRIBUTE_12 ,
            B.INCIDENT_ATTRIBUTE_13 ,
            B.INCIDENT_ATTRIBUTE_14 ,
            B.INCIDENT_ATTRIBUTE_15 ,
            B.INCIDENT_CONTEXT ,
            B.EXTERNAL_ATTRIBUTE_1 ,
            B.EXTERNAL_ATTRIBUTE_2 ,
            B.EXTERNAL_ATTRIBUTE_3 ,
            B.EXTERNAL_ATTRIBUTE_4 ,
            B.EXTERNAL_ATTRIBUTE_5 ,
            B.EXTERNAL_ATTRIBUTE_6 ,
            B.EXTERNAL_ATTRIBUTE_7 ,
            B.EXTERNAL_ATTRIBUTE_8 ,
            B.EXTERNAL_ATTRIBUTE_9 ,
            B.EXTERNAL_ATTRIBUTE_10 ,
            B.EXTERNAL_ATTRIBUTE_11 ,
            B.EXTERNAL_ATTRIBUTE_12 ,
            B.EXTERNAL_ATTRIBUTE_13 ,
            B.EXTERNAL_ATTRIBUTE_14 ,
            B.EXTERNAL_ATTRIBUTE_15 ,
            B.EXTERNAL_CONTEXT ,
            B.RECORD_IS_VALID_FLAG ,
            B.RESOLUTION_CODE ,
            B.ORG_ID ,
            B.ORIGINAL_ORDER_NUMBER ,
            B.WORKFLOW_PROCESS_ID ,
            B.CLOSE_DATE ,
            B.PUBLISH_FLAG ,
            B.ESTIMATE_ID ,
            B.ESTIMATE_BUSINESS_GROUP_ID ,
            B.INTERFACED_TO_DEPOT_FLAG ,
            B.QA_COLLECTION_ID ,
            B.CONTRACT_SERVICE_ID ,
            B.CONTRACT_ID,
            B.CONTRACT_NUMBER,
            B.PROJECT_NUMBER,
            B.TIME_ZONE_ID ,
            B.TIME_DIFFERENCE ,
            B.CUSTOMER_PO_NUMBER ,
            B.OWNER_GROUP_ID ,
            B.CUSTOMER_TICKET_NUMBER ,
            B.OBLIGATION_DATE ,
            B.SITE_ID ,
            B.CUSTOMER_SITE_ID ,
            B.CALLER_TYPE ,
            B.PLATFORM_ID ,
            B.PLATFORM_VERSION,
            B.DB_VERSION,
            B.PLATFORM_VERSION_ID ,
            B.CP_COMPONENT_ID ,
            B.CP_COMPONENT_VERSION_ID ,
            B.CP_SUBCOMPONENT_ID ,
            B.CP_SUBCOMPONENT_VERSION_ID ,
            B.CP_REVISION_ID ,
            B.INV_ITEM_REVISION,
            B.INV_COMPONENT_ID,
            B.INV_COMPONENT_VERSION,
            B.INV_SUBCOMPONENT_ID,
            B.INV_SUBCOMPONENT_VERSION,
            B.LANGUAGE_ID,
            B.TERRITORY_ID,
            B.INV_ORGANIZATION_ID,
            B.OBJECT_VERSION_NUMBER ,
            -- Added for enhancement 11.5.6
            B.CUST_PREF_LANG_ID,
            B.TIER,
            B.TIER_VERSION,
            B.OPERATING_SYSTEM,
            B.OPERATING_SYSTEM_VERSION,
            B.DATABASE,
            B.CATEGORY_ID,
            B.GROUP_TYPE,
            B.GROUP_TERRITORY_ID,
            B.OWNER_ASSIGNED_TIME,
            B.OWNER_ASSIGNED_FLAG,
            B.INV_PLATFORM_ORG_ID,
            B.COMM_PREF_CODE,
            B.CUST_PREF_LANG_CODE,
            B.LAST_UPDATE_CHANNEL,
            B.CATEGORY_SET_ID,
            B.EXTERNAL_REFERENCE,
            B.SYSTEM_ID,
            B.ERROR_CODE,
            B.INCIDENT_ADDRESS,
            B.INCIDENT_CITY,
            B.INCIDENT_STATE,
            B.INCIDENT_COUNTRY,
            B.INCIDENT_PROVINCE,
            B.INCIDENT_POSTAL_CODE,
            B.INCIDENT_COUNTY,
            B.SR_CREATION_CHANNEL,
            TL.RESOLUTION_SUMMARY,
            -- Added for Enh# 1830701
            B.INCIDENT_OCCURRED_DATE,
            B.INCIDENT_RESOLVED_DATE,
            B.INC_RESPONDED_BY_DATE,
            -- Added for Enh# 222054
            B.INCIDENT_LOCATION_ID,
            -- Added for ER# 2320056
            B.COVERAGE_TYPE,
            -- Added for ER#2433831
            B.BILL_TO_ACCOUNT_ID,
            B.SHIP_TO_ACCOUNT_ID,
            -- Added for ER#2463321
            B.CUSTOMER_PHONE_ID,
            B.CUSTOMER_EMAIL_ID,
	    -- Added for 11.5.9
            B.BILL_TO_SITE_ID,
            B.SHIP_TO_SITE_ID,
            B.BILL_TO_PARTY_ID,
            B.SHIP_TO_PARTY_ID,
            B.CREATION_PROGRAM_CODE,
            B.LAST_UPDATE_PROGRAM_CODE,
            B.PROGRAM_ID,
            B.PROGRAM_APPLICATION_ID,
            B.REQUEST_ID,
            B.PROGRAM_LOGIN_ID,
            -- Added for Enh# 2216664
            TL.OWNER,
            TL.GROUP_OWNER,
            TL.LANGUAGE ,
            TL.SOURCE_LANG ,
            TL.SUMMARY ,
            B.INSTALL_SITE_ID,
            B.INSTALL_SITE_USE_ID,
            --TL.SR_CREATION_CHANNEL
            B.STATUS_FLAG,
            -- Added address columns by shijain 26thdec 2002
            B.INCIDENT_POINT_OF_INTEREST  ,
            B.INCIDENT_CROSS_STREET ,
            B.INCIDENT_DIRECTION_QUALIFIER ,
            B.INCIDENT_DISTANCE_QUALIFIER  ,
            B.INCIDENT_DISTANCE_QUAL_UOM  ,
            B.INCIDENT_ADDRESS2   ,
            B.INCIDENT_ADDRESS3 ,
            B.INCIDENT_ADDRESS4  ,
            B.INCIDENT_ADDRESS_STYLE ,
            B.INCIDENT_ADDR_LINES_PHONETIC  ,
            B.INCIDENT_PO_BOX_NUMBER  ,
            B.INCIDENT_HOUSE_NUMBER ,
            B.INCIDENT_STREET_SUFFIX ,
            B.INCIDENT_STREET ,
            B.INCIDENT_STREET_NUMBER ,
            B.INCIDENT_FLOOR,
            B.INCIDENT_SUITE  ,
            B.INCIDENT_POSTAL_PLUS4_CODE ,
            B.INCIDENT_POSITION  ,
            B.INCIDENT_LOCATION_DIRECTIONS,
            B.INCIDENT_LOCATION_DESCRIPTION,
	    --for cmro_eam
            B.OWNING_DEPARTMENT_ID,
            --end of cmro_eam
            -- Added for Misc ERs project (11.5.10) --anmukher --08/26/03
            B.INCIDENT_LOCATION_TYPE  ,
            --B.PRIMARY_CONTACT_ID
            B.maint_organization_id,
            B.instrument_payment_use_id
       FROM cs_incidents_all_b b, cs_incidents_all_tl tl
          WHERE b.incident_id = p_request_id
          AND   b.incident_id = tl.incident_id
          AND   tl.LANGUAGE = DECODE(l_service_request_rec.LANGUAGE,
                                     FND_API.G_MISS_CHAR, USERENV('LANG'),
                                     NULL, USERENV('LANG'), l_service_request_rec.LANGUAGE)
       FOR UPDATE OF b.incident_id;

     l_old_ServiceRequest_rec l_ServiceRequest_csr%ROWTYPE;

     -- Validation record
     l_SR_Validation_rec         Request_Validation_Rec_Type;

     -- Some temp variables
     l_update_desc_flex           VARCHAR2(1) := p_update_desc_flex;
     l_type_id_temp               NUMBER;
     -- l_inventory_org_id        NUMBER;
     l_closed_flag_temp           VARCHAR2(1);
     l_status_validated           BOOLEAN:= FALSE;
     l_employee_name              VARCHAR2(240);
     l_contact_index              BINARY_INTEGER;
     l_primary_contact_id         NUMBER  := NULL;
     l_org_id                     NUMBER;
     l_primary_contact_found      VARCHAR2(1) := 'N';
     l_contacts_passed            VARCHAR2(1) := 'N' ;
     l_old_close_flag             VARCHAR2(1) ;
     l_new_close_flag             VARCHAR2(1) ;
     -- For Workflow Hook
     l_workflow_item_key          NUMBER;
     l_autolaunch_workflow_flag   VARCHAR2(1);
     l_abort_workflow_close_flag  VARCHAR2(1);
     l_disallow_request_update    VARCHAR2(1);
     l_disallow_owner_update      VARCHAR2(1);
     l_disallow_product_update    VARCHAR2(1);
     l_party_id_update            VARCHAR2(1);
     l_contact_point_id_update    VARCHAR2(1);
     l_contact_point_type_update  VARCHAR2(1);
     l_contact_type_update        VARCHAR2(1);
     l_primary_flag_update        VARCHAR2(1) ;
     l_old_party_id               NUMBER;
     l_old_contact_point_id       NUMBER;
     l_old_contact_point_type     VARCHAR2(30);
     l_old_contact_type           VARCHAR2(30);
     l_old_primary_flag           VARCHAR2(1) ;

     l_primary_contact_point_id   NUMBER;
     l_saved_primary_contact_id   NUMBER;
     l_saved_contact_point_id     NUMBER ;
     l_primary_contact_change     VARCHAR2(1) := 'N';
     l_count                      NUMBER;

     ---Added so that workflow can call Update SR API  instead of Calling Create Audit API
     ----bug 1485825
     l_wf_process_itemkey         VARCHAR2(30);
     l_workflow_process_name      VARCHAR2(30);
     l_workflow_process_id        NUMBER;

     l_bill_to_site_id           NUMBER;
     l_ship_to_site_id           NUMBER;
     l_bill_to_site_use_id       NUMBER;
     l_ship_to_site_use_id       NUMBER;

   l_auto_assign_level fnd_profile_option_values.profile_option_value % type :=
                               fnd_profile.value('CS_SR_OWNER_AUTO_ASSIGN_LEVEL');
   l_asgn_owner_id        cs_incidents_all_b.incident_owner_id % type;
   l_asgn_resource_type   cs_incidents_all_b.resource_type % type;
   l_asgn_owner_group_id  cs_incidents_all_b.owner_group_id % type;
   l_territory_id         number;
   l_call_asgn_resource   varchar2(1) := 'n';

   -- For bug 3333340
   p_passed_value	VARCHAR2(3);
   l_update_desc_flex_int      varchar2(1) := FND_API.G_FALSE;
   l_update_desc_flex_ext      varchar2(1) := FND_API.G_FALSE;
   l_ff_name                   varchar2(30);
   l_dummy0 cs_incidents_all_b.product_revision     % type;
   l_dummy1 cs_incidents_all_b.component_version    % type;
   l_dummy2 cs_incidents_all_b.subcomponent_version % type;

   l_pending_approval_flag    cs_incident_statuses_b.pending_approval_flag      % TYPE;
   l_intermediate_status_id   cs_incident_statuses_b.intermediate_status_id     % TYPE;
   l_approval_status_id       cs_incident_statuses_b.approval_action_status_id  % TYPE;
   l_rejection_status_id      cs_incident_statuses_b.rejection_action_status_id % TYPE;

   l_sr_related_data      RELATED_DATA_TYPE;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the New Auit Record
  Initialize_audit_rec(
  p_sr_audit_record         =>           x_audit_vals_rec) ;

  -- Fetch and get the original values
  OPEN l_ServiceRequest_csr;
  FETCH l_ServiceRequest_csr INTO l_old_ServiceRequest_rec;
  IF (l_ServiceRequest_csr%NOTFOUND) THEN

    CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                      ( p_token_an    =>  l_api_name_full,
                        p_token_v     =>  TO_CHAR(p_request_id),
                        p_token_p     =>  'p_request_id',
                        p_table_name  => G_TABLE_NAME,
                        p_column_name => 'INCIDENT_ID');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate flex field segments
  -- Moved this code from cspsrb.pls on 01/23/04
  -- Reason for move: old values are not available in cspsrb.pls
  -- and all g_miss values are to be replaced by values in db
  --
  -- This check is already done in cspsrb.pls. But we need to do it here again
  -- because parameter p_update_desc_flex does not say whether internal FF is changed
  -- or external FF is changed. it says either one of them is changed.
  -- So to make sure that internal FF validation is executed only if any of
  -- internal segments are changed, we need to check these fields again and
  -- set l_update_desc_flex_int and execute FF validation beased on this variable instead
  -- of l_update_desc_flex
  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
     IF NOT (( l_service_request_rec.request_context  = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_1 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_2 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_3 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_4 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_5 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_6 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_7 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_8 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_9 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.request_attribute_10 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.request_attribute_11 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.request_attribute_12 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.request_attribute_13 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.request_attribute_14 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.request_attribute_15 = FND_API.G_MISS_CHAR)     ) THEN
       l_update_desc_flex_int := FND_API.G_TRUE;
     END IF; -- to check if any flex field segment is updated
  END IF; -- to check validation level

    -- if context is changed then all g_miss_char will be replaced by null
    -- if context is not changed then all g_miss_char will be replaced with old value in database
    -- This is doen to make API behaviour same as SR FORM
    -- 01/23/04 smisra
    --
    -- This portion is out of validation level check. Reason: in old code too copy of old value to SR rec
    -- was outside validation level check. 1/28/04
    handle_missing_value(l_service_request_rec.request_context     ,l_old_servicerequest_rec.incident_context     );
    if ((l_service_request_rec.request_context is null and l_old_servicerequest_rec.incident_context is null) or
        (l_service_request_rec.request_context = l_old_servicerequest_rec.incident_context)) then
        -- request context is not changed. so set all g_miss_char to old value from db
        handle_missing_value(l_service_request_rec.request_attribute_1 ,l_old_servicerequest_rec.incident_attribute_1 );
        handle_missing_value(l_service_request_rec.request_attribute_2 ,l_old_servicerequest_rec.incident_attribute_2 );
        handle_missing_value(l_service_request_rec.request_attribute_3 ,l_old_servicerequest_rec.incident_attribute_3 );
        handle_missing_value(l_service_request_rec.request_attribute_4 ,l_old_servicerequest_rec.incident_attribute_4 );
        handle_missing_value(l_service_request_rec.request_attribute_5 ,l_old_servicerequest_rec.incident_attribute_5 );
        handle_missing_value(l_service_request_rec.request_attribute_6 ,l_old_servicerequest_rec.incident_attribute_6 );
        handle_missing_value(l_service_request_rec.request_attribute_7 ,l_old_servicerequest_rec.incident_attribute_7 );
        handle_missing_value(l_service_request_rec.request_attribute_8 ,l_old_servicerequest_rec.incident_attribute_8 );
        handle_missing_value(l_service_request_rec.request_attribute_9 ,l_old_servicerequest_rec.incident_attribute_9 );
        handle_missing_value(l_service_request_rec.request_attribute_10,l_old_servicerequest_rec.incident_attribute_10);
        handle_missing_value(l_service_request_rec.request_attribute_11,l_old_servicerequest_rec.incident_attribute_11);
        handle_missing_value(l_service_request_rec.request_attribute_12,l_old_servicerequest_rec.incident_attribute_12);
        handle_missing_value(l_service_request_rec.request_attribute_13,l_old_servicerequest_rec.incident_attribute_13);
        handle_missing_value(l_service_request_rec.request_attribute_14,l_old_servicerequest_rec.incident_attribute_14);
        handle_missing_value(l_service_request_rec.request_attribute_15,l_old_servicerequest_rec.incident_attribute_15);
    else
        -- incident context is changed. so set all g_miss_char to null except global data segments
        l_ff_name := 'CS_INCIDENTS_ALL_B';
        set_attribute_value(l_service_request_rec.request_attribute_1,l_old_servicerequest_rec.incident_attribute_1,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_1');

        set_attribute_value(l_service_request_rec.request_attribute_2,l_old_servicerequest_rec.incident_attribute_2,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_2');

        set_attribute_value(l_service_request_rec.request_attribute_3,l_old_servicerequest_rec.incident_attribute_3,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_3');

        set_attribute_value(l_service_request_rec.request_attribute_4,l_old_servicerequest_rec.incident_attribute_4,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_4');

        set_attribute_value(l_service_request_rec.request_attribute_5,l_old_servicerequest_rec.incident_attribute_5,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_5');

        set_attribute_value(l_service_request_rec.request_attribute_6,l_old_servicerequest_rec.incident_attribute_6,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_6');

        set_attribute_value(l_service_request_rec.request_attribute_7,l_old_servicerequest_rec.incident_attribute_7,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_7');

        set_attribute_value(l_service_request_rec.request_attribute_8,l_old_servicerequest_rec.incident_attribute_8,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_8');

        set_attribute_value(l_service_request_rec.request_attribute_9,l_old_servicerequest_rec.incident_attribute_9,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_9');

        set_attribute_value(l_service_request_rec.request_attribute_10,l_old_servicerequest_rec.incident_attribute_10,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_10');

        set_attribute_value(l_service_request_rec.request_attribute_11,l_old_servicerequest_rec.incident_attribute_11,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_11');

        set_attribute_value(l_service_request_rec.request_attribute_12,l_old_servicerequest_rec.incident_attribute_12,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_12');

        set_attribute_value(l_service_request_rec.request_attribute_13,l_old_servicerequest_rec.incident_attribute_13,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_13');

        set_attribute_value(l_service_request_rec.request_attribute_14,l_old_servicerequest_rec.incident_attribute_14,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_14');

        set_attribute_value(l_service_request_rec.request_attribute_15,l_old_servicerequest_rec.incident_attribute_15,
                                                            l_ff_name,'INCIDENT_ATTRIBUTE_15');
    end if;

    IF ( l_update_desc_flex_int = FND_API.G_TRUE and
         p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
        Cs_Servicerequest_Util.Validate_Desc_Flex(
	    p_api_name               => l_api_name_full,
      	    p_application_short_name => 'CS',
      	    p_desc_flex_name         => 'CS_INCIDENTS_ALL_B',
      	    p_desc_segment1          => l_service_request_rec.request_attribute_1,
      	    p_desc_segment2          => l_service_request_rec.request_attribute_2,
      	    p_desc_segment3          => l_service_request_rec.request_attribute_3,
      	    p_desc_segment4          => l_service_request_rec.request_attribute_4,
      	    p_desc_segment5          => l_service_request_rec.request_attribute_5,
      	    p_desc_segment6          => l_service_request_rec.request_attribute_6,
      	    p_desc_segment7          => l_service_request_rec.request_attribute_7,
      	    p_desc_segment8          => l_service_request_rec.request_attribute_8,
      	    p_desc_segment9          => l_service_request_rec.request_attribute_9,
      	    p_desc_segment10         => l_service_request_rec.request_attribute_10,
      	    p_desc_segment11         => l_service_request_rec.request_attribute_11,
      	    p_desc_segment12         => l_service_request_rec.request_attribute_12,
      	    p_desc_segment13         => l_service_request_rec.request_attribute_13,
      	    p_desc_segment14         => l_service_request_rec.request_attribute_14,
      	    p_desc_segment15         => l_service_request_rec.request_attribute_15,
      	    p_desc_context           => l_service_request_rec.request_context,
      	    p_resp_appl_id           => p_resp_appl_id,
      	    p_resp_id                => p_resp_id,
      	    p_return_status          => l_return_status );

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          raise FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;


    -- Externl Attributes
    -- whether value of flex field segment is changed or not, it is g_miss_char then it must be
    -- set to value from database. 11/25/2003 smisra
  -- End of Validate flex field segments
  --
  /******** Bug 5216510 spusegao **********/
   -- Validate flex field segments
  -- Moved this code from cspsrb.pls
  -- Reason for move: old values are not available in cspsrb.pls
  -- and all g_miss values are to be replaced by values in db
  --
  -- This check is already done in cspsrb.pls. But we need to do it here again
  -- because parameter p_update_desc_flex does not say whether internal FF is changed
  -- or external FF is changed. it says either one of them is changed.
  -- So to make sure that external FF validation is executed only if any of
  -- external segments are changed, we need to check these fields again and
  -- set l_update_desc_flex_ext and execute FF validation beased on this variable instead
  -- of l_update_desc_flex
  -- whether value of flex field segment is changed or not, it is g_miss_char then it must be

  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
     IF NOT (( l_service_request_rec.external_context  = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_1 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_2 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_3 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_4 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_5 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_6 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_7 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_8 = FND_API.G_MISS_CHAR)  AND
        ( l_service_request_rec.external_attribute_9 = FND_API.G_MISS_CHAR)  AND
         ( l_service_request_rec.external_attribute_10 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.external_attribute_11 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.external_attribute_12 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.external_attribute_13 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.external_attribute_14 = FND_API.G_MISS_CHAR) AND
         ( l_service_request_rec.external_attribute_15 = FND_API.G_MISS_CHAR)     ) THEN
       l_update_desc_flex_ext := FND_API.G_TRUE;
     END IF; -- to check if any flex field segment is updated
  END IF; -- to check validation level

    -- if context is changed then all g_miss_char will be replaced by null
    -- if context is not changed then all g_miss_char will be replaced with old value in database
    -- This is doen to make API behaviour same as SR FORM
    --
    --
    -- This portion is out of validation level check. Reason: in old code too copy of old value to SR rec
    -- was outside validation level check. 1/28/04

    handle_missing_value(l_service_request_rec.external_context,l_old_servicerequest_rec.external_context);
    if ((l_service_request_rec.external_context is null and l_old_servicerequest_rec.external_context is null) or
        (l_service_request_rec.external_context = l_old_servicerequest_rec.external_context)) then
        --  context is not changed. so set all g_miss_char to old value from db
        handle_missing_value(l_service_request_rec.external_attribute_1 ,l_old_servicerequest_rec.external_attribute_1);
        handle_missing_value(l_service_request_rec.external_attribute_2 ,l_old_servicerequest_rec.external_attribute_2);
        handle_missing_value(l_service_request_rec.external_attribute_3 ,l_old_servicerequest_rec.external_attribute_3);
        handle_missing_value(l_service_request_rec.external_attribute_4 ,l_old_servicerequest_rec.external_attribute_4 );
        handle_missing_value(l_service_request_rec.external_attribute_5 ,l_old_servicerequest_rec.external_attribute_5 );
        handle_missing_value(l_service_request_rec.external_attribute_6 ,l_old_servicerequest_rec.external_attribute_6 );
        handle_missing_value(l_service_request_rec.external_attribute_7 ,l_old_servicerequest_rec.external_attribute_7 );
        handle_missing_value(l_service_request_rec.external_attribute_8 ,l_old_servicerequest_rec.external_attribute_8 );
        handle_missing_value(l_service_request_rec.external_attribute_9 ,l_old_servicerequest_rec.external_attribute_9 );
        handle_missing_value(l_service_request_rec.external_attribute_10,l_old_servicerequest_rec.external_attribute_10);
        handle_missing_value(l_service_request_rec.external_attribute_11,l_old_servicerequest_rec.external_attribute_11);
        handle_missing_value(l_service_request_rec.external_attribute_12,l_old_servicerequest_rec.external_attribute_12);
        handle_missing_value(l_service_request_rec.external_attribute_13,l_old_servicerequest_rec.external_attribute_13);
        handle_missing_value(l_service_request_rec.external_attribute_14,l_old_servicerequest_rec.external_attribute_14);
        handle_missing_value(l_service_request_rec.external_attribute_15,l_old_servicerequest_rec.external_attribute_15);
    else

        --  context is changed. so set all g_miss_char to null except global data segments
        l_ff_name := 'CS_INCIDENTS_ALL_B_EXT';
        set_attribute_value(l_service_request_rec.external_attribute_1,l_old_servicerequest_rec.external_attribute_1,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_1');

        set_attribute_value(l_service_request_rec.external_attribute_2,l_old_servicerequest_rec.external_attribute_2,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_2');

        set_attribute_value(l_service_request_rec.external_attribute_3,l_old_servicerequest_rec.external_attribute_3,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_3');

        set_attribute_value(l_service_request_rec.external_attribute_4,l_old_servicerequest_rec.external_attribute_4,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_4');

        set_attribute_value(l_service_request_rec.external_attribute_5,l_old_servicerequest_rec.external_attribute_5,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_5');

        set_attribute_value(l_service_request_rec.external_attribute_6,l_old_servicerequest_rec.external_attribute_6,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_6');

        set_attribute_value(l_service_request_rec.external_attribute_7,l_old_servicerequest_rec.external_attribute_7,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_7');

        set_attribute_value(l_service_request_rec.external_attribute_8,l_old_servicerequest_rec.external_attribute_8,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_8');

        set_attribute_value(l_service_request_rec.external_attribute_9,l_old_servicerequest_rec.external_attribute_9,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_9');

        set_attribute_value(l_service_request_rec.external_attribute_10,l_old_servicerequest_rec.external_attribute_10,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_10');

        set_attribute_value(l_service_request_rec.external_attribute_11,l_old_servicerequest_rec.external_attribute_11,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_11');

        set_attribute_value(l_service_request_rec.external_attribute_12,l_old_servicerequest_rec.external_attribute_12,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_12');

        set_attribute_value(l_service_request_rec.external_attribute_13,l_old_servicerequest_rec.external_attribute_13,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_13');

        set_attribute_value(l_service_request_rec.external_attribute_14,l_old_servicerequest_rec.external_attribute_14,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_14');

        set_attribute_value(l_service_request_rec.external_attribute_15,l_old_servicerequest_rec.external_attribute_15,
                                                            l_ff_name,'EXTERNAL_ATTRIBUTE_15');
    end if;

    IF ( l_update_desc_flex_ext = FND_API.G_TRUE and
         p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
        Cs_ServiceRequest_Util.Validate_external_Desc_Flex
   ( p_api_name                 => l_api_name_full,
     p_application_short_name   => 'CS',
     p_ext_desc_flex_name       => 'CS_INCIDENTS_ALL_B_EXT',
     p_ext_desc_segment1        => l_service_request_rec.external_attribute_1,
     p_ext_desc_segment2        => l_service_request_rec.external_attribute_2,
     p_ext_desc_segment3        => l_service_request_rec.external_attribute_3,
     p_ext_desc_segment4        => l_service_request_rec.external_attribute_4,
     p_ext_desc_segment5        => l_service_request_rec.external_attribute_5,
     p_ext_desc_segment6        => l_service_request_rec.external_attribute_6,
     p_ext_desc_segment7        => l_service_request_rec.external_attribute_7,
     p_ext_desc_segment8        => l_service_request_rec.external_attribute_8,
     p_ext_desc_segment9        => l_service_request_rec.external_attribute_9,
     p_ext_desc_segment10       => l_service_request_rec.external_attribute_10,
     p_ext_desc_segment11       => l_service_request_rec.external_attribute_11,
     p_ext_desc_segment12       => l_service_request_rec.external_attribute_12,
     p_ext_desc_segment13       => l_service_request_rec.external_attribute_13,
     p_ext_desc_segment14       => l_service_request_rec.external_attribute_14,
     p_ext_desc_segment15       => l_service_request_rec.external_attribute_15,
     p_ext_desc_context         => l_service_request_rec.external_context,
     p_resp_appl_id             => p_resp_appl_id,
     p_resp_id                  => p_resp_id,
     p_return_status            => l_return_status
    );

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          raise FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

  /******** Bug 5216510 spusegao **********/

  -- Since we dont care about the org_id parameter passed to the Update
  -- Service Request API, we use the
  -- org_id stored in the table
  -- Use this org_id for all the validations.

  l_org_id := l_old_ServiceRequest_rec.org_id;

  -- Since Caller type is not updatable.
  l_service_request_rec.caller_type := l_old_ServiceRequest_rec.caller_type;

  -----------------------------------------------------------
  -- In B-B model, customer_id cannot be updated
  -- In B-C model, primary contact_id cannot be updated
  ---------------------------------------------------------------
  -- Check if any records are passed in the contacts table.
  -- If so, get the primary contact id.
  -- Only one record with primary flag set to Y must be passed.

  l_contact_index := p_contacts.FIRST;

  -- Flag to indicate records have been passed
  IF (l_contact_index IS NULL) THEN
    l_contacts_passed := 'N';
  ELSE
    l_contacts_passed := 'Y';
  END IF;

  IF (l_service_request_rec.caller_type = 'ORGANIZATION') OR
     (l_service_request_rec.caller_type = 'PERSON') THEN
      --Customer_id is not updatable
      IF (l_service_request_rec.customer_id <> FND_API.G_MISS_NUM) OR
          l_service_request_rec.customer_id IS NULL THEN
        -- Check if one passed is same as old.
        IF (nvl(l_service_request_rec.customer_id,-99) <> nvl(l_old_servicerequest_rec.customer_id,-99) ) THEN

             FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_NOT_UPDATABLE');
             FND_MESSAGE.Set_Token('PARAM_NAME', 'Customer_id');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
        END IF; ---customer_id <> old customer_id
      ELSE

             l_service_request_rec.customer_id  := l_old_servicerequest_rec.customer_id ;

             IF (l_service_request_rec.customer_number <> FND_API.G_MISS_CHAR)
             AND (l_service_request_rec.customer_number IS NOT NULL ) THEN
                   IF (nvl(l_service_request_rec.customer_number,-99) <> nvl(l_old_servicerequest_rec.customer_number,-99) ) THEN

                             FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_NOT_UPDATABLE');
                             FND_MESSAGE.Set_Token('PARAM_NAME', 'Customer_number');
                             FND_MSG_PUB.ADD;
                             RAISE FND_API.G_EXC_ERROR;
                    END IF; ---customer_number <> old customer_number
              END IF; -- customer number is passed
      END IF; ----G_MISS_NUM
  ELSE   --caller type
      NULL;
  END IF ; ----caller type

  --- Added for HA, the WHO columns should be derived before validating
  --- WHO columns
  --- if passed null or has G_MISS values.

  IF (l_service_request_rec.created_by = FND_API.G_MISS_NUM OR
      l_service_request_rec.created_by IS NULL ) THEN
      l_service_request_rec.created_by := p_last_updated_by;
  END IF;

  IF (l_service_request_rec.last_update_login = FND_API.G_MISS_NUM OR
      l_service_request_rec.last_update_login IS NULL ) THEN
      l_service_request_rec.last_update_login := p_last_update_login;
  END IF;

  --
  -- We first deal with some special validation rules
  --
  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
    --
    -- Validate WHO information
    --
    CS_ServiceRequest_UTIL.Validate_Who_Info
      ( p_api_name             => l_api_name_full,
        p_parameter_name_usr   => 'p_last_updated_by',
        p_parameter_name_login => 'p_last_update_login',
        p_user_id              => l_service_request_rec.last_updated_by,
        p_login_id             => l_service_request_rec.last_update_login,
        x_return_status        => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

        -- Validate p_last_update_by information

     IF p_last_updated_by IS NOT NULL AND
        p_last_updated_by <> FND_API.G_MISS_NUM THEN


        CS_ServiceRequest_UTIL.Validate_Who_Info
          ( p_api_name             => l_api_name_full,
            p_parameter_name_usr   => 'p_last_updated_by',
            p_parameter_name_login => null,
            p_user_id              => p_last_updated_by,
            p_login_id             => null,
            x_return_status        => l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF ;

  END IF ;  -- p_validation level end if

    --
    -- Can't update the request type or owner if there is
    -- an active workflow.  Also, cannot close the service
    -- request (by setting the status) if there's an active
    -- workflow process in progress unless this procedure
    -- itself was called by a workflow process.
    --
    IF (l_old_ServiceRequest_rec.workflow_process_id IS NOT NULL) AND
       CS_Workflow_PKG.Is_Servereq_Item_Active
       ( p_request_number  => l_old_ServiceRequest_rec.incident_number,
         p_wf_process_id   => l_old_ServiceRequest_rec.workflow_process_id)  = 'Y'  AND
       ((FND_API.To_Boolean(p_called_by_workflow) = FALSE) OR
      (NOT (l_old_ServiceRequest_rec.workflow_process_id = p_workflow_process_id))) THEN

      IF (l_service_request_rec.type_id <> FND_API.G_MISS_NUM) AND
         (l_service_request_rec.type_id <> l_old_ServiceRequest_rec.incident_type_id) THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_SR_TYPE_READONLY');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_service_request_rec.owner_id <> FND_API.G_MISS_NUM AND
         l_service_request_rec.owner_id <> l_old_ServiceRequest_rec.incident_owner_id) OR
         (l_service_request_rec.owner_id IS NULL AND
          l_old_ServiceRequest_rec.incident_owner_id IS NOT NULL) OR
         (l_service_request_rec.owner_group_id <> FND_API.G_MISS_NUM AND
         l_service_request_rec.owner_group_id <> l_old_ServiceRequest_rec.owner_group_id) THEN

        IF fnd_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_SR_OWNER_READONLY');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;     -- Workflow condition

    CS_SERVICEREQUEST_UTIL.get_status_details
    ( p_status_id                  => l_old_servicerequest_rec.incident_status_id
    , x_close_flag                 => l_sr_related_data.old_close_flag
    , x_disallow_request_update    => l_sr_related_data.old_disallow_request_update
    , x_disallow_agent_dispatch    => l_sr_related_data.old_disallow_owner_update
    , x_disallow_product_update    => l_sr_related_data.old_disallow_product_update
    , x_pending_approval_flag      => l_sr_related_data.old_pending_approval_flag
    , x_intermediate_status_id     => l_sr_related_data.old_intermediate_status_id
    , x_approval_action_status_id  => l_sr_related_data.old_approval_action_status_id
    , x_rejection_action_status_id => l_sr_related_data.old_rejection_action_status_id
    , x_return_status              => l_return_status
    );
    l_old_close_flag  := l_sr_related_data.old_close_flag;
    l_closed_flag_temp := l_old_close_flag;
    l_disallow_request_update  := l_sr_related_data.old_disallow_request_update;
    IF (l_service_request_rec.status_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.status_id <> l_old_servicerequest_rec.incident_status_id)
    THEN
        IF (l_service_request_rec.type_id = FND_API.G_MISS_NUM) THEN
          l_type_id_temp := l_old_ServiceRequest_rec.incident_type_id;
        ELSE
          l_type_id_temp := l_service_request_rec.type_id;
        END IF;

        --This part of the code should just check whether the status can be
        --updated.Also Aborting the workflow code is based on close flag from
        --CS_INCIDENTS_STATUSES and abort_workflow on close flag from
        --CS_INCIDENT_TYPES.

        -- This functionality is based on the change in the SR status
        -- Check if we need to abort the workflow process if the service
        -- request is being closed. First we check if the
        -- abort_workflow_close_flag for the type_id passed is set to 'Y'
        -- then we check if the status of the SR has gone to close for the
        -- first time.
        -- Check what was the old value of close flag depending on old type id
        -- and old status id of SR

        -- Get the old value of close flag
		-- added disallow_request_update, disallow_agent_dispatch, disallow_product_update to the SQL
      -- 3306908 - commented the date validation

  IF (l_service_request_rec.last_updated_by = FND_API.G_MISS_NUM OR
      l_service_request_rec.last_updated_by IS NULL ) THEN
      l_service_request_rec.last_updated_by := p_last_updated_by;
  END IF;

    CS_SERVICEREQUEST_UTIL.get_status_details
    ( p_status_id                  => l_service_request_rec.status_id
    , x_close_flag                 => l_sr_related_data.close_flag
    , x_disallow_request_update    => l_sr_related_data.disallow_request_update
    , x_disallow_agent_dispatch    => l_sr_related_data.disallow_owner_update
    , x_disallow_product_update    => l_sr_related_data.disallow_product_update
    , x_pending_approval_flag      => l_sr_related_data.pending_approval_flag
    , x_intermediate_status_id     => l_sr_related_data.intermediate_status_id
    , x_approval_action_status_id  => l_sr_related_data.approval_action_status_id
    , x_rejection_action_status_id => l_sr_related_data.rejection_action_status_id
    , x_return_status              => l_return_status
    );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
      ( p_token_an    => l_api_name_full
      , p_token_v     => TO_CHAR(l_service_request_rec.status_id)
      , p_token_p     => 'p_status_id'
      , p_table_name  => G_TABLE_NAME
      , p_column_name => 'INCIDENT_STATUS_ID'
      );

      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_new_close_flag  := l_sr_related_data.close_flag;
    l_closed_flag_temp := l_sr_related_data.close_flag;

   -- -------------------------------------------------------------
   --  Check if the passsed type_id has Abort Workflow Close flag set to 'Y'.
   --  If so, get the workflow name asociated with that type_id
   --  Check the close flag from the status table.
   -- -------------------------------------------------------------

      BEGIN
       -- Initialize the return status.
       l_return_status := FND_API.G_RET_STS_SUCCESS;
       -- Verify the type ID against the database.
      -- Suppose type is not updated and old type is end date and then cond on start and
       -- end dates will cause no dat found. old value of type id even if it is end dated
       -- should not cause any error.
          SELECT autolaunch_workflow_flag, abort_workflow_close_flag, workflow
          INTO   x_autolaunch_wkf_flag, x_abort_wkf_close_flag, x_wkf_process_name
          FROM   cs_incident_types
          WHERE  incident_type_id = l_type_id_temp
          AND    incident_subtype = G_SR_SUBTYPE
          ;

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
               l_return_status := FND_API.G_RET_STS_ERROR;

               CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                                 ( p_token_an    => l_api_name_full,
                                   p_token_v     => TO_CHAR(l_type_id_temp),
                                   p_token_p     => 'p_type_id',
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'INCIDENT_TYPE_ID' );

               RAISE FND_API.G_EXC_ERROR;
      END ;

    -- Fix for 11.5.7 bug 2254288 . These variables are not being set properly.
    -- rmanabat 03/12/02
    l_abort_workflow_close_flag := x_abort_wkf_close_flag;
    l_autolaunch_workflow_flag := x_autolaunch_wkf_flag;

     -- Call Abort workflow, if the status is being changed to CLOSE and the
     -- abort workflow on close flag is set to Y and there is an active
     -- workflow process in progress.

     IF (l_abort_workflow_close_flag = 'Y') THEN
        IF (l_old_close_flag = 'N' OR  l_old_close_flag IS NULL)
        AND (l_closed_flag_temp='Y')
        AND (CS_Workflow_PKG.Is_Servereq_Item_Active
                 (p_request_number  => l_old_ServiceRequest_rec.incident_number,
                  p_wf_process_id   => l_old_ServiceRequest_rec.workflow_process_id )  = 'Y')
        THEN
          CS_Workflow_PKG.Abort_Servereq_Workflow
             (p_request_number  => l_old_ServiceRequest_rec.incident_number,
              p_wf_process_id   => l_old_ServiceRequest_rec.workflow_process_id,
              p_user_id         => p_last_updated_by);
        END IF;
     END IF;
     --l_status_validated := TRUE;
	 -- for bug 3640344 - pkesani
   ELSE
    l_sr_related_data.close_flag := l_sr_related_data.old_close_flag;
    -- since SR status is not changed all new flag will be same as old flag
    l_sr_related_data.pending_approval_flag := l_sr_related_data.old_pending_approval_flag;
   END IF ;  /* status id changed end if */

  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
     -- If this flag is set to Y, update only status and return
     -- if last_update_program_code is g_miss_char then it is replaced with 'UNKNOWN'
     -- value from old record is not used for this attribute. so the condition below too
     -- does not check old value rec in case of g_miss_char.
     IF (l_sr_related_data.old_disallow_request_update = 'Y') THEN
       -- if disallow request update is ON and SR is in intermediate status
       -- then only ERES can update service request. if updating program in
       -- other than ERES then raise error and exit.

       IF l_sr_related_data.old_pending_approval_flag = 'Y' AND
          NVL(l_service_requesT_rec.last_update_program_code,'UNKNOWN') <> 'ERES'
       THEN
         FND_MESSAGE.Set_Name('CS', 'CS_SR_APPROVAL_NEEDED');
         FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
         FND_MSG_PUB.ADD_DETAIL
         ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.INCIDENT_STATUS_ID'
         );
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- if new status has pending approval flag then it means ERES update is in
       -- progress and do not call update_status because update_status calls
       -- update_servicerequest to process ERES updates
       IF l_sr_related_data.pending_approval_flag <> 'Y' AND
          NVL(l_service_requesT_rec.last_update_program_code,'UNKNOWN') <> 'ERES'
       THEN
         x_service_request_rec := l_service_request_rec;
         RAISE OnlyUpdStatus ;
       END IF;
     END IF;

    IF (l_sr_related_data.old_disallow_owner_update = 'Y') THEN

       -- Tell the user he cannot update owner and store old value in the field
      IF (NVL(l_service_request_rec.owner_id,-9) <> FND_API.G_MISS_NUM AND
          NVL(l_service_request_rec.owner_id,-9) <> NVL(l_old_servicerequest_rec.incident_owner_id,-9)) OR
         (NVL(l_service_request_rec.resource_type,'x') <> FND_API.G_MISS_CHAR AND
          NVL(l_service_request_rec.resource_type,'x') <> NVL(l_old_servicerequest_rec.resource_type,'x'))
      THEN
        --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_SR_OWNER_NOT_UPDATED');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.ADD_DETAIL
          ( p_message_type=>FND_MSG_PUB.G_INFORMATION_MSG
          , p_associated_column1 => 'CS_INCIDENTS_ALL_B.incident_owner_id'
          );
        --END IF;
      END IF;
      l_service_request_rec.owner_id      := l_old_ServiceRequest_rec.incident_owner_id;
      l_service_request_rec.resource_type := l_old_ServiceRequest_rec.resource_type;

    END IF;


    IF (l_sr_related_data.old_disallow_product_update = 'Y') THEN
      -- Tell the user he cannot update product and related fields and store
      -- old value in the field.Check if install_base or not
      IF (l_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM) THEN
        l_service_request_rec.customer_product_id     := l_old_ServiceRequest_rec.customer_product_id;
        l_service_request_rec.cp_component_id         := l_old_servicerequest_rec.cp_component_id;
        l_service_request_rec.cp_component_version_id := l_old_servicerequest_rec.cp_component_version_id;
        l_service_request_rec.cp_subcomponent_id      := l_old_servicerequest_rec.cp_subcomponent_id;
        l_service_request_rec.cp_subcomponent_version_id := l_old_servicerequest_rec.cp_subcomponent_version_id;
        l_service_request_rec.cp_revision_id          := l_old_servicerequest_rec.cp_revision_id;
        l_service_request_rec.product_revision        := l_old_servicerequest_rec.product_revision;
        l_service_request_rec.component_version       := l_old_servicerequest_rec.component_version;
        l_service_request_rec.subcomponent_version    := l_old_servicerequest_rec.subcomponent_version;
      ELSE
        -- Inv fields
        -- Below two fields will have value only if it is not installed base.
        l_service_request_rec.original_order_number := l_old_ServiceRequest_rec.original_order_number;
        l_service_request_rec.purchase_order_num    := l_old_ServiceRequest_rec.purchase_order_num;
        l_service_request_rec.inv_item_revision     := l_old_ServiceRequest_rec.inv_item_revision;
        l_service_request_rec.inv_component_id      := l_old_ServiceRequest_rec.inv_component_id;
        l_service_request_rec.inv_component_version := l_old_ServiceRequest_rec.inv_component_version ;
        l_service_request_rec.inv_subcomponent_id   := l_old_ServiceRequest_rec.inv_subcomponent_id ;
        l_service_request_rec.inv_subcomponent_version  :=l_old_ServiceRequest_rec.inv_subcomponent_version  ;
      END IF;

      --These are fields which will have value irrespective of Installed base or not.
      l_service_request_rec.inventory_item_id    := l_old_ServiceRequest_rec.inventory_item_id;
      l_service_request_rec.current_serial_number :=l_old_ServiceRequest_rec.current_serial_number;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_SR_PRODUCT_NOT_UPDATED');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.ADD;
      END IF;
    END IF;
 END IF;    /* end of validation level check */

  --
  -- For each column in the table, we have a corresponding local variable.
  -- These local variables will be used in the actual UPDATE SQL statement.
  -- If a column is being updated, we need to initialize the corresponding
  -- local variable to the value of the parameter that was passed in; otherwise,
  -- the the local variable should be set to the original value in the table.
  --
  -- In addition, if the column that is being updated requires validation, then
  -- we need to set the corresponding field in the validation record.  For
  -- validation, we always store the values into the validation record, however,
  -- the validation routine is called depending on the value of the validation
  -- level parameter.
  --
  -- We also keep track of changes in the fields that are audited by setting
  -- the audit records when changes are detected
  --
  -- -----------------------------------------------------------------
  -- Check the header fields: type, status, severity, urgency, owner,
  -- publish flag and summary. All but summary need to be validated if
  -- the validation level is set.
  -- -----------------------------------------------------------------

  IF (l_service_request_rec.type_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.type_id,-99) = nvl(l_old_ServiceRequest_rec.incident_type_id,-99))
  THEN
    l_service_request_rec.type_id := l_old_ServiceRequest_rec.incident_type_id;
    -- For audit record added by shijain
    x_audit_vals_rec.change_incident_type_flag := 'N';
    x_audit_vals_rec.old_incident_type_id      := l_old_ServiceRequest_rec.incident_type_id;
    x_audit_vals_rec.incident_type_id          := l_service_request_rec.type_id;
  ELSE
    l_SR_Validation_rec.validate_type := FND_API.G_TRUE;
    l_SR_Validation_rec.type_id := l_service_request_rec.type_id;
    l_SR_Validation_rec.old_type_id := l_old_ServiceRequest_rec.incident_type_id;

    -- Since the validation of type depends on the value of status,
    -- we need to also set the status_id field in the validation record.
    IF (l_service_request_rec.status_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.status_id,-99) = nvl(l_old_ServiceRequest_rec.incident_status_id,-99))THEN
      l_SR_Validation_rec.status_id := l_old_ServiceRequest_rec.incident_status_id;
      l_SR_Validation_rec.validate_status := FND_API.G_TRUE;
    ELSE
      -- This needs to be done here, cause if both type and status change,
      -- then status_id will be overwritten by the old status id in the
      -- (status change) loop below.

      l_SR_Validation_rec.updated_status_id := l_service_request_rec.status_id;
      l_SR_Validation_rec.validate_updated_status := FND_API.G_TRUE;
      -- This flag is needed cause we have to assign the appropriate status id
      -- to the Validate_Type Procedure

      l_SR_Validation_rec.status_id_change :=  FND_API.G_TRUE;

    END IF;
    -- For audit record
    x_audit_vals_rec.CHANGE_INCIDENT_TYPE_FLAG := 'Y';
    x_audit_vals_rec.OLD_INCIDENT_TYPE_ID      := l_old_ServiceRequest_rec.incident_type_id;
    x_audit_vals_rec.INCIDENT_TYPE_ID          := l_service_request_rec.type_id;
  END IF;

  IF (l_service_request_rec.status_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.status_id,-99) = nvl(l_old_ServiceRequest_rec.incident_status_id,-99)) THEN
     l_service_request_rec.status_id     := l_old_ServiceRequest_rec.incident_status_id;
     -- For audit record added by shijain
     x_audit_vals_rec.change_incident_status_flag := 'N';
     x_audit_vals_rec.old_incident_status_id      := l_old_ServiceRequest_rec.incident_status_id;
     x_audit_vals_rec.incident_status_id          := l_service_request_rec.status_id;
  ELSE
    --IF (l_status_validated = FALSE) THEN
      l_SR_Validation_rec.validate_updated_status := FND_API.G_TRUE;

      -- We need the old status id to validate the new status id. So, we assign
      -- the old status_id to the status_id attribute of the Validation Rec
      -- Type and the new status_id is assigned to the updated_status_id
      -- attribute of the Validation Rec Type

      l_SR_Validation_rec.updated_status_id := l_service_request_rec.status_id;
      l_SR_Validation_rec.status_id         := l_old_ServiceRequest_rec.incident_status_id;
      --
      -- Since the validation of status depends on the value of type,
      -- we need to also set the type_id field in the validation record.
      --
      l_SR_Validation_rec.type_id := l_service_request_rec.type_id;
    --END IF;
    -- For audit record
       x_audit_vals_rec.CHANGE_INCIDENT_STATUS_FLAG := 'Y';
       x_audit_vals_rec.OLD_INCIDENT_STATUS_ID      := l_old_ServiceRequest_rec.incident_status_id;
       x_audit_vals_rec.INCIDENT_STATUS_ID          := l_service_request_rec.status_id;
  END IF;

  IF (l_service_request_rec.severity_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.severity_id,-99) = nvl(l_old_ServiceRequest_rec.incident_severity_id,-99)) THEN
    l_service_request_rec.severity_id     := l_old_ServiceRequest_rec.incident_severity_id;
    -- For audit record added by shijain
    x_audit_vals_rec.change_incident_severity_flag := 'N';
    x_audit_vals_rec.old_incident_severity_id      := l_old_ServiceRequest_rec.incident_severity_id;
    x_audit_vals_rec.incident_severity_id          := l_service_request_rec.severity_id;
  ELSE
    l_SR_Validation_rec.severity_id       := l_service_request_rec.severity_id;
    -- For audit record
    x_audit_vals_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'Y';
    x_audit_vals_rec.OLD_INCIDENT_SEVERITY_ID      := l_old_ServiceRequest_rec.incident_severity_id;
    x_audit_vals_rec.INCIDENT_SEVERITY_ID          := l_service_request_rec.severity_id;
  END IF;

  IF (l_service_request_rec.urgency_id = FND_API.G_MISS_NUM)
  OR
     (nvl(l_service_request_rec.urgency_id,-99) = nvl(l_old_ServiceRequest_rec.incident_urgency_id,-99))
  THEN

    l_service_request_rec.urgency_id     := l_old_ServiceRequest_rec.incident_urgency_id;
    -- For audit record added by shijain
    x_audit_vals_rec.change_incident_urgency_flag := 'N';
    x_audit_vals_rec.old_incident_urgency_id      := l_old_ServiceRequest_rec.incident_urgency_id;
    x_audit_vals_rec.incident_urgency_id          := l_service_request_rec.urgency_id;
  ELSE
    IF (l_service_request_rec.urgency_id IS NOT NULL) THEN
      l_SR_Validation_rec.urgency_id := l_service_request_rec.urgency_id;
    END IF;
    -- For audit record
    x_audit_vals_rec.CHANGE_INCIDENT_URGENCY_FLAG := 'Y';
    x_audit_vals_rec.OLD_INCIDENT_URGENCY_ID      := l_old_ServiceRequest_rec.incident_urgency_id;
    x_audit_vals_rec.INCIDENT_URGENCY_ID          := l_service_request_rec.urgency_id;
  END IF;
-- Added NULL condition for Bug# 2181534

-- commented for 2993526
/*  IF (l_service_request_rec.owner_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.owner_id,-99) = nvl(l_old_ServiceRequest_rec.incident_owner_id,-99))
  THEN
    l_service_request_rec.owner_id := l_old_ServiceRequest_rec.incident_owner_id;
    l_service_request_rec.owner    := l_old_ServiceRequest_rec.owner;

     -- for audit record added by shijain
     x_audit_vals_rec.change_incident_owner_flag := 'N';
     x_audit_vals_rec.old_incident_owner_id      := l_old_ServiceRequest_rec.incident_owner_id;
     x_audit_vals_rec.incident_owner_id          := l_service_request_rec.owner_id;
     x_audit_vals_rec.change_assigned_time_flag  := 'N';
     x_audit_vals_rec.old_owner_assigned_time    := l_old_ServiceRequest_rec.owner_assigned_time;
     x_audit_vals_rec.owner_assigned_time        := SYSDATE;
  ELSE
     l_SR_Validation_rec.owner_id := l_service_request_rec.owner_id;
     -- For audit record
     ---- Added for Enh# 2216664
     IF (l_service_request_rec.owner_id IS NOT NULL AND
        l_service_request_rec.owner_id <> FND_API.G_MISS_NUM) THEN
     -- for bug 2770831 added Begin End and Exception to handle NO_DATA_FOUND.

       BEGIN
        SELECT resource_name INTO l_service_request_rec.owner
        FROM jtf_rs_resource_extns_tl
        WHERE resource_id = l_service_request_rec.owner_id
        AND LANGUAGE =  USERENV('LANG');
       EXCEPTION
	     WHEN NO_DATA_FOUND THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                    ( p_token_an    => l_api_name_full,
                      p_token_v     => TO_CHAR(l_service_request_rec.owner_id),
                      p_token_p     => 'p_owner_id',
                      p_table_name  => G_TABLE_NAME ,
                      p_column_name => 'INCIDENT_OWNER_ID' );

               RAISE FND_API.G_EXC_ERROR;
       END;
     END IF;
     IF (l_service_request_rec.owner_id IS NULL) THEN
         l_service_request_rec.owner := NULL;
     END IF;

     x_audit_vals_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
     x_audit_vals_rec.OLD_INCIDENT_OWNER_ID      := l_old_ServiceRequest_rec.incident_owner_id;
     x_audit_vals_rec.INCIDENT_OWNER_ID          := l_service_request_rec.owner_id;
    -----Added for Bug# 1874546-----jngeorge------07/18/01
     x_audit_vals_rec.change_RESOURCE_TYPE_FLAG  := 'Y';
     x_audit_vals_rec.OLD_RESOURCE_TYPE          := l_old_ServiceRequest_rec.resource_type;
     x_audit_vals_rec.RESOURCE_TYPE              := l_service_request_rec.resource_type;
     x_audit_vals_rec.change_ASSIGNED_TIME_FLAG  := 'Y';
     x_audit_vals_rec.OLD_OWNER_ASSIGNED_TIME    := l_old_ServiceRequest_rec.owner_assigned_time;
     x_audit_vals_rec.OWNER_ASSIGNED_TIME        := SYSDATE;
 END IF;  */

--
--2993526
---
---
 IF (l_service_request_rec.owner_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.owner_id,-99) = nvl(l_old_ServiceRequest_rec.incident_owner_id,-99))
  THEN
    l_service_request_rec.owner_id := l_old_ServiceRequest_rec.incident_owner_id;
 ELSE
     l_SR_Validation_rec.owner_id := l_service_request_rec.owner_id;
 END IF;
 --
 -- Group Type
 -- if Group id passed and group type is not passed and old value is null then set group type from profile
 --
 IF (l_service_request_rec.group_type = FND_API.G_MISS_CHAR AND
     l_old_servicerequest_rec.group_type is null AND
     l_service_request_rec.owner_group_id <> FND_API.G_MISS_NUM) THEN
     l_service_request_rec.group_type := nvl( FND_PROFILE.value('CS_SR_DEFAULT_GROUP_TYPE'), 'RS_GROUP');
 END IF;
 IF (l_service_request_rec.group_type = FND_API.G_MISS_CHAR) OR
     (nvl(l_service_request_rec.group_type,'-99') = nvl(l_old_ServiceRequest_rec.group_type,'-99')) THEN
    l_service_request_rec.group_type := l_old_ServiceRequest_rec.group_type;
 ELSE
    l_SR_Validation_rec.group_type := l_service_request_rec.group_type;
 END IF;
 -- Owner Group ID
 IF (l_service_request_rec.owner_group_id = FND_API.G_MISS_NUM) OR
     (l_service_request_rec.owner_group_id IS NULL AND
      l_old_ServiceRequest_rec.owner_group_id IS NULL) OR
     (l_service_request_rec.owner_group_id = l_old_ServiceRequest_rec.owner_group_id) THEN
    l_service_request_rec.owner_group_id := l_old_ServiceRequest_rec.owner_group_id;
 ELSE
    l_SR_Validation_rec.owner_group_id := l_service_request_rec.owner_group_id;
    l_SR_Validation_rec.group_type := l_service_request_rec.group_type;
 END IF;

  IF (l_service_request_rec.inv_platform_org_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.inv_platform_org_id,-99) = nvl(l_old_ServiceRequest_rec.inv_platform_org_id,-99)) THEN
    l_service_request_rec.inv_platform_org_id := l_old_ServiceRequest_rec.inv_platform_org_id;
    -- For audit record added by shijain
    x_audit_vals_rec.change_platform_org_id_flag := 'N';
    x_audit_vals_rec.old_inv_platform_org_id     := l_old_ServiceRequest_rec.inv_platform_org_id;
    x_audit_vals_rec.inv_platform_org_id         := l_service_request_rec.inv_platform_org_id;
  ELSE
    -- For audit record
    x_audit_vals_rec.change_platform_org_id_FLAG := 'Y';
    x_audit_vals_rec.OLD_inv_platform_org_id := l_old_ServiceRequest_rec.inv_platform_org_id;
    x_audit_vals_rec.inv_platform_org_id := l_service_request_rec.inv_platform_org_id;
  END IF;

  IF ((l_service_request_rec.publish_flag = FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.publish_flag = l_old_ServiceRequest_rec.publish_flag)) THEN
    l_service_request_rec.publish_flag := l_old_ServiceRequest_rec.publish_flag;
  ELSE
    l_SR_Validation_rec.publish_flag := l_service_request_rec.publish_flag;
  END IF;

  IF (l_service_request_rec.summary = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.summary = l_old_ServiceRequest_rec.summary) THEN
    l_service_request_rec.summary := l_old_ServiceRequest_rec.summary;
  END IF;

  ---- Added for Enh# 1830701
  IF (l_service_request_rec.incident_occurred_date = FND_API.G_MISS_DATE) OR
     (l_service_request_rec.incident_occurred_date = l_old_ServiceRequest_rec.incident_occurred_date) THEN
     l_service_request_rec.incident_occurred_date := l_old_ServiceRequest_rec.incident_occurred_date;
  ELSE
    l_SR_Validation_rec.incident_occurred_date := l_service_request_rec.incident_occurred_date;
  END IF;

  IF (l_service_request_rec.incident_resolved_date = FND_API.G_MISS_DATE) OR
     (l_service_request_rec.incident_resolved_date = l_old_ServiceRequest_rec.incident_resolved_date) THEN
     l_service_request_rec.incident_resolved_date := l_old_ServiceRequest_rec.incident_resolved_date;
  ELSE
    l_SR_Validation_rec.incident_resolved_date := l_service_request_rec.incident_resolved_date;
  END IF;


  IF (l_service_request_rec.inc_responded_by_date = FND_API.G_MISS_DATE) OR
     (l_service_request_rec.inc_responded_by_date = l_old_ServiceRequest_rec.inc_responded_by_date) THEN
     l_service_request_rec.inc_responded_by_date := l_old_ServiceRequest_rec.inc_responded_by_date;
  ELSE
    l_SR_Validation_rec.inc_responded_by_date := l_service_request_rec.inc_responded_by_date;
  END IF;

  -- 12/13/2005 smisra bug 4386870
  -- if there is no change in incident location then country too should not change ecause it is
  -- derived from location

  IF l_service_request_rec.incident_location_id = l_old_servicerequest_rec.incident_location_id OR
     (l_service_request_rec.incident_location_id = FND_API.G_MISS_NUM AND
      l_old_servicerequest_rec.incident_location_id IS NOT NULL)
  THEN
    -- siahmed for 12.1.2 project this to make sure that the address field that will be updated
   -- is a one_time_address. This is doen to make so that we can use this
   -- global variabel in the update_sr_validation the country gets assigned
   -- with the old country valu which is preventing the onetime address
   -- to change a country once it has been assined. Using the global
   -- variable we will assign the value accordingly.
   --check if created by module = 'SR_ONETIME'
    IF (G_ONETIME_ADD_CNT >=1) THEN
       --dont do anything
       l_service_request_rec.incident_country := l_service_request_rec.incident_country;
    ELSE
       --there no else if and this was the original line
       l_service_request_rec.incident_country := l_old_ServiceRequest_rec.incident_country;
    END IF;
    --end of addition by siahmed
  END IF;
  ---- Added for Enh# 222054
  -- Modified for Misc ERs project of 11.5.10 --anmukher --08/29/03
  IF (l_service_request_rec.incident_location_id = FND_API.G_MISS_NUM) OR
     (l_service_request_rec.incident_location_id = l_old_ServiceRequest_rec.incident_location_id
     AND l_service_request_rec.incident_location_type = l_old_ServiceRequest_rec.incident_location_type) THEN
       l_service_request_rec.incident_location_id   := l_old_ServiceRequest_rec.incident_location_id;
       l_service_request_rec.incident_location_type := l_old_ServiceRequest_rec.incident_location_type;
  /* 12/13/05 smisra bug 4386870
  These is no need to copy location id and type
  to validation record vecause location validation is moved to vldt_sr_rec
  ELSE
    l_SR_Validation_rec.incident_location_id   := l_service_request_rec.incident_location_id;
    l_SR_Validation_rec.incident_location_type := l_service_request_rec.incident_location_type;
  ***/
  END IF;
  IF (l_service_request_rec.incident_location_id is NULL OR
      (l_service_request_rec.incident_location_id = FND_API.G_MISS_NUM AND
       l_old_servicerequest_rec.incident_location_id IS NULL )) AND
     l_service_request_rec.incident_country <> FND_API.G_MISS_CHAR AND
     l_service_request_rec.incident_country <> NVL(l_old_servicerequest_rec.incident_country,'####')
  THEN
    l_SR_Validation_rec.incident_country := l_service_request_rec.incident_country;
  END IF;
  -- Bug 3420335
  -- if incident_location_id is being set to Null then location_type to be set to null
  IF (l_service_request_rec.incident_location_id is NULL) then
      l_service_request_rec.incident_location_type := NULL;
  END IF;

  /*
  -- Added for Misc ERs project of 11.5.10 --anmukher --08/26/03
  IF (l_service_request_rec.incident_location_type = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_location_type = l_old_ServiceRequest_rec.incident_location_type) THEN
     l_service_request_rec.incident_location_type := l_old_ServiceRequest_rec.incident_location_type;
  ELSE
    l_SR_Validation_rec.incident_location_type := l_service_request_rec.incident_location_type;
  END IF;
  */

  IF (l_service_request_rec.customer_site_id = FND_API.G_MISS_NUM) OR
     (l_service_request_rec.customer_site_id =  l_old_ServiceRequest_rec.customer_site_id) THEN
    l_service_request_rec.customer_site_id := l_old_ServiceRequest_rec.customer_site_id;
  END IF;

  IF (l_service_request_rec.error_code = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.error_code =  l_old_ServiceRequest_rec.error_code) THEN
    l_service_request_rec.error_code := l_old_ServiceRequest_rec.error_code;
  END IF;

  IF (l_service_request_rec.incident_address = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_address =  l_old_ServiceRequest_rec.incident_address) THEN
    l_service_request_rec.incident_address := l_old_ServiceRequest_rec.incident_address;
  END IF;

  IF (l_service_request_rec.incident_city = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_city =  l_old_ServiceRequest_rec.incident_city) THEN
    l_service_request_rec.incident_city := l_old_ServiceRequest_rec.incident_city;
  END IF;

  IF (l_service_request_rec.incident_state = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_state =  l_old_ServiceRequest_rec.incident_state) THEN
    l_service_request_rec.incident_state := l_old_ServiceRequest_rec.incident_state;
  END IF;

  IF (l_service_request_rec.incident_country = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_country =  l_old_ServiceRequest_rec.incident_country) THEN
    l_service_request_rec.incident_country := l_old_ServiceRequest_rec.incident_country;
  END IF;

  IF (l_service_request_rec.incident_province = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_province =  l_old_ServiceRequest_rec.incident_province) THEN
    l_service_request_rec.incident_province := l_old_ServiceRequest_rec.incident_province;
  END IF;

  IF (l_service_request_rec.incident_postal_code = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_postal_code =  l_old_ServiceRequest_rec.incident_postal_code) THEN
    l_service_request_rec.incident_postal_code := l_old_ServiceRequest_rec.incident_postal_code;
  END IF;

  IF (l_service_request_rec.incident_county = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_county =  l_old_ServiceRequest_rec.incident_county) THEN
    l_service_request_rec.incident_county := l_old_ServiceRequest_rec.incident_county;
  END IF;

  IF (l_service_request_rec.resolution_summary = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.resolution_summary =  l_old_ServiceRequest_rec.resolution_summary) THEN
    l_service_request_rec.resolution_summary := l_old_ServiceRequest_rec.resolution_summary;
  END IF;

  -- Added for address fields related changes by shijain
  IF (l_service_request_rec.incident_point_of_interest = FND_API.G_MISS_CHAR)
  OR
     (nvl(l_service_request_rec.incident_point_of_interest,-99) = nvl(l_old_ServiceRequest_rec.incident_point_of_interest,-99))
  THEN
      l_service_request_rec.incident_point_of_interest := l_old_ServiceRequest_rec.incident_point_of_interest;
  END IF;

  IF (l_service_request_rec.incident_cross_street = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_cross_street = l_old_ServiceRequest_rec.incident_cross_street)
  THEN
      l_service_request_rec.incident_cross_street  := l_old_ServiceRequest_rec.incident_cross_street;
  END IF;

  IF (l_service_request_rec.incident_direction_qualifier  = FND_API.G_MISS_CHAR)
  OR
     (l_service_request_rec.incident_direction_qualifier  = l_old_ServiceRequest_rec.incident_direction_qualifier)
  THEN
      l_service_request_rec.incident_direction_qualifier := l_old_ServiceRequest_rec.incident_direction_qualifier;
  END IF;

  IF (l_service_request_rec.incident_distance_qualifier   = FND_API.G_MISS_CHAR)
  OR
     (l_service_request_rec.incident_distance_qualifier   = l_old_ServiceRequest_rec.incident_distance_qualifier )
  THEN
      l_service_request_rec.incident_distance_qualifier  := l_old_ServiceRequest_rec.incident_distance_qualifier ;
  END IF;

  IF (l_service_request_rec.incident_distance_qual_uom  = FND_API.G_MISS_CHAR)
  OR
     (l_service_request_rec.incident_distance_qual_uom  = l_old_ServiceRequest_rec.incident_distance_qual_uom )
  THEN
      l_service_request_rec.incident_distance_qual_uom := l_old_ServiceRequest_rec.incident_distance_qual_uom ;
  END IF;

  IF (l_service_request_rec.incident_address2   = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_address2   = l_old_ServiceRequest_rec.incident_address2  )
  THEN
      l_service_request_rec.incident_address2  := l_old_ServiceRequest_rec.incident_address2  ;
  END IF;

  IF (l_service_request_rec.incident_address3   = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_address3   = l_old_ServiceRequest_rec.incident_address3  )
  THEN
      l_service_request_rec.incident_address3  := l_old_ServiceRequest_rec.incident_address3  ;
  END IF;

  IF (l_service_request_rec.incident_address4   = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_address4   = l_old_ServiceRequest_rec.incident_address4  )
  THEN
      l_service_request_rec.incident_address4  := l_old_ServiceRequest_rec.incident_address4  ;
  END IF;

  IF (l_service_request_rec.incident_address_style   = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_address_style   = l_old_ServiceRequest_rec.incident_address_style  )
  THEN
      l_service_request_rec.incident_address_style  := l_old_ServiceRequest_rec.incident_address_style  ;
  END IF;

  IF (l_service_request_rec.incident_addr_lines_phonetic  = FND_API.G_MISS_CHAR)
  OR
     (l_service_request_rec.incident_addr_lines_phonetic  = l_old_ServiceRequest_rec.incident_addr_lines_phonetic  )
  THEN
      l_service_request_rec.incident_addr_lines_phonetic := l_old_ServiceRequest_rec.incident_addr_lines_phonetic  ;
  END IF;

  IF (l_service_request_rec.incident_po_box_number  = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_po_box_number  = l_old_ServiceRequest_rec.incident_po_box_number  )
  THEN
      l_service_request_rec.incident_po_box_number := l_old_ServiceRequest_rec.incident_po_box_number ;
  END IF;

 IF (l_service_request_rec.incident_house_number   = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.incident_house_number  = l_old_ServiceRequest_rec.incident_house_number ) THEN
      l_service_request_rec.incident_house_number := l_old_ServiceRequest_rec.incident_house_number ;
 END IF;

 IF (l_service_request_rec.incident_street_suffix  = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.incident_street_suffix  = l_old_ServiceRequest_rec.incident_street_suffix)
 THEN
     l_service_request_rec.incident_street_suffix := l_old_ServiceRequest_rec.incident_street_suffix ;
 END IF;

 IF (l_service_request_rec.incident_street  = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.incident_street  = l_old_ServiceRequest_rec.incident_street)
 THEN
     l_service_request_rec.incident_street := l_old_ServiceRequest_rec.incident_street;
 END IF;

 IF (l_service_request_rec.incident_street_number  = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.incident_street_number  = l_old_ServiceRequest_rec.incident_street_number)
 THEN
     l_service_request_rec.incident_street_number := l_old_ServiceRequest_rec.incident_street_number;
 END IF;

 IF (l_service_request_rec.incident_floor  = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.incident_floor  = l_old_ServiceRequest_rec.incident_floor)
 THEN
     l_service_request_rec.incident_floor := l_old_ServiceRequest_rec.incident_floor;
 END IF;

 IF (l_service_request_rec.incident_suite  = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.incident_suite  = l_old_ServiceRequest_rec.incident_suite) THEN
     l_service_request_rec.incident_suite := l_old_ServiceRequest_rec.incident_suite;
 END IF;

 IF (l_service_request_rec.incident_postal_plus4_code = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.incident_postal_plus4_code = l_old_ServiceRequest_rec.incident_postal_plus4_code)
 THEN
     l_service_request_rec.incident_postal_plus4_code:= l_old_ServiceRequest_rec.incident_postal_plus4_code;
 END IF;

 IF (l_service_request_rec.incident_position  = FND_API.G_MISS_CHAR) OR
    (l_service_request_rec.incident_position  = l_old_ServiceRequest_rec.incident_position)
 THEN
     l_service_request_rec.incident_position := l_old_ServiceRequest_rec.incident_position;
 END IF;

 IF (l_service_request_rec.incident_location_directions = FND_API.G_MISS_CHAR)
 OR
    (l_service_request_rec.incident_location_directions = l_old_ServiceRequest_rec.incident_location_directions)
 THEN
     l_service_request_rec.incident_location_directions:= l_old_ServiceRequest_rec.incident_location_directions;
 END IF;

 IF (l_service_request_rec.incident_location_description  = FND_API.G_MISS_CHAR)
 OR
    (l_service_request_rec.incident_location_description  = l_old_ServiceRequest_rec.incident_location_description)
 THEN
     l_service_request_rec.incident_location_description := l_old_ServiceRequest_rec.incident_location_description;
 END IF;

 IF (l_service_request_rec.install_site_id  = FND_API.G_MISS_NUM) OR
    (l_service_request_rec.install_site_id  = l_old_ServiceRequest_rec.INSTALL_SITE_ID)
 THEN
     l_service_request_rec.install_site_id := l_old_ServiceRequest_rec.INSTALL_SITE_ID;
 END IF;

  IF (l_service_request_rec.owner_assigned_flag   = FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.owner_assigned_flag   = l_old_ServiceRequest_rec.owner_assigned_flag  )
  THEN
      l_service_request_rec.owner_assigned_flag  := l_old_ServiceRequest_rec.owner_assigned_flag  ;
  END IF;
  IF (l_service_request_rec.group_territory_id   = FND_API.G_MISS_NUM) OR
     (l_service_request_rec.group_territory_id   = l_old_ServiceRequest_rec.group_territory_id  )
  THEN
      l_service_request_rec.group_territory_id  := l_old_ServiceRequest_rec.group_territory_id  ;
  END IF;

 IF (l_service_request_rec.obligation_date = FND_API.G_MISS_DATE) OR
     (l_service_request_rec.obligation_date IS NULL AND
      l_old_ServiceRequest_rec.obligation_date IS NULL) OR
     (l_service_request_rec.obligation_date = l_old_ServiceRequest_rec.obligation_date) THEN
    l_service_request_rec.obligation_date := l_old_ServiceRequest_rec.obligation_date;
    -- For audit record added by shijain
    x_audit_vals_rec.change_obligation_flag := 'N';
    x_audit_vals_rec.old_obligation_date    := l_old_ServiceRequest_rec.obligation_date;
    x_audit_vals_rec.obligation_date        := l_service_request_rec.obligation_date;
  ELSE
    -- For audit record
    x_audit_vals_rec.change_obligation_FLAG := 'Y';
    x_audit_vals_rec.OLD_obligation_date    := l_old_ServiceRequest_rec.obligation_date;
    x_audit_vals_rec.obligation_date        := l_service_request_rec.obligation_date;
  END IF;


  IF (l_service_request_rec.inventory_item_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.inventory_item_id,-99) = nvl(l_old_ServiceRequest_rec.inventory_item_id,-99))
  THEN
      l_service_request_rec.inventory_item_id := l_old_ServiceRequest_rec.inventory_item_id;

	-- For bug 2907824  we need the inventory_item_id for validation of dependent fields
	-- like inv_item_revision, so we set the old value from the DB to the Validation record.
      l_SR_Validation_rec.inventory_item_id := l_old_ServiceRequest_rec.inventory_item_id;

      -- For audit record added by shijain
      x_audit_vals_rec.change_inventory_item_flag  := 'N';
      x_audit_vals_rec.old_inventory_item_id       := l_old_ServiceRequest_rec.inventory_item_id ;
      x_audit_vals_rec.inventory_item_id           := l_service_request_rec.inventory_item_id ;
  ELSE
        -- For audit record
     x_audit_vals_rec.CHANGE_inventory_item_flag  := 'Y';
     x_audit_vals_rec.OLD_inventory_item_id       := l_old_ServiceRequest_rec.inventory_item_id ;
     x_audit_vals_rec.inventory_item_id           := l_service_request_rec.inventory_item_id ;

  END IF;

  -- For incident date audit record added by shijain
  IF (l_service_request_rec.request_date = FND_API.G_MISS_DATE) OR
     (l_service_request_rec.request_date IS NULL AND
      l_old_ServiceRequest_rec.incident_date IS NULL) OR
     (l_service_request_rec.request_date = l_old_ServiceRequest_rec.incident_date)
  THEN
      l_service_request_rec.request_date         := l_old_ServiceRequest_rec.incident_date;
      -- For audit record
      x_audit_vals_rec.change_incident_date_flag  := 'N';
      x_audit_vals_rec.old_incident_date          := l_old_ServiceRequest_rec.incident_date ;
      x_audit_vals_rec.incident_date              := l_service_request_rec.request_date ;
  ELSE
        -- For audit record
     x_audit_vals_rec.CHANGE_incident_date_flag  := 'Y';
     x_audit_vals_rec.OLD_incident_date          := l_old_ServiceRequest_rec.incident_date ;
     x_audit_vals_rec.incident_date              := l_service_request_rec.request_date ;
  END IF;

  -- 2993526
  -- For owner assigned time audit record added by shijain
/*
  IF (l_service_request_rec.owner_assigned_time = FND_API.G_MISS_DATE) OR
     (l_service_request_rec.owner_assigned_time IS NULL AND
      l_old_ServiceRequest_rec.owner_assigned_time IS NULL) OR
     (l_service_request_rec.owner_assigned_time = l_old_ServiceRequest_rec.owner_assigned_time)
  THEN
      l_service_request_rec.owner_assigned_time   := l_old_ServiceRequest_rec.owner_assigned_time;
      -- For audit record
      x_audit_vals_rec.change_assigned_time_flag  := 'N';
      x_audit_vals_rec.old_owner_assigned_time    := l_old_ServiceRequest_rec.owner_assigned_time;
      x_audit_vals_rec.owner_assigned_time        := SYSDATE;
  ELSE
     -- For audit record
     x_audit_vals_rec.change_ASSIGNED_TIME_FLAG  := 'Y';
     x_audit_vals_rec.OLD_OWNER_ASSIGNED_TIME    := l_old_ServiceRequest_rec.owner_assigned_time;
     x_audit_vals_rec.OWNER_ASSIGNED_TIME        := SYSDATE;

  END IF; */

  IF (l_service_request_rec.current_serial_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.current_serial_number := l_old_ServiceRequest_rec.current_serial_number;
  END IF;

  IF (l_service_request_rec.original_order_number = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.original_order_number := l_old_ServiceRequest_rec.original_order_number;
  END IF;

  IF (l_service_request_rec.purchase_order_num = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.purchase_order_num := l_old_ServiceRequest_rec.purchase_order_num;
  END IF;

  IF (l_service_request_rec.qa_collection_plan_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.qa_collection_plan_id := l_old_ServiceRequest_rec.qa_collection_id;
  END IF;

  IF (l_service_request_rec.resource_subtype_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.resource_subtype_id := l_old_ServiceRequest_rec.resource_subtype_id;
  END IF;

  IF (l_service_request_rec.employee_id IS NOT NULL) THEN
    l_service_request_rec.employee_id := NULL;
  END IF;

  IF (l_service_request_rec.cust_po_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.cust_po_number := l_old_ServiceRequest_rec.customer_po_number;
  END IF;

  IF (l_service_request_rec.cust_ticket_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.cust_ticket_number := l_old_ServiceRequest_rec.customer_ticket_number;
  END IF;

  IF (l_service_request_rec.sr_creation_channel = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.sr_creation_channel := l_old_ServiceRequest_rec.sr_creation_channel;
  END IF;

  IF (l_service_request_rec.time_zone_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.time_zone_id := l_old_ServiceRequest_rec.time_zone_id;
  END IF;

  IF (l_service_request_rec.time_difference = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.time_difference := l_old_ServiceRequest_rec.time_difference;
  END IF;

    IF (l_service_request_rec.contract_service_id = FND_API.G_MISS_NUM)  OR
       (l_service_request_rec.contract_service_id = l_old_ServiceRequest_rec.contract_service_id) THEN
       l_service_request_rec.contract_service_id := l_old_ServiceRequest_rec.contract_service_id;
       l_SR_Validation_rec.contract_service_id   := l_old_serviceRequest_rec.contract_service_id;
       --need to copy value to validation rec as contract id validation depends on it.
    ELSE
      l_SR_Validation_rec.contract_service_id := l_service_request_rec.contract_service_id;
    END IF;

    IF (l_service_request_rec.contract_id = FND_API.G_MISS_NUM)  OR
       (l_service_request_rec.contract_id = l_old_ServiceRequest_rec.contract_id) THEN
       l_service_request_rec.contract_id := l_old_ServiceRequest_rec.contract_id;
       -- need to set o/p vars since these are used in update not the l_service_request_rec
       x_contra_id       := l_old_ServiceRequest_rec.contract_id;
       x_contract_number := l_old_ServiceRequest_Rec.contract_number;
    ELSE
      l_SR_Validation_rec.contract_id := l_service_request_rec.contract_id;
    END IF;

    IF (l_service_request_rec.project_number = FND_API.G_MISS_CHAR)  OR
       (l_service_request_rec.project_number = l_old_ServiceRequest_rec.project_number) THEN
       l_service_request_rec.project_number := l_old_ServiceRequest_rec.project_number;
    ELSE
      l_SR_Validation_rec.project_number := l_service_request_rec.project_number;
    END IF;


    IF (l_service_request_rec.account_id = FND_API.G_MISS_NUM)  OR
       (l_service_request_rec.account_id = l_old_ServiceRequest_rec.account_id) THEN
       l_service_request_rec.account_id := l_old_ServiceRequest_rec.account_id;
          --Added this here, cause user may have passed a new customer product id
          --but nay have not passed a new account id. The validation rec has to be
          --assigned this so that it does not have the MISS NUM value.
          -- l_SR_Validation_rec.account_id := l_service_request_rec.account_id;
    ELSE
      l_SR_Validation_rec.account_id := l_service_request_rec.account_id;
    END IF;

    -- auditing is done after AM API Call
    IF (l_service_request_rec.resource_type = FND_API.G_MISS_CHAR)  OR
       (nvl(l_service_request_rec.resource_type,'-99') = nvl(l_old_ServiceRequest_rec.resource_type,'-99')) THEN
       l_service_request_rec.resource_type := l_old_ServiceRequest_rec.resource_type;
    ELSE
      l_SR_Validation_rec.resource_type := l_service_request_rec.resource_type;
    END IF;

    --For optional fields, the passed value may be FND, SAME AS OLD
    --or user may have passed a valid value or he may want to NULL that field.

    IF (l_service_request_rec.platform_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.platform_id,-99) = nvl(l_old_ServiceRequest_rec.platform_id,-99)) THEN

       l_SR_Validation_rec.platform_id := l_old_ServiceRequest_rec.platform_id;
       l_service_request_rec.platform_id := l_old_ServiceRequest_rec.platform_id;
       -- Audit the change added by shijain
       x_audit_vals_rec.change_platform_id_flag := 'N';
       x_audit_vals_rec.old_platform_id         := l_old_ServiceRequest_rec.platform_id;
       x_audit_vals_rec.platform_id             := l_service_request_rec.platform_id;
    ELSE
      l_SR_Validation_rec.platform_id := l_service_request_rec.platform_id;
      -- Audit the change
      x_audit_vals_rec.change_platform_id_FLAG := 'Y';
      x_audit_vals_rec.OLD_platform_id := l_old_ServiceRequest_rec.platform_id;
      x_audit_vals_rec.platform_id := l_service_request_rec.platform_id;

    END IF;

   -- Added audit changes for platform version id added by shijain
   IF (l_service_request_rec.platform_version_id = FND_API.G_MISS_NUM) OR
      (nvl(l_service_request_rec.platform_version_id,-99) = nvl(l_old_ServiceRequest_rec.platform_version_id,-99)) THEN
       l_service_request_rec.platform_version_id:= l_old_ServiceRequest_rec.platform_version_id;
       -- Audit the change
       x_audit_vals_rec.change_plat_ver_id_flag := 'N';
       x_audit_vals_rec.old_platform_version_id := l_old_ServiceRequest_rec.platform_version_id;
       x_audit_vals_rec.platform_version_id     := l_service_request_rec.platform_version_id;
  ELSE
      l_SR_Validation_rec.platform_version_id := l_service_request_rec.platform_version_id;
      -- Audit the change
      x_audit_vals_rec.change_plat_ver_id_FLAG := 'Y';
      x_audit_vals_rec.OLD_platform_version_id := l_old_ServiceRequest_rec.platform_version_id;
      x_audit_vals_rec.platform_version_id     := l_service_request_rec.platform_version_id;
  END IF;

     IF (l_service_request_rec.inv_platform_org_id = FND_API.G_MISS_NUM) OR
      (nvl(l_service_request_rec.inv_platform_org_id,-99) = nvl(l_old_ServiceRequest_rec.inv_platform_org_id,-99)) THEN
       l_SR_Validation_rec.inv_platform_org_id:= l_old_ServiceRequest_rec.inv_platform_org_id;
       -- Audit the change
       x_audit_vals_rec.change_platform_org_id_flag := 'N';
       x_audit_vals_rec.old_inv_platform_org_id := l_old_ServiceRequest_rec.inv_platform_org_id;
       x_audit_vals_rec.inv_platform_org_id     := l_service_request_rec.inv_platform_org_id;
  ELSE
      l_SR_Validation_rec.inv_platform_org_id := l_service_request_rec.inv_platform_org_id;
      -- Audit the change
      x_audit_vals_rec.change_platform_org_id_flag := 'Y';
      x_audit_vals_rec.OLD_inv_platform_org_id := l_old_ServiceRequest_rec.inv_platform_org_id;
      x_audit_vals_rec.inv_platform_org_id     := l_service_request_rec.inv_platform_org_id;
  END IF;

  IF (l_service_request_rec.platform_version = FND_API.G_MISS_CHAR) OR
      (nvl(l_service_request_rec.platform_version,'-99') = nvl(l_old_ServiceRequest_rec.platform_version,'-99')) THEN
       l_service_request_rec.platform_version:= l_old_ServiceRequest_rec.platform_version;
       -- Audit the change
       x_audit_vals_rec.old_platform_version := l_old_ServiceRequest_rec.platform_version;
       x_audit_vals_rec.platform_version     := l_service_request_rec.platform_version;
  ELSE
      l_SR_Validation_rec.platform_version := l_service_request_rec.platform_version;
      -- Audit the change
      x_audit_vals_rec.OLD_platform_version := l_old_ServiceRequest_rec.platform_version;
      x_audit_vals_rec.platform_version     := l_service_request_rec.platform_version;
  END IF;

  -- Added audit changes for language id added by shijain
  IF (l_service_request_rec.language_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.language_id,-99) = nvl(l_old_ServiceRequest_rec.language_id,-99))
  THEN
       l_service_request_rec.language_id:= l_old_ServiceRequest_rec.language_id;
       -- Audit the change
       x_audit_vals_rec.change_language_id_flag := 'N';
       x_audit_vals_rec.old_language_id := l_old_ServiceRequest_rec.language_id;
       x_audit_vals_rec.language_id     := l_service_request_rec.language_id;
  ELSE
      l_SR_Validation_rec.language_id := l_service_request_rec.language_id;
      -- Audit the change
      x_audit_vals_rec.change_language_id_flag := 'Y';
      x_audit_vals_rec.old_language_id := l_old_ServiceRequest_rec.language_id;
      x_audit_vals_rec.language_id     := l_service_request_rec.language_id;
  END IF;

  IF (l_service_request_rec.platform_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.platform_version := l_old_ServiceRequest_rec.platform_version;
  END IF;

  IF (l_service_request_rec.platform_version_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.platform_version_id := l_old_ServiceRequest_rec.platform_version_id;
  END IF;

  IF (l_service_request_rec.inv_platform_org_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.inv_platform_org_id := l_old_ServiceRequest_rec.inv_platform_org_id;
  END IF;

  IF (l_service_request_rec.db_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.db_version := l_old_ServiceRequest_rec.db_version;
  END IF;

  IF (l_service_request_rec.last_update_channel = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.last_update_channel := l_old_ServiceRequest_rec.last_update_channel;
  END IF;

    -- Check if Territory id has been passed to the API
    IF (l_service_request_rec.territory_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.territory_id,-99) = nvl(l_old_ServiceRequest_rec.territory_id,-99)) THEN
      l_service_request_rec.territory_id := l_old_ServiceRequest_rec.territory_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_territory_id_flag := 'N';
      x_audit_vals_rec.old_territory_id         := l_old_ServiceRequest_rec.territory_id;
      x_audit_vals_rec.territory_id             := l_service_request_rec.territory_id;
    ELSE
      l_SR_Validation_rec.territory_id := l_service_request_rec.territory_id;
      -- Audit the change
      x_audit_vals_rec.change_territory_id_FLAG := 'Y';
      x_audit_vals_rec.OLD_territory_id := l_old_ServiceRequest_rec.territory_id;
      x_audit_vals_rec.territory_id := l_service_request_rec.territory_id;
    END IF;

    IF (l_service_request_rec.cp_component_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.cp_component_id,-99) = nvl(l_old_ServiceRequest_rec.cp_component_id,-99)) THEN
      l_service_request_rec.cp_component_id := l_old_ServiceRequest_rec.cp_component_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_cp_component_id_flag := 'N';
      x_audit_vals_rec.old_cp_component_id         := l_old_ServiceRequest_rec.cp_component_id;
      x_audit_vals_rec.cp_component_id             := l_service_request_rec.cp_component_id;
      IF (l_service_request_rec.component_version = FND_API.G_MISS_CHAR) THEN
          l_service_request_rec.component_version := l_old_servicerequest_rec.component_version;
      END IF;
    ELSE
      l_SR_Validation_rec.cp_component_id := l_service_request_rec.cp_component_id;
      -- Audit the change
      x_audit_vals_rec.change_cp_compONENT_id_FLAG := 'Y';
      x_audit_vals_rec.OLD_cp_component_id := l_old_ServiceRequest_rec.cp_component_id;
      x_audit_vals_rec.cp_component_id := l_service_request_rec.cp_component_id;
    END IF;
    IF (l_service_request_rec.cp_component_id is NULL AND
        l_service_request_rec.component_version is NOT NULL AND
        l_service_request_rec.component_version <> FND_API.G_MISS_CHAR) THEN
        l_service_request_rec.component_version := null;
	CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_component_version' );
    END IF;

    -- Check if Component Version id has been passed to the API
    IF (l_service_request_rec.cp_component_version_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.cp_component_version_id,-99) = nvl(l_old_ServiceRequest_rec.cp_component_version_id,-99)) THEN
      l_service_request_rec.cp_component_version_id := l_old_ServiceRequest_rec.cp_component_version_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_cp_comp_ver_id_flag  := 'N';
      x_audit_vals_rec.old_cp_component_version_id := l_old_ServiceRequest_rec.cp_component_version_id;
      x_audit_vals_rec.cp_component_version_id     := l_service_request_rec.cp_component_version_id;
    ELSE
      l_SR_Validation_rec.cp_component_version_id := l_service_request_rec.cp_component_version_id;
      -- Audit the change
      x_audit_vals_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'Y';
      x_audit_vals_rec.OLD_cp_component_version_id := l_old_ServiceRequest_rec.cp_component_version_id;
      x_audit_vals_rec.cp_component_version_id := l_service_request_rec.cp_component_version_id;
    END IF;

    -- Check if SubComponent id has been passed to the API
    IF (l_service_request_rec.cp_subcomponent_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.cp_subcomponent_id,-99) = nvl(l_old_ServiceRequest_rec.cp_subcomponent_id,-99)) THEN
      l_service_request_rec.cp_subcomponent_id := l_old_ServiceRequest_rec.cp_subcomponent_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_cp_subcomponent_id_flag := 'N';
      x_audit_vals_rec.old_cp_subcomponent_id         := l_old_ServiceRequest_rec.cp_subcomponent_id;
      x_audit_vals_rec.cp_subcomponent_id             := l_service_request_rec.cp_subcomponent_id;
      IF (l_service_request_rec.subcomponent_version = FND_API.G_MISS_CHAR) THEN
          l_service_request_rec.subcomponent_version := l_old_servicerequest_rec.subcomponent_version;
      END IF;
    ELSE
      l_SR_Validation_rec.cp_subcomponent_id := l_service_request_rec.cp_subcomponent_id;
      -- Audit the change
      x_audit_vals_rec.change_cp_subcompONENT_id_FLAG := 'Y';
      x_audit_vals_rec.OLD_cp_subcomponent_id := l_old_ServiceRequest_rec.cp_subcomponent_id;
      x_audit_vals_rec.cp_subcomponent_id := l_service_request_rec.cp_subcomponent_id;
    END IF;
    IF (l_service_request_rec.cp_subcomponent_id is NULL AND
        l_service_request_rec.subcomponent_version is NOT NULL AND
        l_service_request_rec.subcomponent_version <> FND_API.G_MISS_CHAR ) THEN
        l_service_request_rec.subcomponent_version := null;
	CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_subcomponent_version' );
    END IF;

    -- Check if Component Version id has been passed to the API
    IF (l_service_request_rec.cp_subcomponent_version_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.cp_subcomponent_version_id,-99) = nvl(l_old_ServiceRequest_rec.cp_subcomponent_version_id,-99)) THEN
      l_service_request_rec.cp_subcomponent_version_id := l_old_ServiceRequest_rec.cp_subcomponent_version_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_cp_subcomp_ver_id_flag  := 'N';
      x_audit_vals_rec.old_cp_subcomponent_version_id := l_old_ServiceRequest_rec.cp_subcomponent_version_id;
      x_audit_vals_rec.cp_subcomponent_version_id     := l_service_request_rec.cp_subcomponent_version_id;
    ELSE
      l_SR_Validation_rec.cp_subcomponent_version_id := l_service_request_rec.cp_subcomponent_version_id;
      -- Audit the change
      x_audit_vals_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'Y';
      x_audit_vals_rec.OLD_cp_subcomponent_version_id := l_old_ServiceRequest_rec.cp_subcomponent_version_id;
      x_audit_vals_rec.cp_subcomponent_version_id := l_service_request_rec.cp_subcomponent_version_id;
    END IF;

    -- Check if CP Revision ID has been passed to the API
    IF (l_service_request_rec.cp_revision_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.cp_revision_id,-99) = nvl(l_old_ServiceRequest_rec.cp_revision_id,-99)) THEN
      l_service_request_rec.cp_revision_id := l_old_ServiceRequest_rec.cp_revision_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_cp_revision_id_flag := 'N';
      x_audit_vals_rec.old_cp_revision_id         := l_old_ServiceRequest_rec.cp_revision_id;
      x_audit_vals_rec.cp_revision_id             := l_service_request_rec.cp_revision_id;
    ELSE
      l_SR_Validation_rec.cp_revision_id := l_service_request_rec.cp_revision_id;
      -- Audit the change
      x_audit_vals_rec.change_cp_revISION_id_FLAG := 'Y';
      x_audit_vals_rec.OLD_cp_revision_id := l_old_ServiceRequest_rec.cp_revision_id;
      x_audit_vals_rec.cp_revision_id := l_service_request_rec.cp_revision_id;
    END IF;

    /*** smisra 8/16/04 3815808 this will be done inside servicerequest_cross_val procedure
    -- Check if Product Revision has been passed to the API
    IF (l_service_request_rec.product_revision = FND_API.G_MISS_CHAR) OR
       (nvl(l_service_request_rec.product_revision,-99) = nvl(l_old_ServiceRequest_rec.product_revision,-99)) THEN
      l_service_request_rec.product_revision := l_old_ServiceRequest_rec.product_revision;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_product_revision_flag := 'N';
      x_audit_vals_rec.old_product_revision         := l_old_ServiceRequest_rec.product_revision;
      x_audit_vals_rec.product_revision             := l_service_request_rec.product_revision;
    ELSE
      l_SR_Validation_rec.product_revision := l_service_request_rec.product_revision;
      -- Audit the change
      x_audit_vals_rec.change_proDUCT_revISION_FLAG := 'Y';
      x_audit_vals_rec.OLD_product_revision := l_old_ServiceRequest_rec.product_revision;
      x_audit_vals_rec.product_revision := l_service_request_rec.product_revision;
    END IF;
    *****/
    /*** smisra 5/4/04 3566783 this will be done inside servicerequest_cross_val procedure
    -- Check if Component Version has been passed to the API
    IF (l_service_request_rec.component_version = FND_API.G_MISS_CHAR) OR
       (nvl(l_service_request_rec.component_version,-99) = nvl(l_old_ServiceRequest_rec.component_version,-99)) THEN
      l_service_request_rec.component_version := l_old_ServiceRequest_rec.component_version;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_comp_ver_flag  := 'N';
      x_audit_vals_rec.old_component_version := l_old_ServiceRequest_rec.component_version;
      x_auDit_vals_rec.component_version     := l_service_request_rec.component_version;
    ELSE
      l_SR_Validation_rec.component_version := l_service_request_rec.component_version;
      -- Audit the change
      x_audit_vals_rec.CHANGE_COMP_VER_FLAG := 'Y';
      x_audit_vals_rec.OLD_component_version := l_old_ServiceRequest_rec.component_version;
      x_audit_vals_rec.component_version := l_service_request_rec.component_version;
    END IF;

    -- Check if Subcomponent Version has been passed to the API
    IF (l_service_request_rec.subcomponent_version = FND_API.G_MISS_CHAR) OR
       (nvl(l_service_request_rec.subcomponent_version,-99) = nvl(l_old_ServiceRequest_rec.subcomponent_version,-99)) THEN
      l_service_request_rec.subcomponent_version := l_old_ServiceRequest_rec.subcomponent_version;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_subcomp_ver_flag  := 'N';
      x_audit_vals_rec.old_subcomponent_version := l_old_ServiceRequest_rec.subcomponent_version;
      x_audit_vals_rec.subcomponent_version     := l_service_request_rec.subcomponent_version;
    ELSE
      l_SR_Validation_rec.subcomponent_version := l_service_request_rec.subcomponent_version;
      -- Audit the change
      x_audit_vals_rec.CHANGE_SUBCOMP_VER_FLAG := 'Y';
      x_audit_vals_rec.OLD_subcomponent_version := l_old_ServiceRequest_rec.subcomponent_version;
      x_audit_vals_rec.subcomponent_version := l_service_request_rec.subcomponent_version;
    END IF;
    *****************************************************/

    -- Check if Inv Item Revision has been passed to the API
    IF (l_service_request_rec.inv_item_revision = FND_API.G_MISS_CHAR) OR
       (nvl(l_service_request_rec.inv_item_revision,-99) = nvl(l_old_ServiceRequest_rec.inv_item_revision,-99)) THEN
      l_service_request_rec.inv_item_revision := l_old_ServiceRequest_rec.inv_item_revision;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_inv_item_revision := 'N';
      x_audit_vals_rec.old_inv_item_revision    := l_old_ServiceRequest_rec.inv_item_revision;
      x_audit_vals_rec.inv_item_revision        := l_service_request_rec.inv_item_revision;
    ELSE
      l_SR_Validation_rec.inv_item_revision := l_service_request_rec.inv_item_revision;
      -- Audit the change
      x_audit_vals_rec.CHANGE_INV_ITEM_REVISION := 'Y';
      x_audit_vals_rec.OLD_inv_item_revision := l_old_ServiceRequest_rec.inv_item_revision;
      x_audit_vals_rec.inv_item_revision := l_service_request_rec.inv_item_revision;
     END IF;

    -- inventory component and subcomponent for Bug# 2254523
    -- Check if INV COMPONENT ID has been passed to the API
    IF (l_service_request_rec.inv_component_id = FND_API.G_MISS_NUM) OR
       (l_service_request_rec.inv_component_id IS NULL AND
        l_old_ServiceRequest_rec.inv_component_id IS NULL) OR
       (l_service_request_rec.inv_component_id = l_old_ServiceRequest_rec.inv_component_id) THEN
      l_service_request_rec.inv_component_id := l_old_ServiceRequest_rec.inv_component_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_inv_component_id := 'N';
      x_audit_vals_rec.old_inv_component_id    := l_old_ServiceRequest_rec.inv_component_id;
      x_audit_vals_rec.inv_component_id        := l_service_request_rec.inv_component_id;
    ELSE
      l_SR_Validation_rec.inv_component_id := l_service_request_rec.inv_component_id;
      -- Audit the change
      x_audit_vals_rec.CHANGE_INV_COMPONENT_ID := 'Y';
      x_audit_vals_rec.OLD_inv_component_id := l_old_ServiceRequest_rec.inv_component_id;
      x_audit_vals_rec.inv_component_id := l_service_request_rec.inv_component_id;
    END IF;

    -- Check if INV COMPONENT VERSION has been passed to the API
    IF (l_service_request_rec.inv_component_version = FND_API.G_MISS_CHAR) OR
       (l_service_request_rec.inv_component_version IS NULL AND
        l_old_ServiceRequest_rec.inv_component_version IS NULL) OR
       (l_service_request_rec.inv_component_version = l_old_ServiceRequest_rec.inv_component_version) THEN
      l_service_request_rec.inv_component_version := l_old_ServiceRequest_rec.inv_component_version;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_inv_component_version := 'N';
      x_audit_vals_rec.old_inv_component_version    := l_old_ServiceRequest_rec.inv_component_version;
      x_audit_vals_rec.inv_component_version        := l_service_request_rec.inv_component_version;
    ELSE
      l_SR_Validation_rec.inv_component_version := l_service_request_rec.inv_component_version;
      -- Audit the change
      x_audit_vals_rec.CHANGE_INV_COMPONENT_VERSION := 'Y';
      x_audit_vals_rec.OLD_inv_component_version:= l_old_ServiceRequest_rec.inv_component_version;
      x_audit_vals_rec.inv_component_version := l_service_request_rec.inv_component_version;
    END IF;

    -- Check if INV SUB COMPONENT ID has been passed to the API
    IF (l_service_request_rec.inv_subcomponent_id = FND_API.G_MISS_NUM) OR
       (l_service_request_rec.inv_subcomponent_id IS NULL AND
        l_old_ServiceRequest_rec.inv_subcomponent_id IS NULL) OR
       (l_service_request_rec.inv_subcomponent_id = l_old_ServiceRequest_rec.inv_subcomponent_id) THEN
      l_service_request_rec.inv_subcomponent_id := l_old_ServiceRequest_rec.inv_subcomponent_id;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_inv_subcomponent_id := 'N';
      x_audit_vals_rec.old_inv_subcomponent_id    := l_old_ServiceRequest_rec.inv_subcomponent_id;
      x_audit_vals_rec.inv_subcomponent_id        := l_service_request_rec.inv_subcomponent_id;
    ELSE
      l_SR_Validation_rec.inv_subcomponent_id := l_service_request_rec.inv_subcomponent_id;
      -- Audit the change
      x_audit_vals_rec.CHANGE_INV_SUBCOMPONENT_ID := 'Y';
      x_audit_vals_rec.OLD_inv_subcomponent_id := l_old_ServiceRequest_rec.inv_subcomponent_id;
      x_audit_vals_rec.inv_subcomponent_id := l_service_request_rec.inv_subcomponent_id;
    END IF;

    -- Check if INV SUBCOMPONENT VERSION has been passed to the API
    IF (l_service_request_rec.inv_subcomponent_version = FND_API.G_MISS_CHAR) OR
       (l_service_request_rec.inv_subcomponent_version IS NULL AND
        l_old_ServiceRequest_rec.inv_subcomponent_version IS NULL) OR
       (l_service_request_rec.inv_subcomponent_version = l_old_ServiceRequest_rec.inv_subcomponent_version) THEN
      l_service_request_rec.inv_subcomponent_version := l_old_ServiceRequest_rec.inv_subcomponent_version;
      -- Audit the change added by shijain
      x_audit_vals_rec.change_inv_subcomp_version := 'N';
      x_audit_vals_rec.old_inv_subcomponent_version:= l_old_ServiceRequest_rec.inv_subcomponent_version;
      x_audit_vals_rec.inv_subcomponent_version := l_service_request_rec.inv_subcomponent_version;
    ELSE
      l_SR_Validation_rec.inv_subcomponent_version := l_service_request_rec.inv_subcomponent_version;
      -- Audit the change
      x_audit_vals_rec.change_inv_subcomp_verSION := 'Y';
      x_audit_vals_rec.OLD_inv_subcomponent_version:= l_old_ServiceRequest_rec.inv_subcomponent_version;
      x_audit_vals_rec.inv_subcomponent_version := l_service_request_rec.inv_subcomponent_version;
    END IF;

  IF (l_service_request_rec.inventory_org_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.inventory_org_id,-99) = nvl(l_old_ServiceRequest_rec.inv_organization_id,-99))
  THEN
       l_service_request_rec.inventory_org_id  := l_old_ServiceRequest_rec.inv_organization_id ;
       -- For audit record added by shijain
       x_audit_vals_rec.change_inv_organization_flag  := 'N';
       x_audit_vals_rec.old_inv_organization_id       := l_old_ServiceRequest_rec.inv_organization_id ;
       x_audit_vals_rec.inv_organization_id           := l_service_request_rec.inventory_org_id ;
  ELSE
       -- For audit record
       x_audit_vals_rec.CHANGE_inv_organization_flag  := 'Y';
       x_audit_vals_rec.OLD_inv_organization_id     := l_old_ServiceRequest_rec.inv_organization_id ;
       x_audit_vals_rec.inv_organization_id         := l_service_request_rec.inventory_org_id ;
  END IF;

  -- ----------------------------------------------------
  -- Added for enhancements for 11.5.6
  -- category_id, comm_pref_code and cust_pref_lang_id needs to be
  -- validated. tier,tier_version,operating_system,
  -- operating_system_version, database, inv_platform_org_id are not
  -- validated now.
  -- ----------------------------------------------------

  IF (l_service_request_rec.cust_pref_lang_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.cust_pref_lang_id := l_old_ServiceRequest_rec.cust_pref_lang_id;
  ELSE
      l_SR_Validation_rec.cust_pref_lang_id := l_service_request_rec.cust_pref_lang_id;
  END IF;

  IF (l_service_request_rec.comm_pref_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.comm_pref_code := l_old_ServiceRequest_rec.comm_pref_code;
  ELSE
      l_SR_Validation_rec.comm_pref_code := l_service_request_rec.comm_pref_code;
  END IF;

  IF (l_service_request_rec.cust_pref_lang_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.cust_pref_lang_code := l_old_ServiceRequest_rec.cust_pref_lang_code;
  END IF;

  IF (l_service_request_rec.tier = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.tier := l_old_ServiceRequest_rec.tier;
  END IF;

  IF (l_service_request_rec.tier_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.tier_version := l_old_ServiceRequest_rec.tier_version;
  END IF;

  IF (l_service_request_rec.operating_system = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.operating_system := l_old_ServiceRequest_rec.operating_system;
  END IF;

  IF (l_service_request_rec.operating_system_version = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.operating_system_version := l_old_ServiceRequest_rec.operating_system_version;
  END IF;

  IF (l_service_request_rec.DATABASE = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.DATABASE := l_old_ServiceRequest_rec.DATABASE;
  END IF;

  IF (l_service_request_rec.category_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.category_id := l_old_ServiceRequest_rec.category_id;
  ELSE
    l_SR_Validation_rec.category_id   := l_service_request_rec.category_id;
    IF (l_service_request_rec.category_id        IS NOT NULL AND
        l_service_request_rec.category_set_id    = FND_API.G_MISS_NUM AND
        l_old_servicerequest_rec.category_set_id IS NULL) THEN
       l_service_request_rec.category_set_id := FND_PROFILE.value('CS_SR_DEFAULT_CATEGORY_SET');
    END IF;
  END IF;

  IF (l_service_request_rec.category_set_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.category_set_id := l_old_ServiceRequest_rec.category_set_id;
  ELSE
    l_SR_Validation_rec.category_set_id := l_service_request_rec.category_set_id;
  END IF;

  IF (l_service_request_rec.external_reference = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.external_reference := l_old_ServiceRequest_rec.external_reference;
  ELSE
    l_SR_Validation_rec.external_reference := l_service_request_rec.external_reference;
    l_SR_Validation_rec.customer_product_id := l_service_request_rec.customer_product_id;
  END IF;

  IF (l_service_request_rec.system_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.system_id := l_old_ServiceRequest_rec.system_id;
  ELSE
    l_SR_Validation_rec.system_id := l_service_request_rec.system_id;
  END IF;

  -- ----------------------------------------------------
  -- Some other fields that might need validations:
  --   problem_code, expected_resolution_date,
  --   resolution_code, and actual resolution_date
  -- ----------------------------------------------------
  IF (l_service_request_rec.problem_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.problem_code := l_old_ServiceRequest_rec.problem_code;
  ELSE
    l_service_request_rec.problem_code := UPPER(l_service_request_rec.problem_code);
    IF (l_service_request_rec.problem_code IS NOT NULL) THEN
      l_SR_Validation_rec.problem_code := l_service_request_rec.problem_code;
    END IF;
  END IF;


  IF (l_service_request_rec.resolution_code = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.resolution_code := l_old_ServiceRequest_rec.resolution_code;
  ELSE
    l_service_request_rec.resolution_code := UPPER(l_service_request_rec.resolution_code);
    IF (l_service_request_rec.resolution_code IS NOT NULL) THEN
      l_SR_Validation_rec.resolution_code := l_service_request_rec.resolution_code;
    END IF;
  END IF;

-------Fix for Bug#1697139 --jngeorge--05/21/01
------Added two more conditions for Bug# 1874528 ----jngeorge---07/18/01
  IF (l_service_request_rec.exp_resolution_date = FND_API.G_MISS_DATE)OR
     (l_service_request_rec.exp_resolution_date IS NULL AND
      l_old_ServiceRequest_rec.expected_resolution_date IS NULL) OR
     (l_service_request_rec.exp_resolution_date = l_old_ServiceRequest_rec.expected_resolution_date) THEN
    l_service_request_rec.exp_resolution_date := l_old_ServiceRequest_rec.expected_resolution_date;
    --
    -- For audit record added by shijain
    --
    x_audit_vals_rec.change_resolution_flag       := 'N';
    x_audit_vals_rec.old_expected_resolution_date := l_old_ServiceRequest_rec.expected_resolution_date;
    x_audit_vals_rec.expected_resolution_date     := l_service_request_rec.exp_resolution_date;

  ELSE
    IF (l_service_request_rec.exp_resolution_date IS NOT NULL) OR
       (l_service_request_rec.exp_resolution_date <> FND_API.G_MISS_DATE ) THEN
      l_SR_Validation_rec.exp_resolution_date := l_service_request_rec.exp_resolution_date;
    END IF;
    --
    -- For audit record
    --
    x_audit_vals_rec.change_RESOLUTION_FLAG := 'Y';
    x_audit_vals_rec.OLD_EXPECTED_RESOLUTION_DATE := l_old_ServiceRequest_rec.expected_resolution_date;
    x_audit_vals_rec.EXPECTED_RESOLUTION_DATE := l_service_request_rec.exp_resolution_date;
  END IF;

  IF (l_service_request_rec.act_resolution_date = FND_API.G_MISS_DATE) THEN
    l_service_request_rec.act_resolution_date := l_old_ServiceRequest_rec.actual_resolution_date;
  ELSE
    IF (l_service_request_rec.act_resolution_date IS NOT NULL) THEN
      l_SR_Validation_rec.act_resolution_date := l_service_request_rec.act_resolution_date;
    END IF;
  END IF;

  -- -----------------------------------------------------------
  -- Check to see if the descriptive flexfield is being updated
  -- -----------------------------------------------------------
  -- 11/25/03 smisra
  -- All attributes that are g_miss_char must be set to value in database
  -- whether flex fields are changed or not.
  -- So this code is moved immiediately after cursor to fetch values from database
  -- and if attribute value is g_miss_char, it is being set to value from database.
  --IF (FND_API.To_Boolean(l_update_desc_flex)) THEN
    --NULL;
  --ELSE
    --l_service_request_rec.request_attribute_1   := l_old_ServiceRequest_rec.incident_attribute_1;
    --l_service_request_rec.request_attribute_2   := l_old_ServiceRequest_rec.incident_attribute_2;
    --l_service_request_rec.request_attribute_3   := l_old_ServiceRequest_rec.incident_attribute_3;
    --l_service_request_rec.request_attribute_4   := l_old_ServiceRequest_rec.incident_attribute_4;
    --l_service_request_rec.request_attribute_5   := l_old_ServiceRequest_rec.incident_attribute_5;
    --l_service_request_rec.request_attribute_6   := l_old_ServiceRequest_rec.incident_attribute_6;
    --l_service_request_rec.request_attribute_7   := l_old_ServiceRequest_rec.incident_attribute_7;
    --l_service_request_rec.request_attribute_8   := l_old_ServiceRequest_rec.incident_attribute_8;
    --l_service_request_rec.request_attribute_9   := l_old_ServiceRequest_rec.incident_attribute_9;
    --l_service_request_rec.request_attribute_10  := l_old_ServiceRequest_rec.incident_attribute_10;
    --l_service_request_rec.request_attribute_11  := l_old_ServiceRequest_rec.incident_attribute_11;
    --l_service_request_rec.request_attribute_12  := l_old_ServiceRequest_rec.incident_attribute_12;
    --l_service_request_rec.request_attribute_13  := l_old_ServiceRequest_rec.incident_attribute_13;
    --l_service_request_rec.request_attribute_14  := l_old_ServiceRequest_rec.incident_attribute_14;
    --l_service_request_rec.request_attribute_15  := l_old_ServiceRequest_rec.incident_attribute_15;
    --l_service_request_rec.request_context       := l_old_ServiceRequest_rec.incident_context;
    --l_service_request_rec.external_attribute_1   := l_old_ServiceRequest_rec.external_attribute_1;
    --l_service_request_rec.external_attribute_2   := l_old_ServiceRequest_rec.external_attribute_2;
    --l_service_request_rec.external_attribute_3   := l_old_ServiceRequest_rec.external_attribute_3;
    --l_service_request_rec.external_attribute_4   := l_old_ServiceRequest_rec.external_attribute_4;
    --l_service_request_rec.external_attribute_5   := l_old_ServiceRequest_rec.external_attribute_5;
    --l_service_request_rec.external_attribute_6   := l_old_ServiceRequest_rec.external_attribute_6;
    --l_service_request_rec.external_attribute_7   := l_old_ServiceRequest_rec.external_attribute_7;
    --l_service_request_rec.external_attribute_8   := l_old_ServiceRequest_rec.external_attribute_8;
    --l_service_request_rec.external_attribute_9   := l_old_ServiceRequest_rec.external_attribute_9;
    --l_service_request_rec.external_attribute_10  := l_old_ServiceRequest_rec.external_attribute_10;
    --l_service_request_rec.external_attribute_11  := l_old_ServiceRequest_rec.external_attribute_11;
    --l_service_request_rec.external_attribute_12  := l_old_ServiceRequest_rec.external_attribute_12;
    --l_service_request_rec.external_attribute_13  := l_old_ServiceRequest_rec.external_attribute_13;
    --l_service_request_rec.external_attribute_14  := l_old_ServiceRequest_rec.external_attribute_14;
    --l_service_request_rec.external_attribute_15  := l_old_ServiceRequest_rec.external_attribute_15;
    --l_service_request_rec.external_context       := l_old_ServiceRequest_rec.external_context;
  --END IF;

 /* IF (l_service_request_rec.verify_cp_flag = FND_API.G_MISS_CHAR) THEN
    --
    -- We don't actually store a flag in the table to indicate
    -- if Installed Base mode is used.  We could tell this by
    -- checking to see if customer_product_id is NULL or not
    --
    IF (l_old_ServiceRequest_rec.customer_product_id IS NULL) THEN
      l_service_request_rec.verify_cp_flag := 'N';
    ELSE
      l_service_request_rec.verify_cp_flag := 'Y';
    END IF;
	--	 2757488
  ELSIF (l_service_request_rec.verify_cp_flag NOT IN ('Y','N'))  THEN
  		CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                            ( p_token_an    => l_api_name_full,
                              p_token_v     => l_service_request_rec.verify_cp_flag,
                              p_token_p     => 'verify_cp_flag',
                              p_table_name  => G_TABLE_NAME ,
                              p_column_name => '');
		RAISE FND_API.G_EXC_ERROR;
  END IF; */


   -- For bug 3333340
   p_passed_value := l_service_request_rec.verify_cp_flag;
   IF (l_service_request_rec.verify_cp_flag <> FND_API.G_MISS_CHAR
       AND l_service_request_rec.verify_cp_flag IS NOT NULL) THEN

      IF (l_service_request_rec.verify_cp_flag NOT IN ('Y','N'))  THEN
  		CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                            ( p_token_an    => l_api_name_full,
                              p_token_v     => l_service_request_rec.verify_cp_flag,
                              p_token_p     => 'verify_cp_flag',
                              p_table_name  => G_TABLE_NAME ,
                              p_column_name => '');
		RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  IF (l_service_request_rec.customer_product_id <> FND_API.G_MISS_NUM AND
      l_service_request_rec.customer_product_id IS NOT NULL) THEN
      l_service_request_rec.verify_cp_flag := 'Y';
  ELSIF ( l_service_request_rec.customer_product_id IS NULL) THEN
      l_service_request_rec.verify_cp_flag := 'N';
  ELSE
      IF (l_old_ServiceRequest_rec.customer_product_id IS NOT NULL) THEN
           l_service_request_rec.verify_cp_flag := 'Y';
      ELSE
           l_service_request_rec.verify_cp_flag := 'N';
      END IF;
  END IF;

  if ( p_passed_value <> FND_API.G_MISS_CHAR) then
         if ( p_passed_value <> l_service_request_rec.verify_cp_flag) then
	     CS_ServiceRequest_UTIL.Add_Cp_Flag_Ignored_Msg (p_token_an   => l_api_name_full,
					                     p_token_ip   => p_passed_value,
						             p_token_pv   => l_service_request_rec.verify_cp_flag);
	 end if;
  end if;



  l_SR_Validation_rec.caller_type := l_service_request_rec.caller_type;
----**********************
  IF (l_service_request_rec.customer_id = FND_API.G_MISS_NUM) THEN
    IF (l_service_request_rec.customer_number = FND_API.G_MISS_CHAR) THEN
        l_service_request_rec.customer_id := l_old_ServiceRequest_rec.customer_id;
           --Since we are not going to store the customer number in the base table
           --l_service_request_rec.customer_number := l_old_ServiceRequest_rec.customer_number;
    ELSE
      BEGIN
        SELECT party_id INTO l_service_request_rec.customer_id
        FROM hz_parties
        WHERE party_number = l_service_request_rec.customer_number;
      EXCEPTION
        WHEN OTHERS THEN

          CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                            ( p_token_an    => l_api_name_full,
                              p_token_v     => l_service_request_rec.customer_number,
                              p_token_p     => 'p_customer_number',
                              p_table_name  => G_TABLE_NAME ,
                              p_column_name => 'CUSTOMER_NUMBER');

          RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;
  ELSIF (l_service_request_rec.customer_id IS NOT NULL) THEN
    l_SR_Validation_rec.validate_customer := FND_API.G_TRUE;
    l_SR_Validation_rec.customer_id := l_service_request_rec.customer_id;
  END IF;

  IF (l_service_request_rec.bill_to_site_id = FND_API.G_MISS_NUM) OR
     (NVL(l_service_request_rec.bill_to_site_id, -99)
                            = NVL(l_old_ServiceRequest_rec.bill_to_site_id, -99))  THEN
      l_service_request_rec.bill_to_site_id := l_old_ServiceRequest_rec.bill_to_site_id;
  ELSE
      l_SR_Validation_rec.validate_bill_to_site := FND_API.G_TRUE;
      l_SR_Validation_rec.bill_to_party_id := l_service_request_rec.bill_to_party_id;
      l_SR_Validation_rec.bill_to_site_id := l_service_request_rec.bill_to_site_id;
  END IF;

  IF (l_service_request_rec.bill_to_site_use_id = FND_API.G_MISS_NUM) OR
     (NVL(l_service_request_rec.bill_to_site_use_id, -99) =
                          NVL(l_old_ServiceRequest_rec.bill_to_site_use_id, -99))  THEN
      l_service_request_rec.bill_to_site_use_id := l_old_ServiceRequest_rec.bill_to_site_use_id;
  ELSE
      l_SR_Validation_rec.bill_to_party_id := l_service_request_rec.bill_to_party_id;
      l_SR_Validation_rec.bill_to_site_use_id := l_service_request_rec.bill_to_site_use_id;
  END IF;

  IF (l_service_request_rec.bill_to_party_id = FND_API.G_MISS_NUM) OR
     (NVL(l_service_request_rec.bill_to_party_id, -99) =
                     NVL(l_old_ServiceRequest_rec.bill_to_party_id, -99))  THEN
      l_service_request_rec.bill_to_party_id := l_old_ServiceRequest_rec.bill_to_party_id;
  ELSE
      l_SR_Validation_rec.bill_to_party_id := l_service_request_rec.bill_to_party_id;
  END IF;

  --Passed value is FND or same as old(which may be null)
  IF (l_service_request_rec.bill_to_contact_id = FND_API.G_MISS_NUM) OR
     (NVL(l_service_request_rec.bill_to_contact_id, -99) = NVL(l_old_ServiceRequest_rec.bill_to_contact_id, -99))  THEN
    l_service_request_rec.bill_to_contact_id := l_old_ServiceRequest_rec.bill_to_contact_id;
    -- For audit record added by shijain
    x_audit_vals_rec.change_bill_to_flag    := 'N';
    x_audit_vals_rec.old_bill_to_contact_id := l_old_ServiceRequest_rec.bill_to_contact_id;
    x_audit_vals_rec.bill_to_contact_id     := l_service_request_rec.bill_to_contact_id;
  ELSIF (l_service_request_rec.bill_to_contact_id IS NOT NULL) THEN
    l_SR_Validation_rec.bill_to_contact_id := l_service_request_rec.bill_to_contact_id;
    l_SR_Validation_rec.bill_to_party_id := l_service_request_rec.bill_to_party_id;
  END IF;

  IF (NVL(l_service_request_rec.bill_to_contact_id, -99) <> NVL(l_old_ServiceRequest_rec.bill_to_contact_id, -99)) THEN
    -- For audit record
    x_audit_vals_rec.change_bill_to_FLAG := 'Y';
    x_audit_vals_rec.OLD_bill_to_contact_id := l_old_ServiceRequest_rec.bill_to_contact_id;
    x_audit_vals_rec.bill_to_contact_id := l_service_request_rec.bill_to_contact_id;
  --ELSE
    --l_new_vals_rec.bill_to_contact_id := l_service_request_rec.bill_to_contact_id;
  END IF;

  IF (l_service_request_rec.ship_to_party_id = FND_API.G_MISS_NUM) OR
     (NVL(l_service_request_rec.ship_to_party_id, -99) = NVL(l_old_ServiceRequest_rec.ship_to_party_id, -99))  THEN
      l_service_request_rec.ship_to_party_id := l_old_ServiceRequest_rec.ship_to_party_id;
  ELSIF (l_service_request_rec.ship_to_party_id IS NOT NULL) THEN
      l_SR_Validation_rec.ship_to_party_id := l_service_request_rec.ship_to_party_id;
  END IF;

  IF (l_service_request_rec.ship_to_site_id = FND_API.G_MISS_NUM) OR
     (NVL(l_service_request_rec.ship_to_site_id, -99) =
                      NVL(l_old_ServiceRequest_rec.ship_to_site_id, -99))  THEN
      l_service_request_rec.ship_to_site_id := l_old_ServiceRequest_rec.ship_to_site_id;
  ELSE
      l_SR_Validation_rec.validate_ship_to_site := FND_API.G_TRUE;
      l_SR_Validation_rec.ship_to_party_id := l_service_request_rec.ship_to_party_id;
      l_SR_Validation_rec.ship_to_site_id := l_service_request_rec.ship_to_site_id;
  END IF;

  IF (l_service_request_rec.ship_to_site_use_id = FND_API.G_MISS_NUM) OR
     (NVL(l_service_request_rec.ship_to_site_use_id, -99) =
                           NVL(l_old_ServiceRequest_rec.ship_to_site_use_id, -99))  THEN
      l_service_request_rec.ship_to_site_use_id := l_old_ServiceRequest_rec.ship_to_site_use_id;
  ELSE
      l_SR_Validation_rec.ship_to_party_id := l_service_request_rec.ship_to_party_id;
      l_SR_Validation_rec.ship_to_site_use_id := l_service_request_rec.ship_to_site_use_id;
  END IF;

  IF (l_service_request_rec.ship_to_contact_id = FND_API.G_MISS_NUM) OR
        (NVL(l_service_request_rec.ship_to_contact_id, -99) = NVL(l_old_ServiceRequest_rec.ship_to_contact_id, -99))THEN
      l_service_request_rec.ship_to_contact_id := l_old_ServiceRequest_rec.ship_to_contact_id;
    -- For audit record added by shijain
    x_audit_vals_rec.change_ship_to_flag    := 'N';
    x_audit_vals_rec.old_ship_to_contact_id := l_old_ServiceRequest_rec.ship_to_contact_id;
    x_audit_vals_rec.ship_to_contact_id     := l_service_request_rec.ship_to_contact_id;
  ELSIF (l_service_request_rec.ship_to_contact_id IS NOT NULL) THEN
    l_SR_Validation_rec.ship_to_contact_id := l_service_request_rec.ship_to_contact_id;
    l_SR_Validation_rec.ship_to_party_id   := l_service_request_rec.ship_to_party_id;
  END IF;

  IF (NVL(l_service_request_rec.ship_to_contact_id, -99) <> NVL(l_old_ServiceRequest_rec.ship_to_contact_id, -99)) THEN
    -- For audit record
    x_audit_vals_rec.change_ship_to_FLAG := 'Y';
    x_audit_vals_rec.OLD_ship_to_contact_id := l_old_ServiceRequest_rec.ship_to_contact_id;
    x_audit_vals_rec.ship_to_contact_id := l_service_request_rec.ship_to_contact_id;
  --ELSE
   -- l_new_vals_rec.ship_to_contact_id := l_service_request_rec.ship_to_contact_id;
  END IF;

  IF (l_service_request_rec.install_site_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.install_site_id, -99) =
                                 nvl(l_old_ServiceRequest_rec.install_site_id, -99) ) THEN
      l_service_request_rec.install_site_id := l_old_ServiceRequest_rec.install_site_id;
  ELSE
      l_SR_Validation_rec.validate_install_site := FND_API.G_TRUE;
      l_SR_Validation_rec.install_site_id := l_service_request_rec.install_site_id;
  END IF;

  IF (l_service_request_rec.install_site_use_id = FND_API.G_MISS_NUM) OR
     (nvl(l_service_request_rec.install_site_use_id, -99) =
                                 nvl(l_old_ServiceRequest_rec.install_site_use_id, -99) ) THEN
      l_service_request_rec.install_site_use_id := l_old_ServiceRequest_rec.install_site_use_id;
  ELSE
      l_SR_Validation_rec.validate_install_site := FND_API.G_TRUE;
      l_SR_Validation_rec.install_site_use_id := l_service_request_rec.install_site_use_id;
  END IF;

  ---Put this fix because audit was erroring out from CC to SR.

  IF (l_service_request_rec.verify_cp_flag = 'Y') THEN
    IF (l_service_request_rec.customer_product_id = FND_API.G_MISS_NUM) OR
          (NVL(l_service_request_rec.customer_product_id,-99)
            = NVL(l_old_ServiceRequest_rec.customer_product_id,-99)) THEN
      l_service_request_rec.customer_product_id := l_old_ServiceRequest_rec.customer_product_id;
      -- For audit record added by shijain
      x_audit_vals_rec.change_customer_product_FLAG := 'N';
      x_audit_vals_rec.OLD_customer_product_id      := l_old_ServiceRequest_rec.customer_product_id;
      x_audit_vals_rec.customer_product_id          := l_service_request_rec.customer_product_id;

    ELSE
      IF (l_service_request_rec.customer_product_id IS NOT NULL) THEN
        l_SR_Validation_rec.customer_product_id := l_service_request_rec.customer_product_id;
        -- For audit record
        x_audit_vals_rec.change_customer_product_FLAG := 'N';
        x_audit_vals_rec.OLD_customer_product_id := l_old_ServiceRequest_rec.customer_product_id;
        x_audit_vals_rec.customer_product_id := l_service_request_rec.customer_product_id;
      END IF;
    END IF;
 -- END IF;

    l_service_request_rec.original_order_number := NULL;
    l_service_request_rec.purchase_order_num := NULL;

  ELSE

    -- for bug 3333340
       if (l_service_request_rec.cp_component_id <> FND_API.G_MISS_NUM AND
	    l_service_request_rec.cp_component_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_component_id' );

		l_service_request_rec.cp_component_id := NULL;
	end if;

        if (l_service_request_rec.cp_component_version_id <> FND_API.G_MISS_NUM AND
	    l_service_request_rec.cp_component_version_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_component_version_id' );

		l_service_request_rec.cp_component_version_id := NULL;
	end if;

	if (l_service_request_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM AND
	    l_service_request_rec.cp_subcomponent_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_subcomponent_id' );

		l_service_request_rec.cp_subcomponent_id := NULL;
	end if;

	if (l_service_request_rec.cp_subcomponent_version_id <> FND_API.G_MISS_NUM AND
	    l_service_request_rec.cp_subcomponent_version_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_subcomponent_version_id' );

		l_service_request_rec.cp_subcomponent_version_id := NULL;
	end if;

	if (l_service_request_rec.cp_revision_id  <> FND_API.G_MISS_NUM AND
	    l_service_request_rec.cp_revision_id  IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_revision_id' );

		l_service_request_rec.cp_revision_id := NULL;
	end if;
-- Fix for bug 9398013 Sharanya. Checking for validation level also
	if (l_service_request_rec.product_revision  <> FND_API.G_MISS_CHAR AND
	    l_service_request_rec.product_revision  IS NOT NULL AND
	    (p_validation_level > FND_API.G_VALID_LEVEL_NONE)) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_product_revision' );

		l_service_request_rec.product_revision := NULL;
	end if;

	if (l_service_request_rec.component_version <> FND_API.G_MISS_CHAR AND
	    l_service_request_rec.component_version IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_component_version' );

		l_service_request_rec.component_version := NULL;
	end if;

	if (l_service_request_rec.subcomponent_version <> FND_API.G_MISS_CHAR AND
	    l_service_request_rec.subcomponent_version IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_subcomponent_version' );

		l_service_request_rec.subcomponent_version := NULL;
	end if;

    -- Verify CP is 'N'
    -- This step id done so that  l_service_request_rec.customer_product_id does not have MISS NUM value
    -- Added to take care of a situation where verify_cp is passed as 'N' by the caller
    -- This means that the customer_product_id and the related fields should be null
    l_service_request_rec.customer_product_id  := NULL;
    x_audit_vals_rec.customer_product_id       := NULL ;
    ---l_service_request_rec.account_id        := NULL;
    l_service_request_rec.cp_component_id      := NULL;
    l_service_request_rec.cp_component_version_id := NULL;
    l_service_request_rec.cp_subcomponent_id   := NULL;
    l_service_request_rec.cp_subcomponent_version_id := NULL;
    l_service_request_rec.cp_revision_id       := NULL;
    l_service_request_rec.product_revision     := NULL;
    l_service_request_rec.component_version    := NULL;
    l_service_request_rec.subcomponent_version := NULL;



--- fix for bug# 1657370 --jngeorge --05/22/01
    --l_service_request_rec.current_serial_number := NULL;
--- commenting the above line 'coz it clears the current_serial_number
--- during an update for a non-IB .Fix for Bug# 1902127.

-- added a condition to check if the new inventory_item_id is same
-- as old value. Fix for Bug#1854325 -- jngeorge

    IF (l_service_request_rec.inventory_item_id = FND_API.G_MISS_NUM) OR
       (l_service_request_rec.inventory_item_id =l_old_ServiceRequest_rec.inventory_item_id) THEN
      l_service_request_rec.inventory_item_id := l_old_ServiceRequest_rec.inventory_item_id;
    ELSE
      IF (l_service_request_rec.inventory_item_id IS NOT NULL) THEN
        l_SR_Validation_rec.inventory_item_id := l_service_request_rec.inventory_item_id;
      END IF;
    END IF;

    IF (l_service_request_rec.original_order_number = FND_API.G_MISS_NUM) THEN
      l_service_request_rec.original_order_number := l_old_ServiceRequest_rec.original_order_number;
    END IF;

    IF (l_service_request_rec.purchase_order_num = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.purchase_order_num := l_old_ServiceRequest_rec.purchase_order_num;
    END IF;

  END IF;

-- added a condition to check if the new inventory_item_id is same
-- as old value. Fix for Bug#1854325 -- jngeorge
  IF (l_service_request_rec.inventory_item_id = FND_API.G_MISS_NUM) OR
       (l_service_request_rec.inventory_item_id =l_old_ServiceRequest_rec.inventory_item_id) THEN
        l_service_request_rec.inventory_item_id := l_old_ServiceRequest_rec.inventory_item_id;
  ELSE
        IF (l_service_request_rec.inventory_item_id IS NOT NULL) THEN
           l_SR_Validation_rec.inventory_item_id := l_service_request_rec.inventory_item_id;
    END IF;
  END IF;

  IF (NVL(l_service_request_rec.customer_product_id, -99) <> NVL(l_old_ServiceRequest_rec.customer_product_id, -99)) THEN
    -- For audit record
    x_audit_vals_rec.change_customer_product_FLAG := 'Y';
    x_audit_vals_rec.OLD_customer_product_id := l_old_ServiceRequest_rec.customer_product_id;
    x_audit_vals_rec.customer_product_id := l_service_request_rec.customer_product_id;
  END IF;

  IF (l_service_request_rec.current_serial_number = FND_API.G_MISS_CHAR) THEN
    l_service_request_rec.current_serial_number := l_old_ServiceRequest_rec.current_serial_number;
  ELSE
    IF (l_service_request_rec.current_serial_number IS NOT NULL) THEN
      l_SR_Validation_rec.current_serial_number := l_service_request_rec.current_serial_number;
    END IF;
  END IF;

   --Assign the inventory org id retrived from the table to the validation record
   l_SR_Validation_rec.inventory_org_id := l_service_request_rec.inventory_org_id;

   -- Added for ER# 2433831 -- Bill To Account and Ship to Account
   IF (l_service_request_rec.bill_to_account_id = FND_API.G_MISS_NUM) THEN
      l_service_request_rec.bill_to_account_id := l_old_ServiceRequest_rec.bill_to_account_id ;
   ELSE
      IF (l_service_request_rec.bill_to_account_id IS NOT NULL) THEN
          l_SR_Validation_rec.bill_to_account_id := l_service_request_rec.bill_to_account_id ;
          l_SR_Validation_rec.bill_to_party_id := l_service_request_rec.bill_to_party_id ;
      END IF;
   END IF ;

   IF (l_service_request_rec.ship_to_account_id = FND_API.G_MISS_NUM) THEN
      l_service_request_rec.ship_to_account_id := l_old_ServiceRequest_rec.ship_to_account_id ;
   ELSE
      IF (l_service_request_rec.ship_to_account_id IS NOT NULL) THEN
          l_SR_Validation_rec.ship_to_account_id := l_service_request_rec.ship_to_account_id ;
          l_SR_Validation_rec.ship_to_party_id := l_service_request_rec.ship_to_party_id ;
      END IF;
   END IF ;

   -- Added for ER# 2463321 -- Non-Promary customer contacts (Phone and Email).
   IF (l_service_request_rec.customer_phone_id = FND_API.G_MISS_NUM) THEN
      l_service_request_rec.customer_phone_id := l_old_ServiceRequest_rec.customer_phone_id ;
   ELSE
      IF (l_service_request_rec.customer_phone_id IS NOT NULL) THEN
          l_SR_Validation_rec.customer_phone_id := l_service_request_rec.customer_phone_id ;
      END IF;
   END IF ;

   IF (l_service_request_rec.customer_email_id = FND_API.G_MISS_NUM) THEN
      l_service_request_rec.customer_email_id := l_old_ServiceRequest_rec.customer_email_id ;
   ELSE
      IF (l_service_request_rec.customer_email_id IS NOT NULL) THEN
          l_SR_Validation_rec.customer_email_id := l_service_request_rec.customer_email_id ;
      END IF;
   END IF ;

  -- for cmro_eam
   IF (l_service_request_rec.owning_dept_id = FND_API.G_MISS_NUM) THEN
       l_service_request_rec.owning_dept_id := l_old_ServiceRequest_rec.owning_department_id ;
   ELSE
       IF (l_service_request_rec.owning_dept_id IS NOT NULL) THEN
       l_SR_Validation_rec.owning_dept_id := l_service_request_rec.owning_dept_id ;
       END IF;
   END IF;

   -- end of cmro_eam

   -- For bug 3635269
   IF (l_service_request_rec.sr_creation_channel = FND_API.G_MISS_CHAR) THEN
       l_service_request_rec.sr_creation_channel := l_old_ServiceRequest_rec.sr_creation_channel ;
   ELSE
       IF (l_service_request_rec.sr_creation_channel IS NOT NULL) THEN
       l_SR_Validation_rec.sr_creation_channel := l_service_request_rec.sr_creation_channel ;
       END IF;
   END IF;

  --
  -- Call the validation procedure if the validation level is
  -- properly set
  --
  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
    Validate_ServiceRequest_Record(
       p_api_name               => l_api_name_full,
       p_service_request_rec    => l_SR_Validation_rec,
       p_request_date           => l_old_ServiceRequest_rec.incident_date,
       p_org_id                 => l_org_id,
       p_resp_appl_id           => p_resp_appl_id,
       p_resp_id                => p_resp_id,
       p_user_id                => p_last_updated_by,
       p_operation              => l_operation,
       p_close_flag             => l_close_flag,
       p_disallow_request_update=> l_disallow_request_update,
       p_disallow_owner_update  => l_disallow_owner_update,
       p_disallow_product_update=> l_disallow_product_update,
       p_employee_name          => l_employee_name,
       p_inventory_item_id      => l_cp_inventory_item_id,
       p_contract_id            => l_contra_id,
       p_contract_number        => l_contract_number,
       x_bill_to_site_id        => l_bill_to_site_id,
       x_ship_to_site_id        => l_ship_to_site_id,
       x_bill_to_site_use_id    => l_bill_to_site_use_id,
       x_ship_to_site_use_id    => l_ship_to_site_use_id,
       x_return_status          => l_return_status,
       x_group_name             => l_group_name,
       x_owner_name             => l_owner_name,
       x_product_revision       => l_dummy0,
       x_component_version      => l_dummy1,
       x_subcomponent_version   => l_dummy2,
       --for cmro_eam
       p_cmro_flag              => p_cmro_flag,
       p_maintenance_flag       => p_maintenance_flag,
	   p_sr_mode                => 'UPDATE'
      );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_contra_id is NOT NULL) THEN
       x_contra_id := l_contra_id;
    END IF;
    IF (l_contra_id is NOT NULL) THEN
       x_contract_number := l_contract_number;
    END IF;

    -- For bug 3340433
    /* Commenting the assignments as the validations are not called from
    validate_servicerequest_record because of the update mode */

    /*

    IF (l_service_request_rec.ship_to_site_id = FND_API.G_MISS_NUM) OR
       (NVL(l_service_request_rec.ship_to_site_id, -99)
                           = NVL(l_old_ServiceRequest_rec.ship_to_site_id, -99))
    THEN
      IF l_ship_to_site_id IS NULL OR
         l_ship_to_site_id =l_old_ServiceRequest_rec.ship_to_site_id
      THEN
            l_service_request_rec.ship_to_site_id :=
                              l_old_ServiceRequest_rec.ship_to_site_id;
      ELSE
            l_service_request_rec.ship_to_site_id := l_ship_to_site_id;
      END IF;
    END IF;

    IF (l_service_request_rec.ship_to_site_use_id = FND_API.G_MISS_NUM) OR
       (NVL(l_service_request_rec.ship_to_site_use_id, -99)
                       = NVL(l_old_ServiceRequest_rec.ship_to_site_use_id, -99))
    THEN
      IF l_ship_to_site_use_id IS NULL OR
         l_ship_to_site_use_id =l_old_ServiceRequest_rec.ship_to_site_use_id
      THEN
            l_service_request_rec.ship_to_site_use_id :=
                              l_old_ServiceRequest_rec.ship_to_site_use_id;
      ELSE
            l_service_request_rec.ship_to_site_use_id := l_ship_to_site_use_id;
      END IF;
    END IF;

    IF (l_service_request_rec.bill_to_site_id = FND_API.G_MISS_NUM) OR
       (NVL(l_service_request_rec.bill_to_site_id, -99)
                           = NVL(l_old_ServiceRequest_rec.bill_to_site_id, -99))
    THEN
      IF l_bill_to_site_id IS NULL OR
         l_bill_to_site_id =l_old_ServiceRequest_rec.bill_to_site_id
      THEN
            l_service_request_rec.bill_to_site_id :=
                              l_old_ServiceRequest_rec.bill_to_site_id;
      ELSE
            l_service_request_rec.bill_to_site_id := l_bill_to_site_id;
      END IF;
    END IF;

    IF (l_service_request_rec.bill_to_site_use_id = FND_API.G_MISS_NUM) OR
       (NVL(l_service_request_rec.bill_to_site_use_id, -99)
                       = NVL(l_old_ServiceRequest_rec.bill_to_site_use_id, -99))
    THEN
      IF l_bill_to_site_use_id IS NULL OR
         l_bill_to_site_use_id =l_old_ServiceRequest_rec.bill_to_site_use_id
      THEN
            l_service_request_rec.bill_to_site_use_id :=
                              l_old_ServiceRequest_rec.bill_to_site_use_id;
      ELSE
            l_service_request_rec.bill_to_site_use_id := l_bill_to_site_use_id;
      END IF;
    END IF;

    --
    -- Need to store the inventory_item_id from the CP if CP is
    -- used
    --
    -- Added a condition because inventory_item_id becomes null
    -- Fix for Bug# 1854325.-- jngeorge
    -- If customer_product_id is specified then the inventory item id
    -- specified in the record type is always overwritten by the
    -- inventory item id value in the
    -- CS_CUSTOMER_PRODUCTS_ALL for that customer_product_id



    IF (l_service_request_rec.customer_product_id IS NOT NULL) AND
       (l_service_request_rec.inventory_item_id <> l_old_ServiceRequest_rec.inventory_item_id) THEN
      l_service_request_rec.inventory_item_id := l_cp_inventory_item_id;

    END IF; */

    --added this code on dec 8th 2000
    IF  l_status_validated = TRUE  THEN
         l_close_flag := l_closed_flag_temp ;
    END IF;

    -- For bug 3464004
    -- Close date was nullified when the closed SR is updated with summary
    -- or urgency
    -- The validate_status and validate_updated_status is not called when the
    -- status is not updated so the close_flag is null

    if ( l_service_request_rec.status_id = FND_API.G_MISS_NUM) then

      l_temp_close_flag := get_status_flag(l_old_ServiceRequest_rec.incident_status_id);
      if (l_temp_close_flag = 'C') then
            l_close_flag := 'Y';
      else
            l_close_flag := 'N';
      end if;
    else
      -- for bug 3520943 - to get the close date
      l_temp_close_flag := get_status_flag(l_service_request_rec.status_id);

      if (l_temp_close_flag = 'C') then
            l_close_flag := 'Y';
      else
            l_close_flag := 'N';
      end if;

    end if;

    --
    -- We can only verify the close_date after calling the validation
    -- procedure because we need to get the closed_flag first
    --
    IF (l_close_flag = 'Y') THEN
        -- Added it for Ehn. 2655115
        -- Commented out for bug #3050727, since this is now redundant after the bug-fix --anmukher --09/15/03
        -- l_service_request_rec.status_flag := 'C';

      IF ((l_service_request_rec.closed_date = FND_API.G_MISS_DATE) OR
           (l_service_request_rec.closed_date IS NULL)) THEN
        IF (l_old_ServiceRequest_rec.close_date IS NULL) THEN
          l_service_request_rec.closed_date := SYSDATE;
        ELSE
          l_service_request_rec.closed_date := l_old_ServiceRequest_rec.close_date;
        END IF;
      ELSIF (l_service_request_rec.closed_date IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_Closed_Date
          ( p_api_name       => l_api_name_full,
            p_parameter_name => 'p_closed_date',
            p_closed_date    => l_service_request_rec.closed_date,
            p_request_date   => l_old_ServiceRequest_rec.incident_date,
            x_return_status  => l_return_status
          );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    ELSE
      -- Added it for Ehn. 2655115
      -- Commented out for bug #3050727, since this is now redundant after the bug-fix --anmukher --09/15/03
      -- l_service_request_rec.status_flag:= 'O';

      IF (l_service_request_rec.closed_date <> FND_API.G_MISS_DATE) THEN

        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg
                          ( p_token_an     =>  l_api_name_full,
                            p_token_ip     =>  'p_closed_date',
                            p_table_name   =>  G_TABLE_NAME,
                            p_column_name  =>  'CLOSED_DATE' );
      END IF;
      l_service_request_rec.closed_date := NULL;
    END IF;
  END IF;   /* Validation Level */

-- for the bug 3050727
-- Commented out the IF-END IF since the assignment should be done anyway --anmukher --09/15/03
  -- IF (p_validation_level = FND_API.G_VALID_LEVEL_NONE) THEN
	l_service_request_rec.status_flag := get_status_flag(l_service_request_rec.status_id);
  -- END IF;

  /* Bug 2624341 close date should be audited if the status is changed,
     i.e. if the status is changed from closed to open the the close_date
     should be nullfied, in the audit table, so moved this code after
     checking the close_flag and setting the close_date based on the
     close_flag. Change done by shijain*/

  IF (l_service_request_rec.closed_date = FND_API.G_MISS_DATE) OR
     (l_service_request_rec.closed_date IS NULL AND
      l_old_ServiceRequest_rec.close_date IS NULL) OR
     (l_service_request_rec.closed_date = l_old_ServiceRequest_rec.close_date)
  THEN
    l_service_request_rec.closed_date := l_old_ServiceRequest_rec.close_date;
    IF  (x_audit_vals_rec.change_incident_status_flag = 'Y')
    AND (l_closed_flag_temp = 'N' OR l_closed_flag_temp IS NULL)
    THEN
        l_service_request_rec.closed_date := NULL;
    END IF;
    -- For audit record added by shijain
    x_audit_vals_rec.change_close_date_flag := 'N';
    x_audit_vals_rec.old_close_date         := l_old_ServiceRequest_rec.close_date;
    x_audit_vals_rec.close_date             := l_service_request_rec.closed_date;
  ELSE
    -- For audit record
    x_audit_vals_rec.change_close_date_FLAG := 'Y';
    x_audit_vals_rec.OLD_close_date         := l_old_ServiceRequest_rec.close_date;
    x_audit_vals_rec.close_date             := l_service_request_rec.closed_date;
  END IF;

 /* Enh. 2624341 status flag should be audited based on the close_flag,
    if the close flag='Y' then the status_flag should be C else O, so
    we are checking the status flag after we get the close flag in
    validate_service_request procedure.Change done by shijain*/

 IF (l_service_request_rec.status_flag = FND_API.G_MISS_CHAR) OR
    ( l_service_request_rec.status_flag = l_old_ServiceRequest_rec.status_flag )
 THEN
    l_service_request_rec.status_flag  := l_old_ServiceRequest_rec.status_flag;
    -- For audit record added by shijain
    x_audit_vals_rec.change_status_flag  := 'N';
    x_audit_vals_rec.old_status_flag     := l_old_ServiceRequest_rec.status_flag ;
    x_audit_vals_rec.status_flag         := l_service_request_rec.status_flag;
 ELSE
    -- For audit record
    x_audit_vals_rec.CHANGE_status_flag  := 'Y';
    x_audit_vals_rec.OLD_status_flag     := l_old_ServiceRequest_rec.status_flag ;
    x_audit_vals_rec.status_flag         := l_service_request_rec.status_flag;
 END IF;

-- for cmro_eam
IF (l_service_request_rec.owning_dept_id = FND_API.G_MISS_NUM OR
    l_service_request_rec.owning_dept_id = l_old_ServiceRequest_rec.owning_department_id) THEN
    l_service_request_rec.owning_dept_id := l_old_ServiceRequest_rec.owning_department_id;
END IF;

-- end for cmro_eam
---------------------------------------------------
  -- Before the actual update, see if the all the fields have their old values or null values
  --(otherwise they will have the MISS_NUM constants)
  IF (l_service_request_rec.customer_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.customer_id = l_old_ServiceRequest_rec.customer_id) THEN
      l_service_request_rec.customer_id := l_old_ServiceRequest_rec.customer_id;
  END IF;

  IF (l_service_request_rec.bill_to_site_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.bill_to_site_id = l_old_ServiceRequest_rec.bill_to_site_id) THEN
      l_service_request_rec.bill_to_site_id := l_old_ServiceRequest_rec.bill_to_site_id ;
  END IF;

  IF (l_service_request_rec.bill_to_site_use_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.bill_to_site_use_id = l_old_ServiceRequest_rec.bill_to_site_use_id) THEN
      l_service_request_rec.bill_to_site_use_id := l_old_ServiceRequest_rec.bill_to_site_use_id ;
  END IF;

  IF (l_service_request_rec.bill_to_party_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.bill_to_party_id = l_old_ServiceRequest_rec.bill_to_party_id) THEN
      l_service_request_rec.bill_to_party_id := l_old_ServiceRequest_rec.bill_to_party_id ;
  END IF;

  IF (l_service_request_rec.ship_to_site_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.ship_to_site_id = l_old_ServiceRequest_rec.ship_to_site_id) THEN
      l_service_request_rec.ship_to_site_id := l_old_ServiceRequest_rec.ship_to_site_id ;
  END IF;

  IF (l_service_request_rec.ship_to_site_use_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.ship_to_site_use_id = l_old_ServiceRequest_rec.ship_to_site_use_id) THEN
      l_service_request_rec.ship_to_site_use_id := l_old_ServiceRequest_rec.ship_to_site_use_id ;
  END IF;

  IF (l_service_request_rec.ship_to_party_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.ship_to_party_id = l_old_ServiceRequest_rec.ship_to_party_id) THEN
      l_service_request_rec.ship_to_party_id := l_old_ServiceRequest_rec.ship_to_party_id ;
  END IF;

  IF (l_service_request_rec.install_site_id = FND_API.G_MISS_NUM OR
      nvl(l_service_request_rec.install_site_id,-99) = nvl(l_old_ServiceRequest_rec.install_site_id,-99)
     )
  AND (l_service_request_rec.install_site_use_id <> FND_API.G_MISS_NUM OR
       nvl(l_service_request_rec.install_site_use_id,-99) <> nvl(l_old_ServiceRequest_rec.install_site_use_id,-99))
 THEN
	  l_service_request_rec.install_site_use_id := l_service_request_rec.install_site_use_id;
      l_service_request_rec.install_site_id := l_service_request_rec.install_site_use_id;
  END IF;

  IF (l_service_request_rec.install_site_use_id = FND_API.G_MISS_NUM OR
      nvl(l_service_request_rec.install_site_use_id,-99) = nvl(l_old_ServiceRequest_rec.install_site_use_id,-99)
     )
  AND (l_service_request_rec.install_site_id <> FND_API.G_MISS_NUM OR
       nvl(l_service_request_rec.install_site_id,-99) <> nvl(l_old_ServiceRequest_rec.install_site_id,-99))
 THEN
      l_service_request_rec.install_site_id := l_service_request_rec.install_site_id;
      l_service_request_rec.install_site_use_id := l_service_request_rec.install_site_id;
  END IF;

  IF (l_service_request_rec.bill_to_contact_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.bill_to_contact_id = l_old_ServiceRequest_rec.bill_to_contact_id) THEN
      l_service_request_rec.bill_to_contact_id := l_old_ServiceRequest_rec.bill_to_contact_id;
  END IF;

  IF (l_service_request_rec.ship_to_contact_id = FND_API.G_MISS_NUM OR
      l_service_request_rec.ship_to_contact_id = l_old_ServiceRequest_rec.ship_to_contact_id) THEN
      l_service_request_rec.ship_to_contact_id := l_old_ServiceRequest_rec.ship_to_contact_id;
  END IF;

   -- Added for ER# 2320056 -- Coverage Type
   IF (l_service_request_rec.coverage_type = FND_API.G_MISS_CHAR) THEN
       l_service_request_rec.coverage_type := l_old_ServiceRequest_rec.coverage_type  ;
   END IF ;

-- If the contract service id is null then coverage type should be null
-- Added this check for 1159 by shijain dec6th 2002
   IF (l_service_request_rec.contract_service_id = FND_API.G_MISS_NUM)
   OR (l_service_request_rec.contract_service_id IS NULL)  THEN
           l_service_request_rec.coverage_type  := NULL;
   END IF;


   IF (l_service_request_rec.program_id = FND_API.G_MISS_NUM) THEN
       l_service_request_rec.program_id := l_old_ServiceRequest_rec.program_id  ;
   END IF ;

   IF (l_service_request_rec.program_application_id = FND_API.G_MISS_NUM) THEN
       l_service_request_rec.program_application_id := l_old_ServiceRequest_rec.program_application_id  ;
   END IF ;

   IF (l_service_request_rec.conc_request_id = FND_API.G_MISS_NUM) THEN
       l_service_request_rec.conc_request_id := l_old_ServiceRequest_rec.request_id  ;
   END IF ;

   IF (l_service_request_rec.program_login_id = FND_API.G_MISS_NUM) THEN
       l_service_request_rec.program_login_id := l_old_ServiceRequest_rec.program_login_id  ;
   END IF ;

  --- Added for HA, the WHO columns should be derived before inserting
  --- if passed null or has G_MISS values.
  IF (l_service_request_rec.last_update_date = FND_API.G_MISS_DATE OR
      l_service_request_rec.last_update_date IS NULL ) THEN
      l_service_request_rec.last_update_date := SYSDATE;
  END IF;

  IF (l_service_request_rec.last_updated_by = FND_API.G_MISS_NUM OR
      l_service_request_rec.last_updated_by IS NULL ) THEN
      l_service_request_rec.last_updated_by := p_last_updated_by;
  END IF;

  IF (l_service_request_rec.creation_date = FND_API.G_MISS_DATE OR
      l_service_request_rec.creation_date IS NULL ) THEN
      l_service_request_rec.creation_date := SYSDATE;
  END IF;

  IF (l_service_request_rec.created_by = FND_API.G_MISS_NUM OR
      l_service_request_rec.created_by IS NULL ) THEN
      l_service_request_rec.created_by := p_last_updated_by;
  END IF;

  IF (l_service_request_rec.last_update_login = FND_API.G_MISS_NUM OR
      l_service_request_rec.last_update_login IS NULL ) THEN
      l_service_request_rec.last_update_login := p_last_update_login;
  END IF;

  IF (l_service_request_rec.maint_organization_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.maint_organization_id := l_old_ServiceRequest_rec.maint_organization_id  ;
  END IF ;

  IF (l_service_request_rec.site_id = FND_API.G_MISS_NUM) THEN
    l_service_request_rec.site_id := l_old_ServiceRequest_rec.site_id  ;
  END IF ;


---------------------------------------------------
----Added for Enhancements 11.5.6
    IF (l_service_request_rec.owner_group_id IS NOT NULL AND
        l_service_request_rec.owner_id IS NOT NULL) OR
       (l_service_request_rec.owner_group_id IS NOT NULL AND
           l_service_request_rec.group_type = 'RS_TEAM') THEN
         l_service_request_rec.owner_assigned_flag := 'Y';
    ELSIF (l_service_request_rec.owner_group_id IS NULL) THEN
         l_service_request_rec.owner_assigned_flag := 'N';
    END IF;
--*************************************************

--Added code to fix Bug# 1948054
IF (p_validation_level = FND_API.G_VALID_LEVEL_NONE) THEN
    --
    -- Validate contract service id
    --
    IF (l_service_request_rec.contract_service_id <> FND_API.G_MISS_NUM AND
        l_service_request_rec.contract_service_id IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_Contract_Service_Id(
          p_api_name         => l_api_name,
          p_parameter_name   => 'p_contract_service_id',
          p_contract_service_id => l_service_request_rec.contract_service_id,
          x_contract_id      =>x_contra_id,
          x_contract_number  =>x_contract_number,
          x_return_status    => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
          END IF;

    -- Validate contract id
    --
    IF (p_service_request_rec.contract_id <> FND_API.G_MISS_NUM) AND
        (p_service_request_rec.contract_id IS NOT NULL) AND
        (p_service_request_rec.contract_service_id IS NULL OR
         p_service_request_rec.contract_service_id = FND_API.G_MISS_NUM) THEN

        CS_ServiceRequest_UTIL.Validate_Contract_Id(
          p_api_name         => l_api_name,
          p_parameter_name   => 'p_contract_id',
          p_contract_id => l_service_request_rec.contract_id,
                x_contract_number  => x_contract_number,
          x_return_status    => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
      x_contra_id := l_service_request_rec.contract_id;

    END IF;

 END IF;   --- p validation_level

   ---- Added this code because the form is clearing the group,
   ---- when group_type is not entered.

    IF (l_service_request_rec.owner_group_id IS NOT NULL AND
        l_service_request_rec.group_type IS NULL) THEN
         l_service_request_rec.owner_group_id := NULL;
    END IF;

  -- Added this code for source changes for 11.5.9 by shijain dated oct 11 2002
  -- this code is to check if the last_update_program_code is passed and is not
  -- null as this is a mandatory parameter.

  IF (l_service_request_rec.last_update_program_code = FND_API.G_MISS_CHAR  OR
      l_service_request_rec.last_update_program_code  IS NULL) THEN

      /*Commented this code for backward compatibility, that if someone
        passes a last update program code as NULL or G_MISS_CHAR, we are supporting
        it now and defaulting it to UNKNOWN
        CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg
                        ( p_token_an     => l_api_name_full,
                          p_token_np     => 'SR Last Update Program Code',
                          p_table_name   => G_TABLE_NAME ,
                          p_column_name  => 'LAST_UPDATE_PROGRAM_CODE');

       RAISE FND_API.G_EXC_ERROR;
       */
       l_service_request_rec.last_update_program_code:='UNKNOWN';
  END IF;

    --
    -- Validate last update program code 10/11/02 shijain
    --

    IF (l_service_request_rec.last_update_program_code <> FND_API.G_MISS_CHAR) AND
        (l_service_request_rec.last_update_program_code IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_source_program_code(
          p_api_name             => l_api_name,
          p_parameter_name       => 'p_last_update_program_code',
          p_source_program_code  => l_service_request_rec.last_update_program_code,
          x_return_status        => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
   END IF;

-- Added for address by shijain 05 dec 2002
      IF (l_service_request_rec.INCIDENT_DIRECTION_QUALIFIER <> FND_API.G_MISS_CHAR) AND
        (l_service_request_rec.INCIDENT_DIRECTION_QUALIFIER IS NOT NULL) THEN

        CS_ServiceRequest_UTIL.Validate_INC_DIRECTION_QUAL(
          p_api_name             => l_api_name,
          p_parameter_name       => 'p_INC_DIRECTION_QUAL',
          p_INC_DIRECTION_QUAL  => l_service_request_rec.INCIDENT_DIRECTION_QUALIFIER,
          x_return_status        => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
   END IF;

-- Added for address by shijain 05 dec 2002
    IF (l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM <> FND_API.G_MISS_CHAR) AND
        (l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM IS NOT NULL) THEN


        CS_ServiceRequest_UTIL.Validate_INC_DIST_QUAL_UOM(
          p_api_name             => l_api_name,
          p_parameter_name       => 'p_INC_DIST_QUAL_UOM',
          p_INC_DIST_QUAL_UOM  => l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM,
          x_return_status        => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
   END IF;

  x_audit_vals_rec.OLD_INCIDENT_NUMBER		:= l_old_ServiceRequest_rec.INCIDENT_NUMBER;
  x_audit_vals_rec.INCIDENT_NUMBER		:= l_old_ServiceRequest_rec.INCIDENT_NUMBER;

  x_audit_vals_rec.OLD_CUSTOMER_ID		:= l_old_ServiceRequest_rec.CUSTOMER_ID;
  IF (nvl(l_service_request_rec.CUSTOMER_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CUSTOMER_ID,-99) <> nvl(l_old_ServiceRequest_rec.CUSTOMER_ID,-99)) THEN
    x_audit_vals_rec.CUSTOMER_ID		:= l_service_request_rec.CUSTOMER_ID;
  ELSE
    x_audit_vals_rec.CUSTOMER_ID		:= l_old_ServiceRequest_rec.CUSTOMER_ID;
  END IF;

  x_audit_vals_rec.OLD_BILL_TO_SITE_USE_ID	:= l_old_ServiceRequest_rec.BILL_TO_SITE_USE_ID;
  IF (nvl(l_service_request_rec.BILL_TO_SITE_USE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.BILL_TO_SITE_USE_ID,-99) <> nvl(l_old_ServiceRequest_rec.BILL_TO_SITE_USE_ID,-99)) THEN
    x_audit_vals_rec.BILL_TO_SITE_USE_ID	:= l_service_request_rec.BILL_TO_SITE_USE_ID;
  ELSE
    x_audit_vals_rec.BILL_TO_SITE_USE_ID	:= l_old_ServiceRequest_rec.BILL_TO_SITE_USE_ID;
  END IF;

  x_audit_vals_rec.OLD_EMPLOYEE_ID		:= l_old_ServiceRequest_rec.EMPLOYEE_ID;
  IF (nvl(l_service_request_rec.EMPLOYEE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.EMPLOYEE_ID,-99) <> nvl(l_old_ServiceRequest_rec.EMPLOYEE_ID,-99)) THEN
    x_audit_vals_rec.EMPLOYEE_ID		:= l_service_request_rec.EMPLOYEE_ID;
  ELSE
    x_audit_vals_rec.EMPLOYEE_ID		:= l_old_ServiceRequest_rec.EMPLOYEE_ID;
  END IF;

  x_audit_vals_rec.OLD_SHIP_TO_SITE_USE_ID	:= l_old_ServiceRequest_rec.SHIP_TO_SITE_USE_ID;
  IF (nvl(l_service_request_rec.SHIP_TO_SITE_USE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.SHIP_TO_SITE_USE_ID,-99) <> nvl(l_old_ServiceRequest_rec.SHIP_TO_SITE_USE_ID,-99)) THEN
    x_audit_vals_rec.SHIP_TO_SITE_USE_ID	:= l_service_request_rec.SHIP_TO_SITE_USE_ID;
  ELSE
    x_audit_vals_rec.SHIP_TO_SITE_USE_ID	:= l_old_ServiceRequest_rec.SHIP_TO_SITE_USE_ID;
  END IF;

  x_audit_vals_rec.OLD_PROBLEM_CODE		:= l_old_ServiceRequest_rec.PROBLEM_CODE;
  IF (nvl(l_service_request_rec.PROBLEM_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.PROBLEM_CODE,-99) <> nvl(l_old_ServiceRequest_rec.PROBLEM_CODE,-99)) THEN
    x_audit_vals_rec.PROBLEM_CODE		:= l_service_request_rec.PROBLEM_CODE;
  ELSE
    x_audit_vals_rec.PROBLEM_CODE		:= l_old_ServiceRequest_rec.PROBLEM_CODE;
  END IF;

  x_audit_vals_rec.OLD_ACTUAL_RESOLUTION_DATE	:= l_old_ServiceRequest_rec.ACTUAL_RESOLUTION_DATE;
  IF (nvl(l_service_request_rec.ACT_RESOLUTION_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <> FND_API.G_MISS_DATE) AND
    (nvl(l_service_request_rec.ACT_RESOLUTION_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <>
        nvl(l_old_ServiceRequest_rec.ACTUAL_RESOLUTION_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY'))) THEN
    x_audit_vals_rec.ACTUAL_RESOLUTION_DATE	:= l_service_request_rec.ACT_RESOLUTION_DATE;
  ELSE
    x_audit_vals_rec.ACTUAL_RESOLUTION_DATE	:= l_old_ServiceRequest_rec.ACTUAL_RESOLUTION_DATE;
  END IF;

  x_audit_vals_rec.OLD_INSTALL_SITE_USE_ID	:= l_old_ServiceRequest_rec.INSTALL_SITE_USE_ID;
  IF (nvl(l_service_request_rec.INSTALL_SITE_USE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.INSTALL_SITE_USE_ID,-99) <> nvl(l_old_ServiceRequest_rec.INSTALL_SITE_USE_ID,-99)) THEN
    x_audit_vals_rec.INSTALL_SITE_USE_ID	:= l_service_request_rec.INSTALL_SITE_USE_ID;
  ELSE
    x_audit_vals_rec.INSTALL_SITE_USE_ID	:= l_old_ServiceRequest_rec.INSTALL_SITE_USE_ID;
  END IF;

  x_audit_vals_rec.OLD_CURRENT_SERIAL_NUMBER	:= l_old_ServiceRequest_rec.CURRENT_SERIAL_NUMBER;
  IF (nvl(l_service_request_rec.CURRENT_SERIAL_NUMBER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.CURRENT_SERIAL_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.CURRENT_SERIAL_NUMBER,-99)) THEN
    x_audit_vals_rec.CURRENT_SERIAL_NUMBER	:= l_service_request_rec.CURRENT_SERIAL_NUMBER;
  ELSE
    x_audit_vals_rec.CURRENT_SERIAL_NUMBER	:= l_old_ServiceRequest_rec.CURRENT_SERIAL_NUMBER;
  END IF;

  x_audit_vals_rec.OLD_SYSTEM_ID		:= l_old_ServiceRequest_rec.SYSTEM_ID;
  IF (nvl(l_service_request_rec.SYSTEM_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.SYSTEM_ID,-99) <> nvl(l_old_ServiceRequest_rec.SYSTEM_ID,-99)) THEN
    x_audit_vals_rec.SYSTEM_ID			:= l_service_request_rec.SYSTEM_ID;
  ELSE
    x_audit_vals_rec.SYSTEM_ID			:= l_old_ServiceRequest_rec.SYSTEM_ID;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_1;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_1,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_1,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_1,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_1	:= l_service_request_rec.REQUEST_ATTRIBUTE_1;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_1	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_1;
  END IF;


  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_2	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_2;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_2,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_2,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_2,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_2	:= l_service_request_rec.REQUEST_ATTRIBUTE_2;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_2	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_2;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_3	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_3;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_3,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_3,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_3,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_3	:= l_service_request_rec.REQUEST_ATTRIBUTE_3;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_3	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_3;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_4	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_4;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_4,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_4,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_4,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_4	:= l_service_request_rec.REQUEST_ATTRIBUTE_4;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_4	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_4;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_5	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_5;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_5,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_5,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_5,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_5	:= l_service_request_rec.REQUEST_ATTRIBUTE_5;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_5	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_5;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_6	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_6;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_6,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_6,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_6,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_6	:= l_service_request_rec.REQUEST_ATTRIBUTE_6;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_6	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_6;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_7	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_7;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_7,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_7,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_7,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_7	:= l_service_request_rec.REQUEST_ATTRIBUTE_7;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_7	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_7;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_8	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_8;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_8,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_8,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_8,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_8	:= l_service_request_rec.REQUEST_ATTRIBUTE_8;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_8	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_8;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_9	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_9;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_9,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_9,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_9,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_9	:= l_service_request_rec.REQUEST_ATTRIBUTE_9;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_9	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_9;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_10	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_10;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_10,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_10,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_10,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_10	:= l_service_request_rec.REQUEST_ATTRIBUTE_10;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_10	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_10;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_11	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_11;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_11,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_11,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_11,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_11	:= l_service_request_rec.REQUEST_ATTRIBUTE_11;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_11	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_11;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_12	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_12;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_12,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_12,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_12,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_12	:= l_service_request_rec.REQUEST_ATTRIBUTE_12;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_12	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_12;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_13	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_13;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_13,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_13,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_13,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_13	:= l_service_request_rec.REQUEST_ATTRIBUTE_13;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_13	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_13;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_14	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_14;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_14,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_14,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_14,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_14	:= l_service_request_rec.REQUEST_ATTRIBUTE_14;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_14	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_14;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_15	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_15;
  IF (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_15,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_ATTRIBUTE_15,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_15,-99)) THEN
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_15	:= l_service_request_rec.REQUEST_ATTRIBUTE_15;
  ELSE
    x_audit_vals_rec.INCIDENT_ATTRIBUTE_15	:= l_old_ServiceRequest_rec.INCIDENT_ATTRIBUTE_15;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_CONTEXT		:= l_old_ServiceRequest_rec.INCIDENT_CONTEXT;
  IF (nvl(l_service_request_rec.REQUEST_CONTEXT,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.REQUEST_CONTEXT,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_CONTEXT,-99)) THEN
    x_audit_vals_rec.INCIDENT_CONTEXT		:= l_service_request_rec.REQUEST_CONTEXT;
  ELSE
    x_audit_vals_rec.INCIDENT_CONTEXT		:= l_old_ServiceRequest_rec.INCIDENT_CONTEXT;
  END IF;

  x_audit_vals_rec.OLD_RESOLUTION_CODE		:= l_old_ServiceRequest_rec.RESOLUTION_CODE;
  IF (nvl(l_service_request_rec.RESOLUTION_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.RESOLUTION_CODE,-99) <> nvl(l_old_ServiceRequest_rec.RESOLUTION_CODE,-99)) THEN
    x_audit_vals_rec.RESOLUTION_CODE		:= l_service_request_rec.RESOLUTION_CODE;
  ELSE
    x_audit_vals_rec.RESOLUTION_CODE		:= l_old_ServiceRequest_rec.RESOLUTION_CODE;
  END IF;

  x_audit_vals_rec.OLD_ORIGINAL_ORDER_NUMBER	:= l_old_ServiceRequest_rec.ORIGINAL_ORDER_NUMBER;
  IF (nvl(l_service_request_rec.ORIGINAL_ORDER_NUMBER,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.ORIGINAL_ORDER_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.ORIGINAL_ORDER_NUMBER,-99)) THEN
    x_audit_vals_rec.ORIGINAL_ORDER_NUMBER	:= l_service_request_rec.ORIGINAL_ORDER_NUMBER;
  ELSE
    x_audit_vals_rec.ORIGINAL_ORDER_NUMBER	:= l_old_ServiceRequest_rec.ORIGINAL_ORDER_NUMBER;
  END IF;

  /* Could not populate this column as no equivalent column was found in l_service_request_rec */
  /*
  IF (nvl(l_service_request_rec.,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec. ,-99)) THEN
    x_audit_vals_rec.ORG_ID			:= l_service_request_rec.;
  END IF;
  */

  x_audit_vals_rec.OLD_PURCHASE_ORDER_NUMBER	:= l_old_ServiceRequest_rec.PURCHASE_ORDER_NUM;
  IF (nvl(l_service_request_rec.PURCHASE_ORDER_NUM,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.PURCHASE_ORDER_NUM,-99) <> nvl(l_old_ServiceRequest_rec.PURCHASE_ORDER_NUM,-99)) THEN
    x_audit_vals_rec.PURCHASE_ORDER_NUMBER	:= l_service_request_rec.PURCHASE_ORDER_NUM;
  ELSE
    x_audit_vals_rec.PURCHASE_ORDER_NUMBER	:= l_old_ServiceRequest_rec.PURCHASE_ORDER_NUM;
  END IF;

  x_audit_vals_rec.OLD_PUBLISH_FLAG		:= l_old_ServiceRequest_rec.PUBLISH_FLAG;
  IF (nvl(l_service_request_rec.PUBLISH_FLAG,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.PUBLISH_FLAG,-99) <> nvl(l_old_ServiceRequest_rec.PUBLISH_FLAG,-99)) THEN
    x_audit_vals_rec.PUBLISH_FLAG		:= l_service_request_rec.PUBLISH_FLAG;
  ELSE
    x_audit_vals_rec.PUBLISH_FLAG		:= l_old_ServiceRequest_rec.PUBLISH_FLAG;
  END IF;

  x_audit_vals_rec.OLD_QA_COLLECTION_ID		:= l_old_ServiceRequest_rec.QA_COLLECTION_ID;
  IF (nvl(l_service_request_rec.QA_COLLECTION_PLAN_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.QA_COLLECTION_PLAN_ID,-99) <> nvl(l_old_ServiceRequest_rec.QA_COLLECTION_ID,-99)) THEN
    x_audit_vals_rec.QA_COLLECTION_ID		:= l_service_request_rec.QA_COLLECTION_PLAN_ID;
  ELSE
    x_audit_vals_rec.QA_COLLECTION_ID		:= l_old_ServiceRequest_rec.QA_COLLECTION_ID;
  END IF;

  x_audit_vals_rec.OLD_CONTRACT_ID		:= l_old_ServiceRequest_rec.CONTRACT_ID;
  IF (nvl(l_service_request_rec.CONTRACT_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CONTRACT_ID,-99) <> nvl(l_old_ServiceRequest_rec.CONTRACT_ID,-99)) THEN
    x_audit_vals_rec.CONTRACT_ID		:= l_service_request_rec.CONTRACT_ID;
  ELSE
    x_audit_vals_rec.CONTRACT_ID		:= l_old_ServiceRequest_rec.CONTRACT_ID;
  END IF;

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (nvl(l_service_request_rec.,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec. ,-99)) THEN
    x_audit_vals_rec.CONTRACT_NUMBER		:= l_service_request_rec.;
  END IF;
  */

  x_audit_vals_rec.OLD_CONTRACT_SERVICE_ID	:= l_old_ServiceRequest_rec.CONTRACT_SERVICE_ID;
  IF (nvl(l_service_request_rec.CONTRACT_SERVICE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CONTRACT_SERVICE_ID,-99) <> nvl(l_old_ServiceRequest_rec.CONTRACT_SERVICE_ID,-99)) THEN
    x_audit_vals_rec.CONTRACT_SERVICE_ID	:= l_service_request_rec.CONTRACT_SERVICE_ID;
  ELSE
    x_audit_vals_rec.CONTRACT_SERVICE_ID	:= l_old_ServiceRequest_rec.CONTRACT_SERVICE_ID;
  END IF;

  x_audit_vals_rec.OLD_TIME_ZONE_ID		:= l_old_ServiceRequest_rec.TIME_ZONE_ID;
  IF (nvl(l_service_request_rec.TIME_ZONE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.TIME_ZONE_ID,-99) <> nvl(l_old_ServiceRequest_rec.TIME_ZONE_ID,-99)) THEN
    x_audit_vals_rec.TIME_ZONE_ID		:= l_service_request_rec.TIME_ZONE_ID;
  ELSE
    x_audit_vals_rec.TIME_ZONE_ID		:= l_old_ServiceRequest_rec.TIME_ZONE_ID;
  END IF;

  x_audit_vals_rec.OLD_ACCOUNT_ID		:= l_old_ServiceRequest_rec.ACCOUNT_ID;
  IF (nvl(l_service_request_rec.ACCOUNT_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.ACCOUNT_ID,-99) <> nvl(l_old_ServiceRequest_rec.ACCOUNT_ID,-99)) THEN
    x_audit_vals_rec.ACCOUNT_ID			:= l_service_request_rec.ACCOUNT_ID;
  ELSE
    x_audit_vals_rec.ACCOUNT_ID			:= l_old_ServiceRequest_rec.ACCOUNT_ID;
  END IF;

  x_audit_vals_rec.OLD_TIME_DIFFERENCE		:= l_old_ServiceRequest_rec.TIME_DIFFERENCE;
  IF (nvl(l_service_request_rec.TIME_DIFFERENCE,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.TIME_DIFFERENCE,-99) <> nvl(l_old_ServiceRequest_rec.TIME_DIFFERENCE,-99)) THEN
    x_audit_vals_rec.TIME_DIFFERENCE		:= l_service_request_rec.TIME_DIFFERENCE;
  ELSE
    x_audit_vals_rec.TIME_DIFFERENCE		:= l_old_ServiceRequest_rec.TIME_DIFFERENCE;
  END IF;

  x_audit_vals_rec.OLD_CUSTOMER_PO_NUMBER	:= l_old_ServiceRequest_rec.CUSTOMER_PO_NUMBER;
  IF (nvl(l_service_request_rec.CUST_PO_NUMBER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.CUST_PO_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.CUSTOMER_PO_NUMBER,-99)) THEN
    x_audit_vals_rec.CUSTOMER_PO_NUMBER		:= l_service_request_rec.CUST_PO_NUMBER;
  ELSE
    x_audit_vals_rec.CUSTOMER_PO_NUMBER		:= l_old_ServiceRequest_rec.CUSTOMER_PO_NUMBER;
  END IF;

  x_audit_vals_rec.OLD_CUSTOMER_TICKET_NUMBER	:= l_old_ServiceRequest_rec.CUSTOMER_TICKET_NUMBER;
  IF (nvl(l_service_request_rec.CUST_TICKET_NUMBER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.CUST_TICKET_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.CUSTOMER_TICKET_NUMBER,-99)) THEN
    x_audit_vals_rec.CUSTOMER_TICKET_NUMBER	:= l_service_request_rec.CUST_TICKET_NUMBER;
  ELSE
    x_audit_vals_rec.CUSTOMER_TICKET_NUMBER	:= l_old_ServiceRequest_rec.CUSTOMER_TICKET_NUMBER;
  END IF;

  x_audit_vals_rec.OLD_CUSTOMER_SITE_ID		:= l_old_ServiceRequest_rec.CUSTOMER_SITE_ID;
  IF (nvl(l_service_request_rec.CUSTOMER_SITE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CUSTOMER_SITE_ID,-99) <> nvl(l_old_ServiceRequest_rec.CUSTOMER_SITE_ID,-99)) THEN
    x_audit_vals_rec.CUSTOMER_SITE_ID		:= l_service_request_rec.CUSTOMER_SITE_ID;
  ELSE
    x_audit_vals_rec.CUSTOMER_SITE_ID		:= l_old_ServiceRequest_rec.CUSTOMER_SITE_ID;
  END IF;

  x_audit_vals_rec.OLD_CALLER_TYPE		:= l_old_ServiceRequest_rec.CALLER_TYPE;
  IF (nvl(l_service_request_rec.CALLER_TYPE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.CALLER_TYPE,-99) <> nvl(l_old_ServiceRequest_rec.CALLER_TYPE,-99)) THEN
    x_audit_vals_rec.CALLER_TYPE		:= l_service_request_rec.CALLER_TYPE;
  ELSE
    x_audit_vals_rec.CALLER_TYPE		:= l_old_ServiceRequest_rec.CALLER_TYPE;
  END IF;

  x_audit_vals_rec.OLD_PROJECT_NUMBER		:= l_old_ServiceRequest_rec.PROJECT_NUMBER;
  IF (nvl(l_service_request_rec.PROJECT_NUMBER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.PROJECT_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.PROJECT_NUMBER,-99)) THEN
    x_audit_vals_rec.PROJECT_NUMBER		:= l_service_request_rec.PROJECT_NUMBER;
  ELSE
    x_audit_vals_rec.PROJECT_NUMBER		:= l_old_ServiceRequest_rec.PROJECT_NUMBER;
  END IF;

  x_audit_vals_rec.OLD_PLATFORM_VERSION		:= l_old_ServiceRequest_rec.PLATFORM_VERSION;
  IF (nvl(l_service_request_rec.PLATFORM_VERSION,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.PLATFORM_VERSION,-99) <> nvl(l_old_ServiceRequest_rec.PLATFORM_VERSION,-99)) THEN
    x_audit_vals_rec.PLATFORM_VERSION		:= l_service_request_rec.PLATFORM_VERSION;
  ELSE
    x_audit_vals_rec.PLATFORM_VERSION		:= l_old_ServiceRequest_rec.PLATFORM_VERSION;
  END IF;

  x_audit_vals_rec.OLD_PLATFORM_VERSION_ID      := l_old_ServiceRequest_rec.PLATFORM_VERSION_ID;
  IF (nvl(l_service_request_rec.PLATFORM_VERSION_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.PLATFORM_VERSION_ID,-99) <> nvl(l_old_ServiceRequest_rec.PLATFORM_VERSION_ID,-99)) THEN
    x_audit_vals_rec.PLATFORM_VERSION_ID           := l_service_request_rec.PLATFORM_VERSION_ID;
  ELSE
    x_audit_vals_rec.PLATFORM_VERSION_ID           := l_old_ServiceRequest_rec.PLATFORM_VERSION_ID;
  END IF;

  x_audit_vals_rec.OLD_inv_platform_org_id      := l_old_ServiceRequest_rec.inv_platform_org_id;
  IF (nvl(l_service_request_rec.inv_platform_org_id,-99) <> FND_API.G_MISS_NUM) AND
      nvl(l_service_request_rec.inv_platform_org_id,-99) <> nvl(l_old_ServiceRequest_rec.inv_platform_org_id,-99)
     THEN
     x_audit_vals_rec.inv_platform_org_id          := l_service_request_rec.inv_platform_org_id;
  ELSE
     x_audit_vals_rec.inv_platform_org_id          := l_old_ServiceRequest_rec.inv_platform_org_id;
  END IF;

  x_audit_vals_rec.OLD_DB_VERSION		:= l_old_ServiceRequest_rec.DB_VERSION;
  IF (nvl(l_service_request_rec.DB_VERSION,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.DB_VERSION,-99) <> nvl(l_old_ServiceRequest_rec.DB_VERSION,-99)) THEN
    x_audit_vals_rec.DB_VERSION			:= l_service_request_rec.DB_VERSION;
  ELSE
    x_audit_vals_rec.DB_VERSION			:= l_old_ServiceRequest_rec.DB_VERSION;
  END IF;

  x_audit_vals_rec.OLD_CUST_PREF_LANG_ID	:= l_old_ServiceRequest_rec.CUST_PREF_LANG_ID;
  IF (nvl(l_service_request_rec.CUST_PREF_LANG_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CUST_PREF_LANG_ID,-99) <> nvl(l_old_ServiceRequest_rec.CUST_PREF_LANG_ID,-99)) THEN
    x_audit_vals_rec.CUST_PREF_LANG_ID		:= l_service_request_rec.CUST_PREF_LANG_ID;
  ELSE
    x_audit_vals_rec.CUST_PREF_LANG_ID		:= l_old_ServiceRequest_rec.CUST_PREF_LANG_ID;
  END IF;

  x_audit_vals_rec.OLD_TIER			:= l_old_ServiceRequest_rec.TIER;
  IF (nvl(l_service_request_rec.TIER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.TIER,-99) <> nvl(l_old_ServiceRequest_rec.TIER,-99)) THEN
    x_audit_vals_rec.TIER			:= l_service_request_rec.TIER;
  ELSE
    x_audit_vals_rec.TIER			:= l_old_ServiceRequest_rec.TIER;
  END IF;

  x_audit_vals_rec.OLD_CATEGORY_ID		:= l_old_ServiceRequest_rec.CATEGORY_ID;
  IF (nvl(l_service_request_rec.CATEGORY_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CATEGORY_ID,-99) <> nvl(l_old_ServiceRequest_rec.CATEGORY_ID,-99)) THEN
    x_audit_vals_rec.CATEGORY_ID		:= l_service_request_rec.CATEGORY_ID;
  ELSE
    x_audit_vals_rec.CATEGORY_ID		:= l_old_ServiceRequest_rec.CATEGORY_ID;
  END IF;

  x_audit_vals_rec.OLD_OPERATING_SYSTEM		:= l_old_ServiceRequest_rec.OPERATING_SYSTEM;
  IF (nvl(l_service_request_rec.OPERATING_SYSTEM,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.OPERATING_SYSTEM,-99) <> nvl(l_old_ServiceRequest_rec.OPERATING_SYSTEM,-99)) THEN
    x_audit_vals_rec.OPERATING_SYSTEM		:= l_service_request_rec.OPERATING_SYSTEM;
  ELSE
    x_audit_vals_rec.OPERATING_SYSTEM		:= l_old_ServiceRequest_rec.OPERATING_SYSTEM;
  END IF;

  x_audit_vals_rec.OLD_OPERATING_SYSTEM_VERSION	:= l_old_ServiceRequest_rec.OPERATING_SYSTEM_VERSION;
  IF (nvl(l_service_request_rec.OPERATING_SYSTEM_VERSION,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.OPERATING_SYSTEM_VERSION,-99) <> nvl(l_old_ServiceRequest_rec.OPERATING_SYSTEM_VERSION,-99)) THEN
    x_audit_vals_rec.OPERATING_SYSTEM_VERSION	:= l_service_request_rec.OPERATING_SYSTEM_VERSION;
  ELSE
    x_audit_vals_rec.OPERATING_SYSTEM_VERSION	:= l_old_ServiceRequest_rec.OPERATING_SYSTEM_VERSION;
  END IF;


  x_audit_vals_rec.OLD_DATABASE			:= l_old_ServiceRequest_rec.DATABASE;
  IF (nvl(l_service_request_rec.DATABASE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.DATABASE,-99) <> nvl(l_old_ServiceRequest_rec.DATABASE,-99)) THEN
    x_audit_vals_rec.DATABASE			:= l_service_request_rec.DATABASE;
  ELSE
    x_audit_vals_rec.DATABASE			:= l_old_ServiceRequest_rec.DATABASE;
  END IF;

  x_audit_vals_rec.OLD_GROUP_TERRITORY_ID	:= l_old_ServiceRequest_rec.GROUP_TERRITORY_ID;
  IF (nvl(l_service_request_rec.GROUP_TERRITORY_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.GROUP_TERRITORY_ID,-99) <> nvl(l_old_ServiceRequest_rec.GROUP_TERRITORY_ID,-99)) THEN
    x_audit_vals_rec.GROUP_TERRITORY_ID		:= l_service_request_rec.GROUP_TERRITORY_ID;
  ELSE
    x_audit_vals_rec.GROUP_TERRITORY_ID		:= l_old_ServiceRequest_rec.GROUP_TERRITORY_ID;
  END IF;
    IF (l_service_request_rec.territory_id = FND_API.G_MISS_NUM) OR
       (nvl(l_service_request_rec.territory_id,-99) = nvl(l_old_ServiceRequest_rec.territory_id,-99)) THEN
      x_audit_vals_rec.change_territory_id_flag := 'N';
      x_audit_vals_rec.old_territory_id         := l_old_ServiceRequest_rec.territory_id;
      x_audit_vals_rec.territory_id             := l_old_ServiceRequest_rec.territory_id;
    ELSE
      x_audit_vals_rec.change_territory_id_FLAG := 'Y';
      x_audit_vals_rec.OLD_territory_id := l_old_ServiceRequest_rec.territory_id;
      x_audit_vals_rec.territory_id := l_service_request_rec.territory_id;
    END IF;

  x_audit_vals_rec.OLD_COMM_PREF_CODE	:= l_old_ServiceRequest_rec.COMM_PREF_CODE;
  IF (nvl(l_service_request_rec.COMM_PREF_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.COMM_PREF_CODE,-99) <> nvl(l_old_ServiceRequest_rec.COMM_PREF_CODE,-99)) THEN
    x_audit_vals_rec.COMM_PREF_CODE		:= l_service_request_rec.COMM_PREF_CODE;
  ELSE
    x_audit_vals_rec.COMM_PREF_CODE		:= l_old_ServiceRequest_rec.COMM_PREF_CODE;
  END IF;

  x_audit_vals_rec.OLD_LAST_UPDATE_CHANNEL	:= l_old_ServiceRequest_rec.LAST_UPDATE_CHANNEL;
  IF (nvl(l_service_request_rec.LAST_UPDATE_CHANNEL,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.LAST_UPDATE_CHANNEL,-99) <> nvl(l_old_ServiceRequest_rec.LAST_UPDATE_CHANNEL,-99)) THEN
    x_audit_vals_rec.LAST_UPDATE_CHANNEL	:= l_service_request_rec.LAST_UPDATE_CHANNEL;
  ELSE
    x_audit_vals_rec.LAST_UPDATE_CHANNEL	:= l_old_ServiceRequest_rec.LAST_UPDATE_CHANNEL;
  END IF;

  x_audit_vals_rec.OLD_CUST_PREF_LANG_CODE	:= l_old_ServiceRequest_rec.CUST_PREF_LANG_CODE;
  IF (nvl(l_service_request_rec.CUST_PREF_LANG_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.CUST_PREF_LANG_CODE,-99) <> nvl(l_old_ServiceRequest_rec.CUST_PREF_LANG_CODE,-99)) THEN
    x_audit_vals_rec.CUST_PREF_LANG_CODE	:= l_service_request_rec.CUST_PREF_LANG_CODE;
  ELSE
    x_audit_vals_rec.CUST_PREF_LANG_CODE	:= l_old_ServiceRequest_rec.CUST_PREF_LANG_CODE;
  END IF;

  x_audit_vals_rec.OLD_ERROR_CODE		:= l_old_ServiceRequest_rec.ERROR_CODE;
  IF (nvl(l_service_request_rec.ERROR_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.ERROR_CODE,-99) <> nvl(l_old_ServiceRequest_rec.ERROR_CODE,-99)) THEN
    x_audit_vals_rec.ERROR_CODE			:= l_service_request_rec.ERROR_CODE;
  ELSE
    x_audit_vals_rec.ERROR_CODE			:= l_old_ServiceRequest_rec.ERROR_CODE;
  END IF;

  x_audit_vals_rec.OLD_CATEGORY_SET_ID		:= l_old_ServiceRequest_rec.CATEGORY_SET_ID;
  IF (nvl(l_service_request_rec.CATEGORY_SET_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CATEGORY_SET_ID,-99) <> nvl(l_old_ServiceRequest_rec.CATEGORY_SET_ID,-99)) THEN
    x_audit_vals_rec.CATEGORY_SET_ID		:= l_service_request_rec.CATEGORY_SET_ID;
  ELSE
    x_audit_vals_rec.CATEGORY_SET_ID		:= l_old_ServiceRequest_rec.CATEGORY_SET_ID;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_REFERENCE	:= l_old_ServiceRequest_rec.EXTERNAL_REFERENCE;
  IF (nvl(l_service_request_rec.EXTERNAL_REFERENCE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_REFERENCE,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_REFERENCE,-99)) THEN
    x_audit_vals_rec.EXTERNAL_REFERENCE		:= l_service_request_rec.EXTERNAL_REFERENCE;
  ELSE
    x_audit_vals_rec.EXTERNAL_REFERENCE		:= l_old_ServiceRequest_rec.EXTERNAL_REFERENCE;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_OCCURRED_DATE	:= l_old_ServiceRequest_rec.INCIDENT_OCCURRED_DATE;
  IF (nvl(l_service_request_rec.INCIDENT_OCCURRED_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <> FND_API.G_MISS_DATE) AND
    (nvl(l_service_request_rec.INCIDENT_OCCURRED_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <>
        nvl(l_old_ServiceRequest_rec.INCIDENT_OCCURRED_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY'))) THEN
    x_audit_vals_rec.INCIDENT_OCCURRED_DATE	:= l_service_request_rec.INCIDENT_OCCURRED_DATE;
  ELSE
    x_audit_vals_rec.INCIDENT_OCCURRED_DATE	:= l_old_ServiceRequest_rec.INCIDENT_OCCURRED_DATE;
  END IF;

 /*Bug 3666722 smisra. incident resolved date and incident responded by date could set
   if incident status has responded and/or resolved flag set to Y. so copy to audit should
   done after these dates are set depending on new status.
   moved this code after call to update_sr_validation procedure.
 */
 --x_audit_vals_rec.OLD_INCIDENT_RESOLVED_DATE	:= l_old_ServiceRequest_rec.INCIDENT_RESOLVED_DATE;
 --IF (nvl(l_service_request_rec.INCIDENT_RESOLVED_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <> FND_API.G_MISS_DATE) AND
 --  (nvl(l_service_request_rec.INCIDENT_RESOLVED_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <>
 --      nvl(l_old_ServiceRequest_rec.INCIDENT_RESOLVED_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY'))) THEN
 --  x_audit_vals_rec.INCIDENT_RESOLVED_DATE	:= l_service_request_rec.INCIDENT_RESOLVED_DATE;
 --ELSE
 --  x_audit_vals_rec.INCIDENT_RESOLVED_DATE	:= l_old_ServiceRequest_rec.INCIDENT_RESOLVED_DATE;
 --END IF;
 --
 --x_audit_vals_rec.OLD_INC_RESPONDED_BY_DATE	:= l_old_ServiceRequest_rec.INC_RESPONDED_BY_DATE;
 --IF (nvl(l_service_request_rec.INC_RESPONDED_BY_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <> FND_API.G_MISS_DATE) AND
 --  (nvl(l_service_request_rec.INC_RESPONDED_BY_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <>
 --      nvl(l_old_ServiceRequest_rec.INC_RESPONDED_BY_DATE,TO_DATE('09-09-0999', 'DD-MM-YYYY'))) THEN
 --  x_audit_vals_rec.INC_RESPONDED_BY_DATE	:= l_service_request_rec.INC_RESPONDED_BY_DATE;
 --ELSE
 --  x_audit_vals_rec.INC_RESPONDED_BY_DATE	:= l_old_ServiceRequest_rec.INC_RESPONDED_BY_DATE;
 --END IF;

  /* 12/13/05 smisra moved to update_service_request procedure just before call to
     create audit record
  x_audit_vals_rec.OLD_INCIDENT_LOCATION_ID	:= l_old_ServiceRequest_rec.INCIDENT_LOCATION_ID;
  IF (nvl(l_service_request_rec.INCIDENT_LOCATION_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.INCIDENT_LOCATION_ID,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_LOCATION_ID,-99)) THEN
    x_audit_vals_rec.INCIDENT_LOCATION_ID	:= l_service_request_rec.INCIDENT_LOCATION_ID;
  ELSE
    x_audit_vals_rec.INCIDENT_LOCATION_ID	:= l_old_ServiceRequest_rec.INCIDENT_LOCATION_ID;
  END IF;
  */

  x_audit_vals_rec.OLD_INCIDENT_ADDRESS		:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS;
  IF (nvl(l_service_request_rec.INCIDENT_ADDRESS,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_ADDRESS,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ADDRESS,-99)) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS		:= l_service_request_rec.INCIDENT_ADDRESS;
  ELSE
    x_audit_vals_rec.INCIDENT_ADDRESS		:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_CITY		:= l_old_ServiceRequest_rec.INCIDENT_CITY;
  IF (nvl(l_service_request_rec.INCIDENT_CITY,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_CITY,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_CITY,-99)) THEN
    x_audit_vals_rec.INCIDENT_CITY		:= l_service_request_rec.INCIDENT_CITY;
  ELSE
    x_audit_vals_rec.INCIDENT_CITY		:= l_old_ServiceRequest_rec.INCIDENT_CITY;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_STATE		:= l_old_ServiceRequest_rec.INCIDENT_STATE;
  IF (nvl(l_service_request_rec.INCIDENT_STATE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_STATE,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_STATE,-99)) THEN
    x_audit_vals_rec.INCIDENT_STATE		:= l_service_request_rec.INCIDENT_STATE;
  ELSE
    x_audit_vals_rec.INCIDENT_STATE		:= l_old_ServiceRequest_rec.INCIDENT_STATE;
  END IF;

  /* 12/13/05 smisra moved to update_service_request procedure just before call to
     create audit record
  x_audit_vals_rec.OLD_INCIDENT_COUNTRY		:= l_old_ServiceRequest_rec.INCIDENT_COUNTRY;
  IF (nvl(l_service_request_rec.INCIDENT_COUNTRY,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_COUNTRY,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_COUNTRY,-99)) THEN
    x_audit_vals_rec.INCIDENT_COUNTRY		:= l_service_request_rec.INCIDENT_COUNTRY;
  ELSE
    x_audit_vals_rec.INCIDENT_COUNTRY		:= l_old_ServiceRequest_rec.INCIDENT_COUNTRY;
  END IF;
  */

  x_audit_vals_rec.OLD_INCIDENT_PROVINCE	:= l_old_ServiceRequest_rec.INCIDENT_PROVINCE;
  IF (nvl(l_service_request_rec.INCIDENT_PROVINCE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_PROVINCE,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_PROVINCE,-99)) THEN
    x_audit_vals_rec.INCIDENT_PROVINCE		:= l_service_request_rec.INCIDENT_PROVINCE;
  ELSE
    x_audit_vals_rec.INCIDENT_PROVINCE		:= l_old_ServiceRequest_rec.INCIDENT_PROVINCE;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_POSTAL_CODE	:= l_old_ServiceRequest_rec.INCIDENT_POSTAL_CODE;
  IF (nvl(l_service_request_rec.INCIDENT_POSTAL_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_POSTAL_CODE,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_POSTAL_CODE,-99)) THEN
    x_audit_vals_rec.INCIDENT_POSTAL_CODE	:= l_service_request_rec.INCIDENT_POSTAL_CODE;
  ELSE
    x_audit_vals_rec.INCIDENT_POSTAL_CODE	:= l_old_ServiceRequest_rec.INCIDENT_POSTAL_CODE;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_COUNTY		:= l_old_ServiceRequest_rec.INCIDENT_COUNTY;
  IF (nvl(l_service_request_rec.INCIDENT_COUNTY,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_COUNTY,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_COUNTY,-99)) THEN
    x_audit_vals_rec.INCIDENT_COUNTY		:= l_service_request_rec.INCIDENT_COUNTY;
  ELSE
    x_audit_vals_rec.INCIDENT_COUNTY		:= l_old_ServiceRequest_rec.INCIDENT_COUNTY;
  END IF;

  x_audit_vals_rec.OLD_SR_CREATION_CHANNEL	:= l_old_ServiceRequest_rec.SR_CREATION_CHANNEL;
  IF (nvl(l_service_request_rec.SR_CREATION_CHANNEL,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.SR_CREATION_CHANNEL,-99) <> nvl(l_old_ServiceRequest_rec.SR_CREATION_CHANNEL,-99)) THEN
    x_audit_vals_rec.SR_CREATION_CHANNEL	:= l_service_request_rec.SR_CREATION_CHANNEL;
  ELSE
    x_audit_vals_rec.SR_CREATION_CHANNEL	:= l_old_ServiceRequest_rec.SR_CREATION_CHANNEL;
  END IF;

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (nvl(l_service_request_rec.,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec. ,-99)) THEN
    x_audit_vals_rec.DEF_DEFECT_ID		:= l_service_request_rec.;
  END IF;
  */

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (nvl(l_service_request_rec.,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec. ,-99)) THEN
    x_audit_vals_rec.DEF_DEFECT_ID2		:= l_service_request_rec.;
  END IF;
  */

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_1;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_1,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_1,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_1,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_1	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_1	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_1;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_2	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_2;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_2,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_2,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_2,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_2	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_2;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_2	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_2;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_3	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_3;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_3,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_3,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_3,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_3	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_3;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_3	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_3;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_4	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_4;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_4,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_4,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_4,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_4	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_4;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_4	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_4;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_5	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_5;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_5,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_5,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_5,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_5	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_5;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_5	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_5;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_6	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_6;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_6,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_6,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_6,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_6	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_6;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_6	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_6;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_7	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_7;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_7,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_7,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_7,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_7	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_7;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_7	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_7;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_8	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_8;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_8,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_8,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_8,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_8	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_8;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_8	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_8;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_9	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_9;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_9,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_9,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_9,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_9	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_9;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_9	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_9;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_10	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_10;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_10,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_10,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_10,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_10	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_10;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_10	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_10;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_11	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_11;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_11,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_11,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_11,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_11	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_11;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_11	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_11;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_12	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_12;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_12,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_12,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_12,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_12	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_12;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_12	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_12;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_13	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_13;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_13,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_13,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_13,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_13	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_13;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_13	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_13;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_14	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_14;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_14,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_14,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_14,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_14	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_14;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_14	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_14;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_15	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_15;
  IF (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_15,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_ATTRIBUTE_15,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_15,-99)) THEN
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_15	:= l_service_request_rec.EXTERNAL_ATTRIBUTE_15;
  ELSE
    x_audit_vals_rec.EXTERNAL_ATTRIBUTE_15	:= l_old_ServiceRequest_rec.EXTERNAL_ATTRIBUTE_15;
  END IF;

  x_audit_vals_rec.OLD_EXTERNAL_CONTEXT		:= l_old_ServiceRequest_rec.EXTERNAL_CONTEXT;
  IF (nvl(l_service_request_rec.EXTERNAL_CONTEXT,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.EXTERNAL_CONTEXT,-99) <> nvl(l_old_ServiceRequest_rec.EXTERNAL_CONTEXT,-99)) THEN
    x_audit_vals_rec.EXTERNAL_CONTEXT		:= l_service_request_rec.EXTERNAL_CONTEXT;
  ELSE
    x_audit_vals_rec.EXTERNAL_CONTEXT		:= l_old_ServiceRequest_rec.EXTERNAL_CONTEXT;
  END IF;

  x_audit_vals_rec.OLD_LAST_UPDATE_PROGRAM_CODE	:= l_old_ServiceRequest_rec.LAST_UPDATE_PROGRAM_CODE;
  IF (nvl(l_service_request_rec.LAST_UPDATE_PROGRAM_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.LAST_UPDATE_PROGRAM_CODE,-99) <> nvl(l_old_ServiceRequest_rec.LAST_UPDATE_PROGRAM_CODE,-99)) THEN
    x_audit_vals_rec.LAST_UPDATE_PROGRAM_CODE	:= l_service_request_rec.LAST_UPDATE_PROGRAM_CODE;
  ELSE
    x_audit_vals_rec.LAST_UPDATE_PROGRAM_CODE	:= l_old_ServiceRequest_rec.LAST_UPDATE_PROGRAM_CODE;
  END IF;

  x_audit_vals_rec.OLD_CREATION_PROGRAM_CODE := l_old_ServiceRequest_rec.CREATION_PROGRAM_CODE;
  IF (nvl(l_service_request_rec.CREATION_PROGRAM_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.CREATION_PROGRAM_CODE,-99) <> nvl(l_old_ServiceRequest_rec.CREATION_PROGRAM_CODE,-99)) THEN
    x_audit_vals_rec.CREATION_PROGRAM_CODE	:= l_service_request_rec.CREATION_PROGRAM_CODE;
  ELSE
    x_audit_vals_rec.CREATION_PROGRAM_CODE	:= l_old_ServiceRequest_rec.CREATION_PROGRAM_CODE;
  END IF;

  x_audit_vals_rec.OLD_COVERAGE_TYPE		:= l_old_ServiceRequest_rec.COVERAGE_TYPE;
  IF (nvl(l_service_request_rec.COVERAGE_TYPE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.COVERAGE_TYPE,-99) <> nvl(l_old_ServiceRequest_rec.COVERAGE_TYPE,-99)) THEN
    x_audit_vals_rec.COVERAGE_TYPE		:= l_service_request_rec.COVERAGE_TYPE;
  ELSE
    x_audit_vals_rec.COVERAGE_TYPE		:= l_old_ServiceRequest_rec.COVERAGE_TYPE;
  END IF;

  x_audit_vals_rec.OLD_BILL_TO_ACCOUNT_ID	:= l_old_ServiceRequest_rec.BILL_TO_ACCOUNT_ID;
  IF (nvl(l_service_request_rec.BILL_TO_ACCOUNT_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.BILL_TO_ACCOUNT_ID,-99) <> nvl(l_old_ServiceRequest_rec.BILL_TO_ACCOUNT_ID,-99)) THEN
    x_audit_vals_rec.BILL_TO_ACCOUNT_ID		:= l_service_request_rec.BILL_TO_ACCOUNT_ID;
  ELSE
    x_audit_vals_rec.BILL_TO_ACCOUNT_ID		:= l_old_ServiceRequest_rec.BILL_TO_ACCOUNT_ID;
  END IF;

  x_audit_vals_rec.OLD_SHIP_TO_ACCOUNT_ID	:= l_old_ServiceRequest_rec.SHIP_TO_ACCOUNT_ID;
  IF (nvl(l_service_request_rec.SHIP_TO_ACCOUNT_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.SHIP_TO_ACCOUNT_ID,-99) <> nvl(l_old_ServiceRequest_rec.SHIP_TO_ACCOUNT_ID,-99)) THEN
    x_audit_vals_rec.SHIP_TO_ACCOUNT_ID		:= l_service_request_rec.SHIP_TO_ACCOUNT_ID;
  ELSE
    x_audit_vals_rec.SHIP_TO_ACCOUNT_ID		:= l_old_ServiceRequest_rec.SHIP_TO_ACCOUNT_ID;
  END IF;

  x_audit_vals_rec.OLD_CUSTOMER_EMAIL_ID	:= l_old_ServiceRequest_rec.CUSTOMER_EMAIL_ID;
  IF (nvl(l_service_request_rec.CUSTOMER_EMAIL_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CUSTOMER_EMAIL_ID,-99) <> nvl(l_old_ServiceRequest_rec.CUSTOMER_EMAIL_ID,-99)) THEN
    x_audit_vals_rec.CUSTOMER_EMAIL_ID		:= l_service_request_rec.CUSTOMER_EMAIL_ID;
  ELSE
    x_audit_vals_rec.CUSTOMER_EMAIL_ID		:= l_old_ServiceRequest_rec.CUSTOMER_EMAIL_ID;
  END IF;

  x_audit_vals_rec.OLD_CUSTOMER_PHONE_ID	:= l_old_ServiceRequest_rec.CUSTOMER_PHONE_ID;
  IF (nvl(l_service_request_rec.CUSTOMER_PHONE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.CUSTOMER_PHONE_ID,-99) <> nvl(l_old_ServiceRequest_rec.CUSTOMER_PHONE_ID,-99)) THEN
    x_audit_vals_rec.CUSTOMER_PHONE_ID		:= l_service_request_rec.CUSTOMER_PHONE_ID;
  ELSE
    x_audit_vals_rec.CUSTOMER_PHONE_ID		:= l_old_ServiceRequest_rec.CUSTOMER_PHONE_ID;
  END IF;

  x_audit_vals_rec.OLD_BILL_TO_PARTY_ID		:= l_old_ServiceRequest_rec.BILL_TO_PARTY_ID;
  IF (nvl(l_service_request_rec.BILL_TO_PARTY_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.BILL_TO_PARTY_ID,-99) <> nvl(l_old_ServiceRequest_rec.BILL_TO_PARTY_ID,-99)) THEN
    x_audit_vals_rec.BILL_TO_PARTY_ID		:= l_service_request_rec.BILL_TO_PARTY_ID;
  ELSE
    x_audit_vals_rec.BILL_TO_PARTY_ID		:= l_old_ServiceRequest_rec.BILL_TO_PARTY_ID;
  END IF;

  x_audit_vals_rec.OLD_SHIP_TO_PARTY_ID		:= l_old_ServiceRequest_rec.SHIP_TO_PARTY_ID;
  IF (nvl(l_service_request_rec.SHIP_TO_PARTY_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.SHIP_TO_PARTY_ID,-99) <> nvl(l_old_ServiceRequest_rec.SHIP_TO_PARTY_ID,-99)) THEN
    x_audit_vals_rec.SHIP_TO_PARTY_ID		:= l_service_request_rec.SHIP_TO_PARTY_ID;
  ELSE
    x_audit_vals_rec.SHIP_TO_PARTY_ID		:= l_old_ServiceRequest_rec.SHIP_TO_PARTY_ID;
  END IF;

  x_audit_vals_rec.OLD_BILL_TO_SITE_ID		:= l_old_ServiceRequest_rec.BILL_TO_SITE_ID;
  IF (nvl(l_service_request_rec.BILL_TO_SITE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.BILL_TO_SITE_ID,-99) <> nvl(l_old_ServiceRequest_rec.BILL_TO_SITE_ID,-99)) THEN
    x_audit_vals_rec.BILL_TO_SITE_ID		:= l_service_request_rec.BILL_TO_SITE_ID;
  ELSE
    x_audit_vals_rec.BILL_TO_SITE_ID		:= l_old_ServiceRequest_rec.BILL_TO_SITE_ID;
  END IF;

  x_audit_vals_rec.OLD_SHIP_TO_SITE_ID		:= l_old_ServiceRequest_rec.SHIP_TO_SITE_ID;
  IF (nvl(l_service_request_rec.SHIP_TO_SITE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.SHIP_TO_SITE_ID,-99) <> nvl(l_old_ServiceRequest_rec.SHIP_TO_SITE_ID,-99)) THEN
    x_audit_vals_rec.SHIP_TO_SITE_ID		:= l_service_request_rec.SHIP_TO_SITE_ID;
  ELSE
    x_audit_vals_rec.SHIP_TO_SITE_ID		:= l_old_ServiceRequest_rec.SHIP_TO_SITE_ID;
  END IF;

  x_audit_vals_rec.OLD_PROGRAM_LOGIN_ID		:= l_old_ServiceRequest_rec.PROGRAM_LOGIN_ID;
  IF (nvl(l_service_request_rec.PROGRAM_LOGIN_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.PROGRAM_LOGIN_ID,-99) <> nvl(l_old_ServiceRequest_rec.PROGRAM_LOGIN_ID,-99)) THEN
    x_audit_vals_rec.PROGRAM_LOGIN_ID		:= l_service_request_rec.PROGRAM_LOGIN_ID;
  ELSE
    x_audit_vals_rec.PROGRAM_LOGIN_ID		:= l_old_ServiceRequest_rec.PROGRAM_LOGIN_ID;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_POINT_OF_INTEREST := l_old_ServiceRequest_rec.INCIDENT_POINT_OF_INTEREST;
  IF (nvl(l_service_request_rec.INCIDENT_POINT_OF_INTEREST,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_POINT_OF_INTEREST,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_POINT_OF_INTEREST,-99)) THEN
    x_audit_vals_rec.INCIDENT_POINT_OF_INTEREST	:= l_service_request_rec.INCIDENT_POINT_OF_INTEREST;
  ELSE
    x_audit_vals_rec.INCIDENT_POINT_OF_INTEREST	:= l_old_ServiceRequest_rec.INCIDENT_POINT_OF_INTEREST;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_CROSS_STREET	 := l_old_ServiceRequest_rec.INCIDENT_CROSS_STREET;
  IF (nvl(l_service_request_rec.INCIDENT_CROSS_STREET,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_CROSS_STREET,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_CROSS_STREET,-99)) THEN
    x_audit_vals_rec.INCIDENT_CROSS_STREET	:= l_service_request_rec.INCIDENT_CROSS_STREET;
  ELSE
    x_audit_vals_rec.INCIDENT_CROSS_STREET	:= l_old_ServiceRequest_rec.INCIDENT_CROSS_STREET;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_DIRECTION_QUALIF := l_old_ServiceRequest_rec.INCIDENT_DIRECTION_QUALIFIER;
  IF (nvl(l_service_request_rec.incident_direction_qualifier,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.incident_direction_qualifier,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_DIRECTION_QUALIFIER,-99)) THEN
    x_audit_vals_rec.INCIDENT_DIRECTION_QUALIF	:= l_service_request_rec.incident_direction_qualifier;
  ELSE
    x_audit_vals_rec.INCIDENT_DIRECTION_QUALIF	:= l_old_ServiceRequest_rec.INCIDENT_DIRECTION_QUALIFIER;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_DISTANCE_QUALIF	:= l_old_ServiceRequest_rec.INCIDENT_DISTANCE_QUALIFIER;
  IF (nvl(l_service_request_rec.incident_distance_qualifier,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.incident_distance_qualifier,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_DISTANCE_QUALIFIER,-99)) THEN
    x_audit_vals_rec.INCIDENT_DISTANCE_QUALIF	:= l_service_request_rec.incident_distance_qualifier;
  ELSE
    x_audit_vals_rec.INCIDENT_DISTANCE_QUALIF	:= l_old_ServiceRequest_rec.INCIDENT_DISTANCE_QUALIFIER;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_DISTANCE_QUAL_UOM := l_old_ServiceRequest_rec.INCIDENT_DISTANCE_QUAL_UOM;
  IF (nvl(l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_DISTANCE_QUAL_UOM,-99)) THEN
    x_audit_vals_rec.INCIDENT_DISTANCE_QUAL_UOM	:= l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM;
  ELSE
    x_audit_vals_rec.INCIDENT_DISTANCE_QUAL_UOM	:= l_old_ServiceRequest_rec.INCIDENT_DISTANCE_QUAL_UOM;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ADDRESS2	:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS2;
  IF (nvl(l_service_request_rec.INCIDENT_ADDRESS2,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_ADDRESS2,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ADDRESS2,-99)) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS2		:= l_service_request_rec.INCIDENT_ADDRESS2;
  ELSE
    x_audit_vals_rec.INCIDENT_ADDRESS2		:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS2;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ADDRESS3	:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS3;
  IF (nvl(l_service_request_rec.INCIDENT_ADDRESS3,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_ADDRESS3,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ADDRESS3,-99)) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS3		:= l_service_request_rec.INCIDENT_ADDRESS3;
  ELSE
    x_audit_vals_rec.INCIDENT_ADDRESS3		:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS3;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ADDRESS4	:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS4;
  IF (nvl(l_service_request_rec.INCIDENT_ADDRESS4,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_ADDRESS4,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ADDRESS4,-99)) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS4		:= l_service_request_rec.INCIDENT_ADDRESS4;
  ELSE
    x_audit_vals_rec.INCIDENT_ADDRESS4		:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS4;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ADDRESS_STYLE	:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS_STYLE;
  IF (nvl(l_service_request_rec.INCIDENT_ADDRESS_STYLE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_ADDRESS_STYLE,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ADDRESS_STYLE,-99)) THEN
    x_audit_vals_rec.INCIDENT_ADDRESS_STYLE	:= l_service_request_rec.INCIDENT_ADDRESS_STYLE;
  ELSE
    x_audit_vals_rec.INCIDENT_ADDRESS_STYLE	:= l_old_ServiceRequest_rec.INCIDENT_ADDRESS_STYLE;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_ADDR_LNS_PHONETIC := l_old_ServiceRequest_rec.INCIDENT_ADDR_LINES_PHONETIC;
  IF (nvl(l_service_request_rec.incident_addr_lines_phonetic,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.incident_addr_lines_phonetic,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_ADDR_LINES_PHONETIC,-99)) THEN
    x_audit_vals_rec.INCIDENT_ADDR_LNS_PHONETIC	:= l_service_request_rec.incident_addr_lines_phonetic;
  ELSE
    x_audit_vals_rec.INCIDENT_ADDR_LNS_PHONETIC	:= l_old_ServiceRequest_rec.INCIDENT_ADDR_LINES_PHONETIC;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_PO_BOX_NUMBER	:= l_old_ServiceRequest_rec.INCIDENT_PO_BOX_NUMBER;
  IF (nvl(l_service_request_rec.INCIDENT_PO_BOX_NUMBER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_PO_BOX_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_PO_BOX_NUMBER,-99)) THEN
    x_audit_vals_rec.INCIDENT_PO_BOX_NUMBER	:= l_service_request_rec.INCIDENT_PO_BOX_NUMBER;
  ELSE
    x_audit_vals_rec.INCIDENT_PO_BOX_NUMBER	:= l_old_ServiceRequest_rec.INCIDENT_PO_BOX_NUMBER;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_HOUSE_NUMBER	:= l_old_ServiceRequest_rec.INCIDENT_HOUSE_NUMBER;
  IF (nvl(l_service_request_rec.INCIDENT_HOUSE_NUMBER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_HOUSE_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_HOUSE_NUMBER,-99)) THEN
    x_audit_vals_rec.INCIDENT_HOUSE_NUMBER	:= l_service_request_rec.INCIDENT_HOUSE_NUMBER;
  ELSE
    x_audit_vals_rec.INCIDENT_HOUSE_NUMBER	:= l_old_ServiceRequest_rec.INCIDENT_HOUSE_NUMBER;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_STREET_SUFFIX	:= l_old_ServiceRequest_rec.INCIDENT_STREET_SUFFIX;
  IF (nvl(l_service_request_rec.INCIDENT_STREET_SUFFIX,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_STREET_SUFFIX,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_STREET_SUFFIX,-99)) THEN
    x_audit_vals_rec.INCIDENT_STREET_SUFFIX	:= l_service_request_rec.INCIDENT_STREET_SUFFIX;
  ELSE
    x_audit_vals_rec.INCIDENT_STREET_SUFFIX	:= l_old_ServiceRequest_rec.INCIDENT_STREET_SUFFIX;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_STREET		:= l_old_ServiceRequest_rec.INCIDENT_STREET;
  IF (nvl(l_service_request_rec.INCIDENT_STREET,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_STREET,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_STREET,-99)) THEN
    x_audit_vals_rec.INCIDENT_STREET		:= l_service_request_rec.INCIDENT_STREET;
  ELSE
    x_audit_vals_rec.INCIDENT_STREET		:= l_old_ServiceRequest_rec.INCIDENT_STREET;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_STREET_NUMBER	:= l_old_ServiceRequest_rec.INCIDENT_STREET_NUMBER;
  IF (nvl(l_service_request_rec.INCIDENT_STREET_NUMBER,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_STREET_NUMBER,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_STREET_NUMBER,-99)) THEN
    x_audit_vals_rec.INCIDENT_STREET_NUMBER	:= l_service_request_rec.INCIDENT_STREET_NUMBER;
  ELSE
    x_audit_vals_rec.INCIDENT_STREET_NUMBER	:= l_old_ServiceRequest_rec.INCIDENT_STREET_NUMBER;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_FLOOR		:= l_old_ServiceRequest_rec.INCIDENT_FLOOR;
  IF (nvl(l_service_request_rec.INCIDENT_FLOOR,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_FLOOR,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_FLOOR,-99)) THEN
    x_audit_vals_rec.INCIDENT_FLOOR		:= l_service_request_rec.INCIDENT_FLOOR;
  ELSE
    x_audit_vals_rec.INCIDENT_FLOOR		:= l_old_ServiceRequest_rec.INCIDENT_FLOOR;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_SUITE		:= l_old_ServiceRequest_rec.INCIDENT_SUITE;
  IF (nvl(l_service_request_rec.INCIDENT_SUITE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_SUITE,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_SUITE,-99)) THEN
    x_audit_vals_rec.INCIDENT_SUITE		:= l_service_request_rec.INCIDENT_SUITE;
  ELSE
    x_audit_vals_rec.INCIDENT_SUITE		:= l_old_ServiceRequest_rec.INCIDENT_SUITE;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_POSTAL_PLUS4_CODE := l_old_ServiceRequest_rec.INCIDENT_POSTAL_PLUS4_CODE;
  IF (nvl(l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_POSTAL_PLUS4_CODE,-99)) THEN
    x_audit_vals_rec.INCIDENT_POSTAL_PLUS4_CODE	:= l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE;
  ELSE
    x_audit_vals_rec.INCIDENT_POSTAL_PLUS4_CODE	:= l_old_ServiceRequest_rec.INCIDENT_POSTAL_PLUS4_CODE;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_POSITION	:= l_old_ServiceRequest_rec.INCIDENT_POSITION;
  IF (nvl(l_service_request_rec.INCIDENT_POSITION,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.INCIDENT_POSITION,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_POSITION,-99)) THEN
    x_audit_vals_rec.INCIDENT_POSITION		:= l_service_request_rec.INCIDENT_POSITION;
  ELSE
    x_audit_vals_rec.INCIDENT_POSITION		:= l_old_ServiceRequest_rec.INCIDENT_POSITION;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_LOC_DIRECTIONS	:= l_old_ServiceRequest_rec.INCIDENT_LOCATION_DIRECTIONS;
  IF (nvl(l_service_request_rec.incident_location_directions,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.incident_location_directions,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_LOCATION_DIRECTIONS,-99)) THEN
    x_audit_vals_rec.INCIDENT_LOC_DIRECTIONS	:= l_service_request_rec.incident_location_directions;
  ELSE
    x_audit_vals_rec.INCIDENT_LOC_DIRECTIONS	:= l_old_ServiceRequest_rec.INCIDENT_LOCATION_DIRECTIONS;
  END IF;

  x_audit_vals_rec.OLD_INCIDENT_LOC_DESCRIPTION	:= l_old_ServiceRequest_rec.INCIDENT_LOCATION_DESCRIPTION;
  IF (nvl(l_service_request_rec.incident_location_description,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.incident_location_description,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_LOCATION_DESCRIPTION,-99)) THEN
    x_audit_vals_rec.INCIDENT_LOC_DESCRIPTION	:= l_service_request_rec.incident_location_description;
  END IF;

  x_audit_vals_rec.OLD_INSTALL_SITE_ID		:= l_old_ServiceRequest_rec.INSTALL_SITE_ID;
  IF (nvl(l_service_request_rec.INSTALL_SITE_ID,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.INSTALL_SITE_ID,-99) <> nvl(l_old_ServiceRequest_rec.INSTALL_SITE_ID,-99)) THEN
    x_audit_vals_rec.INSTALL_SITE_ID		:= l_service_request_rec.INSTALL_SITE_ID;
  ELSE
    x_audit_vals_rec.INSTALL_SITE_ID		:= l_old_ServiceRequest_rec.INSTALL_SITE_ID;
  END IF;

  x_audit_vals_rec.OLD_TIER_VERSION		:= l_old_ServiceRequest_rec.TIER_VERSION;
  IF (nvl(l_service_request_rec.TIER_VERSION,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.TIER_VERSION,-99) <> nvl(l_old_ServiceRequest_rec.TIER_VERSION,-99)) THEN
    x_audit_vals_rec.TIER_VERSION		:= l_service_request_rec.TIER_VERSION;
  ELSE
    x_audit_vals_rec.TIER_VERSION		:= l_old_ServiceRequest_rec.TIER_VERSION;
  END IF;

  -- anmukher --09/12/03

  x_audit_vals_rec.OLD_INC_OBJECT_VERSION_NUMBER := l_old_ServiceRequest_rec.OBJECT_VERSION_NUMBER;
  x_audit_vals_rec.INC_OBJECT_VERSION_NUMBER	 := l_old_ServiceRequest_rec.OBJECT_VERSION_NUMBER + 1;

  x_audit_vals_rec.OLD_INC_REQUEST_ID		:= l_old_ServiceRequest_rec.REQUEST_ID;
  IF (nvl(l_service_request_rec.conc_request_id,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.conc_request_id,-99) <> nvl(l_old_ServiceRequest_rec.REQUEST_ID,-99)) THEN
    x_audit_vals_rec.INC_REQUEST_ID		:= l_service_request_rec.conc_request_id;
  ELSE
    x_audit_vals_rec.INC_REQUEST_ID		:= l_old_ServiceRequest_rec.REQUEST_ID;
  END IF;

  x_audit_vals_rec.OLD_INC_PROGRAM_APPLICATION_ID := l_old_ServiceRequest_rec.PROGRAM_APPLICATION_ID;
  IF (nvl(l_service_request_rec.program_application_id,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.program_application_id,-99) <> nvl(l_old_ServiceRequest_rec.PROGRAM_APPLICATION_ID,-99)) THEN
    x_audit_vals_rec.INC_PROGRAM_APPLICATION_ID	:= l_service_request_rec.program_application_id;
  ELSE
    x_audit_vals_rec.INC_PROGRAM_APPLICATION_ID	:= l_old_ServiceRequest_rec.PROGRAM_APPLICATION_ID;
  END IF;

  x_audit_vals_rec.OLD_INC_PROGRAM_ID		:= l_old_ServiceRequest_rec.PROGRAM_ID;
  IF (nvl(l_service_request_rec.program_id,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.program_id,-99) <> nvl(l_old_ServiceRequest_rec.PROGRAM_ID,-99)) THEN
    x_audit_vals_rec.INC_PROGRAM_ID		:= l_service_request_rec.program_id;
  ELSE
    x_audit_vals_rec.INC_PROGRAM_ID		:= l_old_ServiceRequest_rec.PROGRAM_ID;
  END IF;

  /* Cannot populate this column as there is no equivalent column in l_service_request_rec */
  /*
  IF (nvl(l_service_request_rec. ,TO_DATE('09-09-0999', 'DD-MM-YYYY')) <> FND_API.G_MISS_DATE) AND
    (l_service_request_rec. ) THEN
    x_audit_vals_rec.INC_PROGRAM_UPDATE_DATE	:= l_service_request_rec.;
  END IF;
  */

  x_audit_vals_rec.OLD_OWNING_DEPARTMENT_ID	:= l_old_ServiceRequest_rec.OWNING_DEPARTMENT_ID;
  IF (nvl(l_service_request_rec.owning_dept_id,-99) <> FND_API.G_MISS_NUM) AND
    (nvl(l_service_request_rec.owning_dept_id,-99) <> nvl(l_old_ServiceRequest_rec.OWNING_DEPARTMENT_ID,-99)) THEN
    x_audit_vals_rec.OWNING_DEPARTMENT_ID	:= l_service_request_rec.owning_dept_id;
  ELSE
    x_audit_vals_rec.OWNING_DEPARTMENT_ID	:= l_old_ServiceRequest_rec.OWNING_DEPARTMENT_ID;
  END IF;

  /* 12/13/05 smisra moved to update_service_request procedure just before call to
     create audit record
  x_audit_vals_rec.OLD_INCIDENT_LOCATION_TYPE	:= l_old_ServiceRequest_rec.INCIDENT_LOCATION_TYPE;
  IF (nvl(l_service_request_rec.incident_location_type,-99) <> FND_API.G_MISS_CHAR) AND
    (nvl(l_service_request_rec.incident_location_type,-99) <> nvl(l_old_ServiceRequest_rec.INCIDENT_LOCATION_TYPE,-99)) THEN
    x_audit_vals_rec.INCIDENT_LOCATION_TYPE	:= l_service_request_rec.incident_location_type;
  ELSE
    x_audit_vals_rec.INCIDENT_LOCATION_TYPE	:= l_old_ServiceRequest_rec.INCIDENT_LOCATION_TYPE;
  END IF;
  ****/


  -- Assigning org_id values for auditing  spusegao 09/22/03
     x_audit_vals_rec.org_id     := l_old_ServiceRequest_rec.org_id ;
     x_audit_vals_rec.old_org_id := l_old_ServiceRequest_rec.org_id ;

/* Credit Card 9358401 */
   IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
     IF l_service_request_rec.instrument_payment_use_id = FND_API.G_MISS_NUM
	THEN
        l_service_request_rec.instrument_payment_use_id :=
	                      l_old_ServiceRequest_rec.instrument_payment_use_id;
     END IF;

     IF l_service_request_rec.instrument_payment_use_id IS not NULL THEN
         CS_ServiceRequest_UTIL.validate_credit_card(
          p_api_name             => l_api_name,
          p_parameter_name       => 'P_INSTRUMENT_PAYMENT_USE_ID',
          p_instrument_payment_use_id  =>
		                   l_service_request_rec.instrument_payment_use_id,
          p_bill_to_acct_id      => l_service_request_rec.bill_to_account_id,
		p_called_from          => 'U',
          x_return_status        => l_return_status);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            /* Ignoring the value but SR needs to be created*/
            l_service_request_rec.instrument_payment_use_id := NULL;
          END IF;
     END IF;
   END IF; /*p_validation level*/
/* Credit Card 9358401 */
CLOSE l_ServiceRequest_csr;

--- Assinging the values to x_service_request_rec
 x_service_request_rec := l_service_request_rec;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN OnlyUpdStatus THEN
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := 'R';
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN OTHERS THEN
    ROLLBACK TO Update_ServiceRequest_PVT;
    IF (l_ServiceRequest_csr%ISOPEN) THEN
      CLOSE l_ServiceRequest_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
END Update_SR_Validation;

PROCEDURE initialize_rec(
  p_sr_record                   IN OUT NOCOPY service_request_rec_type
) AS
BEGIN
  p_sr_record.request_date               := FND_API.G_MISS_DATE;
  p_sr_record.type_id                    := FND_API.G_MISS_NUM;
  p_sr_record.status_id                  := FND_API.G_MISS_NUM;
  p_sr_record.severity_id                := FND_API.G_MISS_NUM;
  p_sr_record.urgency_id                 := FND_API.G_MISS_NUM;
  p_sr_record.closed_date                := FND_API.G_MISS_DATE;
  p_sr_record.owner_id                   := FND_API.G_MISS_NUM;
  p_sr_record.owner_group_id             := FND_API.G_MISS_NUM;
  p_sr_record.publish_flag               := FND_API.G_MISS_CHAR;
  p_sr_record.summary                    := FND_API.G_MISS_CHAR;
  p_sr_record.caller_type                := FND_API.G_MISS_CHAR;
  p_sr_record.customer_id                := FND_API.G_MISS_NUM;
  p_sr_record.customer_number            := FND_API.G_MISS_CHAR;
  p_sr_record.employee_id                := FND_API.G_MISS_NUM;
  p_sr_record.verify_cp_flag             := FND_API.G_MISS_CHAR;
  p_sr_record.customer_product_id        := FND_API.G_MISS_NUM;
  p_sr_record.platform_id                := FND_API.G_MISS_NUM;
  p_sr_record.platform_version		 := FND_API.G_MISS_CHAR;
  p_sr_record.db_version		 := FND_API.G_MISS_CHAR;
  p_sr_record.platform_version_id        := FND_API.G_MISS_NUM;
  p_sr_record.cp_component_id               := FND_API.G_MISS_NUM;
  p_sr_record.cp_component_version_id       := FND_API.G_MISS_NUM;
  p_sr_record.cp_subcomponent_id            := FND_API.G_MISS_NUM;
  p_sr_record.cp_subcomponent_version_id    := FND_API.G_MISS_NUM;
  p_sr_record.language_id                := FND_API.G_MISS_NUM;
  p_sr_record.LANGUAGE                   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_id          := FND_API.G_MISS_NUM;
  p_sr_record.inventory_org_id           := FND_API.G_MISS_NUM;
  p_sr_record.current_serial_number      := FND_API.G_MISS_CHAR;
  p_sr_record.original_order_number      := FND_API.G_MISS_NUM;
  p_sr_record.purchase_order_num         := FND_API.G_MISS_CHAR;
  p_sr_record.problem_code               := FND_API.G_MISS_CHAR;
  p_sr_record.exp_resolution_date        := FND_API.G_MISS_DATE;
  p_sr_record.install_site_use_id        := FND_API.G_MISS_NUM;
  p_sr_record.request_attribute_1        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_2        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_3        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_4        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_5        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_6        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_7        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_8        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_9        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_10       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_11       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_12       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_13       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_14       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_15       := FND_API.G_MISS_CHAR;
  p_sr_record.request_context            := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_1       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_2       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_3       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_4       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_5       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_6       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_7       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_8       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_9       := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_10      := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_11      := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_12      := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_13      := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_14      := FND_API.G_MISS_CHAR;
  p_sr_record.external_attribute_15      := FND_API.G_MISS_CHAR;
  p_sr_record.external_context           := FND_API.G_MISS_CHAR;
  p_sr_record.bill_to_site_use_id        := FND_API.G_MISS_NUM;
  p_sr_record.bill_to_contact_id         := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_site_use_id        := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_contact_id         := FND_API.G_MISS_NUM;
  p_sr_record.resolution_code            := FND_API.G_MISS_CHAR;
  p_sr_record.act_resolution_date        := FND_API.G_MISS_DATE;
  p_sr_record.public_comment_flag        := FND_API.G_MISS_CHAR;
  p_sr_record.parent_interaction_id      := FND_API.G_MISS_NUM;
  p_sr_record.contract_service_id        := FND_API.G_MISS_NUM;
  p_sr_record.contract_id                := FND_API.G_MISS_NUM;
  p_sr_record.project_number             := FND_API.G_MISS_CHAR;
  p_sr_record.qa_collection_plan_id      := FND_API.G_MISS_NUM;
  p_sr_record.account_id                 := FND_API.G_MISS_NUM;
  p_sr_record.resource_type              := FND_API.G_MISS_CHAR;
  p_sr_record.resource_subtype_id        := FND_API.G_MISS_NUM;
  p_sr_record.cust_po_number             := FND_API.G_MISS_CHAR;
  p_sr_record.cust_ticket_number         := FND_API.G_MISS_CHAR;
  p_sr_record.sr_creation_channel        := FND_API.G_MISS_CHAR;
  p_sr_record.obligation_date            := FND_API.G_MISS_DATE;
  p_sr_record.time_zone_id               := FND_API.G_MISS_NUM;
  p_sr_record.time_difference            := FND_API.G_MISS_NUM;
  p_sr_record.site_id                    := FND_API.G_MISS_NUM;
  p_sr_record.customer_site_id           := FND_API.G_MISS_NUM;
  p_sr_record.territory_id               := FND_API.G_MISS_NUM;
  p_sr_record.initialize_flag            := G_INITIALIZED;
  p_sr_record.cp_revision_id             := FND_API.G_MISS_NUM;
  p_sr_record.inv_item_revision          := FND_API.G_MISS_CHAR;
  p_sr_record.inv_component_id           := FND_API.G_MISS_NUM;
  p_sr_record.inv_component_version      := FND_API.G_MISS_CHAR;
  p_sr_record.inv_subcomponent_id        := FND_API.G_MISS_NUM;
  p_sr_record.inv_subcomponent_version   := FND_API.G_MISS_CHAR;
  p_sr_record.tier                       := FND_API.G_MISS_CHAR;
  p_sr_record.tier_version               := FND_API.G_MISS_CHAR;
  p_sr_record.operating_system           := FND_API.G_MISS_CHAR;
  p_sr_record.operating_system           := FND_API.G_MISS_CHAR;
  p_sr_record.DATABASE                   := FND_API.G_MISS_CHAR;
  p_sr_record.cust_pref_lang_id          := FND_API.G_MISS_NUM;
  p_sr_record.category_id                := FND_API.G_MISS_NUM;
  p_sr_record.group_type                 := FND_API.G_MISS_CHAR;
  p_sr_record.group_territory_id         := FND_API.G_MISS_NUM;
  p_sr_record.inv_platform_org_id        := FND_API.G_MISS_NUM;
  p_sr_record.component_version          := FND_API.G_MISS_CHAR;
  p_sr_record.subcomponent_version       := FND_API.G_MISS_CHAR;
  p_sr_record.product_revision           := FND_API.G_MISS_CHAR;
  p_sr_record.comm_pref_code             := FND_API.G_MISS_CHAR;
  p_sr_record.cust_pref_lang_code        := FND_API.G_MISS_CHAR;
  p_sr_record.category_set_id            := FND_API.G_MISS_NUM;
  p_sr_record.external_reference         := FND_API.G_MISS_CHAR;
  p_sr_record.system_id                  := FND_API.G_MISS_NUM;
-- Added for HA
  p_sr_record.last_update_date           := FND_API.G_MISS_DATE;
  p_sr_record.last_updated_by            := FND_API.G_MISS_NUM;
  p_sr_record.creation_date              := FND_API.G_MISS_DATE;
  p_sr_record.created_by                 := FND_API.G_MISS_NUM;
  p_sr_record.last_update_login          := FND_API.G_MISS_NUM;
  p_sr_record.owner_assigned_flag        := FND_API.G_MISS_CHAR;
  p_sr_record.owner_assigned_time        := FND_API.G_MISS_DATE;
  p_sr_record.error_code                 := FND_API.G_MISS_CHAR;
  p_sr_record.incident_occurred_date     := FND_API.G_MISS_DATE;
  p_sr_record.incident_resolved_date     := FND_API.G_MISS_DATE;
  p_sr_record.inc_responded_by_date      := FND_API.G_MISS_DATE;
  p_sr_record.incident_location_id       := FND_API.G_MISS_NUM;
  p_sr_record.incident_address           := FND_API.G_MISS_CHAR;
  p_sr_record.incident_city              := FND_API.G_MISS_CHAR;
  p_sr_record.incident_state             := FND_API.G_MISS_CHAR;
  p_sr_record.incident_country           := FND_API.G_MISS_CHAR;
  p_sr_record.incident_province          := FND_API.G_MISS_CHAR;
  p_sr_record.incident_postal_code       := FND_API.G_MISS_CHAR;
  p_sr_record.incident_county            := FND_API.G_MISS_CHAR;
  p_sr_record.resolution_summary         := FND_API.G_MISS_CHAR;
  p_sr_record.owner                      := FND_API.G_MISS_CHAR;
  p_sr_record.group_owner                := FND_API.G_MISS_CHAR;
  -- Added for ER# 2320056
  p_sr_record.coverage_type              := FND_API.G_MISS_CHAR;
  --  Added for ER# 2433831
  p_sr_record.bill_to_account_id         := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_account_id         := FND_API.G_MISS_NUM;
  --  Added for ER# 2463321
  p_sr_record.customer_phone_id   	 := FND_API.G_MISS_NUM;
  p_sr_record.customer_email_id   	 := FND_API.G_MISS_NUM;
  -- Added these parameters for 11.5.9 source changes
  p_sr_record.creation_program_code      := FND_API.G_MISS_CHAR;
  p_sr_record.last_update_program_code   := FND_API.G_MISS_CHAR;
  -- Bill_to_party, ship_to_party
  p_sr_record.bill_to_party_id           := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_party_id           := FND_API.G_MISS_NUM;
  -- Conc request related fields
  p_sr_record.program_id                 := FND_API.G_MISS_NUM;
  p_sr_record.program_application_id     := FND_API.G_MISS_NUM;
  p_sr_record.conc_request_id            := FND_API.G_MISS_NUM;
  p_sr_record.program_login_id           := FND_API.G_MISS_NUM;
  -- Bill_to_site, ship_to_site
  p_sr_record.bill_to_site_id   	 := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_site_id   	 := FND_API.G_MISS_NUM;
   -- Added to initialize the address columns by shijain dec 4th 2002
  p_sr_record.incident_point_of_interest   := FND_API.G_MISS_CHAR;
  p_sr_record.incident_cross_street        := FND_API.G_MISS_CHAR;
  p_sr_record.incident_direction_qualifier := FND_API.G_MISS_CHAR;
  p_sr_record.incident_distance_qualifier  := FND_API.G_MISS_CHAR;
  p_sr_record.incident_distance_qual_uom   := FND_API.G_MISS_CHAR;
  p_sr_record.incident_address2            := FND_API.G_MISS_CHAR;
  p_sr_record.incident_address3            := FND_API.G_MISS_CHAR;
  p_sr_record.incident_address4            := FND_API.G_MISS_CHAR;
  p_sr_record.incident_address_style       := FND_API.G_MISS_CHAR;
  p_sr_record.incident_addr_lines_phonetic := FND_API.G_MISS_CHAR;
  p_sr_record.incident_po_box_number       := FND_API.G_MISS_CHAR;
  p_sr_record.incident_house_number        := FND_API.G_MISS_CHAR;
  p_sr_record.incident_street_suffix       := FND_API.G_MISS_CHAR;
  p_sr_record.incident_street              := FND_API.G_MISS_CHAR;
  p_sr_record.incident_street_number       := FND_API.G_MISS_CHAR;
  p_sr_record.incident_floor               := FND_API.G_MISS_CHAR;
  p_sr_record.incident_suite               := FND_API.G_MISS_CHAR;
  p_sr_record.incident_postal_plus4_code   := FND_API.G_MISS_CHAR;
  p_sr_record.incident_position            := FND_API.G_MISS_CHAR;
  p_sr_record.incident_location_directions := FND_API.G_MISS_CHAR;
  p_sr_record.incident_location_description:= FND_API.G_MISS_CHAR;
  p_sr_record.install_site_id              := FND_API.G_MISS_NUM;
  -- Added to initialize the columns added for CMRO-EAM project (11.5.10) by anmukher aug 12 2003
  p_sr_record.owning_dept_id		   := FND_API.G_MISS_NUM;
  p_sr_record.old_type_CMRO_flag           := FND_API.G_MISS_CHAR;
  p_sr_record.new_type_CMRO_flag           := FND_API.G_MISS_CHAR;
  p_sr_record.old_type_maintenance_flag    := FND_API.G_MISS_CHAR;
  p_sr_record.new_type_maintenance_flag    := FND_API.G_MISS_CHAR;
  -- Added to initialize the column incident_location_type for MISC ERs Project (11.5.10) --anmukher --08/26/03
  p_sr_record.incident_location_type	   := FND_API.G_MISS_CHAR;
  p_sr_record.maint_organization_id        := FND_API.G_MISS_NUM;
  /* Credit Card 9358401 */
  p_sr_record.instrument_payment_use_id          := FND_API.G_MISS_NUM;
END initialize_rec;

---- Procedure to initialize the audit record.
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name      Desc
-- -------- --------- ----------------------------------------------------------
-- 07/21/05 smisra    Added miant organization and old maint organization id col
-- -----------------------------------------------------------------------------
PROCEDURE initialize_audit_rec(
  p_sr_audit_record         IN OUT NOCOPY sr_audit_rec_type
) AS
BEGIN
  p_sr_audit_record.INCIDENT_STATUS_ID              := NULL;
  p_sr_audit_record.OLD_INCIDENT_STATUS_ID          := NULL;
  p_sr_audit_record.CHANGE_INCIDENT_STATUS_FLAG     := NULL;
  p_sr_audit_record.INCIDENT_TYPE_ID                := NULL;
  p_sr_audit_record.OLD_INCIDENT_TYPE_ID            := NULL;
  p_sr_audit_record.CHANGE_INCIDENT_TYPE_FLAG       := NULL;
  p_sr_audit_record.INCIDENT_URGENCY_ID             := NULL;
  p_sr_audit_record.OLD_INCIDENT_URGENCY_ID         := NULL;
  p_sr_audit_record.CHANGE_INCIDENT_URGENCY_FLAG    := NULL;
  p_sr_audit_record.INCIDENT_SEVERITY_ID            := NULL;
  p_sr_audit_record.OLD_INCIDENT_SEVERITY_ID        := NULL;
  p_sr_audit_record.CHANGE_INCIDENT_SEVERITY_FLAG   := NULL;
  p_sr_audit_record.RESPONSIBLE_GROUP_ID            := NULL;
  p_sr_audit_record.OLD_RESPONSIBLE_GROUP_ID        := NULL;
  p_sr_audit_record.CHANGE_RESPONSIBLE_GROUP_FLAG   := NULL;
  p_sr_audit_record.INCIDENT_OWNER_ID               := NULL;
  p_sr_audit_record.OLD_INCIDENT_OWNER_ID           := NULL;
  p_sr_audit_record.CHANGE_INCIDENT_OWNER_FLAG      := NULL;
  p_sr_audit_record.CREATE_MANUAL_ACTION            := NULL;
  p_sr_audit_record.ACTION_ID                       := NULL;
  p_sr_audit_record.EXPECTED_RESOLUTION_DATE        := NULL;
  p_sr_audit_record.OLD_EXPECTED_RESOLUTION_DATE    := NULL;
  p_sr_audit_record.CHANGE_RESOLUTION_FLAG          := NULL;
  p_sr_audit_record.NEW_WORKFLOW_FLAG               := NULL;
  p_sr_audit_record.WORKFLOW_PROCESS_NAME           := NULL;
  p_sr_audit_record.WORKFLOW_PROCESS_ITEMKEY        := NULL;
  p_sr_audit_record.GROUP_ID                        := NULL;
  p_sr_audit_record.OLD_GROUP_ID                    := NULL;
  p_sr_audit_record.CHANGE_GROUP_FLAG               := NULL;
  p_sr_audit_record.OBLIGATION_DATE                 := NULL;
  p_sr_audit_record.OLD_OBLIGATION_DATE             := NULL;
  p_sr_audit_record.CHANGE_OBLIGATION_FLAG          := NULL;
  p_sr_audit_record.SITE_ID                         := NULL;
  p_sr_audit_record.OLD_SITE_ID                     := NULL;
  p_sr_audit_record.CHANGE_SITE_FLAG                := NULL;
  p_sr_audit_record.BILL_TO_CONTACT_ID              := NULL;
  p_sr_audit_record.OLD_BILL_TO_CONTACT_ID          := NULL;
  p_sr_audit_record.CHANGE_BILL_TO_FLAG             := NULL;
  p_sr_audit_record.SHIP_TO_CONTACT_ID              := NULL;
  p_sr_audit_record.OLD_SHIP_TO_CONTACT_ID          := NULL;
  p_sr_audit_record.CHANGE_SHIP_TO_FLAG             := NULL;
  p_sr_audit_record.INCIDENT_DATE                   := NULL;
  p_sr_audit_record.OLD_INCIDENT_DATE               := NULL;
  p_sr_audit_record.CHANGE_INCIDENT_DATE_FLAG       := NULL;
  p_sr_audit_record.CLOSE_DATE                      := NULL;
  p_sr_audit_record.OLD_CLOSE_DATE                  := NULL;
  p_sr_audit_record.CHANGE_CLOSE_DATE_FLAG          := NULL;
  p_sr_audit_record.CUSTOMER_PRODUCT_ID             := NULL;
  p_sr_audit_record.OLD_CUSTOMER_PRODUCT_ID         := NULL;
  p_sr_audit_record.CHANGE_CUSTOMER_PRODUCT_FLAG    := NULL;
  p_sr_audit_record.PLATFORM_ID                     := NULL;
  p_sr_audit_record.OLD_PLATFORM_ID                 := NULL;
  p_sr_audit_record.CHANGE_PLATFORM_ID_FLAG         := NULL;
  p_sr_audit_record.PLATFORM_VERSION_ID             := NULL;
  p_sr_audit_record.OLD_PLATFORM_VERSION_ID         := NULL;
  p_sr_audit_record.CHANGE_PLAT_VER_ID_FLAG         := NULL;
  p_sr_audit_record.CP_COMPONENT_ID                 := NULL;
  p_sr_audit_record.OLD_CP_COMPONENT_ID             := NULL;
  p_sr_audit_record.CHANGE_CP_COMPONENT_ID_FLAG     := NULL;
  p_sr_audit_record.CP_COMPONENT_VERSION_ID         := NULL;
  p_sr_audit_record.OLD_CP_COMPONENT_VERSION_ID     := NULL;
  p_sr_audit_record.CHANGE_CP_COMP_VER_ID_FLAG      := NULL;
  p_sr_audit_record.CP_SUBCOMPONENT_ID              := NULL;
  p_sr_audit_record.OLD_CP_SUBCOMPONENT_ID          := NULL;
  p_sr_audit_record.CHANGE_CP_SUBCOMPONENT_ID_FLAG  := NULL;
  p_sr_audit_record.CP_SUBCOMPONENT_VERSION_ID      := NULL;
  p_sr_audit_record.OLD_CP_SUBCOMPONENT_VERSION_ID  := NULL;
  p_sr_audit_record.CHANGE_CP_SUBCOMP_VER_ID_FLAG   := NULL;
  p_sr_audit_record.LANGUAGE_ID                     := NULL;
  p_sr_audit_record.OLD_LANGUAGE_ID                 := NULL;
  p_sr_audit_record.CHANGE_LANGUAGE_ID_FLAG         := NULL;
  p_sr_audit_record.TERRITORY_ID                    := NULL;
  p_sr_audit_record.OLD_TERRITORY_ID                := NULL;
  p_sr_audit_record.CHANGE_TERRITORY_ID_FLAG        := NULL;
  p_sr_audit_record.CP_REVISION_ID                  := NULL;
  p_sr_audit_record.OLD_CP_REVISION_ID              := NULL;
  p_sr_audit_record.CHANGE_CP_REVISION_ID_FLAG      := NULL;
  p_sr_audit_record.INV_ITEM_REVISION               := NULL;
  p_sr_audit_record.OLD_INV_ITEM_REVISION           := NULL;
  p_sr_audit_record.CHANGE_INV_ITEM_REVISION        := NULL;
  p_sr_audit_record.INV_COMPONENT_ID                := NULL;
  p_sr_audit_record.OLD_INV_COMPONENT_ID            := NULL;
  p_sr_audit_record.CHANGE_INV_COMPONENT_ID         := NULL;
  p_sr_audit_record.INV_COMPONENT_VERSION           := NULL;
  p_sr_audit_record.OLD_INV_COMPONENT_VERSION       := NULL;
  p_sr_audit_record.CHANGE_INV_COMPONENT_VERSION    := NULL;
  p_sr_audit_record.INV_SUBCOMPONENT_ID             := NULL;
  p_sr_audit_record.OLD_INV_SUBCOMPONENT_ID         := NULL;
  p_sr_audit_record.CHANGE_INV_SUBCOMPONENT_ID      := NULL;
  p_sr_audit_record.INV_SUBCOMPONENT_VERSION        := NULL;
  p_sr_audit_record.OLD_INV_SUBCOMPONENT_VERSION    := NULL;
  p_sr_audit_record.CHANGE_INV_SUBCOMP_VERSION      := NULL;
  p_sr_audit_record.RESOURCE_TYPE                   := NULL;
  p_sr_audit_record.OLD_RESOURCE_TYPE               := NULL;
  p_sr_audit_record.CHANGE_RESOURCE_TYPE_FLAG       := NULL;
  p_sr_audit_record.SECURITY_GROUP_ID               := NULL;
  p_sr_audit_record.UPGRADED_STATUS_FLAG            := NULL;
  p_sr_audit_record.OLD_GROUP_TYPE                  := NULL;
  p_sr_audit_record.GROUP_TYPE                      := NULL;
  p_sr_audit_record.CHANGE_GROUP_TYPE_FLAG          := NULL;
  p_sr_audit_record.OLD_OWNER_ASSIGNED_TIME         := NULL;
  p_sr_audit_record.OWNER_ASSIGNED_TIME             := NULL;
  p_sr_audit_record.CHANGE_ASSIGNED_TIME_FLAG       := NULL;
  p_sr_audit_record.INV_PLATFORM_ORG_ID             := NULL;
  p_sr_audit_record.OLD_INV_PLATFORM_ORG_ID         := NULL;
  p_sr_audit_record.CHANGE_PLATFORM_ORG_ID_FLAG     := NULL;
  p_sr_audit_record.COMPONENT_VERSION               := NULL;
  p_sr_audit_record.OLD_COMPONENT_VERSION           := NULL;
  p_sr_audit_record.CHANGE_COMP_VER_FLAG            := NULL;
  p_sr_audit_record.SUBCOMPONENT_VERSION            := NULL;
  p_sr_audit_record.OLD_SUBCOMPONENT_VERSION        := NULL;
  p_sr_audit_record.CHANGE_SUBCOMP_VER_FLAG         := NULL;
  p_sr_audit_record.PRODUCT_REVISION                := NULL;
  p_sr_audit_record.OLD_PRODUCT_REVISION            := NULL;
  p_sr_audit_record.CHANGE_PRODUCT_REVISION_FLAG    := NULL;
  p_sr_audit_record.STATUS_FLAG                     := NULL;
  p_sr_audit_record.OLD_STATUS_FLAG                 := NULL;
  p_sr_audit_record.CHANGE_STATUS_FLAG              := NULL;
  p_sr_audit_record.INVENTORY_ITEM_ID               := NULL;
  p_sr_audit_record.OLD_INVENTORY_ITEM_ID           := NULL;
  p_sr_audit_record.CHANGE_INVENTORY_ITEM_FLAG      := NULL;
  p_sr_audit_record.INV_ORGANIZATION_ID             := NULL;
  p_sr_audit_record.OLD_INV_ORGANIZATION_ID         := NULL;
  p_sr_audit_record.CHANGE_INV_ORGANIZATION_FLAG    := NULL;
  --p_sr_audit_record.PRIMARY_CONTACT_ID              := NULL;
  --p_sr_audit_record.CHANGE_PRIMARY_CONTACT_FLAG     := NULL;
  --p_sr_audit_record.OLD_PRIMARY_CONTACT_ID          := NULL;

  --Added for Auditing project of 11.5.10 --anmukher --09/09/03

  p_sr_audit_record.UPGRADE_FLAG_FOR_CREATE                  := NULL;
p_sr_audit_record.OLD_INCIDENT_NUMBER                      := NULL;
p_sr_audit_record.INCIDENT_NUMBER                          := NULL;
p_sr_audit_record.OLD_CUSTOMER_ID                          := NULL;
p_sr_audit_record.CUSTOMER_ID                              := NULL;
p_sr_audit_record.OLD_BILL_TO_SITE_USE_ID                  := NULL;
p_sr_audit_record.BILL_TO_SITE_USE_ID                      := NULL;
p_sr_audit_record.OLD_EMPLOYEE_ID                          := NULL;
p_sr_audit_record.EMPLOYEE_ID                              := NULL;
p_sr_audit_record.OLD_SHIP_TO_SITE_USE_ID                  := NULL;
p_sr_audit_record.SHIP_TO_SITE_USE_ID                      := NULL;
p_sr_audit_record.OLD_PROBLEM_CODE                         := NULL;
p_sr_audit_record.PROBLEM_CODE                             := NULL;
p_sr_audit_record.OLD_ACTUAL_RESOLUTION_DATE               := NULL;
p_sr_audit_record.ACTUAL_RESOLUTION_DATE                   := NULL;
p_sr_audit_record.OLD_INSTALL_SITE_USE_ID                  := NULL;
p_sr_audit_record.INSTALL_SITE_USE_ID                      := NULL;
p_sr_audit_record.OLD_CURRENT_SERIAL_NUMBER                := NULL;
p_sr_audit_record.CURRENT_SERIAL_NUMBER                    := NULL;
p_sr_audit_record.OLD_SYSTEM_ID                            := NULL;
p_sr_audit_record.SYSTEM_ID                                := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_1                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_1                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_2                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_2                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_3                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_3                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_4                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_4                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_5                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_5                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_6                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_6                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_7                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_7                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_8                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_8                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_9                 := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_9                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_10                := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_10                    := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_11                := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_11                    := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_12                := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_12                    := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_13                := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_13                    := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_14                := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_14                    := NULL;
p_sr_audit_record.OLD_INCIDENT_ATTRIBUTE_15                := NULL;
p_sr_audit_record.INCIDENT_ATTRIBUTE_15                    := NULL;
p_sr_audit_record.OLD_INCIDENT_CONTEXT                     := NULL;
p_sr_audit_record.INCIDENT_CONTEXT                         := NULL;
p_sr_audit_record.OLD_RESOLUTION_CODE                      := NULL;
p_sr_audit_record.RESOLUTION_CODE                          := NULL;
p_sr_audit_record.OLD_ORIGINAL_ORDER_NUMBER                := NULL;
p_sr_audit_record.ORIGINAL_ORDER_NUMBER                    := NULL;
p_sr_audit_record.OLD_ORG_ID                               := NULL;
p_sr_audit_record.ORG_ID                                   := NULL;
p_sr_audit_record.OLD_PURCHASE_ORDER_NUMBER                := NULL;
p_sr_audit_record.PURCHASE_ORDER_NUMBER                    := NULL;
p_sr_audit_record.OLD_PUBLISH_FLAG                         := NULL;
p_sr_audit_record.PUBLISH_FLAG                             := NULL;
p_sr_audit_record.OLD_QA_COLLECTION_ID                     := NULL;
p_sr_audit_record.QA_COLLECTION_ID                         := NULL;
p_sr_audit_record.OLD_CONTRACT_ID                          := NULL;
p_sr_audit_record.CONTRACT_ID                              := NULL;
p_sr_audit_record.OLD_CONTRACT_NUMBER                      := NULL;
p_sr_audit_record.CONTRACT_NUMBER                          := NULL;
p_sr_audit_record.OLD_CONTRACT_SERVICE_ID                  := NULL;
p_sr_audit_record.CONTRACT_SERVICE_ID                      := NULL;
p_sr_audit_record.OLD_TIME_ZONE_ID                         := NULL;
p_sr_audit_record.TIME_ZONE_ID                             := NULL;
p_sr_audit_record.OLD_ACCOUNT_ID                           := NULL;
p_sr_audit_record.ACCOUNT_ID                               := NULL;
p_sr_audit_record.OLD_TIME_DIFFERENCE                      := NULL;
p_sr_audit_record.TIME_DIFFERENCE                          := NULL;
p_sr_audit_record.OLD_CUSTOMER_PO_NUMBER                   := NULL;
p_sr_audit_record.CUSTOMER_PO_NUMBER                       := NULL;
p_sr_audit_record.OLD_CUSTOMER_TICKET_NUMBER               := NULL;
p_sr_audit_record.CUSTOMER_TICKET_NUMBER                   := NULL;
p_sr_audit_record.OLD_CUSTOMER_SITE_ID                     := NULL;
p_sr_audit_record.CUSTOMER_SITE_ID                         := NULL;
p_sr_audit_record.OLD_CALLER_TYPE                          := NULL;
p_sr_audit_record.CALLER_TYPE                              := NULL;
p_sr_audit_record.OLD_SECURITY_GROUP_ID                    := NULL;
p_sr_audit_record.OLD_ORIG_SYSTEM_REFERENCE                := NULL;
p_sr_audit_record.ORIG_SYSTEM_REFERENCE                    := NULL;
p_sr_audit_record.OLD_ORIG_SYSTEM_REFERENCE_ID             := NULL;
p_sr_audit_record.ORIG_SYSTEM_REFERENCE_ID                 := NULL;
p_sr_audit_record.REQUEST_ID                           := NULL;
p_sr_audit_record.PROGRAM_APPLICATION_ID               := NULL;
p_sr_audit_record.PROGRAM_ID                           := NULL;
p_sr_audit_record.PROGRAM_UPDATE_DATE                  := NULL;
p_sr_audit_record.OLD_PROJECT_NUMBER                       := NULL;
p_sr_audit_record.PROJECT_NUMBER                           := NULL;
p_sr_audit_record.OLD_PLATFORM_VERSION                     := NULL;
p_sr_audit_record.PLATFORM_VERSION                         := NULL;
p_sr_audit_record.OLD_DB_VERSION                           := NULL;
p_sr_audit_record.DB_VERSION                               := NULL;
p_sr_audit_record.OLD_CUST_PREF_LANG_ID                    := NULL;
p_sr_audit_record.CUST_PREF_LANG_ID                        := NULL;
p_sr_audit_record.OLD_TIER                                 := NULL;
p_sr_audit_record.TIER                                     := NULL;
p_sr_audit_record.OLD_CATEGORY_ID                          := NULL;
p_sr_audit_record.CATEGORY_ID                              := NULL;
p_sr_audit_record.OLD_OPERATING_SYSTEM                     := NULL;
p_sr_audit_record.OPERATING_SYSTEM                         := NULL;
p_sr_audit_record.OLD_OPERATING_SYSTEM_VERSION             := NULL;
p_sr_audit_record.OPERATING_SYSTEM_VERSION                 := NULL;
p_sr_audit_record.OLD_DATABASE                             := NULL;
p_sr_audit_record.DATABASE                                 := NULL;
p_sr_audit_record.OLD_GROUP_TERRITORY_ID                   := NULL;
p_sr_audit_record.GROUP_TERRITORY_ID                       := NULL;
p_sr_audit_record.OLD_COMM_PREF_CODE                       := NULL;
p_sr_audit_record.COMM_PREF_CODE                           := NULL;
p_sr_audit_record.OLD_LAST_UPDATE_CHANNEL                  := NULL;
p_sr_audit_record.LAST_UPDATE_CHANNEL                      := NULL;
p_sr_audit_record.OLD_CUST_PREF_LANG_CODE                  := NULL;
p_sr_audit_record.CUST_PREF_LANG_CODE                      := NULL;
p_sr_audit_record.OLD_ERROR_CODE                           := NULL;
p_sr_audit_record.ERROR_CODE                               := NULL;
p_sr_audit_record.OLD_CATEGORY_SET_ID                      := NULL;
p_sr_audit_record.CATEGORY_SET_ID                          := NULL;
p_sr_audit_record.OLD_EXTERNAL_REFERENCE                   := NULL;
p_sr_audit_record.EXTERNAL_REFERENCE                       := NULL;
p_sr_audit_record.OLD_INCIDENT_OCCURRED_DATE               := NULL;
p_sr_audit_record.INCIDENT_OCCURRED_DATE                   := NULL;
p_sr_audit_record.OLD_INCIDENT_RESOLVED_DATE               := NULL;
p_sr_audit_record.INCIDENT_RESOLVED_DATE                   := NULL;
p_sr_audit_record.OLD_INC_RESPONDED_BY_DATE                := NULL;
p_sr_audit_record.INC_RESPONDED_BY_DATE                    := NULL;
p_sr_audit_record.OLD_INCIDENT_LOCATION_ID                 := NULL;
p_sr_audit_record.INCIDENT_LOCATION_ID                     := NULL;
p_sr_audit_record.OLD_INCIDENT_ADDRESS                     := NULL;
p_sr_audit_record.INCIDENT_ADDRESS                         := NULL;
p_sr_audit_record.OLD_INCIDENT_CITY                        := NULL;
p_sr_audit_record.INCIDENT_CITY                            := NULL;
p_sr_audit_record.OLD_INCIDENT_STATE                       := NULL;
p_sr_audit_record.INCIDENT_STATE                           := NULL;
p_sr_audit_record.OLD_INCIDENT_COUNTRY                     := NULL;
p_sr_audit_record.INCIDENT_COUNTRY                         := NULL;
p_sr_audit_record.OLD_INCIDENT_PROVINCE                    := NULL;
p_sr_audit_record.INCIDENT_PROVINCE                        := NULL;
p_sr_audit_record.OLD_INCIDENT_POSTAL_CODE                 := NULL;
p_sr_audit_record.INCIDENT_POSTAL_CODE                     := NULL;
p_sr_audit_record.OLD_INCIDENT_COUNTY                      := NULL;
p_sr_audit_record.INCIDENT_COUNTY                          := NULL;
p_sr_audit_record.OLD_SR_CREATION_CHANNEL                  := NULL;
p_sr_audit_record.SR_CREATION_CHANNEL                      := NULL;
p_sr_audit_record.OLD_DEF_DEFECT_ID                        := NULL;
p_sr_audit_record.DEF_DEFECT_ID                            := NULL;
p_sr_audit_record.OLD_DEF_DEFECT_ID2                       := NULL;
p_sr_audit_record.DEF_DEFECT_ID2                           := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_1                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_1                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_2                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_2                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_3                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_3                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_4                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_4                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_5                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_5                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_6                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_6                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_7                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_7                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_8                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_8                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_9                 := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_9                     := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_10                := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_10                    := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_11                := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_11                    := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_12                := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_12                    := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_13                := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_13                    := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_14                := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_14                    := NULL;
p_sr_audit_record.OLD_EXTERNAL_ATTRIBUTE_15                := NULL;
p_sr_audit_record.EXTERNAL_ATTRIBUTE_15                    := NULL;
p_sr_audit_record.OLD_EXTERNAL_CONTEXT                     := NULL;
p_sr_audit_record.EXTERNAL_CONTEXT                         := NULL;
p_sr_audit_record.OLD_LAST_UPDATE_PROGRAM_CODE             := NULL;
p_sr_audit_record.LAST_UPDATE_PROGRAM_CODE                 := NULL;
p_sr_audit_record.OLD_CREATION_PROGRAM_CODE                := NULL;
p_sr_audit_record.CREATION_PROGRAM_CODE                    := NULL;
p_sr_audit_record.OLD_COVERAGE_TYPE                        := NULL;
p_sr_audit_record.COVERAGE_TYPE                            := NULL;
p_sr_audit_record.OLD_BILL_TO_ACCOUNT_ID                   := NULL;
p_sr_audit_record.BILL_TO_ACCOUNT_ID                       := NULL;
p_sr_audit_record.OLD_SHIP_TO_ACCOUNT_ID                   := NULL;
p_sr_audit_record.SHIP_TO_ACCOUNT_ID                       := NULL;
p_sr_audit_record.OLD_CUSTOMER_EMAIL_ID                    := NULL;
p_sr_audit_record.CUSTOMER_EMAIL_ID                        := NULL;
p_sr_audit_record.OLD_CUSTOMER_PHONE_ID                    := NULL;
p_sr_audit_record.CUSTOMER_PHONE_ID                        := NULL;
p_sr_audit_record.OLD_BILL_TO_PARTY_ID                     := NULL;
p_sr_audit_record.BILL_TO_PARTY_ID                         := NULL;
p_sr_audit_record.OLD_SHIP_TO_PARTY_ID                     := NULL;
p_sr_audit_record.SHIP_TO_PARTY_ID                         := NULL;
p_sr_audit_record.OLD_BILL_TO_SITE_ID                      := NULL;
p_sr_audit_record.BILL_TO_SITE_ID                          := NULL;
p_sr_audit_record.OLD_SHIP_TO_SITE_ID                      := NULL;
p_sr_audit_record.SHIP_TO_SITE_ID                          := NULL;
p_sr_audit_record.OLD_PROGRAM_LOGIN_ID                     := NULL;
p_sr_audit_record.PROGRAM_LOGIN_ID                         := NULL;
p_sr_audit_record.OLD_INCIDENT_POINT_OF_INTEREST           := NULL;
p_sr_audit_record.INCIDENT_POINT_OF_INTEREST               := NULL;
p_sr_audit_record.OLD_INCIDENT_CROSS_STREET                := NULL;
p_sr_audit_record.INCIDENT_CROSS_STREET                    := NULL;
p_sr_audit_record.OLD_INCIDENT_DIRECTION_QUALIF            := NULL;
p_sr_audit_record.INCIDENT_DIRECTION_QUALIF                := NULL;
p_sr_audit_record.OLD_INCIDENT_DISTANCE_QUALIF             := NULL;
p_sr_audit_record.INCIDENT_DISTANCE_QUALIF                 := NULL;
p_sr_audit_record.OLD_INCIDENT_DISTANCE_QUAL_UOM           := NULL;
p_sr_audit_record.INCIDENT_DISTANCE_QUAL_UOM               := NULL;
p_sr_audit_record.OLD_INCIDENT_ADDRESS2                    := NULL;
p_sr_audit_record.INCIDENT_ADDRESS2                        := NULL;
p_sr_audit_record.OLD_INCIDENT_ADDRESS3                    := NULL;
p_sr_audit_record.INCIDENT_ADDRESS3                        := NULL;
p_sr_audit_record.OLD_INCIDENT_ADDRESS4                    := NULL;
p_sr_audit_record.INCIDENT_ADDRESS4                        := NULL;
p_sr_audit_record.OLD_INCIDENT_ADDRESS_STYLE               := NULL;
p_sr_audit_record.INCIDENT_ADDRESS_STYLE                   := NULL;
p_sr_audit_record.OLD_INCIDENT_ADDR_LNS_PHONETIC           := NULL;
p_sr_audit_record.INCIDENT_ADDR_LNS_PHONETIC               := NULL;
p_sr_audit_record.OLD_INCIDENT_PO_BOX_NUMBER               := NULL;
p_sr_audit_record.INCIDENT_PO_BOX_NUMBER                   := NULL;
p_sr_audit_record.OLD_INCIDENT_HOUSE_NUMBER                := NULL;
p_sr_audit_record.INCIDENT_HOUSE_NUMBER                    := NULL;
p_sr_audit_record.OLD_INCIDENT_STREET_SUFFIX               := NULL;
p_sr_audit_record.INCIDENT_STREET_SUFFIX                   := NULL;
p_sr_audit_record.OLD_INCIDENT_STREET                      := NULL;
p_sr_audit_record.INCIDENT_STREET                          := NULL;
p_sr_audit_record.OLD_INCIDENT_STREET_NUMBER               := NULL;
p_sr_audit_record.INCIDENT_STREET_NUMBER                   := NULL;
p_sr_audit_record.OLD_INCIDENT_FLOOR                       := NULL;
p_sr_audit_record.INCIDENT_FLOOR                           := NULL;
p_sr_audit_record.OLD_INCIDENT_SUITE                       := NULL;
p_sr_audit_record.INCIDENT_SUITE                           := NULL;
p_sr_audit_record.OLD_INCIDENT_POSTAL_PLUS4_CODE           := NULL;
p_sr_audit_record.INCIDENT_POSTAL_PLUS4_CODE               := NULL;
p_sr_audit_record.OLD_INCIDENT_POSITION                    := NULL;
p_sr_audit_record.INCIDENT_POSITION                        := NULL;
p_sr_audit_record.OLD_INCIDENT_LOC_DIRECTIONS              := NULL;
p_sr_audit_record.INCIDENT_LOC_DIRECTIONS                  := NULL;
p_sr_audit_record.OLD_INCIDENT_LOC_DESCRIPTION             := NULL;
p_sr_audit_record.INCIDENT_LOC_DESCRIPTION                 := NULL;
p_sr_audit_record.OLD_INSTALL_SITE_ID                      := NULL;
p_sr_audit_record.INSTALL_SITE_ID                          := NULL;
p_sr_audit_record.INCIDENT_LAST_MODIFIED_DATE              := NULL;
p_sr_audit_record.UPDATED_ENTITY_CODE                      := NULL;
p_sr_audit_record.UPDATED_ENTITY_ID                        := NULL;
p_sr_audit_record.ENTITY_ACTIVITY_CODE                     := NULL;
p_sr_audit_record.OLD_TIER_VERSION                         := NULL;
p_sr_audit_record.TIER_VERSION                             := NULL;
-- anmukher --09/12/03
p_sr_audit_record.OLD_INC_OBJECT_VERSION_NUMBER            := NULL;
p_sr_audit_record.INC_OBJECT_VERSION_NUMBER                := NULL;
p_sr_audit_record.OLD_INC_REQUEST_ID                       := NULL;
p_sr_audit_record.INC_REQUEST_ID                           := NULL;
p_sr_audit_record.OLD_INC_PROGRAM_APPLICATION_ID           := NULL;
p_sr_audit_record.INC_PROGRAM_APPLICATION_ID               := NULL;
p_sr_audit_record.OLD_INC_PROGRAM_ID                       := NULL;
p_sr_audit_record.INC_PROGRAM_ID                           := NULL;
p_sr_audit_record.OLD_INC_PROGRAM_UPDATE_DATE              := NULL;
p_sr_audit_record.INC_PROGRAM_UPDATE_DATE                  := NULL;
p_sr_audit_record.OLD_OWNING_DEPARTMENT_ID                 := NULL;
p_sr_audit_record.OWNING_DEPARTMENT_ID                     := NULL;
p_sr_audit_record.OLD_INCIDENT_LOCATION_TYPE               := NULL;
p_sr_audit_record.INCIDENT_LOCATION_TYPE                   := NULL;
p_sr_audit_record.OLD_UNASSIGNED_INDICATOR                 := NULL;
p_sr_audit_record.UNASSIGNED_INDICATOR                     := NULL;
p_sr_audit_record.maint_organization_id                    := NULL;
p_sr_audit_record.old_maint_organization_id                := NULL;

END initialize_audit_rec;

--Procedure to support MLS
PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM CS_INCIDENTS_ALL_TL T
  WHERE NOT EXISTS
  (SELECT NULL
   FROM CS_INCIDENTS_ALL_B B
   WHERE B.INCIDENT_ID = T.INCIDENT_ID
  );

  UPDATE CS_INCIDENTS_ALL_TL T SET (
  SUMMARY,
  RESOLUTION_SUMMARY
  --SR_CREATION_CHANNEL
	 ) = (SELECT
  B.SUMMARY,
  B.RESOLUTION_SUMMARY
  --B.SR_CREATION_CHANNEL
  FROM CS_INCIDENTS_ALL_TL B
  WHERE B.INCIDENT_ID = T.INCIDENT_ID
  AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
   T.INCIDENT_ID,
   T.LANGUAGE
  ) IN (SELECT
   SUBT.INCIDENT_ID,
   SUBT.LANGUAGE
   FROM CS_INCIDENTS_ALL_TL SUBB, CS_INCIDENTS_ALL_TL SUBT
   WHERE SUBB.INCIDENT_ID = SUBT.INCIDENT_ID
   AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
   AND (SUBB.SUMMARY <> SUBT.SUMMARY
   OR SUBB.RESOLUTION_SUMMARY <> SUBT.RESOLUTION_SUMMARY
   OR (SUBB.RESOLUTION_SUMMARY IS NULL AND SUBT.RESOLUTION_SUMMARY IS NOT NULL)
   OR (SUBB.RESOLUTION_SUMMARY IS NOT NULL AND SUBT.RESOLUTION_SUMMARY IS  NULL)
   --or SUBB.SR_CREATION_CHANNEL <> SUBT.SR_CREATION_CHANNEL
   --or (SUBB.SR_CREATION_CHANNEL is null and SUBT.SR_CREATION_CHANNEL is not null)
   --or (SUBB.SR_CREATION_CHANNEL is not null and SUBT.SR_CREATION_CHANNEL is null)
   ));

    INSERT INTO CS_INCIDENTS_ALL_TL (
    INCIDENT_ID,
    SUMMARY,
    RESOLUTION_SUMMARY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    --SR_CREATION_CHANNEL,
    LANGUAGE,
    SOURCE_LANG
 ) SELECT
    B.INCIDENT_ID,
    B.SUMMARY,
    B.RESOLUTION_SUMMARY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    --B.SR_CREATION_CHANNEL,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
    FROM CS_INCIDENTS_ALL_TL B, FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND B.LANGUAGE = USERENV('LANG')
    AND NOT EXISTS
	 (SELECT NULL
	  FROM CS_INCIDENTS_ALL_TL T
       WHERE T.INCIDENT_ID = B.INCIDENT_ID
       AND T.LANGUAGE = L.LANGUAGE_CODE);

   -- This is for the incident_audit_table
  DELETE FROM CS_INCIDENTS_AUDIT_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM CS_INCIDENTS_AUDIT_B B
    WHERE B.INCIDENT_AUDIT_ID = T.INCIDENT_AUDIT_ID
    );

  UPDATE CS_INCIDENTS_AUDIT_TL T SET (
      CHANGE_DESCRIPTION
    ) = (SELECT
      B.CHANGE_DESCRIPTION
    FROM CS_INCIDENTS_AUDIT_TL B
    WHERE B.INCIDENT_AUDIT_ID = T.INCIDENT_AUDIT_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.INCIDENT_AUDIT_ID,
      T.LANGUAGE
  ) IN (SELECT
    SUBT.INCIDENT_AUDIT_ID,
    SUBT.LANGUAGE
    FROM CS_INCIDENTS_AUDIT_TL SUBB, CS_INCIDENTS_AUDIT_TL SUBT
    WHERE SUBB.INCIDENT_AUDIT_ID = SUBT.INCIDENT_AUDIT_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.CHANGE_DESCRIPTION <> SUBT.CHANGE_DESCRIPTION
    OR (SUBB.CHANGE_DESCRIPTION IS NULL AND SUBT.CHANGE_DESCRIPTION IS NOT NULL)
    OR (SUBB.CHANGE_DESCRIPTION IS NOT NULL AND SUBT.CHANGE_DESCRIPTION IS NULL)
  ));

  INSERT INTO CS_INCIDENTS_AUDIT_TL (
    INCIDENT_AUDIT_ID,
    INCIDENT_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CHANGE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    B.INCIDENT_AUDIT_ID,
    B.INCIDENT_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CHANGE_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM CS_INCIDENTS_AUDIT_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM CS_INCIDENTS_AUDIT_TL T
    WHERE T.INCIDENT_AUDIT_ID = B.INCIDENT_AUDIT_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);


END ADD_LANGUAGE;


-- Procedure Lock Row
-- This is called by the Service Request form to lock a record
PROCEDURE LOCK_ROW(
			    X_INCIDENT_ID		NUMBER,
			    X_OBJECT_VERSION_NUMBER	NUMBER
			    )
IS
  CURSOR C IS
	SELECT OBJECT_VERSION_NUMBER
	FROM   CS_INCIDENTS_ALL_B
	WHERE  INCIDENT_ID = X_INCIDENT_ID
	FOR UPDATE OF INCIDENT_ID NOWAIT;

  RECINFO C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO RECINFO;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (RECINFO.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END LOCK_ROW;

   FUNCTION Get_API_Revision RETURN NUMBER IS
   BEGIN
       RETURN G_API_REVISION;
   END Get_API_Revision;


/** Following 3 functions are added for UWQ -SR integration for
    pop-messages in service request form
**/

 FUNCTION Get_Importance_Level(P_Severity_Id IN NUMBER)
 RETURN NUMBER IS
     CURSOR c_imp_csr IS
     SELECT importance_level
     FROM   cs_incident_severities_b
     WHERE  incident_severity_id = p_severity_id;
     l_imp_level  NUMBER;
   BEGIN
     OPEN  c_imp_csr;
     FETCH c_imp_csr INTO l_imp_level;
     CLOSE c_imp_csr;

     RETURN(l_imp_level);
   END Get_Importance_Level;

   FUNCTION Get_Old_Importance_level(p_incident_id IN NUMBER)
   RETURN NUMBER IS
     CURSOR c_imp_old_csr IS
     SELECT importance_level
     FROM cs_incident_severities_b
     WHERE incident_severity_id =( SELECT incident_severity_id
                                   FROM CS_INCIDENTS_ALL_B
                                   WHERE incident_id = p_incident_id);
    l_old_imp_level  NUMBER;
   BEGIN
     OPEN c_imp_old_csr;
     FETCH c_imp_old_csr INTO l_old_imp_level;
     CLOSE c_imp_old_csr;
     RETURN(l_old_imp_level);
   END Get_Old_Importance_level;

  FUNCTION Get_Owner_id(p_incident_id IN NUMBER)
    RETURN NUMBER IS
     CURSOR c_owner_id IS
     SELECT incident_owner_id
     FROM cs_incidents_all_b
     WHERE incident_id = p_incident_id;
     l_owner_id  NUMBER;
   BEGIN
     OPEN c_owner_id;
     FETCH c_owner_id INTO l_owner_id;
     CLOSE c_owner_id;

     RETURN(l_owner_id);
   END Get_Owner_id;

   FUNCTION Get_Title(P_Object_Code IN VARCHAR2)
   RETURN VARCHAR2 IS
     CURSOR c_title_csr IS
     SELECT description
     FROM   jtf_objects_vl
     WHERE  object_code=P_Object_Code;
     --Fixed bug#2802393, changed length from 30 to 80
     l_title VARCHAR2(80);
   BEGIN
     OPEN  c_title_csr;
     FETCH c_title_csr INTO l_title;
     CLOSE c_title_csr;

     RETURN(l_title);
   END Get_Title;

   FUNCTION Get_Message(p_message_code IN VARCHAR2)
   RETURN VARCHAR2 IS
     CURSOR c_uwq_message IS
     SELECT message_text
     FROM fnd_new_messages
     WHERE  application_id = 170
     AND    message_name = p_message_code
     AND    language_code = USERENV('LANG');
     --Fixed bug#2802393, changed length from 80 to 2000
     l_uwq_message VARCHAR2(2000);
   BEGIN
     OPEN c_uwq_message;
     FETCH c_uwq_message INTO l_uwq_message;
     CLOSE c_uwq_message;

     RETURN(l_uwq_message);
   END Get_Message;

/* Added for enh.2655115, procedure to get the value of status_flag for
   inserting into cs_incidents_all_b table. If the closed flag is Y then
   the status is closed, else its open.created by shijain dated nov 27th 2002*/

   FUNCTION GET_STATUS_FLAG( p_incident_status_id IN  NUMBER)
   RETURN VARCHAR2 IS
     CURSOR get_close_flag IS
     SELECT close_flag
     FROM   cs_incident_statuses_b
     WHERE  incident_status_id = p_incident_status_id;

     l_closed_flag VARCHAR2(1);
     l_status_flag VARCHAR2(1):='O';
   BEGIN
     OPEN get_close_flag;
     FETCH get_close_flag INTO l_closed_flag;
     CLOSE get_close_flag;

     IF l_closed_flag = 'Y' THEN
        l_status_flag:= 'C';
     ELSE
        l_status_flag:= 'O';
     END IF;
     RETURN(l_status_flag);

   END GET_STATUS_FLAG;




/* Added for enh.2690787, procedure to get the value of primary_contact_id for
   inserting into cs_incidents_all_b table based on the incident_id and the
   primary flag from the cs_hz_sr_contact_points table by shijain

FUNCTION GET_PRIMARY_CONTACT( p_incident_id IN  NUMBER)
RETURN NUMBER IS

     CURSOR get_primary_contact IS
     SELECT sr_contact_point_id
     FROM   cs_hz_sr_contact_points
     WHERE  incident_id = p_incident_id
     AND    primary_flag = 'Y';

     l_primary_contact NUMBER;

BEGIN
     OPEN get_primary_contact;
     FETCH get_primary_contact INTO l_primary_contact;
     CLOSE get_primary_contact;

     RETURN(l_primary_contact);

END GET_PRIMARY_CONTACT;
*/

/* This is a overloaded procedure for create service request which is mainly
   created for making the changes for 1159 backward compatiable. This does not
   contain the following parameters:-
   x_individual_owner, x_group_owner, x_individual_type and p_auto_assign.
   and will call the above procedure with all these parameters and version
   as 3.0*/

PROCEDURE Create_ServiceRequest(
    p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_org_id                 IN    NUMBER   DEFAULT NULL,
    p_request_id             IN    NUMBER   DEFAULT NULL,
    p_request_number         IN    VARCHAR2 DEFAULT NULL,
    p_invocation_mode        IN    VARCHAR2 := 'NORMAL' ,
    p_service_request_rec    IN    SERVICE_REQUEST_REC_TYPE,
    p_notes                  IN    NOTES_TABLE,
    p_contacts               IN    CONTACTS_TABLE,
    p_default_contract_sla_ind IN  VARCHAR2 Default 'N',
    x_request_id             OUT   NOCOPY NUMBER,
    x_request_number         OUT   NOCOPY VARCHAR2,
    x_interaction_id         OUT   NOCOPY NUMBER,
    x_workflow_process_id    OUT   NOCOPY NUMBER
) IS
     l_api_name             CONSTANT VARCHAR2(30)    := 'Create_ServiceRequest';
     l_api_version          CONSTANT NUMBER          := 2.0;
     l_api_name_full        CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
     l_return_status        VARCHAR2(1);
     l_individual_owner     NUMBER;
     l_group_owner          NUMBER;
     l_individual_type      VARCHAR2(30);


BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Create_ServiceRequest_PVT;

 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CS_ServiceRequest_PVT.Create_ServiceRequest
    ( p_api_version                  => 3.0,
      p_init_msg_list                => p_init_msg_list,
      p_commit                       => p_commit,
      p_validation_level             => p_validation_level,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_resp_appl_id                 => p_resp_appl_id,
      p_resp_id                      => p_resp_id,
      p_user_id                      => p_user_id,
      p_login_id                     => p_login_id,
      p_org_id                       => p_org_id,
      p_request_id                   => p_request_id,
      p_request_number               => p_request_number,
      p_invocation_mode              => p_invocation_mode,
      p_service_request_rec          => p_service_request_rec,
      p_notes                        => p_notes,
      p_contacts                     => p_contacts,
      p_auto_assign                  => 'N',
      p_default_contract_sla_ind     => p_default_contract_sla_ind,
      x_request_id                   => x_request_id,
      x_request_number               => x_request_number,
      x_interaction_id               => x_interaction_id,
      x_workflow_process_id          => x_workflow_process_id,
      x_individual_owner             => l_individual_owner,
      x_group_owner                  => l_group_owner,
      x_individual_type              => l_individual_type
    );

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_ServiceRequest_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Create_ServiceRequest;
--
PROCEDURE handle_missing_value(x_new_value in out nocopy varchar2,
                               p_old_value in            varchar2) is
BEGIN
  -- if new value is g_miss_char then it should be set to value from database
  -- in case of new value being null, if condition will fail and new value will remain
  -- set to null
  IF (x_new_value = FND_API.G_MISS_CHAR) then
      x_new_value := p_old_value;
  END IF;
END;
-- -----------------------------------------------------------------------------
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 12/23/05 smisra   Bug 4868997
--                   Added a condition of application_id column of both tables.
--                   Value of application id should be 170
-- -----------------------------------------------------------------------------
PROCEDURE set_attribute_value(x_attr_val     in out nocopy varchar2,
                              p_attr_val_old in            varchar2,
                              p_ff_name      in            varchar2,
                              p_attr_col     in            varchar2) is
  p_app_id  NUMBER;
  CURSOR c_global_attr is
   select 1
     from fnd_descr_flex_column_usages a,
          fnd_descr_flex_contexts b
   where a.descriptive_flexfield_name = p_ff_name
     and b.descriptive_flexfield_name = p_ff_name
     and a.application_column_name = p_attr_col
     and a.descriptive_flex_context_code = b.descriptive_flex_context_code
     AND a.application_id = p_app_id
     AND b.application_id = p_app_id
     and B.global_flag = 'Y';
  l_dummy number;
BEGIN

  p_app_id := 170;
  if (x_attr_val = FND_API.G_MISS_CHAR) then
     open c_global_attr;
     fetch c_global_attr into l_dummy;
     if c_global_attr%found then
        x_attr_val := p_attr_val_old;
     else
        x_attr_val := null;
     end if;
     close c_global_attr;
  end if;
END set_attribute_value;
------------------------

--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_SERVICEREQUEST
--
--  Parameters (other than standard ones)
--  IN
--      p_purge_set_id                  :   Id that helps identify a set of SRs
--                                          that were purged in a single batch
--      p_processing_set_id             :   Id that helps the API in identifying
--                                          the set of SRs for which the child
--                                          objects have to be deleted.
--      p_purge_source_with_open_task   :   Indicates whether the SRs containing
--                                          OPEN non field service tasks should
--                                          be purged or not
--      p_audit_required                :   Indicates if audit information has
--                                          to be generated after purging the
--                                          service requests
--
--  Description
--      This API physically removes the SRs and all its child objects after
--      performing validations wherever required. This is a wrapper which
--      delegates the work to another helper API named
--      cs_sr_delete_util.delete_servicerequest
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug-2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This API physically removes the SRs and all its child objects after
 * performing validations wherever required. This is a wrapper which delegates
 * the work to another helper API named
 * cs_sr_delete_util.delete_servicerequest
 * @param p_purge_set_id Id that helps identify a set of SRs that were purged
 * in a single batch
 * @param p_processing_set_id Id that helps the API in identifying the set of
 * SRs for which the child
 * objects have to be deleted.
 * @param p_purge_source_with_open_task Indicates whether the SRs containing
 * OPEN non field service
 * tasks should be purged or not
 * @param p_audit_required Indicates if audit information has to be generated
 * after purging the
 * service requests
 * @rep:scope Internal
 * @rep:product CS
 * @rep:displayname Delete Service Requests
 */
PROCEDURE Delete_ServiceRequest
(
  p_api_version_number            IN  NUMBER := 1.0
, p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level              IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_processing_set_id             IN  NUMBER
, p_purge_set_id                  IN  NUMBER
, p_purge_source_with_open_task   IN  VARCHAR2
, p_audit_required                IN  VARCHAR2
, x_return_status                 OUT NOCOPY  VARCHAR2
, x_msg_count                     OUT NOCOPY  NUMBER
, x_msg_data                      OUT NOCOPY  VARCHAR2
)
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER        := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30)  := 'DELETE_SERVICEREQUEST';
L_API_NAME_FULL CONSTANT VARCHAR2(61)  := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

x_msg_index_out NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_purge_source_with_open_task:' || p_purge_source_with_open_task
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_processing_set_id:' || p_processing_set_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 7'
    , 'p_purge_set_id:' || p_purge_set_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 8'
    , 'p_audit_required:' || p_audit_required
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF p_processing_set_id IS NULL
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'p_processing_set_id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF  p_purge_source_with_open_task IS NULL
  OR  NVL(p_purge_source_with_open_task, 'X') NOT IN ('Y', 'N')
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'p_purge_source_with_open_task_invalid'
      , 'p_purge_source_with_open_task value is invalid.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_purge_source_with_open_task');
    FND_MESSAGE.Set_Token
    (
      'CURRVAL'
    , NVL(p_purge_source_with_open_task, 'NULL')
    );
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF  p_audit_required IS NULL
  OR  NVL(p_audit_required, 'X') NOT IN ('Y', 'N')
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'audit_required_invalid'
      , 'p_audit_required value is invalid.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_audit_required');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(p_audit_required, 'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'purge_valid_start'
      , 'calling the SR delete validation API '
        || 'cs_sr_delete_util.delete_sr_validations'
      );
    END IF;

    -- The following procedure call performs validations on child objects
    -- and marks the purge_status in the global temp table. This status
    -- is used by the delete_servicerequest call to identify the SRs that
    -- can be actually purged.

    CS_SR_DELETE_UTIL.Delete_Sr_Validations
    (
      p_api_version_number          => '1.0'
    , p_init_msg_list               => FND_API.G_FALSE
    , p_commit                      => FND_API.G_FALSE
    , p_object_type                 => 'SR'
    , p_processing_set_id           => p_processing_set_id
    , p_purge_source_with_open_task => p_purge_source_with_open_task
    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data
    );

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'purge_valid_end'
      , 'returned from the SR delete validation API with status '
        || x_return_status
      );
    END IF;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'purge_start'
      , 'calling the SR delete helper API '
        || 'cs_sr_delete_util.delete_servicerequest'
      );
    END IF;

    -- This call refers to the SRs in the global temp table with purge_status
    -- null and calls other child object delete APIs to delete the child objects
    -- of SRs and also deletes the SRs from the base and TL tables.

    CS_SR_DELETE_UTIL.Delete_ServiceRequest
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => 'SR'
    , p_purge_set_id       => p_purge_set_id
    , p_audit_required     => p_audit_required
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'purge_end'
      , 'returned from the SR delete helper API with status ' || x_return_status
      );
    END IF;

    IF  p_commit = FND_API.G_TRUE
    AND x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      COMMIT;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'commit'
        , 'Performed a COMMIT.'
        );
      END IF;
    END IF;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'unexpected_error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_DEL_API_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Delete_ServiceRequest;
-- -----------------------------------------------------------------------------
-- Procedure Name : process_sr_ext_attrs
-- Parameters     : For in out parameter, please look at procedure
--                  process_sr_ext_attrs in file csvextb.pls
-- IN             :
-- OUT            :
--
-- Description    : This is a wrapper for procedure
--                  cs_servicerequest_pvt.process_sr_ext_attrs
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/23/05 smisra   Created
-- -----------------------------------------------------------------------------
PROCEDURE process_sr_ext_attrs
( p_api_version         IN         NUMBER
, p_init_msg_list       IN         VARCHAR2 DEFAULT NULL
, p_commit              IN         VARCHAR2 DEFAULT NULL
, p_incident_id         IN         NUMBER
, p_ext_attr_grp_tbl    IN         CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
, p_ext_attr_tbl        IN         CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
, p_modified_by         IN         NUMBER   DEFAULT NULL
, p_modified_on         IN         DATE     DEFAULT NULL
, x_failed_row_id_list  OUT NOCOPY VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_errorcode           OUT NOCOPY NUMBER
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
) IS
BEGIN
  CS_SR_EXTATTRIBUTES_PVT.process_sr_ext_attrs
  ( p_api_version         => p_api_version
  , p_init_msg_list       => p_init_msg_list
  , p_commit              => p_commit
  , p_incident_id         => p_incident_id
  , p_ext_attr_grp_tbl    => p_ext_attr_grp_tbl
  , p_ext_attr_tbl        => p_ext_attr_tbl
  , p_modified_by         => p_modified_by
  , p_modified_on         => p_modified_on
  , x_failed_row_id_list  => x_failed_row_id_list
  , x_return_status       => x_return_status
  , x_errorcode           => x_errorcode
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  );
END process_sr_ext_attrs;

-- -----------------------------------------------------------------------------
-- Procedure Name : Log_SR_PVT_Parameters
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    : Procedure to LOG the in parameters of PVT SR procedures
--                  service request rec and notes, contacts tables are covered.
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 09/06/05 pkesani   Created
-- -----------------------------------------------------------------------------

PROCEDURE Log_SR_PVT_Parameters
( p_service_request_rec   	  IN         service_request_rec_type
,p_notes                 	  IN         notes_table
,p_contacts              	  IN         contacts_table
)
IS
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Create_ServiceRequest';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
  l_note_index                  BINARY_INTEGER;
  l_contact_index               BINARY_INTEGER;
BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
--- service_request_rec_type parameters --
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_date	:' || p_service_request_rec.request_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'type_id	:' || p_service_request_rec.type_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'status_id   	:' || p_service_request_rec.status_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'severity_id 	:' || p_service_request_rec.severity_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'urgency_id  	:' || p_service_request_rec.urgency_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'closed_date 	:' || p_service_request_rec.closed_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner_id    	:' || p_service_request_rec.owner_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner_group_id   	:' || p_service_request_rec.owner_group_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'publish_flag	:' || p_service_request_rec.publish_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'summary	:' || p_service_request_rec.summary
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'caller_type 	:' || p_service_request_rec.caller_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_id 	:' || p_service_request_rec.customer_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_number  	:' || p_service_request_rec.customer_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'employee_id 	:' || p_service_request_rec.employee_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'verify_cp_flag   	:' || p_service_request_rec.verify_cp_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_product_id   	:' || p_service_request_rec.customer_product_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'platform_id 	:' || p_service_request_rec.platform_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'platform_version	:' || p_service_request_rec.platform_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'db_version	:' || p_service_request_rec.db_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'platform_version_id   	:' || p_service_request_rec.platform_version_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_component_id  	:' || p_service_request_rec.cp_component_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_component_version_id    	:' || p_service_request_rec.cp_component_version_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_subcomponent_id    	:' || p_service_request_rec.cp_subcomponent_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_subcomponent_version_id 	:' || p_service_request_rec.cp_subcomponent_version_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'language_id 	:' || p_service_request_rec.language_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'language    	:' || p_service_request_rec.language
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_id	:' || p_service_request_rec.inventory_item_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_org_id 	:' || p_service_request_rec.inventory_org_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'current_serial_number 	:' || p_service_request_rec.current_serial_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'original_order_number 	:' || p_service_request_rec.original_order_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'purchase_order_num    	:' || p_service_request_rec.purchase_order_num
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'problem_code	:' || p_service_request_rec.problem_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'exp_resolution_date   	:' || p_service_request_rec.exp_resolution_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'install_site_use_id   	:' || p_service_request_rec.install_site_use_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_1   	:' || p_service_request_rec.request_attribute_1
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_2   	:' || p_service_request_rec.request_attribute_2
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_3   	:' || p_service_request_rec.request_attribute_3
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_4   	:' || p_service_request_rec.request_attribute_4
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_5   	:' || p_service_request_rec.request_attribute_5
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_6   	:' || p_service_request_rec.request_attribute_6
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_7   	:' || p_service_request_rec.request_attribute_7
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_8   	:' || p_service_request_rec.request_attribute_8
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_9   	:' || p_service_request_rec.request_attribute_9
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_10  	:' || p_service_request_rec.request_attribute_10
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_11  	:' || p_service_request_rec.request_attribute_11
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_12  	:' || p_service_request_rec.request_attribute_12
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_13  	:' || p_service_request_rec.request_attribute_13
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_14  	:' || p_service_request_rec.request_attribute_14
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_15  	:' || p_service_request_rec.request_attribute_15
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_context  	:' || p_service_request_rec.request_context
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_1  	:' || p_service_request_rec.external_attribute_1
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_2  	:' || p_service_request_rec.external_attribute_2
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_3  	:' || p_service_request_rec.external_attribute_3
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_4  	:' || p_service_request_rec.external_attribute_4
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_5  	:' || p_service_request_rec.external_attribute_5
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_6  	:' || p_service_request_rec.external_attribute_6
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_7  	:' || p_service_request_rec.external_attribute_7
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_8  	:' || p_service_request_rec.external_attribute_8
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_9  	:' || p_service_request_rec.external_attribute_9
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_10 	:' || p_service_request_rec.external_attribute_10
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_11 	:' || p_service_request_rec.external_attribute_11
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_12 	:' || p_service_request_rec.external_attribute_12
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_13 	:' || p_service_request_rec.external_attribute_13
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_14 	:' || p_service_request_rec.external_attribute_14
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_15 	:' || p_service_request_rec.external_attribute_15
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_context 	:' || p_service_request_rec.external_context
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_site_use_id   	:' || p_service_request_rec.bill_to_site_use_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_contact_id    	:' || p_service_request_rec.bill_to_contact_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_site_use_id   	:' || p_service_request_rec.ship_to_site_use_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_contact_id    	:' || p_service_request_rec.ship_to_contact_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resolution_code  	:' || p_service_request_rec.resolution_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'act_resolution_date   	:' || p_service_request_rec.act_resolution_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'public_comment_flag   	:' || p_service_request_rec.public_comment_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'parent_interaction_id 	:' || p_service_request_rec.parent_interaction_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contract_service_id   	:' || p_service_request_rec.contract_service_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contract_id 	:' || p_service_request_rec.contract_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'project_number   	:' || p_service_request_rec.project_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'qa_collection_plan_id 	:' || p_service_request_rec.qa_collection_plan_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'account_id  	:' || p_service_request_rec.account_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resource_type    	:' || p_service_request_rec.resource_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resource_subtype_id   	:' || p_service_request_rec.resource_subtype_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_po_number   	:' || p_service_request_rec.cust_po_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_ticket_number	:' || p_service_request_rec.cust_ticket_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'sr_creation_channel   	:' || p_service_request_rec.sr_creation_channel
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'obligation_date  	:' || p_service_request_rec.obligation_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'time_zone_id	:' || p_service_request_rec.time_zone_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'time_difference  	:' || p_service_request_rec.time_difference
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'site_id	:' || p_service_request_rec.site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_site_id 	:' || p_service_request_rec.customer_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'territory_id	:' || p_service_request_rec.territory_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'initialize_flag  	:' || p_service_request_rec.initialize_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_revision_id   	:' || p_service_request_rec.cp_revision_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_item_revision	:' || p_service_request_rec.inv_item_revision
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_component_id	:' || p_service_request_rec.inv_component_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_component_version 	:' || p_service_request_rec.inv_component_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_subcomponent_id   	:' || p_service_request_rec.inv_subcomponent_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_subcomponent_version   	:' || p_service_request_rec.inv_subcomponent_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'tier   	:' || p_service_request_rec.tier
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'tier_version	:' || p_service_request_rec.tier_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'operating_system 	:' || p_service_request_rec.operating_system
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'operating_system_version   	:' || p_service_request_rec.operating_system_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'database    	:' || p_service_request_rec.database
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_pref_lang_id	:' || p_service_request_rec.cust_pref_lang_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'category_id 	:' || p_service_request_rec.category_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'group_type  	:' || p_service_request_rec.group_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'group_territory_id    	:' || p_service_request_rec.group_territory_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_platform_org_id   	:' || p_service_request_rec.inv_platform_org_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'product_revision 	:' || p_service_request_rec.product_revision
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'component_version	:' || p_service_request_rec.component_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'subcomponent_version  	:' || p_service_request_rec.subcomponent_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'comm_pref_code   	:' || p_service_request_rec.comm_pref_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'last_update_date 	:' || p_service_request_rec.last_update_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'last_updated_by  	:' || p_service_request_rec.last_updated_by
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'creation_date    	:' || p_service_request_rec.creation_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'created_by  	:' || p_service_request_rec.created_by
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'last_update_login	:' || p_service_request_rec.last_update_login
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner_assigned_time   	:' || p_service_request_rec.owner_assigned_time
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner_assigned_flag   	:' || p_service_request_rec.owner_assigned_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'last_update_channel   	:' || p_service_request_rec.last_update_channel
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_pref_lang_code   	:' || p_service_request_rec.cust_pref_lang_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'load_balance	:' || p_service_request_rec.load_balance
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'assign_owner	:' || p_service_request_rec.assign_owner
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'category_set_id  	:' || p_service_request_rec.category_set_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_reference    	:' || p_service_request_rec.external_reference
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'system_id   	:' || p_service_request_rec.system_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'error_code  	:' || p_service_request_rec.error_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_occurred_date	:' || p_service_request_rec.incident_occurred_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_resolved_date	:' || p_service_request_rec.incident_resolved_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inc_responded_by_date 	:' || p_service_request_rec.inc_responded_by_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resolution_summary    	:' || p_service_request_rec.resolution_summary
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_id  	:' || p_service_request_rec.incident_location_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address 	:' || p_service_request_rec.incident_address
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_city    	:' || p_service_request_rec.incident_city
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_state   	:' || p_service_request_rec.incident_state
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_country 	:' || p_service_request_rec.incident_country
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_province	:' || p_service_request_rec.incident_province
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_postal_code  	:' || p_service_request_rec.incident_postal_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_county  	:' || p_service_request_rec.incident_county
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner  	:' || p_service_request_rec.owner
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'group_owner 	:' || p_service_request_rec.group_owner
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_number   	:' || p_service_request_rec.cc_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_expiration_date    	:' || p_service_request_rec.cc_expiration_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_type_code	:' || p_service_request_rec.cc_type_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_first_name    	:' || p_service_request_rec.cc_first_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_last_name	:' || p_service_request_rec.cc_last_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_middle_name   	:' || p_service_request_rec.cc_middle_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_id   	:' || p_service_request_rec.cc_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'coverage_type    	:' || p_service_request_rec.coverage_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_account_id    	:' || p_service_request_rec.bill_to_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_account_id    	:' || p_service_request_rec.ship_to_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_phone_id   	:' || p_service_request_rec.customer_phone_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_email_id   	:' || p_service_request_rec.customer_email_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'creation_program_code 	:' || p_service_request_rec.creation_program_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'last_update_program_code   	:' || p_service_request_rec.last_update_program_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_party_id 	:' || p_service_request_rec.bill_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_party_id 	:' || p_service_request_rec.ship_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'program_id  	:' || p_service_request_rec.program_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'program_application_id	:' || p_service_request_rec.program_application_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'conc_request_id  	:' || p_service_request_rec.conc_request_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'program_login_id 	:' || p_service_request_rec.program_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_site_id  	:' || p_service_request_rec.bill_to_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_site_id  	:' || p_service_request_rec.ship_to_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_point_of_interest 	:' || p_service_request_rec.incident_point_of_interest
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_cross_street 	:' || p_service_request_rec.incident_cross_street
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_direction_qualifier    	:' || p_service_request_rec.incident_direction_qualifier
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_distance_qualifier	:' || p_service_request_rec.incident_distance_qualifier
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_distance_qual_uom 	:' || p_service_request_rec.incident_distance_qual_uom
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address2	:' || p_service_request_rec.incident_address2
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address3 	:' || p_service_request_rec.incident_address3
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address4	:' || p_service_request_rec.incident_address4
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address_style 	:' || p_service_request_rec.incident_address_style
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_addr_lines_phonetic    	:' || p_service_request_rec.incident_addr_lines_phonetic
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_po_box_number	:' || p_service_request_rec.incident_po_box_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_house_number  	:' || p_service_request_rec.incident_house_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_street_suffix	:' || p_service_request_rec.incident_street_suffix
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_street   	:' || p_service_request_rec.incident_street
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_street_number	:' || p_service_request_rec.incident_street_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_floor   	:' || p_service_request_rec.incident_floor
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_suite   	:' || p_service_request_rec.incident_suite
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_postal_plus4_code 	:' || p_service_request_rec.incident_postal_plus4_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_position	:' || p_service_request_rec.incident_position
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_directions    	:' || p_service_request_rec.incident_location_directions
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_description   	:' || p_service_request_rec.incident_location_description
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'install_site_id  	:' || p_service_request_rec.install_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'status_flag 	:' || p_service_request_rec.status_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'primary_contact_id    	:' || p_service_request_rec.primary_contact_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'old_type_maintenance_flag	:' || p_service_request_rec.old_type_maintenance_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'new_type_maintenance_flag	:' || p_service_request_rec.new_type_maintenance_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'old_type_CMRO_flag	:' || p_service_request_rec.old_type_CMRO_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'new_type_CMRO_flag	:' || p_service_request_rec.new_type_CMRO_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'item_serial_number	:' || p_service_request_rec.item_serial_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owning_dept_id	:' || p_service_request_rec.owning_dept_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_type	:' || p_service_request_rec.incident_location_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'org_id    	:' || p_service_request_rec.org_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'maint_organization_id    	:' || p_service_request_rec.maint_organization_id
    );
    /* Credit Card 9358401 */
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'instrument_payment_use_id    	:' ||
                             p_service_request_rec.instrument_payment_use_id
    );

  -- For Notes
  l_note_index := p_notes.FIRST;
  WHILE l_note_index IS NOT NULL LOOP
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note                  	:' ||p_notes(l_note_index).note
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_detail                  	:' ||p_notes(l_note_index).note_detail
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_type                  	:' ||p_notes(l_note_index).note_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_context_type_01            	:' ||p_notes(l_note_index).note_context_type_01
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_context_type_id_01         	:' ||p_notes(l_note_index).note_context_type_id_01
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_context_type_02            	:' ||p_notes(l_note_index).note_context_type_02
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_context_type_id_02      	:' ||p_notes(l_note_index).note_context_type_id_02
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_context_type_03       	:' ||p_notes(l_note_index).note_context_type_03
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'note_context_type_id_03         	:' ||p_notes(l_note_index).note_context_type_id_03
    );

    l_note_index := p_notes.NEXT(l_note_index);
  END LOOP;

  -- For Contacts
  l_contact_index := p_contacts.FIRST;
  WHILE l_contact_index IS NOT NULL LOOP
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'sr_contact_point_id             	:' ||  p_contacts(l_contact_index).sr_contact_point_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'party_id                  	:' ||  p_contacts(l_contact_index).party_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contact_point_id                	:' ||  p_contacts(l_contact_index).contact_point_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contact_point_type       	:' ||  p_contacts(l_contact_index).contact_point_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'primary_flag                  	:' ||  p_contacts(l_contact_index).primary_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contact_type                  	:' ||  p_contacts(l_contact_index).contact_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'party_role_code                 	:' ||  P_contacts(l_contact_index).party_role_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'start_date_active        	:' ||  P_contacts(l_contact_index).start_date_active
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'end_date_active                 	:' ||  P_contacts(l_contact_index).end_date_active
    );

    l_contact_index := p_contacts.NEXT(l_contact_index);
  END LOOP;

  END IF ;

END Log_SR_PVT_Parameters;

----------------------------------------------------------------------------------------------
--CREATED BY SIAHMED FOR 12.1.2 PROJECT siahmed
--this procdure will called during onetime address creation.
--this basically allows creation of one-time addresses and party sites as TCA locations via service
--request API that will be used by all EBS CRM service applications
PROCEDURE create_onetime_address
(    p_service_req_rec   IN  service_request_rec_type,
     x_msg_count         OUT NOCOPY  NUMBER,
     x_msg_data          OUT NOCOPY  VARCHAR2,
     x_return_status     OUT NOCOPY  VARCHAR2,
     x_location_id       OUT NOCOPY  NUMBER)
Is
   l_service_req_rec  service_request_rec_type DEFAULT p_service_req_rec;

   l_location_rec      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_location_id       NUMBER;
   l_loc_id            NUMBER;
   l_created_by_module VARCHAR2(150);
   l_application_id    NUMBER;
   l_init_msg_list     VARCHAR2(10);
   l_do_addr_val       VARCHAR2(10);
   l_addr_val_status   VARCHAR2(200);
   l_addr_warn_msg     VARCHAR2(2000);
   -- party site related variables
   l_party_site_rec      HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
   l_party_site_id       NUMBER;
   l_party_site_number   VARCHAR2(2000);
   -- common attributes for all return types
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);



BEGIN
   l_created_by_module                := 'SR_ONETIME';

   -- prepare the location_rec with the values that has been passed in the service_request_rec_type
   l_location_rec.address1            := l_service_req_rec.incident_address;
   l_location_rec.address2            := l_service_req_rec.incident_address2;
   l_location_rec.address3            := l_service_req_rec.incident_address3;
   l_location_rec.address4            := l_service_req_rec.incident_address4;
   l_location_rec.city                := l_service_req_rec.incident_city;
   l_location_rec.state               := l_service_req_rec.incident_state;
   l_location_rec.postal_code         := l_service_req_rec.incident_postal_code;
   l_location_rec.county              := l_service_req_rec.incident_county;
   l_location_rec.province            := l_service_req_rec.incident_province;
   l_location_rec.country             := l_service_req_rec.incident_country;
   l_location_rec.created_by_module   := l_created_by_module;
   l_location_rec.postal_plus4_code   := l_service_req_rec.incident_postal_plus4_code;
   l_location_rec.address_lines_phonetic := l_service_req_rec.incident_addr_lines_phonetic;

   --save point to be rolled back if one time address creation fails during location or site creation.
   SAVEPOINT create_onetime_address;

   IF (fnd_profile.value('CS_SR_VALIDATE_ONE_TIME_ADDRESS_AGAINST_TCA_GEOGRAPHY') = 'Y') THEN
	l_do_addr_val := 'Y';
   else
	l_do_addr_val := 'N';
   END IF;

   HZ_LOCATION_V2PUB.create_location (
     p_init_msg_list     => FND_API.G_FALSE,
     p_location_rec      => l_location_rec,
     p_do_addr_val       => l_do_addr_val,
     x_location_id       => l_location_id,
     x_addr_val_status   => l_addr_val_status,
     x_addr_warn_msg     => l_addr_warn_msg,
     x_return_status     => l_return_status,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data
     );



     --if location has been created successfully then create party_site
     --if party_site creation fails then roll back all the way to create_onetime_address;
     If l_return_status = FND_API.G_RET_STS_SUCCESS Then
          -- populating the msg_count and msg_data to capture warning during
          -- location creation.
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;

	  --party_site initialization
          l_party_site_rec.party_id          := l_service_req_rec.customer_id;
          l_party_site_rec.location_id       := l_location_id;
          l_party_site_rec.party_site_number := l_service_req_rec.site_number;
          l_party_site_rec.party_site_name   := l_service_req_rec.site_name;
          l_party_site_rec.addressee	     := l_service_req_rec.addressee;
          l_party_site_rec.created_by_module := l_created_by_module;
	  l_party_site_rec.identifying_address_flag := 'N';
	  l_party_site_rec.status := 'I';

          -- Create the party site
          HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE(
            p_init_msg_list      => l_init_msg_list,
            p_party_site_rec     => l_party_site_rec,
            x_party_site_id      => l_party_site_id,
            x_party_site_number  => l_party_site_number,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
	    );


	 If l_return_status = FND_API.G_RET_STS_SUCCESS Then
	    -- if location creation and party_site creation is both successful then pass the location_id
                x_location_id   := l_party_site_id;

                x_return_status := l_return_status;

                -- taking the following msg log out as we dont care much for
                -- party site creation messages. Will move this 2 lines up
                -- to log any warning msg during location creation as we might
                -- get warning during location verification.
                --      x_msg_count     := l_msg_count;
                --      x_msg_data      := l_msg_data;

         elsif l_return_status <> FND_API.G_RET_STS_SUCCESS Then
		x_return_status := l_return_status;
                x_msg_count     := l_msg_count;
	       	x_msg_data      := l_msg_data;

		ROLLBACK to create_onetime_address;
		--raise exception here
         END IF;


     --if location creation is not successful roll back and raise exception
     elsif  l_return_status <> FND_API.G_RET_STS_SUCCESS Then
     	  x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
	  x_msg_data      := l_msg_data || l_addr_warn_msg ;

          ROLLBACK TO create_onetime_address;
	  -- raise exception here
     END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := l_msg_data;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := l_msg_data;
END create_onetime_address;
--end of procedure  siahmed
----------------------------------------------------------------------------------------------
--update onetime address
--CREATED BY SIAHMED FOR 12.1.2 PROJECT siahmed
--this procdure will called during updation of address.
PROCEDURE update_onetime_address
(    p_service_req_rec     IN  service_request_rec_type,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     x_return_status       OUT NOCOPY  VARCHAR2)
Is
   l_service_req_rec      service_request_rec_type DEFAULT p_service_req_rec;

   l_location_rec      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_location_id       NUMBER;
   l_loc_id            NUMBER;
   l_created_by_module VARCHAR2(150);
   l_application_id    NUMBER;
   l_init_msg_list     VARCHAR2(10);
   l_do_addr_val       VARCHAR2(10);
   -- party site related variables
   l_party_site_rec      HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
   l_party_site_id       NUMBER;
   -- common attributes for all return types
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   l_ps_object_version_number NUMBER;
   l_loc_object_version_number NUMBER;
   l_addr_val_status          VARCHAR2(10);
   l_addr_warn_msg            VARCHAR2(200);


   --variables for address
   l_address1               hz_locations.address1%TYPE;
   l_address2               hz_locations.address2%TYPE;
   l_address3               hz_locations.address3%TYPE;
   l_address4               hz_locations.address4%TYPE;
   l_city                   hz_locations.city%TYPE;
   l_state                  hz_locations.state%TYPE;
   l_postal_code            hz_locations.postal_code%TYPE;
   l_county                 hz_locations.county%TYPE;
   l_province               hz_locations.province%TYPE;
   l_country                hz_locations.country%TYPE;
   l_postal_plus4_code      hz_locations.postal_plus4_code%TYPE;
   l_address_lines_phonetic hz_locations.address_lines_phonetic%TYPE;
   l_party_site_number      hz_party_sites.party_site_number%TYPE;
   l_party_site_name        hz_party_sites.party_site_name%TYPE;
   l_addressee              hz_party_sites.addressee%TYPE;

BEGIN
   SELECT a.location_id,
          a.address1,
          a.address2,
          a.address3,
          a.address4,
	  a.city,
          a.state,
          a.postal_code,
          a.county,
	  a.province,
          a.country,
          a.postal_plus4_code ,
          a.address_lines_phonetic,
	  b.party_site_number,
          b.party_site_name,
	  b.addressee,
	  a.object_version_number,
	  b.object_version_number
    INTO
          l_loc_id,
          l_address1,
          l_address2,
          l_address3,
          l_address4,
          l_city,
          l_state,
          l_postal_code,
          l_county,
          l_province,
          l_country,
          l_postal_plus4_code,
          l_address_lines_phonetic,
          l_party_site_number,
          l_party_site_name,
          l_addressee,
	  l_loc_object_version_number,
	  l_ps_object_version_number
    from hz_locations a,
         hz_party_sites b
    where b.party_site_id = l_service_req_rec.incident_location_id
    and   b.location_id = a.location_id
    and   b.created_by_module = a.created_by_module;

   l_created_by_module  := 'SR_ONETIME';


          --well not be checking if the current site ifnromation is the same as the old site information
          --as site information are not stored in the incidents table (CS_INCIDENT_ALL B)
          --we are going to just check if site information is coming in if so then just update

          IF ((nvl(l_service_req_rec.site_name,' ')   <> nvl(l_party_site_name,' ')) OR
              (nvl(l_service_req_rec.site_number,' ') <> nvl(l_party_site_number,' ')) OR
              (nvl(l_service_req_rec.addressee,' ')   <> nvl(l_addressee,' '))) THEN

              --party_site initialization
              l_party_site_rec.party_site_id     := l_service_req_rec.incident_location_id;
              l_party_site_rec.party_id          := l_service_req_rec.customer_id;
              l_party_site_rec.party_site_number := l_service_req_rec.site_number;
              -- we are doing the NVL during assignment because null is not an accepted
              -- value by the TCA api and we have to pass G_MISS_NUM OR CHAR as needed
              l_party_site_rec.party_site_name   := nvl(l_service_req_rec.site_name,FND_API.G_MISS_CHAR);
              l_party_site_rec.addressee         := nvl(l_service_req_rec.addressee,FND_API.G_MISS_CHAR);
              l_party_site_rec.created_by_module := l_created_by_module;

              SAVEPOINT UPDATE_PARTY_SITE;

              -- update  the party site
              HZ_PARTY_SITE_V2PUB.UPDATE_PARTY_SITE(
                p_init_msg_list          => l_init_msg_list,
                p_party_site_rec         => l_party_site_rec,
                p_object_version_number  => l_ps_object_version_number,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data
                );


             If l_return_status = FND_API.G_RET_STS_SUCCESS Then
                  x_return_status := l_return_status;
                  x_msg_count     := l_msg_count;
                  x_msg_data      := l_msg_data;
             elsif l_return_status <> FND_API.G_RET_STS_SUCCESS Then
                  x_return_status := l_return_status;
                  x_msg_count     := l_msg_count;
                  x_msg_data      := l_msg_data;

                  ROLLBACK to UPDATE_PARTY_SITE;
                  --raise exception here
              END IF;

          END IF; --end of update party site


          --check if any of the location fiels have been changed
          IF ((nvl(l_service_req_rec.incident_address,' ')  <> nvl(l_address1,' ')) OR
              (nvl(l_service_req_rec.incident_address2,' ') <> nvl(l_address2,' ')) OR
              (nvl(l_service_req_rec.incident_address3,' ') <> nvl(l_address3,' ')) OR
              (nvl(l_service_req_rec.incident_address4,' ') <> nvl(l_address4,' ')) OR
              (nvl(l_service_req_rec.incident_city,' ')     <> nvl(l_city,' ')) OR
              (nvl(l_service_req_rec.incident_state,' ')    <> nvl(l_state,' ')) OR
              (nvl(l_service_req_rec.incident_postal_code,' ') <> nvl(l_postal_code,' ')) OR
              (nvl(l_service_req_rec.incident_county,' ')   <> nvl(l_county,' ')) OR
              (nvl(l_service_req_rec.incident_province,' ') <> nvl(l_province,' ')) OR
              (nvl(l_service_req_rec.incident_country,' ')  <> nvl(l_country,' '))  OR
              (nvl(l_service_req_rec.incident_postal_plus4_code,' ') <> nvl(l_postal_plus4_code,' ')) OR
              (nvl(l_service_req_rec.incident_addr_lines_phonetic,' ') <> nvl(l_address_lines_phonetic,' '))) THEN

               -- prepare the location_rec with the values that has been passed in the service_request_rec_type
               -- over here we are doing nvl with G_MISS_CHAR because the TCA api does not accept nuull values
                  l_location_rec.location_id         := l_loc_id;
                  l_location_rec.address1            := nvl(l_service_req_rec.incident_address,FND_API.G_MISS_CHAR);
                  l_location_rec.address2            := nvl(l_service_req_rec.incident_address2,FND_API.G_MISS_CHAR);
                  l_location_rec.address3            := nvl(l_service_req_rec.incident_address3,FND_API.G_MISS_CHAR);
                  l_location_rec.address4            := nvl(l_service_req_rec.incident_address4,FND_API.G_MISS_CHAR);
                  l_location_rec.city                := nvl(l_service_req_rec.incident_city,FND_API.G_MISS_CHAR);
                  l_location_rec.state               := nvl(l_service_req_rec.incident_state,FND_API.G_MISS_CHAR);
                  l_location_rec.postal_code         := nvl(l_service_req_rec.incident_postal_code,FND_API.G_MISS_CHAR);
                  l_location_rec.county              := nvl(l_service_req_rec.incident_county,FND_API.G_MISS_CHAR);
                  l_location_rec.province            := nvl(l_service_req_rec.incident_province,FND_API.G_MISS_CHAR);
                  l_location_rec.country             := nvl(l_service_req_rec.incident_country,FND_API.G_MISS_CHAR);
                  l_location_rec.created_by_module   := l_created_by_module;
                  l_location_rec.postal_plus4_code   := nvl(l_service_req_rec.incident_postal_plus4_code,FND_API.G_MISS_CHAR);
                  l_location_rec.address_lines_phonetic := nvl(l_service_req_rec.incident_addr_lines_phonetic,FND_API.G_MISS_CHAR);

                  SAVEPOINT UPDATE_LOCATION;
		   IF (fnd_profile.value('CS_SR_VALIDATE_ONE_TIME_ADDRESS_AGAINST_TCA_GEOGRAPHY') = 'Y') THEN
			l_do_addr_val := 'Y';
		   else
			l_do_addr_val := 'N';
		   END IF;

                  HZ_LOCATION_V2PUB.update_location (
                       p_init_msg_list           => FND_API.G_FALSE,
                       p_location_rec            => l_location_rec,
		       p_do_addr_val             => l_do_addr_val,
                       p_object_version_number   => l_loc_object_version_number,
		       x_addr_val_status         => l_addr_val_status,
		       x_addr_warn_msg           => l_addr_warn_msg,
                       x_return_status           => l_return_status,
                       x_msg_count               => l_msg_count,
                       x_msg_data                => l_msg_data
                       );

                  If l_return_status = FND_API.G_RET_STS_SUCCESS Then
                      -- if location creation and party_site creation is both successful then pass the location_id
                      x_return_status := l_return_status;
                      x_msg_count     := l_msg_count;
                      x_msg_data      := l_msg_data;
                  elsif l_return_status <> FND_API.G_RET_STS_SUCCESS Then
                      x_return_status := l_return_status;
                      x_msg_count     := l_msg_count;
                      x_msg_data      := l_msg_data;

                      ROLLBACK to UPDATE_LOCATION;
                      --raise exception here
                  END IF;

         END IF; --end of updating location


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END update_onetime_address;
--end of procedure  siahmed

----------------------------------------------------------------------------------------------


END CS_ServiceRequest_PVT;

/
