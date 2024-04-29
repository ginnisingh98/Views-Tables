--------------------------------------------------------
--  DDL for Package CS_SERVICEREQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SERVICEREQUEST_PVT" AUTHID CURRENT_USER AS
/* $Header: csvsrs.pls 120.4.12010000.3 2010/04/03 18:18:04 rgandhi ship $ */
-- -----------------------------------------------------------------------------
-- Structure Name : related_data_type
-- components     :
--   close_flag                     Close flag asociated with SR status
--   old_close_flag                 Close flag asociated with new value of SR
--                                  status before update
--   disallow_request_update        Request update indicator associated with new
--                                  value of SR status
--   old_disallow_request_update    Request update indicator associated with SR
--                                  status before update
--   disallow_owner_update          Request owner update ind associated with
--                                  new value of SR status
--   old_disallow_owner_update      Request owner update ind associated with
--                                  SR status before update
--   disallow_product_update        Request product update ind associated with
--                                  new value of SR status
--   old_disallow_product_update    Request product update ind associated with
--                                  SR status before update
--   pending_approval_flag          pending approval flag associated with new
--                                  value of SR status
--   old_pending_approval_flag      pending approval flag associated with
--                                  SR status before update
--   intermediate_status_id         intermediate status associated with new
--                                  value of SR
--   old_intermediate_status_id     intermediate status associated with SR
--                                  before update
--   approval_action_status_id      approval status associated with new
--                                  value of SR status
--   old_approval_action_status_id  approval status associated with SR status
--                                  before update
--   rejection_action_status_id     Rejection status associated with new value
--                                  SR status
--   old_rejection_action_status_id Rejection status associated with SR status
--                                  before update
--   target_status_id               Same as status_id passed to SR API
--   autolaunch_workflow_flag       Launch workflow flag associated with SR Type
--   abort_workflow_close_flag      Abort Workflow flag associated with SR Type
--   workflow                       Workflow associated with SR Type
--   business_process_id            Business process associated with SR Type
--   primary_party_id               Primary contact for SR
--   primary_contact_point_id       Contact point for Primary contact
-- Description    : This structure holds certain attributes related following SR
--                  attributes
--                  1. old value of SR status
--                  2. new value of SR status
--                  3. new value of SR type
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 07/10/05 smisra   Created
-- -----------------------------------------------------------------------------
TYPE related_data_type IS RECORD
( close_flag                     cs_incident_statuses_b.close_flag                 % TYPE
, old_close_flag                 cs_incident_statuses_b.close_flag                 % TYPE
, disallow_request_update        cs_incident_statuses_b.disallow_request_update    % TYPE
, old_disallow_request_update    cs_incident_statuses_b.disallow_request_update    % TYPE
, disallow_owner_update          cs_incident_statuses_b.disallow_agent_dispatch    % TYPE
, old_disallow_owner_update      cs_incident_statuses_b.disallow_agent_dispatch    % TYPE
, disallow_product_update        cs_incident_statuses_b.disallow_product_update    % TYPE
, old_disallow_product_update    cs_incident_statuses_b.disallow_product_update    % TYPE
, pending_approval_flag          cs_incident_statuses_b.pending_approval_flag      % TYPE
, old_pending_approval_flag      cs_incident_statuses_b.pending_approval_flag      % TYPE
, intermediate_status_id         cs_incident_statuses_b.intermediate_status_id     % TYPE
, old_intermediate_status_id     cs_incident_statuses_b.intermediate_status_id     % TYPE
, approval_action_status_id      cs_incident_statuses_b.approval_action_status_id  % TYPE
, old_approval_action_status_id  cs_incident_statuses_b.approval_action_status_id  % TYPE
, rejection_action_status_id     cs_incident_statuses_b.rejection_action_status_id % TYPE
, old_rejection_action_status_id cs_incident_statuses_b.rejection_action_status_id % TYPE
, target_status_id               cs_incident_statuses_b.incident_status_id         % TYPE
, autolaunch_workflow_flag       cs_incident_types_b.autolaunch_workflow_flag      % TYPE
, abort_workflow_close_flag      cs_incident_types_b.abort_workflow_close_flag     % TYPE
, workflow                       cs_incident_types_b.workflow                      % TYPE
, business_process_id            cs_incident_types_b.business_process_id           % TYPE
, primary_party_id               cs_hz_sr_contact_points.party_id                  % TYPE
, primary_contact_point_id       cs_hz_sr_contact_points.contact_point_id          % TYPE
);
------------------------------------------------------------------------
-- Set up record types to be used for the Validate_ServiceRequest_Record Procedure
------------------------------------------------------------------------
TYPE Request_Validation_Rec_Type IS RECORD
( type_id                         NUMBER       := FND_API.G_MISS_NUM,
  status_id                       NUMBER       := FND_API.G_MISS_NUM,
  severity_id                     NUMBER       := FND_API.G_MISS_NUM,
  urgency_id                      NUMBER       := FND_API.G_MISS_NUM,
  resource_type                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
  owner_id                        NUMBER       := FND_API.G_MISS_NUM,
  publish_flag                    VARCHAR2(1)  := FND_API.G_MISS_CHAR,
  customer_id                     NUMBER       := FND_API.G_MISS_NUM,
  employee_id                     NUMBER       := FND_API.G_MISS_NUM,
  contact_id                      NUMBER       := FND_API.G_MISS_NUM,
  represented_by_id               NUMBER       := FND_API.G_MISS_NUM,
  customer_product_id             NUMBER       := FND_API.G_MISS_NUM,
  inventory_item_id               NUMBER       := FND_API.G_MISS_NUM,
  inventory_org_id                NUMBER       := FND_API.G_MISS_NUM,
  problem_code                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
  exp_resolution_date             DATE         := FND_API.G_MISS_DATE,
  rma_header_id                   NUMBER       := FND_API.G_MISS_NUM,
  bill_to_site_use_id             NUMBER       := FND_API.G_MISS_NUM,
  bill_to_contact_id              NUMBER       := FND_API.G_MISS_NUM,
  ship_to_site_use_id             NUMBER       := FND_API.G_MISS_NUM,
  ship_to_contact_id              NUMBER       := FND_API.G_MISS_NUM,
  -- Nullified value as thic column will no longer be used and install_site
  -- id column will be used instead by shijain dec4th 2002
  install_site_use_id             NUMBER       := FND_API.G_MISS_NUM,
  resolution_code                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
  act_resolution_date             DATE         := FND_API.G_MISS_DATE,
  current_contact_time_diff       NUMBER       := FND_API.G_MISS_NUM,
  rep_by_time_difference          NUMBER       := FND_API.G_MISS_NUM,
  validate_type                   VARCHAR2(1)  := FND_API.G_FALSE,
  validate_status                 VARCHAR2(1)  := FND_API.G_FALSE,
  validate_customer               VARCHAR2(1)  := FND_API.G_FALSE,
  validate_employee               VARCHAR2(1)  := FND_API.G_FALSE,
  validate_bill_to_site           VARCHAR2(1)  := FND_API.G_FALSE,
  validate_ship_to_site           VARCHAR2(1)  := FND_API.G_FALSE,
  validate_install_site           VARCHAR2(1)  := FND_API.G_FALSE,
  contract_service_id             NUMBER       := FND_API.G_MISS_NUM,
--04/16/01
  contract_id                     NUMBER       := FND_API.G_MISS_NUM,
  project_number                  VARCHAR2(120):= FND_API.G_MISS_CHAR,
--04/16/01
  account_id                      NUMBER       := FND_API.G_MISS_NUM,
  site_id                         NUMBER       := FND_API.G_MISS_NUM,
  territory_id                    NUMBER       := FND_API.G_MISS_NUM,
  platform_id                     NUMBER       := FND_API.G_MISS_NUM,
  platform_version		          VARCHAR2(250)  := FND_API.G_MISS_CHAR,
  db_version			VARCHAR2(250)  := FND_API.G_MISS_CHAR,
  platform_version_id        NUMBER       := FND_API.G_MISS_NUM,
  cp_component_id               NUMBER       := FND_API.G_MISS_NUM,
  cp_component_version_id      NUMBER       := FND_API.G_MISS_NUM,
  cp_subcomponent_id            NUMBER       := FND_API.G_MISS_NUM,
  cp_subcomponent_version_id    NUMBER       := FND_API.G_MISS_NUM,
  cp_revision_id             NUMBER       := FND_API.G_MISS_NUM,
  language_id                NUMBER       := FND_API.G_MISS_NUM,
  inv_item_revision          VARCHAR2(240):= FND_API.G_MISS_CHAR,
  inv_component_id           NUMBER:= FND_API.G_MISS_NUM,
  inv_component_version      VARCHAR2(90):= FND_API.G_MISS_CHAR,
  inv_subcomponent_id        NUMBER:= FND_API.G_MISS_NUM,
  inv_subcomponent_version   VARCHAR2(90):= FND_API.G_MISS_CHAR,
  caller_type                VARCHAR2(30):= FND_API.G_MISS_CHAR,
  primary_contact_id         NUMBER:= FND_API.G_MISS_NUM,
  validate_updated_status    VARCHAR2(1)  := FND_API.G_FALSE,
  updated_status_id          NUMBER       := FND_API.G_MISS_NUM,
  status_id_change           VARCHAR2(1) := FND_API.G_FALSE,
  current_serial_number      VARCHAR2(30) := FND_API.G_MISS_CHAR,
-----jngeorge-----enhancements-----11.5.6 ------07/20/01
     tier                       VARCHAR2(250) :=FND_API.G_MISS_CHAR,
     tier_version               VARCHAR2(250) := FND_API.G_MISS_CHAR,
     operating_system           VARCHAR2(250) := FND_API.G_MISS_CHAR,
     operating_system_version   VARCHAR2(250) := FND_API.G_MISS_CHAR,
     database                   VARCHAR2(250) :=FND_API.G_MISS_CHAR,
     cust_pref_lang_id          NUMBER        := FND_API.G_MISS_NUM,
     category_id                NUMBER        := FND_API.G_MISS_NUM,
     owner_group_id             NUMBER        := FND_API.G_MISS_NUM,
     group_type                 VARCHAR2(30)  := FND_API.G_MISS_CHAR,
     group_territory_id         NUMBER        := FND_API.G_MISS_NUM,
     inv_platform_org_id        NUMBER        := FND_API.G_MISS_NUM,
     product_revision           VARCHAR2(240) := FND_API.G_MISS_CHAR,
     component_version          VARCHAR2(3)   := FND_API.G_MISS_CHAR,
     subcomponent_version       VARCHAR2(3)   := FND_API.G_MISS_CHAR,
     comm_pref_code             VARCHAR2(30)  := FND_API.G_MISS_CHAR,
     cust_pref_lang_code        VARCHAR2(4)   := FND_API.G_MISS_CHAR,
     category_set_id            NUMBER        := FND_API.G_MISS_NUM,
     external_reference         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
     system_id                  NUMBER        := FND_API.G_MISS_NUM,
    ---- Added for Enh# 1830701
     request_date               DATE          := FND_API.G_MISS_DATE,
     incident_occurred_date     DATE          := FND_API.G_MISS_DATE,
     incident_resolved_date     DATE          := FND_API.G_MISS_DATE,
     inc_responded_by_date      DATE          := FND_API.G_MISS_DATE,
   ---- Added for Enh# 222054
     incident_location_id       NUMBER        := FND_API.G_MISS_NUM,
     incident_country           VARCHAR2(60)  := FND_API.G_MISS_CHAR,
 ---  Added for ER# 2433831
     bill_to_account_id         NUMBER        := FND_API.G_MISS_NUM ,
     ship_to_account_id         NUMBER        := FND_API.G_MISS_NUM ,
 ---  Added for ER# 2463321
    customer_phone_id   NUMBER        := FND_API.G_MISS_NUM ,
    customer_email_id   NUMBER        := FND_API.G_MISS_NUM  ,
    bill_to_party_id   NUMBER        := FND_API.G_MISS_NUM  ,
    ship_to_party_id   NUMBER        := FND_API.G_MISS_NUM  ,
    bill_to_site_id   NUMBER        := FND_API.G_MISS_NUM  ,
    ship_to_site_id   NUMBER        := FND_API.G_MISS_NUM ,

   -- Added address related columns by shijain 4th dec 2002
    incident_point_of_interest     Varchar2(240):=FND_API.G_MISS_CHAR ,
    incident_cross_street          Varchar2(240):=FND_API.G_MISS_CHAR ,
    incident_direction_qualifier   Varchar2(30):=FND_API.G_MISS_CHAR,
    incident_distance_qualifier    Varchar2(240):=FND_API.G_MISS_CHAR ,
    incident_distance_qual_uom     Varchar2(30):=FND_API.G_MISS_CHAR,
    incident_address2              Varchar2(240):=FND_API.G_MISS_CHAR ,
    incident_address3              Varchar2(240):=FND_API.G_MISS_CHAR,
    incident_address4              Varchar2(240):=FND_API.G_MISS_CHAR ,
    incident_address_style         Varchar2(30):=FND_API.G_MISS_CHAR,
    incident_addr_lines_phonetic   Varchar2(560):=FND_API.G_MISS_CHAR ,
    incident_po_box_number         Varchar2(50):=FND_API.G_MISS_CHAR ,
    incident_house_number          Varchar2(50):=FND_API.G_MISS_CHAR,
    incident_street_suffix         Varchar2(50):=FND_API.G_MISS_CHAR ,
    incident_street                Varchar2(150):=FND_API.G_MISS_CHAR,
    incident_street_number         Varchar2(50):=FND_API.G_MISS_CHAR ,
    incident_floor                 Varchar2(50):=FND_API.G_MISS_CHAR ,
    incident_suite                 Varchar2(50):=FND_API.G_MISS_CHAR ,
    incident_postal_plus4_code     Varchar2(30):=FND_API.G_MISS_CHAR ,
    incident_position              Varchar2(50):=FND_API.G_MISS_CHAR ,
    incident_location_directions   Varchar2(640):=FND_API.G_MISS_CHAR,
    incident_location_description  Varchar2(2000):=FND_API.G_MISS_CHAR ,
    install_site_id                NUMBER := FND_API.G_MISS_NUM ,
    group_owner                    Varchar2(60):=FND_API.G_MISS_CHAR,
    owner                          Varchar2(360):=FND_API.G_MISS_CHAR,
    --------------------anmukher--------------------08/01/03
    -- Added for CMRO-EAM project of Release 11.5.10
    item_serial_number		   VARCHAR2(30) := FND_API.G_MISS_CHAR,
    owning_dept_id		   NUMBER	:= FND_API.G_MISS_NUM,
    ---------------------anmukher--------------------08/18/03
    incident_location_type	   VARCHAR2(30) := FND_API.G_MISS_CHAR,
     --Added for bug 3635269
    sr_creation_channel            VARCHAR2(50) := FND_API.G_MISS_CHAR,
    maint_organization_id          NUMBER := FND_API.G_MISS_NUM,
    old_type_id                    NUMBER,
    -- Credit Card 9358401
    instrument_payment_use_id            Number  := FND_API.G_MISS_NUM

);
--------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Request_Validation_Rec_Type
--  Description     : Holds the Service Request attribute Ids for validation.
--   type_id             NUMBER         Optional
--        Service request type identifier
--   status_id           NUMBER         Optional
--        Service request status identifier
--   severity_id         NUMBER         Optional
--        Service request severity identifier
--   urgency_id          NUMBER         Optional
--        Service request urgency identifier
-----------------------------------------------------
--   This field is no longer there in the Request_Validation_Rec_Type
--   closed_date         DATE           Optional
--         Closed Date
------------------------------------------------------
--   resource_type       VARCHAR2       Optional

--   owner_id            NUMBER         Optional
--        Service request owner identifier
--
--   publish_flag        VARCHAR2(1)    Optional

--   customer_id         NUMBER         Optional
--        Service request customer identifier

--   employee_id         NUMBER         Optional

--   contact_id          NUMBER         Optional
--        Customer contact identifier

--   represented_by_id   NUMBER         Optional
--        Represented By identifier

--   customer_product_id NUMBER         Optional
--        Unique identifier for a customer product in the Installed Base

--   inventory_item_id   NUMBER         Optional
--        Inventory item identifier

--   problem_code        VARCHAR2(30)   Optional
--        Service request problem code

--   exp_resolution_date DATE      Optional
--        Expected resolution date

--   rma_header_id       NUMBER         Optional
--        Sales order header identifier of the RMA

--   bill_to_site_use_id NUMBER         Optional
--        Bill To site use identifier

--   bill_to_contact_id  NUMBER         Optional
--        Bill To contact identifier

--   ship_to_site_use_id NUMBER         Optional
--        Ship To site use identifier

--   ship_to_contact_id  NUMBER         Optional
--        Ship To contact identifier

--   install_site_use_id NUMBER         Optional
--        Install site use identifier

--   resolution_code          VARCHAR2(30)    Optional
--        Service request resolution code

--   act_resolution_date DATE      Optional
--        Actual resolution date

--   current_contact_time_diff   NUMBER        Optional
--        Current Contact Time Diff

--   rep_by_time_difference   NUMBER           Optional
--        Represented By Time Diff

--   validate_type         VARCHAR2(1)         Optional
--        Whether or not to validate type_id

--   validate_status          VARCHAR2(1)      Optional
--        Whether or not to validate status_id

--   validate_customer    VARCHAR2(1)          Optional
--         Whether or not to validate customer_id

--   validate_employee    VARCHAR2(1)          Optional
--         Whether or not to validate employee_id

--   validate_bill_to_site    VARCHAR2(1)      Optional
--         Whether or not to validate bill_to_site_use_id

--   validate_ship_to_site    VARCHAR2(1)      Optional
--         Whether or not to validate ship_to_site_use_id

--   validate_install_site    VARCHAR2(1)      Optional
--         Whether or not to validate install_site_use_id

--     coverage_type              VARCHAR2(30)  Optional
--          Service Request Coverage Type

--     bill_to_account_id         NUMBER        Optional
--          Service Request Bill To Account Identifier

--     ship_to_account_id         NUMBER        Optional
--          Service Request Ship To Account Identifier

--     customer_phone_id   NUMBER        Optional
--          SR Customer's non-primary phone Id

--     customer_email_id   NUMBER        Optional
--          SR Customer's non-primary Email Id
-- End of comments

--------------------------------------------------------------------------
-- Start of comments
--  Procedure  : Validate_ServiceRequest_Record
--  Description     : Validate all non-missing record fields.
--  Parameters :
--  IN         :
--   p_api_name          IN   VARCHAR2       Required
--        Name of the calling procedure.
--   p_service_request_rec    IN   Request_Validation_Rec_Type    Required
--        Record which holds all the non-missing record fields to be
--        validated.
--   p_request_date      IN   DATE           Optional
--        Service request date; required for closed date, expected
--        resolution date, and actual resolution date validation.
--   p_org_id       IN   NUMBER              Optional
--        Operating unit identifier; required for owner, customer
--        contact, customer product, sales order (RMA), Bill To site,
--        Bill To contact, Ship To site, Ship To contact validation.
--   p_resp_appl_id      IN   NUMBER              Optional
--   p_resp_id      IN   NUMBER              Optional
--   p_user_id      IN   NUMBER              Optional
--   p_inventory_org_id  IN   NUMBER              Optional
--        Organization identifier; required for inventory item
--        validation.
--  OUT        :
--   p_close_flag        OUT  VARCHAR2(1)
--        Returned iff status_id is passed
--        'Y' => the given status is a "closed" status
--   p_employee_name          OUT  VARCHAR2(240)
--        Returned iff employee_id is passed

--  The following 3 fields are returned iff type_id is passed.
--  p_autolaunch_workflow_flag  OUT VARCHAR2,
--  p_abort_workflow_close_flag  OUT  VARCHAR2,
--  p_workflow_process_name   OUT  VARCHAR2,
--   p_inventory_item_id OUT  NUMBER
--        Returned iff customer_product_id is passed
--        Identifies an item for a customer product
--   p_return_status          OUT  VARCHAR2(1)
--        FND_API.G_RET_STS_SUCCESS => all non-missing fields are valid
--        FND_API.G_RET_STS_ERROR   => one or more non-missing fields
--                                     are invalid
--  Notes :
--   Please take into considerations the following dependencies when
--   passing in parameters and record fields. For example, the status of
--   the service request has dependency on the type of the service request.
--   Therefore, the request type must be passed in for status validation.
--      1. type_id              requires  status_id
--      2. status_id            requires  type_id
--      3. closed_date          requires  p_request_date
--      4. owner_id             requires  p_org_id
--      5. publish_flag         requires  p_resp_appl_id, p_resp_id,
--                                        p_user_id
--      6. employee_id      requires  p_org_id
--      7. contact_id           requires  p_org_id, customer_id or
--                                        customer_product_id
--      8. customer_product_id  requires  p_org_id
--      9. inventory_item_id    requires  p_inventory_org_id
--     10. exp_resolution_date  requires  p_request_date
--     11. rma_header_id        requires  p_org_id, customer_id or
--                                        customer_product_id
--     12. bill_to_site_use_id  requires  p_org_id, customer_id or
--                                        customer_product_id
--     13. bill_to_contact_id   requires  p_org_id, bill_to_site_use_id or
--                                        customer_id or customer_product_id
--     14. ship_to_site_use_id  requires  p_org_id, customer_id or
--                                        customer_product_id
--     15. ship_to_contact_id   requires  p_org_id, ship_to_site_use_id or
--                                        customer_id or customer_product_id
--     16. act_resolution_date  requires  request_date
-- End of comments
--------------------------------------------------------------------------

-----------------------------------------------------------
-- Set up record types to be used for the audit record API
-----------------------------------------------------------
/*************** Comment out these 3 audit recs and use New Audit Rec **
TYPE audit_flags_rec_type IS RECORD (
		change_status		         VARCHAR2(1) := FND_API.G_FALSE,
		change_owner		         VARCHAR2(1) := FND_API.G_FALSE,
		change_group                     VARCHAR2(1) := FND_API.G_FALSE,
		change_group_type                VARCHAR2(1) := FND_API.G_FALSE,
		change_assigned_time             VARCHAR2(1) := FND_API.G_FALSE,
		change_platform_org_id           VARCHAR2(1) := FND_API.G_FALSE,
		change_type		         		 VARCHAR2(1) := FND_API.G_FALSE,
		change_urgency	                 VARCHAR2(1) := FND_API.G_FALSE,
		change_severity	                 VARCHAR2(1) := FND_API.G_FALSE,
		change_exp_res_date	         VARCHAR2(1) := FND_API.G_FALSE,
		new_action		         	 VARCHAR2(1) := FND_API.G_FALSE,
		new_workflow		         VARCHAR2(1) := FND_API.G_FALSE,
		change_obligation_date           VARCHAR2(1) := FND_API.G_FALSE,
		change_site_id                   VARCHAR2(1) := FND_API.G_FALSE,
		change_contact_id                VARCHAR2(1) := FND_API.G_FALSE,
		change_bill_to_contact_id        VARCHAR2(1) := FND_API.G_FALSE,
		change_ship_to_contact_id        VARCHAR2(1) := FND_API.G_FALSE,
		change_incident_date             VARCHAR2(1) := FND_API.G_FALSE,
		change_close_date                VARCHAR2(1) := FND_API.G_FALSE,
		change_customer_product_id       VARCHAR2(1) := FND_API.G_FALSE,
                change_platform_id               VARCHAR2(1) := FND_API.G_FALSE,
                change_plat_ver_id               VARCHAR2(1) := FND_API.G_FALSE,
                change_cp_comp_id                VARCHAR2(1) := FND_API.G_FALSE,
                change_cp_pro_rev             VARCHAR2(1) := FND_API.G_FALSE,
                change_cp_comp_ver_id               VARCHAR2(1) := FND_API.G_FALSE,
                change_cp_comp_ver           VARCHAR2(1) := FND_API.G_FALSE,
                change_cp_subcomp_id           VARCHAR2(1) := FND_API.G_FALSE,
                change_cp_subcomp_ver        VARCHAR2(1) := FND_API.G_FALSE,
                change_cp_subcomp_ver_id            VARCHAR2(1) := FND_API.G_FALSE,
                change_language_id               VARCHAR2(1) := FND_API.G_FALSE,
               change_cp_rev_id             VARCHAR2(1) := FND_API.G_FALSE,
               change_inv_item_rev           VARCHAR2(1) := FND_API.G_FALSE,
               change_inv_comp_id            VARCHAR2(1) := FND_API.G_FALSE,
               change_inv_comp_ver           VARCHAR2(1) := FND_API.G_FALSE,
               change_inv_subcomp_id        VARCHAR2(1) := FND_API.G_FALSE,
               change_inv_subcomp_ver       VARCHAR2(1) := FND_API.G_FALSE,
               change_territory_id              VARCHAR2(1) := FND_API.G_FALSE,
               change_resource_type             VARCHAR2(1) := FND_API.G_FALSE
);

TYPE audit_vals_rec_type IS RECORD (
	status_id	           NUMBER := FND_API.G_MISS_NUM,
	owner_id	           NUMBER := FND_API.G_MISS_NUM,
	group_id                   NUMBER := FND_API.G_MISS_NUM,
        group_type                 VARCHAR2(30) :=FND_API.G_MISS_CHAR,
        owner_assigned_time        DATE   := FND_API.G_MISS_DATE,
        inv_platform_org_id        NUMBER := FND_API.G_MISS_NUM,
	type_id		           NUMBER := FND_API.G_MISS_NUM,
	urgency_id	           NUMBER := FND_API.G_MISS_NUM,
	severity_id	           NUMBER := FND_API.G_MISS_NUM,
	exp_res_date               DATE   := FND_API.G_MISS_DATE,
	obligation_date            DATE   := FND_API.G_MISS_DATE,
	site_id                    NUMBER := FND_API.G_MISS_NUM,
 	contact_id                 NUMBER := FND_API.G_MISS_NUM,
 	bill_to_contact_id         NUMBER := FND_API.G_MISS_NUM,
 	ship_to_contact_id         NUMBER := FND_API.G_MISS_NUM,
 	incident_date              DATE   := FND_API.G_MISS_DATE,
 	close_date                 DATE   := FND_API.G_MISS_DATE,
 	customer_product_id        NUMBER := FND_API.G_MISS_NUM,
        platform_id                NUMBER := FND_API.G_MISS_NUM,
        platform_version_id        NUMBER := FND_API.G_MISS_NUM,
        cp_component_id            NUMBER := FND_API.G_MISS_NUM,
        product_revision           VARCHAR2(240):= FND_API.G_MISS_CHAR,
        cp_component_version_id    NUMBER := FND_API.G_MISS_NUM,
        component_version          VARCHAR2(3):= FND_API.G_MISS_CHAR,
        cp_subcomponent_id         NUMBER := FND_API.G_MISS_NUM,
        cp_subcomponent_version_id NUMBER := FND_API.G_MISS_NUM,
        subcomponent_version       VARCHAR2(3):= FND_API.G_MISS_CHAR,
        language_id                NUMBER := FND_API.G_MISS_NUM,
        cp_revision_id             NUMBER := FND_API.G_MISS_NUM,
        inv_item_revision          VARCHAR2(240) := FND_API.G_MISS_CHAR,
        inv_component_id           NUMBER := FND_API.G_MISS_NUM,
        inv_component_version      VARCHAR2(90) := FND_API.G_MISS_CHAR,
        inv_subcomponent_id        NUMBER := FND_API.G_MISS_NUM,
        inv_subcomponent_version   VARCHAR2(90) := FND_API.G_MISS_CHAR,
        territory_id               NUMBER := FND_API.G_MISS_NUM,
        resource_type              VARCHAR2(30) := FND_API.G_MISS_CHAR
);
G_MISS_AUDIT_VALS_REC audit_vals_rec_type;
********** End of Comments - Use the Ne Audit Record ***/

TYPE sr_audit_rec_type IS RECORD (
 	 	INCIDENT_STATUS_ID                       NUMBER(15) ,
		OLD_INCIDENT_STATUS_ID                   NUMBER(15) ,
		CHANGE_INCIDENT_STATUS_FLAG              VARCHAR2(1),
                INCIDENT_TYPE_ID                         NUMBER(15) ,
	        OLD_INCIDENT_TYPE_ID                     NUMBER(15) ,
		CHANGE_INCIDENT_TYPE_FLAG                VARCHAR2(1),
  		INCIDENT_URGENCY_ID                      NUMBER(15) ,
 		OLD_INCIDENT_URGENCY_ID                  NUMBER(15) ,
		CHANGE_INCIDENT_URGENCY_FLAG             VARCHAR2(1),
		INCIDENT_SEVERITY_ID                     NUMBER(15) ,
		OLD_INCIDENT_SEVERITY_ID                 NUMBER(15) ,
		CHANGE_INCIDENT_SEVERITY_FLAG            VARCHAR2(1),
		RESPONSIBLE_GROUP_ID                     NUMBER(15) ,
		OLD_RESPONSIBLE_GROUP_ID                 NUMBER(15) ,
		CHANGE_RESPONSIBLE_GROUP_FLAG            VARCHAR2(1),
		INCIDENT_OWNER_ID                        NUMBER(15) ,
		OLD_INCIDENT_OWNER_ID                    NUMBER(15) ,
		CHANGE_INCIDENT_OWNER_FLAG               VARCHAR2(1),
		CREATE_MANUAL_ACTION                     VARCHAR2(1),
		ACTION_ID                                NUMBER(15) ,
		EXPECTED_RESOLUTION_DATE                 DATE ,
		OLD_EXPECTED_RESOLUTION_DATE             DATE ,
		CHANGE_RESOLUTION_FLAG                   VARCHAR2(1) ,
		NEW_WORKFLOW_FLAG                        VARCHAR2(1) ,
		WORKFLOW_PROCESS_NAME                    VARCHAR2(30),
		WORKFLOW_PROCESS_ITEMKEY                 VARCHAR2(240),
		GROUP_ID                                 NUMBER ,
		OLD_GROUP_ID                             NUMBER ,
		CHANGE_GROUP_FLAG                        VARCHAR2(1) ,
		OBLIGATION_DATE                          DATE ,
		OLD_OBLIGATION_DATE                      DATE ,
		CHANGE_OBLIGATION_FLAG                   VARCHAR2(1) ,
		SITE_ID                                  NUMBER ,
		OLD_SITE_ID                              NUMBER ,
		CHANGE_SITE_FLAG                         VARCHAR2(1),
		BILL_TO_CONTACT_ID                       NUMBER(15) ,
		OLD_BILL_TO_CONTACT_ID                   NUMBER(15) ,
		CHANGE_BILL_TO_FLAG                      VARCHAR2(1),
		SHIP_TO_CONTACT_ID                       NUMBER(15) ,
		OLD_SHIP_TO_CONTACT_ID                   NUMBER(15) ,
		CHANGE_SHIP_TO_FLAG                      VARCHAR2(1) ,
		INCIDENT_DATE                            DATE ,
		OLD_INCIDENT_DATE                        DATE ,
		CHANGE_INCIDENT_DATE_FLAG                VARCHAR2(1) ,
		CLOSE_DATE                               DATE ,
		OLD_CLOSE_DATE                           DATE ,
		CHANGE_CLOSE_DATE_FLAG                   VARCHAR2(1) ,
		CUSTOMER_PRODUCT_ID                      NUMBER(15) ,
		OLD_CUSTOMER_PRODUCT_ID                  NUMBER(15) ,
		CHANGE_CUSTOMER_PRODUCT_FLAG             VARCHAR2(1) ,
		PLATFORM_ID                              NUMBER ,
		OLD_PLATFORM_ID                          NUMBER ,
		CHANGE_PLATFORM_ID_FLAG                  VARCHAR2(1) ,
		PLATFORM_VERSION_ID                      NUMBER ,
		OLD_PLATFORM_VERSION_ID                  NUMBER ,
		CHANGE_PLAT_VER_ID_FLAG                  VARCHAR2(1) ,
		CP_COMPONENT_ID                          NUMBER ,
		OLD_CP_COMPONENT_ID                      NUMBER ,
		CHANGE_CP_COMPONENT_ID_FLAG              VARCHAR2(1) ,
		CP_COMPONENT_VERSION_ID                  NUMBER ,
		OLD_CP_COMPONENT_VERSION_ID              NUMBER ,
		CHANGE_CP_COMP_VER_ID_FLAG               VARCHAR2(1) ,
		CP_SUBCOMPONENT_ID                       NUMBER ,
		OLD_CP_SUBCOMPONENT_ID                   NUMBER ,
		CHANGE_CP_SUBCOMPONENT_ID_FLAG           VARCHAR2(1) ,
		CP_SUBCOMPONENT_VERSION_ID               NUMBER ,
		OLD_CP_SUBCOMPONENT_VERSION_ID           NUMBER ,
		CHANGE_CP_SUBCOMP_VER_ID_FLAG            VARCHAR2(1) ,
		LANGUAGE_ID                              NUMBER ,
		OLD_LANGUAGE_ID                          NUMBER ,
		CHANGE_LANGUAGE_ID_FLAG                  VARCHAR2(1) ,
		TERRITORY_ID                             NUMBER ,
		OLD_TERRITORY_ID                         NUMBER ,
		CHANGE_TERRITORY_ID_FLAG                 VARCHAR2(1) ,
		CP_REVISION_ID                           NUMBER ,
		OLD_CP_REVISION_ID                       NUMBER ,
		CHANGE_CP_REVISION_ID_FLAG               VARCHAR2(1) ,
		INV_ITEM_REVISION                        VARCHAR2(240) ,
		OLD_INV_ITEM_REVISION                    VARCHAR2(240) ,
		CHANGE_INV_ITEM_REVISION                 VARCHAR2(1) ,
		INV_COMPONENT_ID                         NUMBER ,
		OLD_INV_COMPONENT_ID                     NUMBER ,
		CHANGE_INV_COMPONENT_ID                  VARCHAR2(1) ,
		INV_COMPONENT_VERSION                    VARCHAR2(90) ,
		OLD_INV_COMPONENT_VERSION                VARCHAR2(90) ,
		CHANGE_INV_COMPONENT_VERSION             VARCHAR2(1) ,
		INV_SUBCOMPONENT_ID                      NUMBER ,
		OLD_INV_SUBCOMPONENT_ID                  NUMBER ,
		CHANGE_INV_SUBCOMPONENT_ID               VARCHAR2(1) ,
		INV_SUBCOMPONENT_VERSION                 VARCHAR2(90) ,
		OLD_INV_SUBCOMPONENT_VERSION             VARCHAR2(90) ,
		CHANGE_INV_SUBCOMP_VERSION               VARCHAR2(1) ,
		RESOURCE_TYPE                            VARCHAR2(30) ,
		OLD_RESOURCE_TYPE                        VARCHAR2(30) ,
		CHANGE_RESOURCE_TYPE_FLAG                VARCHAR2(1) ,
		SECURITY_GROUP_ID                        NUMBER ,
		UPGRADED_STATUS_FLAG                     VARCHAR2(1) ,
		OLD_GROUP_TYPE                           VARCHAR2(30) ,
		GROUP_TYPE                               VARCHAR2(30) ,
		CHANGE_GROUP_TYPE_FLAG                   VARCHAR2(1) ,
		OLD_OWNER_ASSIGNED_TIME                  DATE ,
		OWNER_ASSIGNED_TIME                      DATE ,
		CHANGE_ASSIGNED_TIME_FLAG                VARCHAR2(1) ,
		INV_PLATFORM_ORG_ID                      NUMBER ,
		OLD_INV_PLATFORM_ORG_ID                  NUMBER ,
		CHANGE_PLATFORM_ORG_ID_FLAG              VARCHAR2(1) ,
		COMPONENT_VERSION                        VARCHAR2(3) ,
		OLD_COMPONENT_VERSION                    VARCHAR2(3) ,
		CHANGE_COMP_VER_FLAG                     VARCHAR2(1) ,
		SUBCOMPONENT_VERSION                     VARCHAR2(3) ,
		OLD_SUBCOMPONENT_VERSION                 VARCHAR2(3) ,
		CHANGE_SUBCOMP_VER_FLAG                  VARCHAR2(1) ,
		PRODUCT_REVISION                         VARCHAR2(240) ,
 		OLD_PRODUCT_REVISION                     VARCHAR2(240) ,
 		CHANGE_PRODUCT_REVISION_FLAG             VARCHAR2(1) ,
                STATUS_FLAG                              VARCHAR2(3) ,
                OLD_STATUS_FLAG                          VARCHAR2(3) ,
                CHANGE_STATUS_FLAG                       VARCHAR2(3) ,
                INVENTORY_ITEM_ID                        NUMBER(15),
                OLD_INVENTORY_ITEM_ID                    NUMBER(15),
                CHANGE_INVENTORY_ITEM_FLAG               VARCHAR2(3),
                INV_ORGANIZATION_ID                      NUMBER,
                OLD_INV_ORGANIZATION_ID                  NUMBER,
                CHANGE_INV_ORGANIZATION_FLAG             VARCHAR2(3),
                PRIMARY_CONTACT_ID                       NUMBER,
                CHANGE_PRIMARY_CONTACT_FLAG              VARCHAR2(3),
                OLD_PRIMARY_CONTACT_ID                   NUMBER,
                -- Added for Enhanced Auditing features in 11.5.10 --anmukher --09/02/03
                UPGRADE_FLAG_FOR_CREATE                  VARCHAR2(1),
 		OLD_INCIDENT_NUMBER                      VARCHAR2(64),
		INCIDENT_NUMBER                          VARCHAR2(64),
		OLD_CUSTOMER_ID                          NUMBER(15),
		CUSTOMER_ID                              NUMBER(15),
		OLD_BILL_TO_SITE_USE_ID                  NUMBER(15),
		BILL_TO_SITE_USE_ID                      NUMBER(15),
		OLD_EMPLOYEE_ID                          NUMBER(15),
		EMPLOYEE_ID                              NUMBER(15),
		OLD_SHIP_TO_SITE_USE_ID                  NUMBER(15),
		SHIP_TO_SITE_USE_ID                      NUMBER(15),
		OLD_PROBLEM_CODE                         VARCHAR2(50),
		PROBLEM_CODE                             VARCHAR2(50),
		OLD_ACTUAL_RESOLUTION_DATE               DATE,
		ACTUAL_RESOLUTION_DATE                   DATE,
		OLD_INSTALL_SITE_USE_ID                  NUMBER(15),
		INSTALL_SITE_USE_ID                      NUMBER(15),
--		OLD_PRODUCT_DESCRIPTION                  VARCHAR2(240),
--		PRODUCT_DESCRIPTION                      VARCHAR2(240),
		OLD_CURRENT_SERIAL_NUMBER                VARCHAR2(30),
		CURRENT_SERIAL_NUMBER                    VARCHAR2(30),
		OLD_SYSTEM_ID                            NUMBER(15),
		SYSTEM_ID                                NUMBER(15),
		OLD_INCIDENT_ATTRIBUTE_1                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_1                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_2                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_2                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_3                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_3                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_4                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_4                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_5                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_5                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_6                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_6                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_7                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_7                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_8                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_8                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_9                 VARCHAR2(150),
		INCIDENT_ATTRIBUTE_9                     VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_10                VARCHAR2(150),
		INCIDENT_ATTRIBUTE_10                    VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_11                VARCHAR2(150),
		INCIDENT_ATTRIBUTE_11                    VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_12                VARCHAR2(150),
		INCIDENT_ATTRIBUTE_12                    VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_13                VARCHAR2(150),
		INCIDENT_ATTRIBUTE_13                    VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_14                VARCHAR2(150),
		INCIDENT_ATTRIBUTE_14                    VARCHAR2(150),
		OLD_INCIDENT_ATTRIBUTE_15                VARCHAR2(150),
		INCIDENT_ATTRIBUTE_15                    VARCHAR2(150),
		OLD_INCIDENT_CONTEXT                     VARCHAR2(30),
		INCIDENT_CONTEXT                         VARCHAR2(30),
		OLD_RESOLUTION_CODE                      VARCHAR2(50),
		RESOLUTION_CODE                          VARCHAR2(50),
		OLD_ORIGINAL_ORDER_NUMBER                NUMBER,
		ORIGINAL_ORDER_NUMBER                    NUMBER,
		OLD_ORG_ID                               NUMBER,
		ORG_ID                                   NUMBER,
		OLD_PURCHASE_ORDER_NUMBER                VARCHAR2(50),
		PURCHASE_ORDER_NUMBER                    VARCHAR2(50),
		OLD_PUBLISH_FLAG                         VARCHAR2(1),
		PUBLISH_FLAG                             VARCHAR2(1),
		OLD_QA_COLLECTION_ID                     NUMBER,
		QA_COLLECTION_ID                         NUMBER,
		OLD_CONTRACT_ID                          NUMBER,
		CONTRACT_ID                              NUMBER,
		OLD_CONTRACT_NUMBER                      VARCHAR2(120),
		CONTRACT_NUMBER                          VARCHAR2(120),
		OLD_CONTRACT_SERVICE_ID                  NUMBER,
		CONTRACT_SERVICE_ID                      NUMBER,
		OLD_TIME_ZONE_ID                         NUMBER(15),
		TIME_ZONE_ID                             NUMBER(15),
		OLD_ACCOUNT_ID                           NUMBER,
		ACCOUNT_ID                               NUMBER,
		OLD_TIME_DIFFERENCE                      NUMBER,
		TIME_DIFFERENCE                          NUMBER,
		OLD_CUSTOMER_PO_NUMBER                   VARCHAR2(50),
		CUSTOMER_PO_NUMBER                       VARCHAR2(50),
		OLD_CUSTOMER_TICKET_NUMBER               VARCHAR2(50),
		CUSTOMER_TICKET_NUMBER                   VARCHAR2(50),
		OLD_CUSTOMER_SITE_ID                     NUMBER,
		CUSTOMER_SITE_ID                         NUMBER,
		OLD_CALLER_TYPE                          VARCHAR2(30),
		CALLER_TYPE                              VARCHAR2(30),
		OLD_SECURITY_GROUP_ID                    NUMBER(15),
		OLD_ORIG_SYSTEM_REFERENCE                VARCHAR2(60),
		ORIG_SYSTEM_REFERENCE                    VARCHAR2(60),
		OLD_ORIG_SYSTEM_REFERENCE_ID             NUMBER,
		ORIG_SYSTEM_REFERENCE_ID                 NUMBER,
		REQUEST_ID                           NUMBER(15),
		PROGRAM_APPLICATION_ID               NUMBER(15),
		PROGRAM_ID                           NUMBER(15),
		PROGRAM_UPDATE_DATE                  DATE,
		OLD_PROJECT_NUMBER                       VARCHAR2(120),
		PROJECT_NUMBER                           VARCHAR2(120),
		OLD_PLATFORM_VERSION                     VARCHAR2(250),
		PLATFORM_VERSION                         VARCHAR2(250),
		OLD_DB_VERSION                           VARCHAR2(250),
		DB_VERSION                               VARCHAR2(250),
		OLD_CUST_PREF_LANG_ID                    NUMBER,
		CUST_PREF_LANG_ID                        NUMBER,
		OLD_TIER                                 VARCHAR2(250),
		TIER                                     VARCHAR2(250),
		OLD_CATEGORY_ID                          NUMBER,
		CATEGORY_ID                              NUMBER,
		OLD_OPERATING_SYSTEM                     VARCHAR2(250),
		OPERATING_SYSTEM                         VARCHAR2(250),
		OLD_OPERATING_SYSTEM_VERSION             VARCHAR2(250),
		OPERATING_SYSTEM_VERSION                 VARCHAR2(250),
		OLD_DATABASE                             VARCHAR2(250),
		DATABASE                                 VARCHAR2(250),
		OLD_GROUP_TERRITORY_ID                   NUMBER,
		GROUP_TERRITORY_ID                       NUMBER,
		OLD_COMM_PREF_CODE                       VARCHAR2(30),
		COMM_PREF_CODE                           VARCHAR2(30),
		OLD_LAST_UPDATE_CHANNEL                  VARCHAR2(10),
		LAST_UPDATE_CHANNEL                      VARCHAR2(10),
		OLD_CUST_PREF_LANG_CODE                  VARCHAR2(4),
		CUST_PREF_LANG_CODE                      VARCHAR2(4),
		OLD_ERROR_CODE                           VARCHAR2(250),
		ERROR_CODE                               VARCHAR2(250),
		OLD_CATEGORY_SET_ID                      NUMBER,
		CATEGORY_SET_ID                          NUMBER,
		OLD_EXTERNAL_REFERENCE                   VARCHAR2(30),
		EXTERNAL_REFERENCE                       VARCHAR2(30),
		OLD_INCIDENT_OCCURRED_DATE               DATE,
		INCIDENT_OCCURRED_DATE                   DATE,
		OLD_INCIDENT_RESOLVED_DATE               DATE,
		INCIDENT_RESOLVED_DATE                   DATE,
		OLD_INC_RESPONDED_BY_DATE                DATE,
		INC_RESPONDED_BY_DATE                    DATE,
		OLD_INCIDENT_LOCATION_ID                 NUMBER,
		INCIDENT_LOCATION_ID                     NUMBER,
		OLD_INCIDENT_ADDRESS                     VARCHAR2(960),
		INCIDENT_ADDRESS                         VARCHAR2(960),
		OLD_INCIDENT_CITY                        VARCHAR2(60),
		INCIDENT_CITY                            VARCHAR2(60),
		OLD_INCIDENT_STATE                       VARCHAR2(60),
		INCIDENT_STATE                           VARCHAR2(60),
		OLD_INCIDENT_COUNTRY                     VARCHAR2(60),
		INCIDENT_COUNTRY                         VARCHAR2(60),
		OLD_INCIDENT_PROVINCE                    VARCHAR2(60),
		INCIDENT_PROVINCE                        VARCHAR2(60),
		OLD_INCIDENT_POSTAL_CODE                 VARCHAR2(60),
		INCIDENT_POSTAL_CODE                     VARCHAR2(60),
		OLD_INCIDENT_COUNTY                      VARCHAR2(60),
		INCIDENT_COUNTY                          VARCHAR2(240),
		OLD_SR_CREATION_CHANNEL                  VARCHAR2(50),
		SR_CREATION_CHANNEL                      VARCHAR2(50),
		OLD_DEF_DEFECT_ID                        NUMBER,
		DEF_DEFECT_ID                            NUMBER,
		OLD_DEF_DEFECT_ID2                       NUMBER,
		DEF_DEFECT_ID2                           NUMBER,
		OLD_EXTERNAL_ATTRIBUTE_1                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_1                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_2                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_2                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_3                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_3                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_4                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_4                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_5                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_5                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_6                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_6                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_7                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_7                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_8                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_8                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_9                 VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_9                     VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_10                VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_10                    VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_11                VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_11                    VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_12                VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_12                    VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_13                VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_13                    VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_14                VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_14                    VARCHAR2(150),
		OLD_EXTERNAL_ATTRIBUTE_15                VARCHAR2(150),
		EXTERNAL_ATTRIBUTE_15                    VARCHAR2(150),
		OLD_EXTERNAL_CONTEXT                     VARCHAR2(30),
		EXTERNAL_CONTEXT                         VARCHAR2(30),
		OLD_LAST_UPDATE_PROGRAM_CODE             VARCHAR2(30),
		LAST_UPDATE_PROGRAM_CODE                 VARCHAR2(30),
		OLD_CREATION_PROGRAM_CODE           	 VARCHAR2(30),
		CREATION_PROGRAM_CODE               	 VARCHAR2(30),
		OLD_COVERAGE_TYPE                        VARCHAR2(30),
		COVERAGE_TYPE                            VARCHAR2(30),
		OLD_BILL_TO_ACCOUNT_ID                   NUMBER(15),
		BILL_TO_ACCOUNT_ID                       NUMBER(15),
		OLD_SHIP_TO_ACCOUNT_ID                   NUMBER(15),
		SHIP_TO_ACCOUNT_ID                       NUMBER(15),
		OLD_CUSTOMER_EMAIL_ID                    NUMBER(15),
		CUSTOMER_EMAIL_ID                        NUMBER(15),
		OLD_CUSTOMER_PHONE_ID                    NUMBER(15),
		CUSTOMER_PHONE_ID                        NUMBER(15),
		OLD_BILL_TO_PARTY_ID                     NUMBER,
		BILL_TO_PARTY_ID                         NUMBER,
		OLD_SHIP_TO_PARTY_ID                     NUMBER,
		SHIP_TO_PARTY_ID                         NUMBER,
		OLD_BILL_TO_SITE_ID                      NUMBER,
		BILL_TO_SITE_ID                          NUMBER,
		OLD_SHIP_TO_SITE_ID                      NUMBER,
		SHIP_TO_SITE_ID                          NUMBER,
		OLD_PROGRAM_LOGIN_ID                     NUMBER,
		PROGRAM_LOGIN_ID                         NUMBER,
		OLD_INCIDENT_POINT_OF_INTEREST           VARCHAR2(240),
		INCIDENT_POINT_OF_INTEREST               VARCHAR2(240),
		OLD_INCIDENT_CROSS_STREET                VARCHAR2(240),
		INCIDENT_CROSS_STREET                    VARCHAR2(240),
		OLD_INCIDENT_DIRECTION_QUALIF            VARCHAR2(30),
		INCIDENT_DIRECTION_QUALIF                VARCHAR2(30),
		OLD_INCIDENT_DISTANCE_QUALIF             VARCHAR2(240),
		INCIDENT_DISTANCE_QUALIF                 VARCHAR2(240),
		OLD_INCIDENT_DISTANCE_QUAL_UOM           VARCHAR2(30),
		INCIDENT_DISTANCE_QUAL_UOM               VARCHAR2(240),
		OLD_INCIDENT_ADDRESS2                    VARCHAR2(240),
		INCIDENT_ADDRESS2                        VARCHAR2(240),
		OLD_INCIDENT_ADDRESS3                    VARCHAR2(240),
		INCIDENT_ADDRESS3                        VARCHAR2(240),
		OLD_INCIDENT_ADDRESS4                    VARCHAR2(240),
		INCIDENT_ADDRESS4                        VARCHAR2(240),
		OLD_INCIDENT_ADDRESS_STYLE               VARCHAR2(30),
		INCIDENT_ADDRESS_STYLE                   VARCHAR2(30),
		OLD_INCIDENT_ADDR_LNS_PHONETIC           VARCHAR2(560),
		INCIDENT_ADDR_LNS_PHONETIC               VARCHAR2(560),
		OLD_INCIDENT_PO_BOX_NUMBER               VARCHAR2(50),
		INCIDENT_PO_BOX_NUMBER                   VARCHAR2(50),
		OLD_INCIDENT_HOUSE_NUMBER                VARCHAR2(50),
		INCIDENT_HOUSE_NUMBER                    VARCHAR2(50),
		OLD_INCIDENT_STREET_SUFFIX               VARCHAR2(50),
		INCIDENT_STREET_SUFFIX                   VARCHAR2(50),
		OLD_INCIDENT_STREET                      VARCHAR2(150),
		INCIDENT_STREET                          VARCHAR2(150),
		OLD_INCIDENT_STREET_NUMBER               VARCHAR2(50),
		INCIDENT_STREET_NUMBER                   VARCHAR2(50),
		OLD_INCIDENT_FLOOR                       VARCHAR2(50),
		INCIDENT_FLOOR                           VARCHAR2(50),
		OLD_INCIDENT_SUITE                       VARCHAR2(50),
		INCIDENT_SUITE                           VARCHAR2(50),
		OLD_INCIDENT_POSTAL_PLUS4_CODE           VARCHAR2(30),
		INCIDENT_POSTAL_PLUS4_CODE               VARCHAR2(30),
		OLD_INCIDENT_POSITION                    VARCHAR2(50),
		INCIDENT_POSITION                        VARCHAR2(50),
		OLD_INCIDENT_LOC_DIRECTIONS              VARCHAR2(640),
		INCIDENT_LOC_DIRECTIONS                  VARCHAR2(640),
		OLD_INCIDENT_LOC_DESCRIPTION             VARCHAR2(2000),
		INCIDENT_LOC_DESCRIPTION                 VARCHAR2(2000),
		OLD_INSTALL_SITE_ID                      NUMBER,
		INSTALL_SITE_ID                          NUMBER,
		INCIDENT_LAST_MODIFIED_DATE              DATE,
		UPDATED_ENTITY_CODE                      VARCHAR2(30),
		UPDATED_ENTITY_ID                        NUMBER(15),
		ENTITY_ACTIVITY_CODE                     VARCHAR2(30),
		OLD_TIER_VERSION                         VARCHAR2(250),
		TIER_VERSION                             VARCHAR2(250),
		-- Added new audit columns --anmukher --09/11/03
		OLD_INC_OBJECT_VERSION_NUMBER            NUMBER(9),
 		INC_OBJECT_VERSION_NUMBER                NUMBER(9),
 		OLD_INC_REQUEST_ID                       NUMBER(15),
 		INC_REQUEST_ID                           NUMBER(15),
 		OLD_INC_PROGRAM_APPLICATION_ID           NUMBER(15),
 		INC_PROGRAM_APPLICATION_ID               NUMBER(15),
 		OLD_INC_PROGRAM_ID                       NUMBER(15),
 		INC_PROGRAM_ID                           NUMBER(15),
 		OLD_INC_PROGRAM_UPDATE_DATE              DATE,
 		INC_PROGRAM_UPDATE_DATE                  DATE,
		OLD_OWNING_DEPARTMENT_ID                 NUMBER,
 		OWNING_DEPARTMENT_ID                     NUMBER,
 		OLD_INCIDENT_LOCATION_TYPE               VARCHAR2(30),
 		INCIDENT_LOCATION_TYPE                   VARCHAR2(30),
 		OLD_UNASSIGNED_INDICATOR                 VARCHAR2(1),
 		UNASSIGNED_INDICATOR                     VARCHAR2(1),
-- audit component R12 project
		OLD_MAINT_ORGANIZATION_ID                  NUMBER(15),
 		MAINT_ORGANIZATION_ID                      NUMBER(15)
);

--
-- RMJ:
-- A table within a record type is not possible. That's why I defined
-- three context fields in the following record type.
--
TYPE notes_rec IS RECORD (
    NOTE_ID                         NUMBER          := FND_API.G_MISS_NUM,
    NOTE                            VARCHAR2(2000)  := FND_API.G_MISS_CHAR,
    NOTE_DETAIL                     VARCHAR2(32767) := FND_API.G_MISS_CHAR,
    NOTE_TYPE                       VARCHAR2(240)   := FND_API.G_MISS_CHAR,
    NOTE_STATUS                     VARCHAR2(240)   := FND_API.G_MISS_CHAR,
    ENTERED_BY                      NUMBER          := FND_API.G_MISS_NUM,
    ENTERED_DATE                    DATE            := FND_API.G_MISS_DATE,
    SOURCE_OBJECT_ID                NUMBER          := FND_API.G_MISS_NUM,
    SOURCE_OBJECT_CODE              VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_ID_01              NUMBER          := FND_API.G_MISS_NUM,
    NOTE_CONTEXT_TYPE_01            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_TYPE_ID_01         NUMBER          := FND_API.G_MISS_NUM,
    NOTE_CONTEXT_ID_02              NUMBER          := FND_API.G_MISS_NUM,
    NOTE_CONTEXT_TYPE_02            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_TYPE_ID_02         NUMBER          := FND_API.G_MISS_NUM,
    NOTE_CONTEXT_ID_03              NUMBER          := FND_API.G_MISS_NUM,
    NOTE_CONTEXT_TYPE_03            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_TYPE_ID_03         NUMBER          := FND_API.G_MISS_NUM,
    ATTRIBUTE_1                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_2                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_3                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_4                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_5                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_6                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_7                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_8                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_9                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_10                    VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_11                    VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_12                    VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_13                    VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_14                    VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    ATTRIBUTE_15                    VARCHAR2(150)   := FND_API.G_MISS_CHAR,
    CONTEXT                         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    LAST_UPDATE_DATE                DATE            := FND_API.G_MISS_DATE,
    CREATION_DATE                   DATE            := FND_API.G_MISS_DATE,
    CREATED_BY                      NUMBER          := FND_API.G_MISS_NUM,
    LAST_UPDATED_BY                 NUMBER          := FND_API.G_MISS_NUM,
    LAST_UPDATE_LOGIN               NUMBER          := FND_API.G_MISS_NUM
);
TYPE notes_table IS TABLE OF notes_rec INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------
-- Start of comments
--  Record Type     : notes_rec
--  Description     : Holds the Notes attributes for the
--                    Creating records in JTF_NOTES_B
--  Fields     :
--  NOTE              OPTIONAL
--  NOTE_DETAIL       OPTIONAL
--  NOTE_TYPE         OPTIONAL
--  VAlid values are SR_PROBLEM and SR_RESOLUTION
-- NOTE_CONTEXT_TYPE_01  OPTIONAL   - VAlid value is 'SR'
-- NOTE_CONTEXT_TYPE_ID_01   OPTIONAL
-- VAlid incident_id from cs_incidents_all_b
--    NOTE_CONTEXT_TYPE_02     - VAlid value is 'SR'
--   NOTE_CONTEXT_TYPE_ID_02   - VAlid incident_id from cs_incidents_all_b
--    NOTE_CONTEXT_TYPE_03     - VAlid value is 'SR'
--    NOTE_CONTEXT_TYPE_ID_03 - VAlid incident_id from cs_incidents_all_b
--------------------------------------------------------------------------

--
--This table will hold the contacts and contact information
--for a Service Request customer
--
TYPE contacts_rec IS RECORD (
    SR_CONTACT_POINT_ID            NUMBER            := FND_API.G_MISS_NUM,
    PARTY_ID                       NUMBER            := FND_API.G_MISS_NUM,
    CONTACT_POINT_ID               NUMBER            := FND_API.G_MISS_NUM,
    PRIMARY_FLAG                   VARCHAR2(1)       := FND_API.G_MISS_CHAR,
    CONTACT_POINT_TYPE             VARCHAR2(30)      := FND_API.G_MISS_CHAR,
    CONTACT_TYPE                   VARCHAR2(30)      := FND_API.G_MISS_CHAR,
    party_role_code                VARCHAR2(30)      := FND_API.G_MISS_CHAR,
    start_date_active              DATE              := FND_API.G_MISS_DATE,
    end_date_active                DATE              := FND_API.G_MISS_DATE
);
TYPE contacts_table IS TABLE OF contacts_rec INDEX BY BINARY_INTEGER;

--
-----------------------------------------------------------------------
-- Start of comments
--  Record Type     : contacts_rec
--  Description     : Holds the Contacts attributes for the
--                    Creating records in CS_HZ_SR_CONTACT_POINTS
--  Fields     :
--  sr_contact_point_id         OPTIONAL
--  can be specified only if you waNt to update an existing
--  record(when called from Update_ServiceRequest API)
--  party_id                    REQUIRED
--  Valid party id from HZ_PARTIES
--  contact_point_id            OPTIONAL
--  VAlid contact_point_id from HZ_CONTACT_POINTS
--  contact_point_type           OPTIONAL
--  From AR_LOOKUPS where lookup_type = 'COMMUNICATION_TYPE'
--  and 'PHONE_LINE_TYPE'
--  primary_flag               REQUIRED
--  At least one record in the table should have this flag set to Y
--  contact_type               REQUIRED
--  Valid values are 'PERSON" and 'EMPLOYEE'

--------------------------------------------------------    pkesani
-- Start of comments
--  Record Type     : coverage_type_rec
--  Description     : To Get the coverage type.
--------------------------------------------------------
coverage_type_rec OKS_Entitlements_Pub.CovType_Rec_Type;

TYPE service_request_rec_type IS RECORD (
     request_date               DATE,
     type_id                    NUMBER,
     status_id                  NUMBER,
     severity_id                NUMBER,
     urgency_id                 NUMBER,
     closed_date                DATE,
     owner_id                   NUMBER,
     owner_group_id             NUMBER,
     publish_flag               VARCHAR2(1),
     summary                    VARCHAR2(240),
     caller_type                VARCHAR2(30),
     customer_id                NUMBER,
     customer_number            VARCHAR2(30),
     employee_id                NUMBER,
     verify_cp_flag             VARCHAR2(1),
     customer_product_id        NUMBER,
     platform_id                NUMBER,
     platform_version		VARCHAR2(250),
     db_version			VARCHAR2(250),
     platform_version_id        NUMBER,
     cp_component_id            NUMBER,
     cp_component_version_id    NUMBER,
     cp_subcomponent_id         NUMBER,
     cp_subcomponent_version_id NUMBER,
     language_id                NUMBER,
     language                   VARCHAR2(4),
     inventory_item_id          NUMBER,
     inventory_org_id           NUMBER,
     current_serial_number      VARCHAR2(30),
     original_order_number      NUMBER,
     purchase_order_num         VARCHAR2(50),
     problem_code               VARCHAR2(50),
     exp_resolution_date        DATE,
     install_site_use_id        NUMBER,
     request_attribute_1        VARCHAR2(150),
     request_attribute_2        VARCHAR2(150),
     request_attribute_3        VARCHAR2(150),
     request_attribute_4        VARCHAR2(150),
     request_attribute_5        VARCHAR2(150),
     request_attribute_6        VARCHAR2(150),
     request_attribute_7        VARCHAR2(150),
     request_attribute_8        VARCHAR2(150),
     request_attribute_9        VARCHAR2(150),
     request_attribute_10       VARCHAR2(150),
     request_attribute_11       VARCHAR2(150),
     request_attribute_12       VARCHAR2(150),
     request_attribute_13       VARCHAR2(150),
     request_attribute_14       VARCHAR2(150),
     request_attribute_15       VARCHAR2(150),
     request_context            VARCHAR2(30),
     external_attribute_1       VARCHAR2(150),
     external_attribute_2       VARCHAR2(150),
     external_attribute_3       VARCHAR2(150),
     external_attribute_4       VARCHAR2(150),
     external_attribute_5       VARCHAR2(150),
     external_attribute_6       VARCHAR2(150),
     external_attribute_7       VARCHAR2(150),
     external_attribute_8       VARCHAR2(150),
     external_attribute_9       VARCHAR2(150),
     external_attribute_10      VARCHAR2(150),
     external_attribute_11      VARCHAR2(150),
     external_attribute_12      VARCHAR2(150),
     external_attribute_13      VARCHAR2(150),
     external_attribute_14      VARCHAR2(150),
     external_attribute_15      VARCHAR2(150),
     external_context           VARCHAR2(30),
     bill_to_site_use_id        NUMBER,
     bill_to_contact_id         NUMBER,
     ship_to_site_use_id        NUMBER,
     ship_to_contact_id         NUMBER,
     resolution_code            VARCHAR2(50),
     act_resolution_date        DATE,
     public_comment_flag        VARCHAR2(1),
     parent_interaction_id      NUMBER,
     contract_service_id        NUMBER,
     -- 04/16/01
     contract_id                NUMBER,
     project_number             VARCHAR2(120),
     -- 04/16/01
     qa_collection_plan_id      NUMBER,
     account_id                 NUMBER,
     resource_type              VARCHAR2(30),
     resource_subtype_id        NUMBER,
     cust_po_number             VARCHAR2(50),
     cust_ticket_number         VARCHAR2(50),
     sr_creation_channel        VARCHAR2(50),
     obligation_date            DATE,
     time_zone_id               NUMBER,
     time_difference            NUMBER,
     site_id                    NUMBER,
     customer_site_id           NUMBER,
     territory_id               NUMBER,
     initialize_flag            VARCHAR2(1),
     cp_revision_id             NUMBER,
     inv_item_revision          VARCHAR2(240),
     inv_component_id           NUMBER,
     inv_component_version      VARCHAR2(90),
     inv_subcomponent_id        NUMBER,
     inv_subcomponent_version   VARCHAR2(90),
     -- jngeorge---11.5.6----07/12/01
     tier                       VARCHAR2(250),
     tier_version               VARCHAR2(250),
     operating_system           VARCHAR2(250),
     operating_system_version   VARCHAR2(250),
     database                   VARCHAR2(250),
     cust_pref_lang_id          NUMBER,
     category_id                NUMBER,
     group_type                 VARCHAR2(30),
     group_territory_id         NUMBER,
     inv_platform_org_id        NUMBER,
     product_revision           VARCHAR2(240),
     component_version          VARCHAR2(3),
     subcomponent_version       VARCHAR2(3),
     comm_pref_code             VARCHAR2(30),
     -- Added for HA
     last_update_date           DATE,
     last_updated_by            NUMBER,
     creation_date              DATE,
     created_by                 NUMBER,
     last_update_login          NUMBER,
     owner_assigned_time        DATE,
     owner_assigned_flag        VARCHAR2(1),
     -- Added for UWQ
     -- Changed the width from 10 to 30 shijain 3rd dec 2002
     last_update_channel        VARCHAR2(30),
     cust_pref_lang_code        VARCHAR2(4),
     --- Added for Automatic Assignments
     load_balance               VARCHAR2(1),
     assign_owner               VARCHAR2(1),
     category_set_id            NUMBER,
     external_reference         VARCHAR2(30),
     system_id                  NUMBER,
     -- jngeorge-----07/12/01
     error_code                 VARCHAR2(250),
     incident_occurred_date     DATE,
     incident_resolved_date     DATE,
     inc_responded_by_date      DATE,
     resolution_summary         VARCHAR2(250),
     incident_location_id       NUMBER,
     incident_address           VARCHAR2(960),
     incident_city              VARCHAR2(60),
     incident_state             VARCHAR2(60),
     incident_country           VARCHAR2(60),
     incident_province          VARCHAR2(60),
     incident_postal_code       VARCHAR2(60),
     incident_county            VARCHAR2(60),
     -- Added by siahmed for 12.1.2 enhancement
     site_number                VARCHAR2(30)  DEFAULT NULL,
     site_name                  VARCHAR2(240) DEFAULT NULL,
     addressee                  VARCHAR2(150) DEFAULT NULL,
     -- Added for Enh# 2216664
     owner                      VARCHAR2(360),
     group_owner                VARCHAR2(60),
     -- Added for Credit Card ER# 2255263 (UI ER#2208078)
     cc_number                  VARCHAR2(48),
     cc_expiration_date         DATE,
     cc_type_code               VARCHAR(30),
     cc_first_name              VARCHAR(250),
     cc_last_name               VARCHAR(250),
     cc_middle_name             VARCHAR(250),
     cc_id                      NUMBER  ,
     ---- Added for ER# 2320056
     coverage_type              VARCHAR2(30),
     ---  Added for ER# 2433831
     bill_to_account_id         NUMBER ,
     ship_to_account_id         NUMBER ,
     ---  Added for ER# 2463321
     customer_phone_id   NUMBER ,
     customer_email_id   NUMBER ,
     --- Added these parameters for 11.5.9 source changes
     creation_program_code      VARCHAR2(30),
     last_update_program_code   VARCHAR2(30),
     -- Bill_to_party, ship_to_party
     bill_to_party_id           NUMBER,
     ship_to_party_id           NUMBER,
     -- Conc request related fields
     program_id                 NUMBER,
     program_application_id     NUMBER,
     conc_request_id            NUMBER,
     program_login_id           NUMBER,
     -- Bill_to_site, ship_to_site
     bill_to_site_id            NUMBER,
     ship_to_site_id            NUMBER,
     -- Added address related columns by shijain 4th dec 2002
     incident_point_of_interest      Varchar2(240) ,
     incident_cross_street           Varchar2(240) ,
     incident_direction_qualifier    Varchar2(30),
     incident_distance_qualifier     Varchar2(240) ,
     incident_distance_qual_uom      Varchar2(30),
     incident_address2               Varchar2(240) ,
     incident_address3               Varchar2(240),
     incident_address4               Varchar2(240) ,
     incident_address_style          Varchar2(30),
     incident_addr_lines_phonetic    Varchar2(560) ,
     incident_po_box_number          Varchar2(50) ,
     incident_house_number           Varchar2(50),
     incident_street_suffix          Varchar2(50) ,
     incident_street                 Varchar2(150),
     incident_street_number          Varchar2(50) ,
     incident_floor                  Varchar2(50) ,
     incident_suite                  Varchar2(50) ,
     incident_postal_plus4_code      Varchar2(30) ,
     incident_position               Varchar2(50) ,
     incident_location_directions    Varchar2(640),
     incident_location_description   Varchar2(2000) ,
     install_site_id                 Number ,
     status_flag                     Varchar2(3) ,
     primary_contact_id              Number,
     ------anmukher---------------07/31/03
     -- Added for CMRO-EAM project of Release 11.5.10
     old_type_maintenance_flag		VARCHAR2(3),
     new_type_maintenance_flag		VARCHAR2(3),
     old_type_CMRO_flag			VARCHAR2(3),
     new_type_CMRO_flag			VARCHAR2(3),
     item_serial_number			VARCHAR2(30),
     owning_dept_id			NUMBER,
     -- Added for Misc ERs project of Release 11.5.10
     incident_location_type		VARCHAR2(30) Default 'HZ_LOCATION',
     org_id                             NUMBER,
     maint_organization_id              NUMBER,
   /* Credit Card 9358401 */
     instrument_payment_use_id          NUMBER
  );


----------anmukher--------------07/31/03
-- Added new record type for OUT parameters of Create API
-- so that future overloading of the API can be avoided
TYPE sr_create_out_rec_type IS RECORD
(
  request_id			NUMBER,
  request_number		VARCHAR2(64),
  interaction_id		NUMBER,
  workflow_process_id		NUMBER,
  individual_owner		NUMBER,
  group_owner			NUMBER,
  individual_type		VARCHAR2(30),
  auto_task_gen_status		VARCHAR2(3),
  auto_task_gen_attempted	BOOLEAN Default FALSE,
  field_service_task_created	BOOLEAN,
  contract_service_id		NUMBER,
  resolve_by_date		DATE,
  respond_by_date		DATE,
  resolved_on_date		DATE,
  responded_on_date		DATE,
  -- added by siahmed for 12.1.2 project
  incident_location_id   NUMBER
  );

-- Added new record type for OUT parameters of Update API
-- so that future overloading of the API can be avoided
TYPE sr_update_out_rec_type IS RECORD
( interaction_id		NUMBER,
  workflow_process_id		NUMBER,
  individual_owner		NUMBER,
  group_owner			NUMBER,
  individual_type		VARCHAR2(30),
  resolved_on_date		DATE,
  responded_on_date		DATE
, status_id              NUMBER
, close_date             DATE
  -- added by siahmed for 12.1.2 project
, incident_location_id   NUMBER
  );

--This Global service request record type is declared
--for internal hooks.
TYPE internal_user_hooks_rec IS  RECORD  (
     request_id                 NUMBER,
     request_number             VARCHAR2(64),
     request_date               DATE,
     type_id                    NUMBER,
     status_id                  NUMBER,
     severity_id                NUMBER,
     urgency_id                 NUMBER,
     closed_date                DATE,
     owner_id                   NUMBER,
     owner_group_id             NUMBER,
     publish_flag               VARCHAR2(1),
     summary                    VARCHAR2(240),
     caller_type                VARCHAR2(30),
     customer_id                NUMBER,
     customer_number            VARCHAR2(30),
     employee_id                NUMBER,
     verify_cp_flag             VARCHAR2(1),
     customer_product_id        NUMBER,
     platform_id                NUMBER,
     platform_version		VARCHAR2(250),
     db_version			VARCHAR2(250),
     platform_version_id        NUMBER,
     cp_component_id            NUMBER,
     cp_component_version_id    NUMBER,
     cp_subcomponent_id         NUMBER,
     cp_subcomponent_version_id NUMBER,
     language_id                NUMBER,
     language                   VARCHAR2(4),
     inventory_item_id          NUMBER,
     inventory_org_id           NUMBER,
     current_serial_number      VARCHAR2(30),
     original_order_number      NUMBER,
     purchase_order_num         VARCHAR2(50),
     problem_code               VARCHAR2(50),
     exp_resolution_date        DATE,
     install_site_use_id        NUMBER,
     request_attribute_1        VARCHAR2(150),
     request_attribute_2        VARCHAR2(150),
     request_attribute_3        VARCHAR2(150),
     request_attribute_4        VARCHAR2(150),
     request_attribute_5        VARCHAR2(150),
     request_attribute_6        VARCHAR2(150),
     request_attribute_7        VARCHAR2(150),
     request_attribute_8        VARCHAR2(150),
     request_attribute_9        VARCHAR2(150),
     request_attribute_10       VARCHAR2(150),
     request_attribute_11       VARCHAR2(150),
     request_attribute_12       VARCHAR2(150),
     request_attribute_13       VARCHAR2(150),
     request_attribute_14       VARCHAR2(150),
     request_attribute_15       VARCHAR2(150),
     request_context            VARCHAR2(30),
     external_attribute_1       VARCHAR2(150),
     external_attribute_2       VARCHAR2(150),
     external_attribute_3       VARCHAR2(150),
     external_attribute_4       VARCHAR2(150),
     external_attribute_5       VARCHAR2(150),
     external_attribute_6       VARCHAR2(150),
     external_attribute_7       VARCHAR2(150),
     external_attribute_8       VARCHAR2(150),
     external_attribute_9       VARCHAR2(150),
     external_attribute_10      VARCHAR2(150),
     external_attribute_11      VARCHAR2(150),
     external_attribute_12      VARCHAR2(150),
     external_attribute_13      VARCHAR2(150),
     external_attribute_14      VARCHAR2(150),
     external_attribute_15      VARCHAR2(150),
     external_context           VARCHAR2(30),
     bill_to_site_use_id        NUMBER,
     bill_to_contact_id         NUMBER,
     ship_to_site_use_id        NUMBER,
     ship_to_contact_id         NUMBER,
     resolution_code            VARCHAR2(50),
     act_resolution_date        DATE,
     public_comment_flag        VARCHAR2(1),
     parent_interaction_id      NUMBER,
     contract_service_id        NUMBER,
--04/16/01
	contract_id             NUMBER,
	project_number          VARCHAR2(120),
--04/16/01
     qa_collection_plan_id      NUMBER,
     account_id                 NUMBER,
     resource_type              VARCHAR2(30),
     resource_subtype_id        NUMBER,
     cust_po_number             VARCHAR2(50),
     cust_ticket_number         VARCHAR2(50),
     sr_creation_channel        VARCHAR2(50),
     obligation_date            DATE,
     time_zone_id               NUMBER,
     time_difference            NUMBER,
     site_id                    NUMBER,
     customer_site_id           NUMBER,
     territory_id               NUMBER,
     initialize_flag            VARCHAR2(1),
     cp_revision_id             NUMBER,
     inv_item_revision          VARCHAR2(240),
     inv_component_id           NUMBER,
     inv_component_version      VARCHAR2(90),
     inv_subcomponent_id        NUMBER,
     inv_subcomponent_version   VARCHAR2(90),
------jngeorge---11.5.6----07/12/01
     tier                       VARCHAR2(250),
     tier_version               VARCHAR2(250),
     operating_system           VARCHAR2(250),
     operating_system_version   VARCHAR2(250),
     database                   VARCHAR2(250),
     cust_pref_lang_id          NUMBER,
     category_id                NUMBER,
     group_type                 VARCHAR2(30),
     group_territory_id         NUMBER,
     inv_platform_org_id        NUMBER,
     product_revision           VARCHAR2(240),
     component_version          VARCHAR2(3),
     subcomponent_version       VARCHAR2(3),
     comm_pref_code             VARCHAR2(30),
     cust_pref_lang_code        VARCHAR2(4),
     error_code                 VARCHAR2(250),
     incident_occurred_date     DATE,
     incident_resolved_date     DATE,
     inc_responded_by_date      DATE,
     resolution_summary         VARCHAR2(250),
     incident_location_id       NUMBER,
     incident_address           VARCHAR2(960),
     incident_city              VARCHAR2(60),
     incident_state             VARCHAR2(60),
     incident_country           VARCHAR2(60),
     incident_province          VARCHAR2(60),
     incident_postal_code       VARCHAR2(60),
     incident_county            VARCHAR2(60),
     -- Added for Enh# 2216664
     owner                      VARCHAR2(360),
     group_owner                VARCHAR2(60),
     -- Added for ER# 2320056
     coverage_type              VARCHAR2(30),
     --  Added for ER# 2433831
     bill_to_account_id         NUMBER ,
     ship_to_account_id         NUMBER ,
     --  Added for ER# 2463321
     customer_phone_id   	NUMBER ,
     customer_email_id   	NUMBER ,
    -- for cmro_eam
    status_flag                 VARCHAR2(3),
    old_type_cmro_flag          VARCHAR2(3),
    new_type_cmro_flag          VARCHAR2(3)
);

--This declaration is for the internal user hooks
user_hooks_rec     CS_ServiceRequest_PVT.internal_user_hooks_rec ;

   -- This cursor is defined so that we can define a subtype
   -- and use it pass the old_rec values to wrokitem and API validations
   -- calls.This was mainly done for the Misc ER:owner auto assg changes.

   cursor l_ServiceRequest_csr(c_incident_id number)  is
   select *
   from CS_INCIDENTS_ALL_VL
   where incident_id = c_incident_id;
   -- FOR UPDATE OF incident_id NOWAIT;
   -- This declaration is to store the old values of SR when SR is updated.

   SUBTYPE SR_OLDVALUES_REC_TYPE IS L_SERVICEREQUEST_CSR%ROWTYPE;

PROCEDURE initialize_rec(
  p_sr_record     IN OUT NOCOPY service_request_rec_type );
--------------------------------------------------------------------------
-- Start of comments
--  API name	: Create_ServiceRequest
--  Type	: Private
--  Function	: Creates a service request in the table CS_INCIDENTS.
--  Pre-reqs	: None.
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level		IN	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters:
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--	p_resp_id			IN	NUMBER		Optional
--	p_user_id			IN	NUMBER		Required
--		Application user identifier
--        Valid user from fnd_user

--	p_login_id			IN	NUMBER		Optional
--		Identifier of login session
--	p_org_id			IN	NUMBER		Optional
--		Operating unit identifier
--      p_request_id                    IN      NUMBER          Optional
--        Service Request Identifier
--      p_request_number                IN      VARCHAR2(64)    Optional
--      p_service_request_rec           IN      service_request_rec_type Required
--      p_notes                         IN      notes_table              Optional
--
--      p_contacts                      IN     contacts_table   Required if CALLER TYPE IS
--                                                              ORGANIZATION OR PERSON
--  Service Request OUT parameters:
--	x_request_id			OUT	NUMBER
--		System generated ID
--	x_request_number		OUT	VARCHAR2(64)
--		User-visible number of service request
--      x_interaction_id                OUT     NUMBER
--  Workflow OUT parameters:
--  x_workflow_process_id               OUT NUMBER
--
--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--
--  Interaction IN parameters:
--	p_parent_interaction_id		IN	NUMBER		Optional
--		Corresponds to the column INTERACTION_ID in the table
--		CS_INTERACTIONS, and identifies the parent interaction that
--		resulted in this service request
--  Version	: Current version	1.1
--			Added IN parameter p_parent_interaction_id.
--		  Previous version	1.0
--		  Initial version	1.0
-- End of comments

--------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Service_Request_Rec_Type
--  Description     : Holds the Service Request attributes
--                    for the Create_ServiceRequest Procedure.
--  Fields     :
--
--        Service request type identifier
--	request_date				DATE		Required
--		Service request date

--	type_id				        NUMBER		Required
--		Service request type identifier
--   VAlid incident_type_id from cs_incident_types

--	status_id				NUMBER		Required
--		Service request status identifier
--   Valid incident_status_id from cs_incident_statuses


--	severity_id				NUMBER		Required
--		Service request severity identifier
--   Valid incident_severity_id from cs_incident_severities


--	urgency_id				NUMBER		Optional
--		Service request urgency identifier
--   Valid incident_urgency_id  from cs_incident_urgencies


--	closed_date				DATE		Optional
--		Service request closed date
--		Ignored if the status is not a "closed" status

--	owner_id				NUMBER		Required
--		Service request owner identifier
--   Valid resource_id from cs_sr_owners_v

--	owner_group_id	    	                NUMBER		Optional
--		Service request owner group  identifier
--
--      resource_type                 VARCHAR2(30)         Optional
--    VAlid resource_type from  cs_sr_owners_v

--      resource_subtype_id           NUMBER               Optional

--	publish_flag				VARCHAR2(1)	Optional

--	summary				        VARCHAR2(240)	Required
--		Service request summary

---------------------------------------------------------------------------
--   These fields are no longer there in the service_request_rec_type

--   verify_request_flag            VARCHAR2(1)    Required
--        Corresponds to the column RECORD_IS_VALID_FLAG in the table
--        CS_INCIDENTS. Allows API callers to request that the API does
--        the validation of the optional fields (customer_id,
--        contact_id, bill_to_site_use_id, bill_to_contact_id,
--        ship_to_site_use_id, ship_to_contact_id).

--   filed_by_emp_flag         VARCHAR2(1)    Required
--------------------------------------------------------------------------

--      caller_type                   	       VARCHAR2(30)	Required
--         Caller Type
--      VAlid values are : ORGANIZATION, PERSON and CALLER_EMP


--	customer_id				NUMBER		Optional
--		Service request customer identifier


--	customer_number			       VARCHAR2(30)	Optional
--		Service request customer number


------------------------------------------------------------------------

--   These fields are no longer there in the service_request_rec_type

--	customer_prefix			       VARCHAR2(50)	Optional
--		Service request customer prefix

--	customer_firstname		       VARCHAR2(150)	Optional
--              Service request customer first name

--	customer_lastname		       VARCHAR2(150)	Optional
--              Service request customer last name


--	customer_company_name			VARCHAR2(255)	Optional
--              Service request customer company name
-------------------------------------------------------------------------------




--	employee_id				NUMBER		Optional

------------------------------------------------------------------------------
---These fileds are no longer there in the record type

--	contact01_id				NUMBER		Optional
--		Service request customer contact identifier

--	contact01_prefix			VARCHAR2(50)	Optional
--		Service request customer contact prefix

--	contact01_firstname			VARCHAR2(150)	Optional
--		Service request customer contact firstname



--	contact01_lastname			VARCHAR2(150)	Optional
--		Service request customer contact lastname

--	contact01_area_code			VARCHAR2(10)	Optional
--	contact01_telephone			VARCHAR2(40)	Optional
--	contact01_extension			VARCHAR2(20)	Optional
--	contact01_fax_area_code			VARCHAR2(10)	Optional
--	contact01_fax_number			VARCHAR2(40)	Optional
--	contact01_email_address			VARCHAR2(2000)	Optional

------------------------------------------------------------------------
--      This field is no longer present in the record type
--	contact_time_diff			NUMBER      	Optional
-------------------------------------------------------------------------
---These fileds are no longer there in the record type

--	contact02_id				NUMBER		Optional
--		Service request customer represented by identifier


--	contact02_prefix			VARCHAR2(50)	Optional
--		Service request customer represented by prefix


--	contact02_firstname			VARCHAR2(150)	Optional
--		Service request customer represented by firstname

--	contact02_lastname			VARCHAR2(150)	Optional
--		Service request customer represented by lastname

--	contact02_area_code			VARCHAR2(10)	Optional
--	contact02_telephone			VARCHAR2(40)	Optional
--	contact02_extension			VARCHAR2(20)	Optional
--	contact02_fax_area_code			VARCHAR2(10)	Optional
--	contact02_fax_number			VARCHAR2(40)	Optional
--	contact02_email_address			VARCHAR2(2000)	Optional
--------------------------------------------------------------------------------------------------

--	verify_cp_flag			VARCHAR2(1)	Required
--		The verify_cp_flag parameter allows API callers to request
--		that the API does the validation of the optional customer
--		product ID.

--	customer_product_id			NUMBER		Optional
--		Unique identifier for a customer product in the Installed Base.
--		Required if the verify_cp_flag parameter is 'Y'.
--		Ignored if the verify_cp_flag parameter is 'N'.

-----------------------------------------------------------
--     No longer there in rec type
--     lot_num                    VARCHAR2(30)   Optional
------------------------------------------------------------


-- Supporting platform_id again because of enh 1711552
--     platform_id                NUMBER         Optional
--     *********THE functionality for the below 2 fileds is no longer supported.
--     platform_version_id        NUMBER         Optional

--     language_id                NUMBER         Optional
--          This is the Product's language id

--     cp_component_id               NUMBER         Optional
--     cp_component_version_id       NUMBER         Optional
--     cp_subcomponent_id            NUMBER         Optional
--     cp_subcomponent_version_id    NUMBER         Optional

--     language                   VARCHAR2(4)    Optional
--          This is used for TL tables

--	inventory_item_id			NUMBER		Optional
--		Corresponds to the column INVENTORY_ITEM_ID in the table
--		MTL_SYSTEM_ITEMS, and identifies the service request product.
--		Ignored if the verify_cp_flag parameter is 'Y'.


--	inventory_org_id		        NUMBER		Optional
--		Item organization ID. Part of the unique key that uniquely
--		identifies an inventory item.
--		Required if inventory_item_id is used.

--	current_serial_number			VARCHAR2(30)	OPTIONAL
--		Serial number for serialized items.
--		Ignored if the verify_cp_flag parameter is 'Y'.

--	original_order_number			NUMBER		OPTIONAL
--		Sales Order information.
--		Ignored if the verify_cp_flag parameter is 'Y'.

--	purchase_order_number			VARCHAR2(50)	OPTIONAL
--		Sales Order information.
--		Ignored if the verify_cp_flag parameter is 'Y'.

-----------------------------------------------------------------------
--      This field is no longer present in the record type
--	problem_description			VARCHAR2(2000)	OPTIONAL
--		Service request problem description
-----------------------------------------------------------------------

--	problem_code				VARCHAR2(30)	OPTIONAL
--		Service request problem code

--	exp_resolution_date			DATE		OPTIONAL
--		Service request expected resolution date

-----------------------------------------------------------------------
--      This field is no longer present in the record type
--	make_public_problem			VARCHAR2(1)	Optional
-----------------------------------------------------------------------

--   install_site_use_id        NUMBER          Optional



------------------------------------------------------------------------

--   These fields are no longer there in the service_request_rec_type

--   install_location		VARCHAR2(40)	Optional
--   install_customer		VARCHAR2(50)	Optional
--   install_country            VARCHAR2(60)    Optional
--   install_address_1		VARCHAR2(240)	Optional
--   install_address_2		VARCHAR2(240)	Optional
--   install_address_3		VARCHAR2(240)	Optional



-----------------------------------------------------------------------
--      These fields are no longer present in the record type

--	rma_flag				VARCHAR2(1)	Required
--		Corresponds to the column RMA_FLAG in the table	CS_INCIDENTS.
--		Allows API callers to request that the API does	the validation
--		of the optional RMA header ID. It can only be set when the
--		verify_request_flag parameter is set to 'Y'.
--	rma_header_id				NUMBER		Optional
--		Sales order header identifier of the RMA.
--		Ignored if the rma_flag parameter is 'N'.
--	web_entry_flag			VARCHAR2(1)	Required
--		Indicates whether the service request is entered via the web.
-------------------------------------------------------------------------------


--	request_segment1			VARCHAR2(150)	Optional
--	request_segment2			VARCHAR2(150)	Optional
--	request_segment3			VARCHAR2(150)	Optional
--	request_segment4			VARCHAR2(150)	Optional
--	request_segment5			VARCHAR2(150)	Optional
--	request_segment6			VARCHAR2(150)	Optional
--	request_segment7			VARCHAR2(150)	Optional
--	request_segment8			VARCHAR2(150)	Optional
--	request_segment9			VARCHAR2(150)	Optional
--	request_segment10			VARCHAR2(150)	Optional
--	request_segment11			VARCHAR2(150)	Optional
--	request_segment12			VARCHAR2(150)	Optional
--	request_segment13			VARCHAR2(150)	Optional
--	request_segment14			VARCHAR2(150)	Optional
--	request_segment15			VARCHAR2(150)	Optional
--	request_context			        VARCHAR2(30)	Optional


--	bill_to_site_use_id			NUMBER		Optional
--		Bill To site use identifier

--	bill_to_contact_id			NUMBER		Optional
--		Bill To contact identifier



------------------------------------------------------------------------

--   These fields are no longer there in the service_request_rec_type

--	bill_to_location			VARCHAR2(40)	Optional

--	bill_to_customer			VARCHAR2(50)	Optional

--      bill_country                            VARCHAR2(60)    Optional

--	bill_to_address_1		        VARCHAR2(240)	Optional

--	bill_to_address_2		        VARCHAR2(240)	Optional

--	bill_to_address_3		         VARCHAR2(240)	Optional

--	bill_to_contact 			VARCHAR2(100)	Optional
-----------------------------------------------------------------------------------------


--	ship_to_site_use_id			NUMBER		Optional
--		Ship To site use identifier

--	ship_to_contact_id			NUMBER		Optional
--		Ship To contact identifier
------------------------------------------------------------------------

--   These fields are no longer there in the service_request_rec_type

--	ship_to_location			VARCHAR2(40)	Optional

--	ship_to_customer			VARCHAR2(50)	Optional

--      ship_country                            VARCHAR2(60)    Optional

--	ship_to_address_1		        VARCHAR2(240)	Optional

--	ship_to_address_2		        VARCHAR2(240)	Optional

--	ship_to_address_3		        VARCHAR2(240)	Optional

--	ship_to_contact 			VARCHAR2(100)	Optional
-----------------------------------------------------------------------------

------------------------------------------------------------------------
-- This field is no longer there in the record type
--	problem_resolution			VARCHAR2(2000)	OPTIONAL
--		Service request problem resolution
---------------------------------------------------------------------

--	resolution_code			VARCHAR2(30)	OPTIONAL
--		Service request resolution code

--	act_resolution_date			DATE		OPTIONAL
--		Service request actual resolution date

------------------------------------------------------------------------
-- This field is no longer there in the record type
--	make_public_resolution	 VARCHAR2(1)	Optional
-----------------------------------------------------------------------

--      public_comment_flag           VARCHAR2(1)     OPTIONAL
--      parent_interaction_id         NUMBER          OPTIONAL
--      contract_service_id           NUMBER          OPTIONAL
--      qa_collection_plan_id         NUMBER          OPTIONAL
--      account_id                    NUMBER          OPTIONAL
--      cust_po_number                VARCHAR2(50)    OPTIONAL
--      cust_ticket_number            VARCHAR2(50)    OPTIONAL
--      sr_creation_channel           VARCHAR2(50)    OPTIONAL
--      obligation_date               DATE            OPTIONAL
--      time_zone_id                  NUMBER          OPTIONAL
--      time_difference               NUMBER          OPTIONAL
--      site_id                       NUMBER          OPTIONAL
--      customer_site_id              NUMBER          OPTIONAL
--      territory_id                  NUMBER          OPTIONAL
--      initialize_flag               VARCHAR2(1)     OPTIONAL

--      cp_revision_id                NUMBER          OPTIONAL
--      inv_item_revision             VARCHAR2(3)     OPTIONAL
--      inv_component_id              NUMBER          OPTIONAL
--      inv_component_version         VARCHAR2(3)     OPTIONAL
--      inv_subcomponent_id           NUMBER          OPTIONAL
--      inv_subcomponent_version      VARCHAR2(3)     OPTIONAL

--     coverage_type              VARCHAR2(30)  Optional
--          Service Request Coverage Type
--     bill_to_account_id         NUMBER        Optional
--          Service Request Bill To Account Identifier
--     ship_to_account_id         NUMBER        Optional
--          Service Request Ship To Account Identifier
--     customer_phone_id   NUMBER        Optional
--          SR Customer's non-primary phone Id
--     customer_email_id   NUMBER        Optional
--          SR Customer's non-primary Email Id

-- End of service_request_rec_type comments
--------------------------------------------------------------

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
    p_service_request_rec    IN    service_request_rec_type,
    p_notes                  IN    notes_table,
    p_contacts               IN    contacts_table,
     -- Added for Assignment Manager 11.5.9 change
    p_auto_assign            IN   VARCHAR2  Default 'N',
    --------------anmukher----------------------07/31/03
    -- Added for 11.5.10 projects (AutoTask, Miscellaneous ERs)
    p_auto_generate_tasks	    IN		VARCHAR2 Default 'N',
    p_default_contract_sla_ind	    IN		VARCHAR2 Default 'N',
    p_default_coverage_template_id  IN		NUMBER Default NULL,
    x_sr_create_out_rec	    	    OUT NOCOPY	sr_create_out_rec_type
    ---------------anmukher----------------------07/31/03
    -- The following OUT parameters have been added to the record type sr_create_out_rec_type
    -- and have therefore been commented out. This will allow avoidance of future overloading
    -- if a new OUT parameter were to be needed, since it can be added to the same record type.
    -- x_request_id             OUT   NOCOPY NUMBER,
    -- x_request_number         OUT   NOCOPY VARCHAR2,
    -- x_interaction_id         OUT   NOCOPY NUMBER,
    -- x_workflow_process_id    OUT   NOCOPY NUMBER,
    -- x_individual_owner       OUT   NOCOPY NUMBER,
    -- x_group_owner            OUT   NOCOPY NUMBER,
    -- x_individual_type        OUT   NOCOPY VARCHAR2
);

----------------anmukher--------------07/31/03
-- Overloaded procedure added for backward compatibility in 11.5.10
-- since several new OUT parameters have been added to the 11.5.9 signature
-- in the form of a new record type, sr_create_out_rec_type
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
    p_service_request_rec    IN    service_request_rec_type,
    p_notes                  IN    notes_table,
    p_contacts               IN    contacts_table,
     -- Added for Assignment Manager 11.5.9 change
    p_auto_assign            IN   VARCHAR2  Default 'N',
    p_default_contract_sla_ind	    IN	VARCHAR2 Default 'N',
    x_request_id             OUT   NOCOPY NUMBER,
    x_request_number         OUT   NOCOPY VARCHAR2,
    x_interaction_id         OUT   NOCOPY NUMBER,
    x_workflow_process_id    OUT   NOCOPY NUMBER,
    x_individual_owner       OUT   NOCOPY NUMBER,
    x_group_owner            OUT   NOCOPY NUMBER,
    x_individual_type        OUT   NOCOPY VARCHAR2
);

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
    p_service_request_rec    IN    service_request_rec_type,
    p_notes                  IN    notes_table,
    p_contacts               IN    contacts_table,
    p_default_contract_sla_ind	    IN	VARCHAR2 Default 'N',
    x_request_id             OUT   NOCOPY NUMBER,
    x_request_number         OUT   NOCOPY VARCHAR2,
    x_interaction_id         OUT   NOCOPY NUMBER,
    x_workflow_process_id    OUT   NOCOPY NUMBER
);





--------------------------------------------------------------------------
-- Start of comments
--  API name	: Update_ServiceRequest
--  Type	: Private
--  Function	: Updates a service request in the table CS_INCIDENTS.
--  Pre-reqs	: None.
--  Parameters	:
--  IN		:
--	p_api_version		  	IN	NUMBER		Required
--	p_init_msg_list		  	IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit		  	IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level	  	IN	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_request_id			IN	NUMBER		Required
--      p_object_version_number         IN      NUMBER          Required for Web-Apps
-----------------------------------------------------------------
--      No longer there in the API
--	p_org_id			IN	NUMBER		Optional
--		For validating the service request id
--		Default = NULL
----------------------------------------------------------------------------
--	p_resp_appl_id			IN	NUMBER		Optional
--	p_resp_id			IN	NUMBER		Optional
--	p_last_updated_by		IN	NUMBER		Required
--      VAlid user from fnd_user

--	p_last_update_login		IN	NUMBER		Optional
--		Default = NULL
--	p_last_update_date		IN	DATE		Required

--      p_service_request_rec           IN      service_request_rec_type  Required

--      p_update_desc_flex              IN      VARCHAR2(1)     Optional
--		Indicates whether the descriptive flexfields are being updated
--		Default = FND_API.G_FALSE

--      p_notes                         IN      notes_table     Optional

--      p_contacts                      IN      contacts_table  Optional
--
------------------------------------------------------
--      p_audit_comments                IN      VARCHAR2
--		To be used for the audit record
--		Default = NULL

--      p_called_by_workflow            IN      VARCHAR2(1)
--		Indicates whether this API is being called by the active
--		workflow process for the service request
--		Default = FND_API.G_FALSE

--      p_workflow_process_id           IN      NUMBER
--		The workflow process id of the workflow process that is
--		calling this API
--		Default = NULL

--  OUT		:
--      x_workflow_process_id           OUT NUMBER
--      x_interaction_id                OUT     NUMBER
--
--	x_return_status			OUT	VARCHAR2(1)	Required
--	x_msg_count			OUT	NUMBER		Required
--	x_msg_data			OUT	VARCHAR2(2000)	Required
--	x_call_id			OUT	NUMBER		Required
--
--  Version	: Current version	1.1
--			Added IN parameter p_parent_interaction_id.
--		  Previous version	1.0
--		  Initial Version	1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
--
--
-- Start of comments
--  Record Type     : Service_Request_Rec_Type
--  Description     : Holds the Service Request attributes
--                    for the Update_ServiceRequest Procedure.
--  Fields     :
--      request_date                            DATE
--
--	type_id				        NUMBER		Optional
--		Cannot be NULL
--	status_id				NUMBER		Optional
--		Cannot be NULL
--	severity_id				NUMBER		Optional
--		Cannot be NULL
--	urgency_id				NUMBER		Optional
--	closed_date				DATE		Optional
--	owner_id				NUMBER		Optional
--		Cannot be NULL
--	owner_group_id				NUMBER		Optional
--	publish_flag				VARCHAR2	Optional
--	summary				        VARCHAR2	Optional
--		Cannot be NULL
----------------------------------------------------------------------
-- This field is no longer there in the record type
--	verify_request_flag			VARCHAR2	Optional
--		Must be either 'Y' or 'N'
----------------------------------------------------------------------
--	customer_id				NUMBER	        Optional
--	customer_number			        VARCHAR2	Optional
------------------------------------------------------------------------
--   These fields are no longer there in the service_request_rec_type
--	customer_prefix				VARCHAR2	Optional
--	customer_firstname			VARCHAR2	Optional
--	customer_lastname			VARCHAR2	Optional
--	customer_company_name			VARCHAR2	Optional
-----------------------------------------------------------------------------------
--      employee_id                             NUMBER
---------------------------------------------------------------------------
--- These fields are no longer there in rec type
--	contact01_id				NUMBER	        Optional
--	contact01_prefix			VARCHAR2	Optional
--	contact01_firstname			VARCHAR2	Optional
--	contact01_lastname			VARCHAR2	Optional
--	contact01_area_code			VARCHAR2	Optional
--	contact01_telephone			VARCHAR2	Optional
--	contact01_extension			VARCHAR2	Optional
--	contact01_fax_area_code			VARCHAR2	Optional
--	contact01_fax_number			VARCHAR2	Optional
--	contact01_email_address			VARCHAR2	Optional
------------------------------------------------------------------------
-- This field is no longer in the service request record type
--	contact_time_diff			NUMBER		Optional
--------------------------------------------------------------------------
--- These fields are no longer there in rec type
--	contact02_id				NUMBER		Optional
--		Service request customer represented by identifier
--	contact02_prefix			VARCHAR2(50)	Optional
--		Service request customer represented by prefix
--	contact02_firstname			VARCHAR2(150)	Optional
--		Service request customer represented by firstname
--	contact02_lastname			VARCHAR2(150)	Optional
--		Service request customer represented by lastname
--	contact02_area_code			VARCHAR2(10)	Optional
--	contact02_telephone			VARCHAR2(40)	Optional
--	contact02_extension			VARCHAR2(20)	Optional
--	contact02_fax_area_code			VARCHAR2(10)	Optional
--	contact02_fax_number			VARCHAR2(40)	Optional
--	contact02_email_address			VARCHAR2(2000)	Optional
---------------------------------------------------------------------------
--	verify_cp_flag			VARCHAR2	Optional
--		Must be either 'Y' or 'N'.
--	customer_product_id			NUMBER		Optional
--		For Installed Base mode only
-------------------------------------------------------------------
--     no longer there
--     lot_num                    VARCHAR2(30)    Optional
----------------------------------------------------------------------

-- Supporting platform_id again because of enh 1711552
--     platform_id                NUMBER         Optional
--     ********THE functionality for the below 2 fileds is no longer supported.
--     platform_version_id        NUMBER         Optional
--     language_id                NUMBER         Optional
--          This is the Product's language id
--     cp_component_id               NUMBER          Optional
--     cp_component_version_id       NUMBER          Optional
--     cp_subcomponent_id            NUMBER          Optional
--     cp_subcomponent_version_id    NUMBER          Optional
--     language                   VARCHAR2(4)     Optional
--          This is used for TL tables
--          If not passed to the api, the userenv('LANG') is used.
--	inventory_item_id			NUMBER 		Optional
--	inventory_org_id			NUMBER		Optional
--	current_serial_number			VARCHAR2	Optional
--		Used only if verify_cp_flag is 'N'
--	original_order_number			NUMBER	        Optional
--		Used only if verify_cp_flag is 'N'
--	purchase_order_num 			VARCHAR2	Optional
--		Used only if verify_cp_flag is 'N'
--------------------------------------------------------------------------
-- This field is not there in the record type
--	problem_description			VARCHAR2	Optional
------------------------------------------------------------------------
--	problem_code				VARCHAR2	Optional
--	exp_resolution_date			DATE 		Optional
-----------------------------------------------------------------------------
-- This field is not there in the record type
--	make_public_problem			VARCHAR2	Optional
---------------------------------------------------------------------------------
--      install_site_use_id                     NUMBER          Optional
------------------------------------------------------------------------
--   These fields are no longer there in the service_request_rec_type
--	install_location			VARCHAR2	Optional
--	install_customer			VARCHAR2	Optional
--      install_country                         VARCHAR2        Optional
--	install_address_1			VARCHAR2	Optional
--	install_address_2			VARCHAR2	Optional
--	install_address_3			VARCHAR2	Optional
-----------------------------------------------------------------------
--  These fields are no longer present in the record type
--	rma_flag				VARCHAR2	Optional
--		Must be either 'Y' or 'N'. Can only be set to 'Y' for verified
--		requests
--	rma_header_id			IN	NUMBER	Optional
--	web_entry_flag			VARCHAR2	Optional
--		Indicates whether the update was done through the web
--		Default = 'N'
------------------------------------------------------------------------------
--	request_attribute_1			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_2			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_3			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_4			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_5			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_6			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_7			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_8			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_9			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_10			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_11			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_12			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_13			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_14			VARCHAR2	Optional
--		Default = NULL
--	request_attribute_15			VARCHAR2	Optional
--		Default = NULL
--	request_context			        VARCHAR2	Optional
--		Default = NULL
--	bill_to_site_use_id			NUMBER		Optional
--	bill_to_contact_id			NUMBER		Optional
------------------------------------------------------------------------
--   These fields are no longer there in the service_request_rec_type
--	bill_to_location			VARCHAR2	Optional
--	bill_to_customer			VARCHAR2	Optional
--      bill_country                            VARCHAR2        Optional
--	bill_to_address_1			VARCHAR2	Optional
--	bill_to_address_2			VARCHAR2	Optional
--	bill_to_address_3			VARCHAR2	Optional
--	bill_to_contact			        VARCHAR2	Optional
---------------------------------------------------------------------------------------
--	ship_to_site_use_id			NUMBER		Optional
--	ship_to_contact_id			NUMBER		Optional
-----------------------------------------------------------------------
--   These fields are no longer there in the service_request_rec_type
--	ship_to_location			VARCHAR2	Optional
--	ship_to_customer			VARCHAR2	Optional
--      ship_country                            VARCHAR2        Optional
--	ship_to_address_1			VARCHAR2	Optional
--	ship_to_address_2			VARCHAR2	Optional
--	ship_to_address_3			VARCHAR2	Optional
--	ship_to_contact			        VARCHAR2	Optional
----------------------------------------------------------
--      This field is not there in the record type
--	problem_resolution			VARCHAR2	Optional
------------------------------------------------------------------------
--	resolution_code			        VARCHAR2	Optional
--	act_resolution_date			DATE	 	Optional
--		Must be later than the service request date
----------------------------------------------------------
-- This field
--	make_public_resolution		VARCHAR2	Optional
------------------------------------------------------------------
--	public_comment_flag			VARCHAR2	Optional
--		Default = 'N'
--	parent_interaction_id			NUMBER		Optional
--		Corresponds to the column INTERACTION_ID in the table
--		CS_INTERACTIONS, and identifies the parent interaction that
--		resulted in this service request update
--      contract_service_id           NUMBER              Optional
--      qa_collection_plan_id         NUMBER              Optional
--      account_id                    NUMBER              Optional
--      resource_type                 VARCHAR2(30)        Optional
--      resource_subtype_id           NUMBER              Optional
--      cust_po_number                VARCHAR2(50)        Optional
--      cust_ticket_number            VARCHAR2(50)        Optional
------------------------------------------------------------------
--      This cannot be updated
--      sr_creation_channel           VARCHAR2(50)        Optional
----------------------------------------------------------------------
--      obligation_date               DATE                Optional
--      time_zone_id                  NUMBER              Optional
--      time_difference               NUMBER              Optional
--      site_id                       NUMBER              Optional
--      customer_site_id              NUMBER              Optional
--      territory_id                  NUMBER              Optional
--      cp_revision_id                NUMBER          OPTIONAL
--      inv_item_revision             VARCHAR2(3)     OPTIONAL
--      inv_component_id              NUMBER          OPTIONAL
--      inv_component_version         VARCHAR2(3)     OPTIONAL
--      inv_subcomponent_id           NUMBER          OPTIONAL
--      inv_subcomponent_version      VARCHAR2(3)     OPTIONAL
--      initialize_flag               VARCHAR2(1)         Optional
--     coverage_type              VARCHAR2(30)  Optional
--          Service Request Coverage Type
--     bill_to_account_id         NUMBER        Optional
--          Service Request Bill To Account Identifier
--     ship_to_account_id         NUMBER        Optional
--          Service Request Ship To Account Identifier
--     customer_phone_id   NUMBER        Optional
--          SR Customer's non-primary phone Id
--     customer_email_id   NUMBER        Optional
--          SR Customer's non-primary Email Id
-- End of service_request_rec_type comments
--------------------------------------------------------------

PROCEDURE Update_ServiceRequest
  ( p_api_version		    IN	NUMBER,
    p_init_msg_list		    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit			    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level	            IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status		    OUT	NOCOPY VARCHAR2,
    x_msg_count		            OUT	NOCOPY NUMBER,
    x_msg_data			    OUT	NOCOPY VARCHAR2,
    p_request_id		    IN	NUMBER,
    p_audit_id                      IN  NUMBER   DEFAULT NULL,
    p_object_version_number         IN  NUMBER,
    p_resp_appl_id		    IN	NUMBER   DEFAULT NULL,
    p_resp_id			    IN	NUMBER   DEFAULT NULL,
    p_last_updated_by	            IN	NUMBER,
    p_last_update_login	            IN	NUMBER   DEFAULT NULL,
    p_last_update_date	            IN	DATE,
    p_service_request_rec           IN  service_request_rec_type,
    p_invocation_mode               IN  VARCHAR2 := 'NORMAL',
    p_update_desc_flex              IN  VARCHAR2 DEFAULT fnd_api.g_false,
    p_notes                         IN  notes_table,
    p_contacts                      IN  contacts_table,
    p_audit_comments                IN  VARCHAR2 DEFAULT NULL,
    p_called_by_workflow	    IN 	VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id           IN	NUMBER   DEFAULT NULL,
    -- Commented out since these are now part of the out rec type --anmukher--08/08/03
    -- x_workflow_process_id        OUT NOCOPY NUMBER,
    -- x_interaction_id	            OUT	NOCOPY NUMBER,
    ----------------anmukher--------------------08/05/03
    -- Added for 11.5.10 projects
    p_auto_assign		    IN		VARCHAR2 Default 'N',
    p_validate_sr_closure	    IN		VARCHAR2 Default 'N',
    p_auto_close_child_entities	    IN		VARCHAR2 Default 'N',
    p_default_contract_sla_ind	    IN	        VARCHAR2 Default 'N',
    x_sr_update_out_rec		    OUT NOCOPY	sr_update_out_rec_type
    );

----------------anmukher--------------08/11/03
-- Overloaded procedure added for backward compatibility in 11.5.10
-- since several new OUT parameters have been added to the 11.5.9 signature
-- in the form of a new record type, sr_update_out_rec_type
PROCEDURE Update_ServiceRequest
  ( p_api_version		    IN	NUMBER,
    p_init_msg_list		    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit			    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level	            IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status		    OUT	NOCOPY VARCHAR2,
    x_msg_count		            OUT	NOCOPY NUMBER,
    x_msg_data			    OUT	NOCOPY VARCHAR2,
    p_request_id		    IN	NUMBER,
    p_audit_id                      IN  NUMBER   DEFAULT NULL,
    p_object_version_number         IN  NUMBER,
    p_resp_appl_id		    IN	NUMBER   DEFAULT NULL,
    p_resp_id			    IN	NUMBER   DEFAULT NULL,
    p_last_updated_by	            IN	NUMBER,
    p_last_update_login	            IN	NUMBER   DEFAULT NULL,
    p_last_update_date	            IN	DATE,
    p_service_request_rec           IN  service_request_rec_type,
    p_invocation_mode               IN  VARCHAR2 := 'NORMAL',
    p_update_desc_flex              IN  VARCHAR2 DEFAULT fnd_api.g_false,
    p_notes                         IN  notes_table,
    p_contacts                      IN  contacts_table,
    p_audit_comments                IN  VARCHAR2 DEFAULT NULL,
    p_called_by_workflow	    IN 	VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id           IN	NUMBER   DEFAULT NULL,
    p_default_contract_sla_ind	    IN	VARCHAR2 Default 'N',
    x_workflow_process_id           OUT NOCOPY NUMBER,
    x_interaction_id	            OUT	NOCOPY NUMBER
    );

--------------------------------------------------------------------------
-- Start of comments
--  API Name	: Update_Status
--  Type	: Private
--  Description	: Update the status of a service request
--  Pre-reqs	: None
--  Parameters	:
--  IN		:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level		IN	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_request_id	 		IN	NUMBER		Required
----------------------------------------------------
--   Removed from the api
--	p_org_id			IN	NUMBER		Optional
--		For validating the service request ID
--		Default = NULL
----------------------------------------------------------

--	p_status_id			IN	NUMBER		Required
--		Cannot be NULL
--	p_closed_date			IN	DATE		Optional
--		The date the service request is closed
--		Default = NULL
--	p_last_updated_by		IN	VARCHAR2	Required
--	p_last_update_login		IN	NUMBER		Optional
--		Default = NULL
--	p_last_update_date		IN	DATE		Required
--	p_audit_comments		IN	VARCHAR2	Optional
--		To be used for the audit record
--		Default = NULL
--	p_call_by_workflow		IN	VARCHAR2	Optional
--		Indicates whether this API is being called by a workflow
--		process
--		Default = FND_API.G_FALSE
--	p_workflow_process_id		IN	NUMBER		Optional
--		The workflow process id of the workflow process that is
--		calling this API
--		Default = NULL
--	p_comments			IN	VARCHAR2	Optional
--		Default = NULL
--	p_public_comment_flag		IN	VARCHAR2	Optional
--		Default = 'N'
--	p_parent_interaction_id		IN	NUMBER		Optional
--		Corresponds to the column INTERACTION_ID in the table
--		CS_INTERACTIONS, and identifies the parent interaction that
--		resulted in this service request update
--
--  OUT		:
--	p_return_status			OUT	VARCHAR2(1)	Required
--	p_msg_count			OUT	NUMBER		Required
--	p_msg_data			OUT	VARCHAR2(2000)	Required
--	p_call_id			OUT	NUMBER		Required
--
--  Version	: Current version	1.1
--			Added IN parameter p_parent_interaction_id.
--		  Previous version	1.0
--		  Initial Version	1.0
--
--  Notes:	: If the old value is the same as the new value, then no
--		  update is performed and a warning message is appended to the
--		  message list.
--
--		  If there is an active workflow process for the service
--		  request, its status cannot be updated to a "closed" status
--		  (a status with the close_flag set) unless the caller of the
--		  API is the workflow process itself. In that case, the caller
--		  must pass in the workflow_process_id of the process for
--		  validation.
--
--		  The p_closed_date parameter is ignored if the new status is
--		  not a "closed" status.  If this parameter is not passed in
--		  for a "closed" status, sysdate will be used as the default
--		  value.
--
-- End of comments
--------------------------------------------------------------------------


FUNCTION Get_API_Revision
 RETURN NUMBER;

PROCEDURE Update_Status
  ( p_api_version             IN    NUMBER,
    p_init_msg_list           IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                  IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_resp_id                 IN    NUMBER,
    p_validation_level		IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status	          OUT   NOCOPY VARCHAR2,
    x_msg_count               OUT   NOCOPY NUMBER,
    x_msg_data	               OUT   NOCOPY VARCHAR2,
    p_request_id              IN    NUMBER,
    p_object_version_number   IN    NUMBER,
    p_status_id               IN    NUMBER,
    p_closed_date             IN    DATE     DEFAULT fnd_api.g_miss_date,
    p_last_updated_by		IN    NUMBER,
    p_last_update_login		IN    NUMBER   DEFAULT NULL,
    p_last_update_date		IN    DATE,
    p_audit_comments		IN    VARCHAR2 DEFAULT NULL,
    p_called_by_workflow      IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id     IN    NUMBER   DEFAULT NULL,
    p_comments	               IN    VARCHAR2 DEFAULT NULL,
    p_public_comment_flag	IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_parent_interaction_id	IN    NUMBER   DEFAULT NULL,
     -- Added for 11.5.10 projects
    p_validate_sr_closure           IN          VARCHAR2 Default 'N',
    p_auto_close_child_entities     IN          VARCHAR2 Default 'N',
    x_interaction_id          OUT   NOCOPY NUMBER
  );

--------------------------------------------------------------------------
-- Start of comments
--  API Name	: Update_Owner
--  Type	: Private
--  Description	: Update the owner field of a service request
--  Pre-reqs	: p_owner_id must be a valid employee ID for an active
--		   employee in HR.
--  Parameters	:
--  IN		:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level		IN	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_request_id			IN	NUMBER		Required
--	p_resp_id			IN	NUMBER		Optional
--		Default = NULL
--	p_resp_appl_id			IN	NUMBER		Optional
--		Default = NULL
--		For validating the service request owner

---------------------------------------------------
--   Removed from API
--	p_org_id			IN	NUMBER		Optional
--		For validating the service request ID
--		Default = NULL
-----------------------------------------------------------


--	p_owner_id			IN	VARCHAR2	Required
--		Cannot be NULL
--	p_last_updated_by		IN	NUMBER		Required
--	p_last_update_login		IN	NUMBER		Optional
--		Default = NULL
--	p_last_update_date		IN	DATE	Required
--	p_audit_comments		IN	VARCHAR2	Optional
--		To be used for the audit record
--		Default = NULL
--	p_call_by_workflow		IN	VARCHAR2	Optional
--		Indicates whether this API is being called by a workflow
--		process
--		Default = FND_API.G_FALSE
--	p_workflow_process_id		IN	NUMBER		Optional
--		Default = NULL
--		The workflow process id of the workflow process that is
--		calling this API
--	p_comments			IN	VARCHAR2	Optional
--		Default = NULL
--	p_public_comment_flag		IN	VARCHAR2	Optional
--		Default = 'N'
--	p_parent_interaction_id		IN	NUMBER		Optional
--		Corresponds to the column INTERACTION_ID in the table
--		CS_INTERACTIONS, and identifies the parent interaction that
--		resulted in this service request update
--
--  OUT		:
--	p_return_status			OUT	VARCHAR2(1)	Required
--	p_msg_count			OUT	NUMBER		Required
--	p_msg_data			OUT	VARCHAR2(2000)	Required
--	p_call_id			OUT	NUMBER		Required
--
--  Version	: Current version	1.1
--			Added IN parameter p_parent_interaction_id.
--		 Previous version	1.0
--		 Initial Version	1.0
--
--  Notes:	: If the old value is the same as the new value, then no
--		  update is performed and a warning message is appended to the
--		  message list.
--
--		  If there is an active workflow process for the service
--		  request, its owner cannot be updated unless the caller of
--		  the API is the workflow process itself. In that case, the
--		  caller must pass in the workflow_process_id of the process
--		  for validation.
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Update_Owner
  ( p_api_version		     IN	NUMBER,
    p_init_msg_list		     IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit			     IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level		IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status		     OUT	NOCOPY VARCHAR2,
    x_msg_count			OUT	NOCOPY NUMBER,
    x_msg_data			     OUT	NOCOPY VARCHAR2,
    p_request_id  		     IN	NUMBER,
    p_object_version_number   IN    NUMBER,
    p_resp_id			     IN    NUMBER   DEFAULT NULL,
    p_resp_appl_id		     IN	NUMBER   DEFAULT NULL,
    p_owner_id			     IN	NUMBER,
    p_owner_group_id          IN   NUMBER,
    p_resource_type           IN VARCHAR2,
    p_last_updated_by		IN	NUMBER,
    p_last_update_login		IN	NUMBER   DEFAULT NULL,
    p_last_update_date		IN	DATE,
    p_audit_comments		IN	VARCHAR2 DEFAULT NULL,
    p_called_by_workflow	IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id	IN	NUMBER   DEFAULT NULL,
    p_comments			IN	VARCHAR2 DEFAULT NULL,
    p_public_comment_flag	IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_parent_interaction_id	IN	NUMBER   DEFAULT NULL,
    x_interaction_id			OUT	NOCOPY NUMBER
  );

-- -------------------------------------------------------------------
-- Start of comments
--  API Name	: Create_Audit_Record
--  Type	: Private
--  Description	: Insert an audit record into CS_INCIDENTS_AUDIT for
--		  service request updates.
--  Pre-reqs	: None
--  Parameters	:
--  IN		:
--     p_api_version		  IN NUMBER	Required
--     p_init_msg_list		  IN VARCHAR2	Optional  Default = FND_API.G_FALSE
--     p_commit			  IN VARCHAR2	Optional  Default = FND_API.G_FALSE
--     p_request_id	          IN NUMBER	Required
--     p_change_flags             IN AUDIT_FLAGS_REC_TYPE Required
--     p_old_vals_rec             IN AUDIT_VALS_REC_TYPE  Optional
--     p_new_vals_rec             IN AUDIT_VALS_REC_TYPE  Optional
--     p_action_id                IN NUMBER	Optional  Default = FND_API.G_MISS_NUM
--     p_wf_process_name          IN VARCHAR2   Optional  Default = FND_API.G_MISS_CHAR
--     p_wf_process_itemkey       IN VARCHAR2   Optional  Default = FND_API.G_MISS_CHAR
--     p_user_id		  IN NUMBER     Required
--     p_login_id		  IN NUMBER     Optional  Default = NULL
--     p_comments		  IN VARCHAR2   Optional  Default = NULL
--
--  OUT		:
--     p_return_status		 OUT VARCHAR2   Required  Length = 1
--     p_msg_count		 OUT NUMBER     Required
--     p_msg_data		 OUT VARCHAR2   Required  Length = 2000
--
--  Version	: Initial Version	1.0
--
--  Notes:	:
--
-- End of comments
-- -------------------------------------------------------------------

  PROCEDURE Create_Audit_Record (
	p_api_version            IN  NUMBER,
	p_init_msg_list          IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		 IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_return_status          OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
	p_request_id  	         IN  NUMBER,
        p_audit_id               IN  NUMBER DEFAULT NULL,
        --p_change_flags         IN  audit_flags_rec_type,
        --p_old_vals_rec         IN  audit_vals_rec_type DEFAULT G_MISS_AUDIT_VALS_REC,
        --p_new_vals_rec         IN  audit_vals_rec_type DEFAULT G_MISS_AUDIT_VALS_REC,
        p_audit_vals_rec         IN  SR_AUDIT_REC_TYPE,
	p_action_id		 IN  NUMBER   DEFAULT FND_API.G_MISS_NUM,
	p_wf_process_name	 IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_wf_process_itemkey     IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_user_id		 IN  NUMBER,
	p_login_id		 IN  NUMBER   DEFAULT NULL,
        p_last_update_date       IN  DATE,
        p_creation_date          IN  DATE,
	p_comments		 IN  VARCHAR2 DEFAULT NULL,
        x_audit_id               OUT NOCOPY NUMBER
     );

PROCEDURE Add_Language;

-- Lock row procedure
-- This is used to lock a row in the Service Request form

PROCEDURE LOCK_ROW(
			    X_INCIDENT_ID			NUMBER,
			    X_OBJECT_VERSION_NUMBER	NUMBER
			    );


/* Added for enh. 2655115, to get the status flag based on close_flag
and status_id by shijain date 27th nov 2002*/

FUNCTION GET_STATUS_FLAG ( p_incident_status_id IN  NUMBER)
RETURN VARCHAR2;

/* Added for enh. 2690787, to get the primary flag based on incident_id
and primary_flag by shijain date 09th dec 2002

FUNCTION GET_PRIMARY_CONTACT ( p_incident_id IN  NUMBER)
RETURN NUMBER;

*/

/* defined the global variable to get the profile valus for cs_sr_restrict_ib
   profile variable by shijain 4th dec 2002*/

G_RESTRICT_IB       VARCHAR2(5)          ;

-- Added for 11.5.10 Auditing project --anmukher --09/10/03

PROCEDURE initialize_audit_rec
(
  p_sr_audit_record         IN OUT NOCOPY sr_audit_rec_type
);

PROCEDURE Delete_ServiceRequest
(
  p_api_version_number          IN  NUMBER   := 1.0
, p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE
, p_commit                      IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level            IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_processing_set_id           IN  NUMBER
, p_purge_set_id                IN  NUMBER
, p_purge_source_with_open_task IN  VARCHAR2
, p_audit_required              IN  VARCHAR2
, x_return_status               OUT NOCOPY  VARCHAR2
, x_msg_count                   OUT NOCOPY  NUMBER
, x_msg_data                    OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
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
);
--------------------------------------------------------------------------------
--created by siahmed for 12.1.2 projet for one time address creation
PROCEDURE create_onetime_address
(    p_service_req_rec   IN  service_request_rec_type,
     x_msg_count         OUT NOCOPY  NUMBER,
     x_msg_data          OUT NOCOPY  VARCHAR2,
     x_return_status     OUT NOCOPY  VARCHAR2,
     x_location_id       OUT NOCOPY  NUMBER
);
--end of address creation procedure siahmed
--------------------------------------------------------------------------------
--created by siahmed for 12.1.2 projet for one time address updation
PROCEDURE update_onetime_address
(    p_service_req_rec     IN  service_request_rec_type,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     x_return_status       OUT NOCOPY  VARCHAR2);
--end of address updation procedure siahmed
--------------------------------------------------------------------------------
END CS_ServiceRequest_PVT;

/
