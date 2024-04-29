--------------------------------------------------------
--  DDL for Package CS_SERVICEREQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SERVICEREQUEST_PUB" AUTHID CURRENT_USER AS
/* $Header: cspsrs.pls 120.9.12010000.3 2010/04/03 17:54:37 rgandhi ship $ */
/*#
 * You can use this public interface  to create and update a service request.
 * This interface applies to all service request business rules.
 *
 * @rep:scope public
 * @rep:product CS
 * @rep:displayname Service Request Processing
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
 */

/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that the interfaces
      defined in this package appears in the integration repository.
****/

TYPE notes_rec IS RECORD (
    NOTE                            VARCHAR2(2000)  := FND_API.G_MISS_CHAR,
    NOTE_DETAIL                     VARCHAR2(32767) := FND_API.G_MISS_CHAR,
    NOTE_TYPE                       VARCHAR2(240)   := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_TYPE_01            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_TYPE_ID_01         NUMBER          := FND_API.G_MISS_NUM,
    NOTE_CONTEXT_TYPE_02            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_TYPE_ID_02         NUMBER          := FND_API.G_MISS_NUM,
    NOTE_CONTEXT_TYPE_03            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    NOTE_CONTEXT_TYPE_ID_03         NUMBER          := FND_API.G_MISS_NUM

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

-- NOTE_CONTEXT_TYPE_01  OPTIONAL
-- VAlid value is 'SR'

-- NOTE_CONTEXT_TYPE_ID_01   OPTIONAL
-- VAlid incident_id from cs_incidents_all_b

--    NOTE_CONTEXT_TYPE_02
-- VAlid value is 'SR'

--   NOTE_CONTEXT_TYPE_ID_02
-- VAlid incident_id from cs_incidents_all_b

--    NOTE_CONTEXT_TYPE_03
-- VAlid value is 'SR'


--    NOTE_CONTEXT_TYPE_ID_03
-- VAlid incident_id from cs_incidents_all_b
-------------------------------------------------------------------

--
--This table will hold the contacts and contact information
--for a Service Request customer
--
TYPE contacts_rec IS RECORD (
   SR_CONTACT_POINT_ID            NUMBER         := FND_API.G_MISS_NUM,
   PARTY_ID                       NUMBER         := FND_API.G_MISS_NUM,
   CONTACT_POINT_ID               NUMBER         := FND_API.G_MISS_NUM,
   CONTACT_POINT_TYPE             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
   PRIMARY_FLAG                   VARCHAR2(1)    := FND_API.G_MISS_CHAR,
   CONTACT_TYPE                   VARCHAR2(30)   := FND_API.G_MISS_CHAR,
   party_role_code                VARCHAR2(30)   := FND_API.G_MISS_CHAR,
   start_date_active              DATE           := FND_API.G_MISS_DATE,
   end_date_active                DATE           := FND_API.G_MISS_DATE
);

TYPE contacts_table IS TABLE OF contacts_rec INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------
-- Start of comments
--  Record Type     : contacts_rec
--  Description     : Holds the Contacts attributes for the
--                    Creating records in CS_HZ_SR_CONTACT_POINTS
--  Fields     :
--
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

--  primary_flag                OPTIONAL
--  At least one record in the table should have this flag set to Y

--  contact_type                REQUIRED
--  Valid values are 'PERSON" and 'EMPLOYEE'

--------------------------------------------------------

TYPE service_request_rec_type IS RECORD (
     request_date               DATE,
     type_id                    NUMBER,
     type_name                  VARCHAR2(30),
     status_id                  NUMBER,
     status_name                VARCHAR2(30),
     severity_id                NUMBER,
     severity_name              VARCHAR2(30),
     urgency_id                 NUMBER,
     urgency_name               VARCHAR2(30),
     closed_date                DATE,
     owner_id                   NUMBER,
     owner_group_id             NUMBER,
     publish_flag               VARCHAR2(1),
     summary                    VARCHAR2(240),
     caller_type                VARCHAR2(30),
     customer_id                NUMBER,
     customer_number            VARCHAR2(30),
     employee_id                NUMBER,
     employee_number            VARCHAR2(30),
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
     cp_ref_number              NUMBER, -- 3840658
     inventory_item_id          NUMBER,
     inventory_item_conc_segs   VARCHAR2(800),
     inventory_item_segment1    VARCHAR2(200),
     inventory_item_segment2    VARCHAR2(200),
     inventory_item_segment3    VARCHAR2(200),
     inventory_item_segment4    VARCHAR2(200),
     inventory_item_segment5    VARCHAR2(200),
     inventory_item_segment6    VARCHAR2(200),
     inventory_item_segment7    VARCHAR2(200),
     inventory_item_segment8    VARCHAR2(200),
     inventory_item_segment9    VARCHAR2(200),
     inventory_item_segment10   VARCHAR2(200),
     inventory_item_segment11   VARCHAR2(200),
     inventory_item_segment12   VARCHAR2(200),
     inventory_item_segment13   VARCHAR2(200),
     inventory_item_segment14   VARCHAR2(200),
     inventory_item_segment15   VARCHAR2(200),
     inventory_item_segment16   VARCHAR2(200),
     inventory_item_segment17   VARCHAR2(200),
     inventory_item_segment18   VARCHAR2(200),
     inventory_item_segment19   VARCHAR2(200),
     inventory_item_segment20   VARCHAR2(200),
     inventory_item_vals_or_ids VARCHAR2(1),
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
     contract_service_number    VARCHAR2(150),
     contract_id                NUMBER,
     project_number             VARCHAR2(120),
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
------jngeorge---------------07/12/01
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
     component_version          VARCHAR2(3),
     subcomponent_version       VARCHAR2(3),
     product_revision           VARCHAR2(240),
     comm_pref_code             VARCHAR2(30),
     ---- Added for Post 11.5.6 Enhancement
     cust_pref_lang_code        VARCHAR2(4),
     -- Changed the width from 10 to 30 for last_update_channel for bug 2688856
     -- shijain 3rd dec 2002
     last_update_channel        VARCHAR2(30),
     category_set_id            NUMBER,
     external_reference         VARCHAR2(30),
     system_id                  NUMBER,
------jngeorge---------------07/12/01
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
     bill_to_account_id         NUMBER,         -- ER# 2433831
     ship_to_account_id         NUMBER,         -- ER# 2433831
     customer_phone_id   	NUMBER,         -- ER# 2463321
     customer_email_id   	NUMBER,         -- ER# 2463321
     -- Added for source changes for 1159 by shijain oct 11 2002
     creation_program_code      VARCHAR2(30),
     last_update_program_code   VARCHAR2(30),
     -- Bill_to_party, ship_to_party
     bill_to_party_id           NUMBER,
     ship_to_party_id           NUMBER,
     -- Conc request related fields
     program_id                 NUMBER,
     program_application_id     NUMBER,
     conc_request_id            NUMBER, -- Renamed so that it doesn't clash with SR id
     program_login_id           NUMBER,
     -- Bill_to_site, ship_to_site
     bill_to_site_id           NUMBER,
     ship_to_site_id           NUMBER,
     -- Added address related columns by shijain 4th dec 2002
     incident_point_of_interest        Varchar2(240) ,
     incident_cross_street             Varchar2(240) ,
     incident_direction_qualifier      Varchar2(30),
     incident_distance_qualifier       Varchar2(240) ,
     incident_distance_qual_uom        Varchar2(30),
     incident_address2                 Varchar2(240) ,
     incident_address3                 Varchar2(240),
     incident_address4                 Varchar2(240) ,
     incident_address_style            Varchar2(30),
     incident_addr_lines_phonetic      Varchar2(560) ,
     incident_po_box_number            Varchar2(50) ,
     incident_house_number             Varchar2(50),
     incident_street_suffix            Varchar2(50) ,
     incident_street                   Varchar2(150),
     incident_street_number            Varchar2(50) ,
     incident_floor                    Varchar2(50) ,
     incident_suite                    Varchar2(50) ,
     incident_postal_plus4_code        Varchar2(30) ,
     incident_position                 Varchar2(50) ,
     incident_location_directions      Varchar2(640),
     incident_location_description     Varchar2(2000) ,
     install_site_id                   NUMBER,
     ------anmukher---------------07/31/03
     -- Added for CMRO-EAM project of Release 11.5.10
     item_serial_number			VARCHAR2(30),
     owning_department_id		NUMBER,
     -- Added for Misc ERs project of Release 11.5.10
     -- Changed the default value to 'HZ_LOCATION' --anmukher --09/05/03
     incident_location_type		VARCHAR2(30) Default 'HZ_LOCATION' ,
     coverage_type                     VARCHAR2(30),    -- Addedd on 09/09/03 spusegao
     maint_organization_id             NUMBER,
     creation_date                     DATE,
     created_by                        NUMBER,
	-- Credit Card 9358401
	instrument_payment_use_id         NUMBER
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
  --added by siahmed for 12.1.2 project
  incident_location_id   NUMBER
  );

-- Added new record type for OUT parameters of Update API
-- so that future overloading of the API can be avoided
TYPE sr_update_out_rec_type IS RECORD
( interaction_id        NUMBER
, workflow_process_id   NUMBER
, individual_owner      NUMBER
, group_owner           NUMBER
, individual_type       VARCHAR2(30)
, resolved_on_date      DATE
, responded_on_date     DATE
, status_id             NUMBER
, close_date            DATE
--added by siahmed for 12.1.2 project
, incident_location_id  NUMBER
);

-- Added a new record structure for extensible attributes header information
-- R12 functionality
-----------------------------------------------------------------------
-- Start of comments
--  Record Type     : ext_attr_grp_rec_type
--  Description     : Holds the Attribute Group, Primary Keys and context information for
--                    a business object
--  Fields     :
--
--  Row_identifier       REQUIRED
--  is the unique numeric identifier for this attribute
--  group row within a set of rows to be processed; no two EXT_ATTR_GRP_REC_TYPE
--  elements in any single API call can share the same ROW_IDENTIFIER value.

--  pk_column_1          REQUIRED
--  Primary Key Identifier 1: This column maps to INCIDENT_ID in the CS_INCIDENTS_ALL_B for both
--  Service Request and Party Roles Extensible Attributes implementation

--  pk_column_2          OPTIONAL
--  Primary Key Identifier 2: This column maps to PARTY_ID in the CS_SHZ_SR_CONTACT_POINTS table.
--  This should be null for Service Request Extensible Attributes.
--  This is REQUIRED for Party Roles Extensible Attributes.

--  pk_column_3          OPTIONAL
--  Primary Key Identifier 3: This column maps to CONTACT_TYPE in the CS_SHZ_SR_CONTACT_POINTS table.
--  This should be null for Service Request Extensible Attributes.
--  This is REQUIRED for Party Roles Extensible Attributes.

--  pk_column_4          OPTIONAL
--  Primary Key Identifier 4: This column maps to PARTY_ROLE_CODE in the CS_SHZ_SR_CONTACT_POINTS table.
--  This should be null for Service Request Extensible Attributes.
--  This is REQUIRED for Party Roles Extensible Attributes.

--  pk_column_5          OPTIONAL
--  Primary Key Identifier 5: This column is for future use.  Currently it is not mapped to any Primary Key Identifier.

--  context              REQUIRED
--  This is the classification for the business object:
--  For Service Request Business Object valid values are -1 or a valid SR Type ID
--  For Party Roles Business Object valid value a valid Party Role Code

--  object_name          REQUIRED
--  Object Name for Object from FND_OBJECTS table
--  For Service Request Business Object valid value is 'CS_SR'
--  For Party Roles Business Object valid value is 'CS_PR'

--  attr_group_id        OPTIONAL
--  Numeric Identifier for Attribute Group.  This is required for both the SR and PR Extensible Attributes implementation.
--  This is REQUIRED if the composite key comprising of attr_group_app_id, attr_group_type, attr_group_name IS NULL.

--  attr_group_app_id    OPTIONAL
--  The value for this is 170 for the Service Request Module.  REQUIRED if attribute_group_id is NULL.

--  attr_group_type      OPTIONAL
--  This is the descriptive flex seeded for implementing Extensible Attributes.  REQUIRED if attribute_group_id is NULL.
--  Service Request Extensible Attributes this value equals 'CS_SR_CONTEXT'
--  Party Roles Extensible Attributes this value equals 'CS_PR_CONTEXT'

--  attr_group_name      OPTIONAL
--  This is a unique name for the attribute group.  REQUIRED if attribute_group_id is NULL.

--  attr_group_disp_name            REQUIRED
--  This is the Attrbute Group Display (or user friendly) name.

--  mapping_req          OPTIONAL
--  If the attributes sent through the attributes child table uses database columns instead of attribute_name then
--  this flag should be set to 'Y', else this flag should be 'N'.

--  operation            REQUIRED
--  Valid operations are 'CREATE', 'UPDATE'.  The 'DELETE' operation is only handled through the HTML Service UI

--------------------------------------------------------

TYPE EXT_ATTR_GRP_REC_TYPE IS RECORD
( row_identifier       number
, pk_column_1          varchar2(150)
, pk_column_2          varchar2(150)
, pk_column_3          varchar2(150)
, pk_column_4          varchar2(150)
, pk_column_5          varchar2(150)
, context              varchar2(150)
, object_name          varchar2(30)
, attr_group_id        number
, attr_group_app_id    number
, attr_group_type      varchar2(40)
, attr_group_name      varchar2(30)
, attr_group_disp_name varchar2(150)
, mapping_req          varchar2(1)
, operation            varchar2(30)
   );

TYPE EXT_ATTR_GRP_TBL_TYPE IS TABLE OF EXT_ATTR_GRP_REC_TYPE INDEX BY BINARY_INTEGER;


-- Added a new record structure for extensible attributes child information
-- R12 functionality
-----------------------------------------------------------------------
-- Start of comments
--  Record Type     : EXT_ATTR_REC_TYPE
--  Description     : This record structure holds data for one  attribute in an attribute group row
--  Fields     :
--
--  Row_identifier         REQUIRED
--  This is a foriegn key that associates the Attribute Group in the EXT_ATTR_GRP_REC_TYPE structure to the Attribute in
--  the EXT_ATTR_REC_TYPE structure .

--  Column_name            OPTIONAL
--  This maps top the database column name that is setup for the attribute being passed.  If the user is using
--  this column to pass attribute information to Service then the MAPPING_REQ in the EXT_ATTR_GRP_REC_TYPE structure needs to be set to 'Y'
--  This is REQUIRED if Attr_Name is NULL

--  Attr_name              OPTIONAL
--  This holds the internal name of the attribute. This is REQUIRED if Column_name is NULL.

--  ATTR_DISP_NAME         OPTIONAL
--  This holds the display value or user friendly name of the Attribute

--  ATTR_VALUE_STR         OPTIONAL
--  The value being passed for the attribute is stored in ATTR_VALUE_STR if
--  the attribute is a string.  This attribute is mutually exclusive to ATTR_VALUE_NUM,
--  ATTR_VALUE_DATE, ATTR_VALUE_DISPLAY.  At any time only one of these fields should be populated

--  ATTR_VALUE_NUM         OPTIONAL
--  The value being passed for the attribute is stored in ATTR_VALUE_NUM if
--  the attribute is a Number.  This attribute is mutually exclusive to ATTR_VALUE_STR,
--  ATTR_VALUE_DATE, ATTR_VALUE_DISPLAY.  At any time only one of these fields should be populated

--  ATTR_VALUE_DATE        OPTIONAL
--  The value being passed for the attribute is stored in ATTR_VALUE_DATE if
--  the attribute is a Date.  This attribute is mutually exclusive to ATTR_VALUE_NUM,
--  ATTR_VALUE_STR, ATTR_VALUE_DISPLAY.  At any time only one of these fields should be populated


--  ATTR_VALUE_DISPLAY     OPTIONAL
--  The value being passed for the attribute is stored in ATTR_VALUE_DISPLAY
--  if the attribute has a value set with distinct internal and display values
--  This attribute is mutually exclusive to ATTR_VALUE_NUM, ATTR_VALUE_DATE, ATTR_VALUE_STR.
--  At any time only one of these fields should be populated


--  ATTR_UNIT_OF_MEASURE   OPTIONAL
--  If the attribute is a number that has a Unit of Measure class associated
--  with it, ATTR_UNIT_OF_MEASURE stores the UOM Code for the Unit of Measure
--  in which the attribute's value will be displayed; however, the value
--  itself will always be passed in ATTR_VALUE_NUM in the base units for
--  the Unit of Measure class, not in the display units (unless they happen
--  to be the same).  For example, consider an attribute whose Unit of
--  Measure class is Length (a UOM Class whose base unit we will assume for
--  this example to be Centimeters).  If the caller wants data for this
--  attribute to be displayed in Feet (assuming its UOM_CODE is 'FT'),
--  then ATTR_UNIT_OF_MEASURE should be passed with 'FT'; however, no
--  matter in what unit the caller wants to display this attribute, the
--  value in ATTR_VALUE_NUM will always be the attribute's value as
--  expressed in Centimeters.

--------------------------------------------------------

TYPE EXT_ATTR_REC_TYPE IS RECORD
(row_identifier        number
, column_name          varchar2(30)
, attr_name            varchar2(150)
, attr_disp_name       varchar2(150)
, attr_value_str       varchar2(4000)
, attr_value_num       number
, attr_value_date      date
, attr_value_display   varchar2(4000)
, attr_unit_of_measure varchar2(3)
    );

TYPE EXT_ATTR_TBL_TYPE IS TABLE OF EXT_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;


-- Added new table type for Security project of 11.5.10 --anmukher --08/18/03
-- This table type will be used to pass in and receive a table of resource IDs
-- in the new security procedure Validate_Resource

TYPE Resource_Validate_Tbl_Type IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

PROCEDURE initialize_rec(
  p_sr_record                   IN OUT NOCOPY service_request_rec_type
);

-- Added for Credit Card ER# 2255263 (UI ER#2208078)
-- Added for encoding/decoding in Base64. Used for Credit Card
-- encoding / decoding

   TYPE vc2_table IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
   map  vc2_table;

--------------------------------------------------------------------------
-- Start of comments
--  API name	: Create_ServiceRequest
--  Type	: Public
--  Function	: Creates a service request in the table CS_INCIDENTS_ALL.
--  Pre-reqs	: None.
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--		Application identifier
--	p_resp_id			IN	NUMBER		Optional
--		Responsibility identifier
--	p_user_id			IN	NUMBER	        Optional
--		Application user identifier
--	p_login_id			IN	NUMBER		Optional
--		Login session identifier
--	p_org_id			IN	NUMBER		Optional
--		Operating unit identifier
--		Required if Multi-Org is enabled.
--		Ignored if Multi-Org is disabled.
--      p_request_id                    IN      NUMBER          Optional
--
--      p_request_number                IN      VARCHAR2        Optional
--
--      p_service_request_rec           IN     service_request_rec_type   Required
--
--      p_notes                         IN     notes_table      Optional
--
--
--      p_contacts                      IN     contacts_table   Required if CALLER TYPE IS
--                                                              ORGANIZATION OR PERSON

--
--

--------------------------------------------------------------------------
--  This parameter is no longer present in the PUBLIC API. The workflow
--  is always launched based on the autolaunch flag in the INCIDENT TYPES table

--  Workflow IN parameters:
--	p_launch_workflow		IN	VARCHAR2(1)	Optional
--		If set to TRUE, the API will call the Workflow API to launch
--		a workflow process for this service request.

--------------------------------------------------------------------------
--
--  Service Request OUT parameters:
--	x_request_id			OUT	NUMBER
--		System generated ID of service request.
--	x_request_number		OUT	VARCHAR2(64)
--		User-visible number of service request.
--
--
--  x_interaction_id                    OUT     NUMBER
--
--

--------------------------------------------------------------------------
--

--  Workflow OUT parameters:
--  x_workflow_process_id               OUT      NUMBER
---------------------------------------------------------------------------------------


--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--		Service request comments or log of the conversation.
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--		DEFAULT = FND_API.G_FALSE
--		Indicate whether the service request comment is public (can be
--		viewed by anyone).
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--		System generated ID of service request call.
--
--  Version : Initial version	1.0
-----------------------------------------------------------------------
-- Start of comments
--  Record Type     : Service_Request_Rec_Type
--  Description     : Holds the Service Request attributes for the
--                    Create_ServiceRequest Procedure.
--  Fields     :
--
--  The following fields are defaulted to the profile values if not
--  passed in the record type :
--  request_date, type_id, status_id, severity_id, urgency_id,
--  owner_id, resource_type

--
--	request_date				DATE		Optional
--		Service request date. Must be non-null.

--	type_id				       NUMBER		Optional
--		Service request type identifier. Must be non-null.
--   VAlid incident_type_id from cs_incident_types


--	type_name				VARCHAR2(30)	Optional
--		Service request type name.

--	status_id				NUMBER		Optional
--		Service request status identifier. Must be non-null.
--   Valid incident_status_id  from cs_incident_statuses

--	status_name				VARCHAR2(30)	Optional
--		Service request status name.

--	severity_id				NUMBER		Optional
--		Service request severity identifier. Must be non-null.
--   Valid incident_severity_id from cs_incident_severities

--	severity_name				VARCHAR2(30)	Optional
--		Service request severity name.

--	urgency_id				NUMBER		Optional
--		Service request urgency identifier.
--   Valid incident_urgency_id  from cs_incident_urgencies


--	urgency_name				VARCHAR2(30)	Optional
--		Service request urgency name.

--	closed_date				DATE		Optional
--		Service request closed date.
--		Ignored if the status is not a "closed" status.

--	owner_id				NUMBER		Optional
--		Service request owner identifier. Must be non-null.
--   Valid resource_id from cs_sr_owners_v
--
--
--      owner_group_id                       NUMBER             Optional

--      resource_type                 VARCHAR2(30)         Optional
--    VAlid resource_type from  cs_sr_owners_v

--      resource_subtype_id           NUMBER               Optional

--	publish_flag				VARCHAR2	Optional
--		Indicate whether the service request is published (entered
--		into knowledge base if ConText Server Option is enabled).

--	summary				VARCHAR2(240)	        Required
--		Service request summary. Must be non-null.
--
--
-----------------------------------------------------------------------
--      These fields are no longer present in the record type
--	verify_request_flag			VARCHAR2(1)	Required
--
--		DEFAULT = FND_API.G_TRUE
--		Indicate whether the service request is entered in verified
--		mode. Must be non-null. If set to TRUE, the API will perform
--		validation on the attributes customer_id, employee_id,
--		contact_id, bill_to_site_use_id, bill_to_contact_id,
--		ship_to_site_use_id, and ship_to_contact_id.
--	filed_by_emp_flag			VARCHAR2(1)	Required
--		DEFAULT = FND_API.G_FALSE
--		Indicate that the service request is filed by an employee.
--		Must be non-null. It can only be set when the
--		verify_request_flag parameter is set.
-------------------------------------------------------------------------------------
--
--      caller_type                             VARCHAR2(30)    Required
--      VAlid values are : ORGANIZATION, PERSON and CALLER_EMP

--
--	customer_id				NUMBER		Optional
--		Service request customer identifier.
--
--	customer_number			       VARCHAR2(30)	Optional
--		Service request customer number.
--

-----------------------------------------------------------------------
--      These fields are no longer present in the record type
--
--      customer_prefix                        VARCHAR2(50)     Optional
--		Service request customer name.

--
--      customer_firstname                     VARCHAR2(150)     Optional
--              Service request customer first name

--      customer_lastname                     VARCHAR2(150)     Optional
--              Service request customer last name

--      customer_company_name                   VARCHAR2(255)  Optional
--              Service request customer company name
-----------------------------------------------------------------------------------
--	employee_id				NUMBER		Optional
--		Service request employee identifier.
-------------------------------------------------------------------
--   This field is no longer present in the record type
--	employee_name				VARCHAR2(240)	Optional
------------------------------------------------------------------------
--	employee_number			      VARCHAR2(30)	Optional
------------------------------------------------------------------
-- These fiels are no longer there in rec type
--
--	contact01_id				NUMBER		Optional
--		Service request customer contact identifier.
--
--      contact01_prefix                       VARCHAR2(50)   Optional
--		Service request customer contact name.
--
--      contact01_firstname                   VARCHAR2(150)  Optional
--
--
--   contact01_lastname            VARCHAR2(150)  Optional
--
--   contact01_area_code           VARCHAR2(10)   Optional

--   contact01_telephone           VARCHAR2(40)   Optional

--   contact01_extension           VARCHAR2(20)   Optional

--   contact01_fax_area_code       VARCHAR2(10)   Optional

--   contact01_fax_number          VARCHAR2(40)   Optional

--   contact01_email_address       VARCHAR2(2000) Optional
--
--
--   contact02_id                  NUMBER         Optional
--        Service request customer represented by identifier

--   contact02_prefix              VARCHAR2(50)   Optional
--        Service request customer represented by prefix

--   contact02_firstname           VARCHAR2(150)  Optional
--        Service request customer represented by firstname

--   contact02_lastname            VARCHAR2(150)  Optional
--        Service request customer represented by lastname
--
--   contact02_area_code           VARCHAR2(10)   Optional

--   contact02_telephone           VARCHAR2(40)   Optional

--   contact02_extension           VARCHAR2(20)   Optional

--   contact02_fax_area_code       VARCHAR2(10)   Optional

--   contact02_fax_number          VARCHAR2(40)   Optional

--   contact02_email_address       VARCHAR2(2000) Optional
-------------------------------------------------------------------

--
--
--   verify_cp_flag		   VARCHAR2(1)	  Required
--		Indicate whether to use the Installed Base. Must be non-null.
--		If set to TRUE, the API will perform validation on the
--		customer product ID.

--   customer_product_id	  NUMBER	   Optional
--		Unique identifier for a customer product in the Installed Base.
--
---------------------------------------------------------
-----no longer used
--     lot_num                    VARCHAR2(30)   Optional
-------------------------------------------------------
-- Supporting platform_id again because of enh 1711552
--     platform_id                NUMBER         Optional
--- ********THE functionality for the below 2 fileds is no longer supported.
--     platform_version_id        NUMBER         Optional

--     language_id                NUMBER         Optional
--          This is the Product's language id


--     cp_component_id               NUMBER         Optional

--     cp_component_version_id       NUMBER         Optional

--     cp_subcomponent_id            NUMBER         Optional

--     cp_subcomponent_version_id    NUMBER         Optional


--     language                   VARCHAR2(4)    Optional
--          This is used for TL tables

--
--	cp_ref_number				Number	Optional -- 3840658
--		Reference number for a customer product in the Installed Base.

--	inventory_item_id			NUMBER		Optional
--		Corresponds to the column INVENTORY_ITEM_ID in the table
--		MTL_SYSTEM_ITEMS, and identifies the service request product.
--		Ignored if the verify_cp_flag parameter is set.
--
--
--	inventory_item_conc_segs		VARCHAR2	Optional
--		String that contains a concatenation of the key flexfield
--		segments.

--	inventory_item_segment1		VARCHAR2(40)	Optional
--		System Items key flexfield individual segments (1..20).
--	inventory_item_segment2		VARCHAR2(40)	Optional
--	inventory_item_segment3		VARCHAR2(40)	Optional
--	inventory_item_segment4		VARCHAR2(40)	Optional
--	inventory_item_segment5		VARCHAR2(40)	Optional
--	inventory_item_segment6		VARCHAR2(40)	Optional
--	inventory_item_segment7		VARCHAR2(40)	Optional
--	inventory_item_segment8		VARCHAR2(40)	Optional
--	inventory_item_segment9		VARCHAR2(40)	Optional
--	inventory_item_segment10		VARCHAR2(40)	Optional
--	inventory_item_segment11		VARCHAR2(40)	Optional
--	inventory_item_segment12		VARCHAR2(40)	Optional
--	inventory_item_segment13		VARCHAR2(40)	Optional
--	inventory_item_segment14		VARCHAR2(40)	Optional
--	inventory_item_segment15		VARCHAR2(40)	Optional
--	inventory_item_segment16		VARCHAR2(40)	Optional
--	inventory_item_segment17		VARCHAR2(40)	Optional
--	inventory_item_segment18		VARCHAR2(40)	Optional
--	inventory_item_segment19		VARCHAR2(40)	Optional
--	inventory_item_segment20		VARCHAR2(40)	Optional

--	inventory_item_vals_or_ids		VARCHAR2(1)	Optional
--		DEFAULT = 'V'
--		Indicate whether input segments are values ('V') or hidden
--		IDs ('I'). If values are input the API expects one value for
--		every displayed segment, whereas if IDs are input the API
--		expects one ID for each enabled segment whether or not the
--		segment is displayed.
--
--
--	inventory_org_id			NUMBER		Optional
--		Item organization ID. Part of the unique key that uniquely
--		identifies an inventory item. Corresponds to the column
--		ORGANIZATION_ID in the table MTL_SYSTEM_ITEMS.
--		Required if inventory_item_id is used.
--
--	current_serial_number			VARCHAR2(30)	Optional
--		Serial number for serialized items.
--		Ignored if the verify_cp_flag parameter is set.

--	original_order_number				NUMBER		Optional
--		Sales Order information.
--		Ignored if the verify_cp_flag parameter is set.

--	purchase_order_number			VARCHAR2(50)	Optional
--		Sales Order information.
--		Ignored if the verify_cp_flag parameter is set.

------------------------------------------------------------------
--   This field is no longer present in the record type
--	problem_description			VARCHAR2(2000)	Optional
--		Service request problem description.
-----------------------------------------------------------------------
--
--	problem_code				VARCHAR2(30)	Optional
--		Service request problem code.

--	exp_resolution_date			DATE		Optional
--		Service request expected resolution date.
--
------------------------------------------------------------------
--   This field is no longer present in the record type
--	make_public_problem			VARCHAR2(1)	Optional
--		Indicate whether the problem description is public.
------------------------------------------------------------------------

--      install_site_use_id             NUMBER          Optional


-----------------------------------------------------------------------
--      These fields are no longer present in the record type

--	install_location		VARCHAR2(40)	Optional
--	install_customer		VARCHAR2(50)	Optional
--      install_country                 VARCHAR2(60)    Optional
--	install_address_1		VARCHAR2(240)	Optional
--	install_address_2		VARCHAR2(240)	Optional
--	install_address_3		VARCHAR2(240)	Optional

------------------------------------------------------------------

--   These fields are no longer present in the record type
--	rma_flag				VARCHAR2(1)	Required
--		Indicate whether an RMA is assigned. Must be non-null. If set
--		to TRUE, the API will perform validation on the RMA header ID.
--		It can only be set when the verify_request_flag parameter is
--		set.
--	rma_header_id				NUMBER		Optional
--		Sales order header identifier of the RMA.
--		Ignored if the rma_flag parameter is not set.
--	rma_number				NUMBER		Optional
--		User-visible sales order number of the RMA.
--	order_type_id				NUMBER		Optional
--		Sales order type of the RMA.
--	web_entry_flag			VARCHAR2(1)	Required
--		DEFAULT = FND_API.G_FALSE
--		Indicate whether the service request is entered from
--		Self-Service Web Applications. Must be non-null.
--------------------------------------------------------------------------------------
--	request_segment1			VARCHAR2(150)	Optional
--		Service request descriptive flexfield individual segments
--		(1..15).
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
--	request_context			VARCHAR2(30)	Optional
--		Descriptive flexfield structure defining column.
--



--	bill_to_site_use_id			NUMBER		Optional
--		Bill To site use identifier.

--	bill_to_contact_id			NUMBER		Optional
--		Bill To contact identifier.
--

-----------------------------------------------------------------------
--      These fields are no longer present in the record type

--	bill_to_location			VARCHAR2(40)	Optional
--

--	bill_to_customer			VARCHAR2(50)	Optional
--

--      bill_country                            VARCHAR2(60)    Optional

--	bill_to_address_1		        VARCHAR2(240)	Optional

--	bill_to_address_2		        VARCHAR2(240)	Optional

--	bill_to_address_3		        VARCHAR2(240)	Optional

--	bill_to_contact 			VARCHAR2(100)	Optional
--------------------------------------------------------------------------------

--	ship_to_site_use_id			NUMBER		Optional
--		Ship To site use identifier.
--

--	ship_to_contact_id			NUMBER		Optional
--		Ship To contact identifier.
--

-----------------------------------------------------------------------
--      These fields are no longer present in the record type

--	ship_to_location			VARCHAR2(40)	Optional
--

--	ship_to_customer			VARCHAR2(50)	Optional
--
--
--      ship_country                            VARCHAR2(60)    Optional

--	ship_to_address_1		        VARCHAR2(240)	Optional

--	ship_to_address_2		        VARCHAR2(240)	Optional
--

--	ship_to_address_3		        VARCHAR2(240)	Optional
--
--	ship_to_contact 			VARCHAR2(100)	Optional
----------------------------------------------------------------------



------------------------------------------------------------------
--   This field is no longer present in the record type
--	problem_resolution			VARCHAR2(2000)	Optional
--		Service request problem resolution.
---------------------------------------------------------------------
--
--	resolution_code			VARCHAR2(30)	Optional
--		Service request resolution code.

--	act_resolution_date		DATE		Optional
--		Service request actual resolution date.
--
------------------------------------------------------------------
--   This field is no longer present in the record type
--	make_public_resolution		VARCHAR2(1)	Optional
--		Indicate whether the problem resolution is public.
-------------------------------------------------------------------------

--      public_comment_flag           VARCHAR2(1)          Optional
--      parent_interaction_id         NUMBER               Optional
--      contract_service_id           NUMBER               Optional
--      contract_service_number       VARCHAR2(150)        Optional
--      qa_collection_plan_id         NUMBER               Optional
--      account_id                    NUMBER               Optional
--      cust_po_number                VARCHAR2(50)         Optional
--      cust_ticket_number            VARCHAR2(50)         Optional
--      sr_creation_channel           VARCHAR2(50)         Optional
--      obligation_date               DATE                 Optional
--      time_zone_id                  NUMBER               Optional
--      time_difference               NUMBER               Optional
--      site_id                       NUMBER               Optional
--      customer_site_id              NUMBER               Optional
--      territory_id                  NUMBER               Optional
--      initialize_flag               VARCHAR2(1)          Optional

--      cp_revision_id                NUMBER          OPTIONAL
--      inv_item_revision             VARCHAR2(3)     OPTIONAL
--      inv_component_id              NUMBER          OPTIONAL
--      inv_component_version         VARCHAR2(3)     OPTIONAL
--      inv_subcomponent_id           NUMBER          OPTIONAL
--      inv_subcomponent_version      VARCHAR2(3)     OPTIONAL





-- End of service_request_rec_type comments
--
--  Notes:	If request_date is not passed, the default value will be
--		SYSDATE.
--
--		If both type_id and type_name are passed, type_name will
--		be ignored. If neither is passed, the default value will be
--		retrieved from the 'Service: Default Service Request Type'
--		profile.
--
--		If both status_id and status_name are passed,
--		status_name will be ignored. If neither is passed, the
--		default value will be the seeded value 1 ('Open').
--
--		If both severity_id and severity_name are passed,
--		severity_name will be ignored. If neither is passed, the
--		default value will be retrieved from the 'Service: Default
--		Service Request Severity' profile.
--
--		If both urgency_id and urgency_name are passed,
--		urgency_name will be ignored. If neither is passed, the
--		default value will be retrieved from the 'Service: Default
--		Service Request Urgency' profile.
--
--		If owner_id is not passed, the default value will be
--		retrieved from the 'Service: Default Service Request Owner'
--		profile.
--
--		If resource_type is not passed, the default value will be
--		retrieved based on 'Service: Default Service Request Owner'
--		profile.



--		Insertion of the publish flag is controlled by the profile
--		'Service: Publish Flag Update Allowed'. If the profile is not
--		set and the caller passes in a non-null value, the API will
--		return an error.
--
--		Either customer_id, customer_name, or customer_number
--		must be passed if the filed_by_emp_flag is not set. If more
--		than one parameter are passed, the customer ID has precedence
--		over the customer number, and the customer number has
--		precedence over the customer name.
--
--		Either employee_id, employee_name, or employee_number
--		must be passed if the filed_by_emp_flag is set. If more than
--		one parameter are passed, the employee ID has precedence over
--		the employee number, and the employee number has precedence
--		over the employee name.
--
--		Either customer_product_id or cp_ref_number must be passed
--		if the verify_cp_flag is set. If both are passed,
--		cp_ref_number will be ignored.
--
--		If inventory_org_id is not passed, the default value will be
--		retrieved from the 'OE: Item Validation Organization' profile.
--
--		If make_public_problem or make_public_resolution is not
--		passed, the default value will be retrieved from the 'Service:
--		Default Make Public Flag' profile.
--
--		If both rma_header_id and rma_number are passed,
--		rma_number will be ignored.
--
--		For value-ID conversion, when the ID of an attribute is not
--		passed, and the value of the attribute is passed and the value
--		is NULL, the ID is converted into NULL. For example, if
--		urgency_id = FND_API.G_MISS_NUM and urgency_name = NULL,
--		NULL is inserted into the incident_urgency_id column. This has
--		the effect that urgency ID will not be defaulted from the
--		profile option (since the caller explicitly passed in NULL).
--
--		For the key and descriptive flexfield segments, segment	values
--		must be input in attribute_segment1..attribute_segmentN in
--		the order displayed. The caller must explicitly set
--		attribute_segmentM to NULL if the Mth segment is NULL, or
--		this will generate a 'NO DATA FOUND' error. Alternatively, the
--		caller may pass in the segment values in a string concatenated
--		by the segment delimiter for the flexfield.
--
--		For the descriptive flexfield segments, the caller must pass
--		the IDs for all columns that might be used in the descriptive
--		flexfield. Values input is currently not supported.
--
--
--		The service request record must be committed before launching
--		the workflow process. This is necessary because Workflow needs
--		to obtain a lock on the record. If the caller passes in FALSE
--		for p_commit and (the autolaunch workflow flag is set ),
--              the API will return an error.

----------------------------------------------------
--              Old logic
--              (TRUE for p_launch_workflow)
--		A workflow is automatically launched only if the caller passes
--		in TRUE for the p_launch_workflow parameter and the profile
--		option 'Service: Auto Launch Workflow' is set to 'Y'.
--------------------------------------------------------------------------

--		A workflow is automatically launched only if the autolaunch
--              workflow falg is set to Y in the incident types table.

-------------------------------------------------------------------------
--              Old Logic
--		If p_launch_workflow is set, the Workflow API will try to lock
--		the service request record because it needs to update the
--		workflow_process_id column. The NOWAIT option can be specified
--		by setting the p_nowait parameter. If p_nowait is set and the
--		service request record is locked by another user, an error
--		status is returned via the p_return_status_wkflw parameter
--		indicating the workflow process is not launched.
--
--		If p_launch_workflow is set and the service request record is
--		created successfully, a success code will be returned via the
--		p_return_status parameter regardless of the result of the
--		workflow launch. The status code from the Workflow launch is
--		returned via the p_return_status_wkflw parameter instead.

-----------------

--		If the autolaunch workflow flag is set, the Workflow API will try to lock
--		the service request record because it needs to update the
--		workflow_process_id column. The NOWAIT option can be specified
--		by setting the p_nowait parameter. If p_nowait is set and the
--		service request record is locked by another user, an error
--		status is returned via the p_return_status_wkflw parameter
--		indicating the workflow process is not launched.
--
--		If autolaunch workflow flag is set and the service request record is
--		created successfully, a success code will be returned via the
--		p_return_status parameter regardless of the result of the
--		workflow launch. The status code from the Workflow launch is
--		returned via the p_return_status_wkflw parameter instead.





--
-- End of comments
--------------------------------------------------------------
/*#
 * Creates a new service request and related information such as service request contacts, notes, and tasks.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Create Service Request
 * @rep:primaryinstance
 * @rep:businessevent oracle.apps.cs.sr.ServiceRequest.created
 * @rep:metalink 390479.1 Oracle White Paper : Service Request Public Application Programming Interfaces (APIs)
 */

/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that
      Create_ServiceRequest API appears in the integration repository.
****/

PROCEDURE Create_ServiceRequest
( p_api_version		  	  IN         NUMBER,
  p_init_msg_list	  	  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit		  	  IN         VARCHAR2 	:= FND_API.G_FALSE,
  x_return_status	  	  OUT NOCOPY VARCHAR2,
  x_msg_count		  	  OUT NOCOPY NUMBER,
  x_msg_data		  	  OUT NOCOPY VARCHAR2,
  p_resp_appl_id	  	  IN         NUMBER	:= NULL,
  p_resp_id		  	  IN         NUMBER	:= NULL,
  p_user_id		  	  IN         NUMBER	:= NULL,
  p_login_id		  	  IN         NUMBER	:= NULL,
  p_org_id		  	  IN         NUMBER	:= NULL,
  p_request_id            	  IN         NUMBER     := NULL,
  p_request_number	  	  IN         VARCHAR2	:= NULL,
  p_service_request_rec   	  IN         service_request_rec_type,
  p_notes                 	  IN         notes_table,
  p_contacts              	  IN         contacts_table,
   -- Added for Assignment Manager 11.5.9 change
  p_auto_assign           	  IN         VARCHAR2  Default 'N',
  --------------anmukher----------------------07/31/03
  -- Added for 11.5.10 projects (AutoTask, Miscellaneous ERs)
  p_auto_generate_tasks		  IN		VARCHAR2 Default 'N',
  x_sr_create_out_rec		  OUT NOCOPY	sr_create_out_rec_type,
  p_default_contract_sla_ind	  IN		VARCHAR2 Default 'N',
  p_default_coverage_template_id  IN		NUMBER Default NULL
  ---------------anmukher----------------------07/31/03
  -- The following OUT parameters have been added to the record type sr_create_out_rec_type
  -- and have therefore been commented out. This will allow avoidance of future overloading
  -- if a new OUT parameter were to be needed, since it can be added to the same record type.
  -- x_request_id		  OUT NOCOPY NUMBER,
  -- x_request_number		  OUT NOCOPY VARCHAR2,
  -- x_interaction_id        	  OUT NOCOPY NUMBER,
  -- x_workflow_process_id   	  OUT NOCOPY NUMBER,
  -- Added for assignment manager changes for 11.5.9
  -- x_individual_owner      	  OUT NOCOPY NUMBER,
  -- x_group_owner           	  OUT NOCOPY NUMBER,
  -- x_individual_type       	  OUT NOCOPY VARCHAR2
);

----------------anmukher--------------07/31/03
-- Overloaded procedure added for backward compatibility in 11.5.10
-- since several new OUT parameters have been added to the 11.5.9 signature
-- in the form of a new record type, sr_create_out_rec_type
PROCEDURE Create_ServiceRequest
( p_api_version		  IN         NUMBER,
  p_init_msg_list	  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  x_return_status	  OUT NOCOPY VARCHAR2,
  x_msg_count		  OUT NOCOPY NUMBER,
  x_msg_data		  OUT NOCOPY VARCHAR2,
  p_resp_appl_id	  IN         NUMBER	:= NULL,
  p_resp_id		  IN         NUMBER	:= NULL,
  p_user_id		  IN         NUMBER	:= NULL,
  p_login_id		  IN         NUMBER	:= NULL,
  p_org_id		  IN         NUMBER	:= NULL,
  p_request_id            IN         NUMBER     := NULL,
  p_request_number	  IN         VARCHAR2	:= NULL,
  p_service_request_rec   IN         service_request_rec_type,
  p_notes                 IN         notes_table,
  p_contacts              IN         contacts_table,
  -- Added for Assignment Manager 11.5.9 change
  p_auto_assign           IN         VARCHAR2  Default 'N',
  p_default_contract_sla_ind	  IN		VARCHAR2 Default 'N',
  x_request_id		  OUT NOCOPY NUMBER,
  x_request_number	  OUT NOCOPY VARCHAR2,
  x_interaction_id        OUT NOCOPY NUMBER,
  x_workflow_process_id   OUT NOCOPY NUMBER,
  -- Added for assignment manager changes for 11.5.9
  x_individual_owner      OUT NOCOPY NUMBER,
  x_group_owner           OUT NOCOPY NUMBER,
  x_individual_type       OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------------
-- Start of comments
--  API name	: Update_ServiceRequest
--  Type	: Public
--  Function	: Updates a service request in the table CS_INCIDENTS_ALL.
--  Pre-reqs	: None.
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list		  	IN	VARCHAR2 	Optional
--	p_commit			IN	VARCHAR2 	Optional
--
--  Standard OUT Parameters:
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--
---------------------------------------------------------------------
--      These are required only for create_servicerequest procedure
--  	p_user_id			IN	NUMBER		Optional
--  	p_login_id			IN	NUMBER		Optional
------------------------------------------------------------------
--
--  Service Request IN Parameters:
--	p_resp_appl_id		  	IN	NUMBER		Optional
--	p_resp_id			IN	NUMBER		Optional



----------------------------------------------------------------------
--     No longer there in the Update_ServiceRequest
--  	p_org_id			IN	NUMBER		Optional
----------------------------------------------------------------------------


--	p_request_id		 	IN    	NUMBER		Optional
--	p_request_number		IN	VARCHAR2	Optional
--      p_object_version_number         IN      NUMBER          Required by web-apps
--
--
--	p_audit_comments		IN	VARCHAR2 	Optional
--		Maximum string length of 2000 bytes


--   p_last_updated_by                 IN   NUMBER         Required
--   valid user from fnd_user

--   p_last_update_login               IN   NUMBER         Optional
--        Default = NULL
--   p_last_update_date                IN   DATE           Required
--
--   p_service_request_rec             IN   service_request_rec_type  Required
--   p_notes                           IN   notes_table               Optional

--   p_contacts                        IN   contacts_table            Optional
--
--   p_called_by_workflow		IN	VARCHAR2	Optional
--	        Whether or not the API is being called by a workflow process

--   p_workflow_process_id		IN	NUMBER		Optional
--	        Workflow process ID of the active workflow process
--
--   p_default_contract_sla_ind      IN      VARCHAR2        Optional
--              DEFAULT 'N'
--              Indicates whether the API needs to determine the contract, respond by date
--              and resolve by date for a service request and stamp it on the service request.
--
--   Service Request OUT Parameters:
--   x_workflow_process_id          OUT   NUMBER
--           This will have a value if a new workflow got launched during the update
--   x_intercation_id               OUT   NUMBER

-------------------------------------------------------------------
--      Not present in the Procedure declaration
--	p_web_entry_flag
--		Whether the update was entered through the Web
-----------------------------------------------------------------
--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--		Service request comments or log of the conversation.
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--		Indicate whether the service request comment is public (can be
--		viewed by anyone).
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--		System generated ID of service request call
--
--  Version : Initial version	1.0
------------------------------------------------------------------------------

-- Start of comments
--  Record Type     : Service_Request_Rec_Type
--  Description     : Holds the Service Request attributes
--                    for the Update_ServiceRequest Procedure.
--  Fields     :
--
--
--  	type_id				NUMBER		Optional
--		Must be non-null

--	type_name			VARCHAR2	Optional
--		Must be non-null

--	status_id			NUMBER		Optional
--		Must be non-null

--	status_name			VARCHAR2 	Optional
--		Must be non-null

--	severity_id			NUMBER		Optional
--		Must be non-null

--	severity_name		  	VARCHAR2 	Optional
--		Must be non-null

--	urgency_id			NUMBER		Optional

--  	urgency_name			VARCHAR2 	Optional

--	closed_date			DATE		Optional

--	owner_id			NUMBER		Optional
--		Must be non-null

--      owner_group_id                  NUMBER          Optional
--
--	publish_flag			VARCHAR2	Optional
--		Indicate whether the service request is published (entered
--		  into knowledge base if ConText Server Option is enabled).

-- 	summary				VARCHAR2	Optional
--		Must be non-null
-----------------------------------------------------------------------
--      These fields are no longer present in the record type
--	verify_request_flag			VARCHAR2	Optional
--		Must be either FND_API.G_TRUE or FND_API.G_FALSE.  Used
-- 		to indicate if this is a verified or non-verified request
-----------------------------------------------------------------------------
--	customer_id			 NUMBER		 Optional


--	customer_number		         VARCHAR2	 Optional


-----------------------------------------------------------------------
--      These fields are no longer present in the record type

--   customer_prefix                     VARCHAR2(50)    Optional
--		Service request customer name.
--
--   customer_firstname                  VARCHAR2(150)   Optional
--              Service request customer first name

--   customer_lastname                   VARCHAR2(150)  Optional
--              Service request customer last name


--   customer_company_name               VARCHAR2(255)  Optional
--              Service request customer company name

----------------------------------------------------------------

--	employee_id			 NUMBER		Optional

--	employee_number			 VARCHAR2(30)	Optional
--

------------------------------------------------------------------
-- These fiels are no longer there in rec type

--
--	contact01_id			 NUMBER		Optional

--       contact01_prefix                VARCHAR2(50)   Optional
--		Service request customer contact name.

--
--   contact01_firstname           VARCHAR2(150)  Optional
--
--
--   contact01_lastname            VARCHAR2(150)  Optional
--
--   contact01_area_code           VARCHAR2(10)   Optional
--   contact01_telephone           VARCHAR2(40)   Optional
--   contact01_extension           VARCHAR2(20)   Optional
--   contact01_fax_area_code       VARCHAR2(10)   Optional
--   contact01_fax_number          VARCHAR2(40)   Optional
--   contact01_email_address       VARCHAR2(2000) Optional
--
--
--   contact02_id                  NUMBER         Optional
--        Service request customer represented by identifier

--   contact02_prefix              VARCHAR2(50)   Optional
--        Service request customer represented by prefix

--   contact02_firstname           VARCHAR2(150)  Optional
--        Service request customer represented by firstname

--   contact02_lastname            VARCHAR2(150)  Optional
--        Service request customer represented by lastname
--
--   contact02_area_code           VARCHAR2(10)   Optional

--   contact02_telephone           VARCHAR2(40)   Optional

--   contact02_extension           VARCHAR2(20)   Optional

--   contact02_fax_area_code       VARCHAR2(10)   Optional

--   contact02_fax_number          VARCHAR2(40)   Optional

--   contact02_email_address       VARCHAR2(2000) Optional
-------------------------------------------------------------------

--
--    verify_cp_flag		   VARCHAR2	  Optional

--    customer_product_id	   NUMBER	  Optional
--
---------------------------------------------------
--no longer used
--     lot_num                    VARCHAR2(30)   Optional
--------------------------------------------------------

-- Supporting platform_id again because of enh 1711552
--     platform_id                NUMBER         Optional
--    *********THE functionality for the below 2 fileds is no longer supported.
--     platform_version_id        NUMBER         Optional

--     language_id                NUMBER         Optional
--          This is the Product's language id

--     cp_component_id               NUMBER         Optional
--     cp_component_version_id       NUMBER         Optional
--     cp_subcomponent_id            NUMBER         Optional
--     cp_subcomponent_version_id    NUMBER         Optional


--     language                   VARCHAR2(4)    Optional
--          This is used for TL tables
--          IF not passed to the api, the userenv('LANG') is used.
--

--
--	cp_ref_number		  Number  	 Optional -- 3840658
--
--	inventory_item_id         NUMBER	 Optional

--	inventory_item_conc_segs	VARCHAR2	Optional
--	inventory_item_segment1		VARCHAR2	Optional
--	inventory_item_segment2		VARCHAR2	Optional
--	inventory_item_segment3		VARCHAR2	Optional
--	inventory_item_segment4		VARCHAR2	Optional
--	inventory_item_segment5		VARCHAR2	Optional
--	inventory_item_segment6		VARCHAR2	Optional
--	inventory_item_segment7		VARCHAR2	Optional
--	inventory_item_segment8	        VARCHAR2	Optional
--	inventory_item_segment9		VARCHAR2	Optional
--	inventory_item_segment10	VARCHAR2	Optional
--	inventory_item_segment11	VARCHAR2	Optional
--	inventory_item_segment12	VARCHAR2	Optional
--	inventory_item_segment13	VARCHAR2	Optional
--	inventory_item_segment14	VARCHAR2	Optional
--	inventory_item_segment15	VARCHAR2	Optional
--	inventory_item_segment16	VARCHAR2	Optional
--	inventory_item_segment17	VARCHAR2	Optional
--	inventory_item_segment18	VARCHAR2	Optional
--	inventory_item_segment19	VARCHAR2	Optional
--	inventory_item_segment20	VARCHAR2	Optional

--	inventory_item_vals_or_ids	VARCHAR2	Optional
--		Must be 'I' for IDs and 'V' for values.  This parameter
--		indicate whether the item key flex segments are passed
--		in by ID or value
--
--	inventory_org_id			NUMBER		Optional

--	current_serial_number	  		VARCHAR2	Optional
--

--	original_order_number	  		NUMBER		Optional

--	purchase_order_num  	  		VARCHAR2	Optional
--

------------------------------------------------------------------
--   This field is no longer present in the record type
--	problem_description			VARCHAR2	Optional
--		Maximum string length of 2000 bytes
-----------------------------------------------------------------------
--
--	problem_code		  		VARCHAR2	Optional

--	exp_resolution_date			DATE		Optional

------------------------------------------------------------------
--   This field is no longer present in the record type
--	make_public_problem			VARCHAR2	Optional
--		Indicate whether the problem description is public.
----------------------------------------------------------------------

--      install_site_use_id                     NUMBER          Optional


-----------------------------------------------------------------------
--      These fields are no longer present in the record type
--	install_location			VARCHAR2	Optional
--
--	install_customer			VARCHAR2	Optional
--
--      install_country                         VARCHAR2(60)    Optional

--	install_address_1		        VARCHAR2	Optional
--
--  	install_address_2		        VARCHAR2	Optional
--
--	install_address_3		        VARCHAR2	Optional
--
------------------------------------------------------------------
--   These fields are no longer present in the record type
--	rma_flag				VARCHAR2	Optional
--	rma_header_id		  		NUMBER		Optional
--	rma_number				NUMBER		Optional
--	order_type_id		  		NUMBER		Optional
-------------------------------------------------------------------------
--
--	request_segment1			VARCHAR2	Optional
--	request_segment2			VARCHAR2	Optional
--	request_segment3		        VARCHAR2	Optional
--	request_segment4			VARCHAR2	Optional
--	request_segment5			VARCHAR2	Optional
--	request_segment6			VARCHAR2	Optional
--	request_segment7			VARCHAR2	Optional
--	request_segment8			VARCHAR2	Optional
--	request_segment9			VARCHAR2	Optional
--	request_segment10			VARCHAR2	Optional
--	request_segment11			VARCHAR2	Optional
--	request_segment12			VARCHAR2	Optional
--	request_segment13			VARCHAR2	Optional
--	request_segment14		        VARCHAR2	Optional
--	request_segment15			VARCHAR2	Optional
--	request_context			        VARCHAR2	Optional
--
--	bill_to_site_use_id			NUMBER		Optional

--	bill_to_contact_id			NUMBER		Optional



-----------------------------------------------------------------------
--      These fields are no longer present in the record type

--	bill_to_location			VARCHAR2	Optional

--	bill_to_customer			VARCHAR2	Optional

--      bill_country                            VARCHAR2(60)    Optional
--
--	bill_to_address_1		        VARCHAR2	Optional

--	bill_to_address_2		        VARCHAR2	Optional

--	bill_to_address_3		        VARCHAR2	Optional

--	bill_to_contact			        VARCHAR2	Optional
---------------------------------------------------------------------------
--
--	ship_to_site_use_id			NUMBER		Optional

--	ship_to_contact_id			NUMBER		Optional


-----------------------------------------------------------------------
--      These fields are no longer present in the record type

--	ship_to_location			VARCHAR2	Optional

--	ship_to_customer			VARCHAR2	Optional

--      ship_country                            VARCHAR2(60)    Optional

--	ship_to_address_1		        VARCHAR2	Optional

--	ship_to_address_2		        VARCHAR2	Optional

--	ship_to_address_3		        VARCHAR2	Optional

--	ship_to_contact			        VARCHAR2	Optional


------------------------------------------------------------------
--   This field is no longer present in the record type
--	problem_resolution			VARCHAR2	Optional
--		Maximum string length of 2000 bytes
--------------------------------------------------------------------

--	resolution_code		      VARCHAR2	        Optional
--	act_resolution_date	      DATE		Optional
--      public_comment_flag           VARCHAR2(1)       Optional
--      parent_interaction_id         NUMBER            Optional
--      contract_service_id           NUMBER            Optional
--      contract_service_number       VARCHAR2(150)     Optional
--      qa_collection_plan_id         NUMBER            Optional
--      account_id                    NUMBER            Optional
--      resource_type                 VARCHAR2(30)      Optional
--      resource_subtype_id           NUMBER            Optional
--      cust_po_number                VARCHAR2(50)      Optional
--      cust_ticket_number            VARCHAR2(50)      Optional
---------------------------------------------------------------
--   This is a non updatable field
--      sr_creation_channel           VARCHAR2(50)      Optional
------------------------------------------------------------------
--      obligation_date               DATE              Optional
--      time_zone_id                  NUMBER            Optional
--      time_difference               NUMBER            Optional
--      site_id                       NUMBER            Optional
--      customer_site_id              NUMBER            Optional
--      territory_id                  NUMBER            Optional
--      initialize_flag               VARCHAR2(1)       Optional

--      cp_revision_id                NUMBER          OPTIONAL
--      inv_item_revision             VARCHAR2(3)     OPTIONAL
--      inv_component_id              NUMBER          OPTIONAL
--      inv_component_version         VARCHAR2(3)     OPTIONAL
--      inv_subcomponent_id           NUMBER          OPTIONAL
--      inv_subcomponent_version      VARCHAR2(3)     OPTIONAL
--
--
--  Notes:	: Either request_id or request_number must be non-null.
--		  If both are passed in, request_number will be ignored
--
--      	  If a field is not to be updated, do not pass in NULL.  Either
--                don't pass in the parameter at all, or pass in one of the
--		  missing parameter constants defined in the FND_API
--		  package(G_MISS_...).
--
--      	  For all the "flag" parameters, and p_called_by_workflow
--		  parameter, pass in the boolean constants defined in the
--		  FND_API package (G_TRUE and G_FALSE).
--
--		  Varchar parameters with the maximum length noted above will
--		  be truncated if the length of the value being passed in
--		  exceeds the maximum allowance, and a warning will be appended
--		  to the runtime message list.
--
--		  The type and owner of the the service request cannot be
--		  updated when there is an active workflow process. The status
--		  of the service request can be set to a "closed" status
--		  (status whose close_flag is set) under the same condition.
--		  In that case, this API will abort the active workflow
--		  process. When this API is being called by the workflow
--		  process, the caller must pass in the workflow process ID of
--		  the active workflow process for verification.
--
--		  For the descriptive flexfield segments, the caller must pass
--		  in the IDs for all columns that are used in the descriptive
--	    	  flexfield. Input by value is currently not supported.
--
--		  The publish flag cannot be updated if the profile
--		  'Service: Publish Flag Update Allowed' is not set. If the
--		  caller passes in a non-null value when the profile is not
--		  set, the API will return an error.

--        The service request record must be committed before launching
--        the workflow process. This is necessary because Workflow needs
--        to obtain a lock on the record. If the caller passes in FALSE
--        for p_commit and TRUE for p_launch_workflow, the API will
--        return an error.
--
--        A workflow is automatically launched only if the caller passes
--        in TRUE for the p_launch_workflow parameter and the profile
--        option 'Service: Auto Launch Workflow' is set to 'Y'.
--
--        If p_launch_workflow is set, the Workflow API will try to lock
--        the service request record because it needs to update the
--        workflow_process_id column. The NOWAIT option can be specified
--        by setting the p_nowait parameter. If p_nowait is set and the
--        service request record is locked by another user, an error
--        status is returned via the p_return_status_wkflw parameter
--        indicating the workflow process is not launched.
--
--        If p_launch_workflow is set and the service request record is
--        created successfully, a success code will be returned via the
--        p_return_status parameter regardless of the result of the
--        workflow launch. The status code from the Workflow launch is
--        returned via the p_return_status_wkflw parameter instead.

--
-- End of comments
--
--------------------------------------------------------------------------
/*#
 * Update Service Request enables user to update a service request, and other service request related data
 * such as service contacts, and tasks. For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Update Service Request
 * @rep:primaryinstance
 * @rep:businessevent oracle.apps.cs.sr.ServiceRequest.updated
 * @rep:metalink 390479.1 Oracle White Paper : Service Request Public Application Programming Interfaces (APIs)
 */

/**** Above text has been added to enable the integration repository to extract the
      data from the source code file and populate the integration repository schema so
      that Update_ServiceRequest API appears in the integration repository.
****/


PROCEDURE Update_ServiceRequest(
  p_api_version            	IN     NUMBER,
  p_init_msg_list          	IN     VARCHAR2      := FND_API.G_FALSE,
  p_commit                 	IN     VARCHAR2      := FND_API.G_FALSE,
  x_return_status          	OUT NOCOPY VARCHAR2,
  x_msg_count              	OUT NOCOPY NUMBER,
  x_msg_data               	OUT NOCOPY VARCHAR2,
  p_request_id             	IN     NUMBER        := NULL,
  p_request_number         	IN     VARCHAR2      := NULL,
  p_audit_comments         	IN     VARCHAR2      := NULL,
  p_object_version_number  	IN     NUMBER,
  p_resp_appl_id           	IN     NUMBER        := NULL,
  p_resp_id                	IN     NUMBER        := NULL,
  p_last_updated_by        	IN     NUMBER,
  p_last_update_login      	IN     NUMBER        := NULL,
  p_last_update_date       	IN     DATE,
  p_service_request_rec    	IN     service_request_rec_type,
  p_notes                  	IN     notes_table,
  p_contacts               	IN     contacts_table,
  p_called_by_workflow     	IN     VARCHAR2      := FND_API.G_FALSE,
  p_workflow_process_id    	IN     NUMBER        := NULL,
  -- Commented out since these are now part of the out rec type --anmukher--08/08/03
  -- x_workflow_process_id    	OUT NOCOPY NUMBER,
  -- x_interaction_id         	OUT NOCOPY NUMBER,
  ----------------anmukher--------------------08/08/03
  -- Added for 11.5.10 projects
  p_auto_assign		    	IN	VARCHAR2 Default 'N',
  p_validate_sr_closure	    	IN	VARCHAR2 Default 'N',
  p_auto_close_child_entities	IN	VARCHAR2 Default 'N',
  p_default_contract_sla_ind	IN      VARCHAR2 Default 'N',
  x_sr_update_out_rec		OUT NOCOPY	sr_update_out_rec_type
);


----------------anmukher--------------08/08/03
-- Overloaded procedure added for backward compatibility in 11.5.10
-- since several new OUT parameters have been added to the 11.5.9 signature
-- in the form of a new record type, sr_update_out_rec_type
PROCEDURE Update_ServiceRequest(
  p_api_version            	IN     NUMBER,
  p_init_msg_list          	IN     VARCHAR2      := FND_API.G_FALSE,
  p_commit                 	IN     VARCHAR2      := FND_API.G_FALSE,
  x_return_status          	OUT NOCOPY VARCHAR2,
  x_msg_count              	OUT NOCOPY NUMBER,
  x_msg_data               	OUT NOCOPY VARCHAR2,
  p_request_id             	IN     NUMBER        := NULL,
  p_request_number         	IN     VARCHAR2      := NULL,
  p_audit_comments         	IN     VARCHAR2      := NULL,
  p_object_version_number  	IN     NUMBER,
  p_resp_appl_id           	IN     NUMBER        := NULL,
  p_resp_id                	IN     NUMBER        := NULL,
  p_last_updated_by        	IN     NUMBER,
  p_last_update_login      	IN     NUMBER        := NULL,
  p_last_update_date       	IN     DATE,
  p_service_request_rec    	IN     service_request_rec_type,
  p_notes                  	IN     notes_table,
  p_contacts               	IN     contacts_table,
  p_called_by_workflow     	IN     VARCHAR2      := FND_API.G_FALSE,
  p_workflow_process_id    	IN     NUMBER        := NULL,
  p_default_contract_sla_ind	IN      VARCHAR2 Default 'N',
  x_workflow_process_id    	OUT NOCOPY NUMBER,
  x_interaction_id         	OUT NOCOPY NUMBER
  );

-- -------------------------------------------------------------------
-- Start of comments
--  API Name	: Update_Status
--  Type	: Public
--  Description	: Update the status of a service request
--  Pre-reqs	: None
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--	p_return_status			OUT	VARCHAR2(1)
--	p_msg_count			OUT	NUMBER
--	p_msg_data			OUT	VARCHAR2(2000)
--
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--		Default = NULL
--	p_resp_id			IN	NUMBER		Optional
--		Default = NULL
--	p_user_id			IN	NUMBER		Optional
--		Default = NULL
--	p_login_id			IN	NUMBER		Optional
--		Default = FND_API.G_MISS_NUM

----------------------------------------------------
--   Not in the API
--      p_org_id			IN	NUMBER		Optional
--		Default = NULL
------------------------------------------------------------



--	p_request_id			IN	NUMBER		Optional
--		Default = NULL
--	p_request_number		IN	VARCHAR2	Optional
--		Default = NULL
--	p_status_id			IN	NUMBER		Optional
--		Default = NULL
--	p_status			IN	VARCHAR2	Optional
--		Default = NULL
--      p_closed_date			IN	DATE		Optional
--		Default = FND_API.G_MISS_DATE
--	p_audit_comments		IN	VARCHAR2	Optional
--		Default = NULL
--		Used for the audit record.
--	p_called_by_workflow		IN	NUMBER		Optional
--		Default = FND_API.G_FALSE
--		Whether or not this API is being called by the active workflow
--		process of the service request.
--	p_workflow_process_id		IN	NUMBER		Optional
--		Default = NULL
--		The workflow process ID of the active workflow process.
--
--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--		Service request comments or log of the conversation.
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--		Indicate whether the service request comment is public (can be
--		viewed by anyone).
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--		System generated ID of service request call
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either p_request_id or p_request_number must be non-null.
--		  If both are passed in, p_request_number will be ignored
--
--		  Either p_Status or p_Status_id must be passed in. If
--		  both are passed in, the value of p_Status will be ignore.
--
--		  The status of the service request can be updated to a
--		  "closed" status (statuses whose close_flag is set) when
--		  there is an active workflow process. In that case, the API
--		  will abort the active workflow process. When the API is
--		  being called by the process itself, the caller must pass in
--		  the workflow process ID of the active workflow process for
--		  verification.
--
--		  If the new status is a "closed" status, then the value
--		  of p_closed_date will be used to set the close date of
-- 		  the service request.  If p_closed_date is not passed
--                in, sysdate will be defaulted.
--
-- End of comments
-- -------------------------------------------------------------------
/*#
 * Updates the status of an existing service request.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Update Service Request Status
 * @rep:primaryinstance
 * @rep:metalink 390479.1 Oracle White Paper : Service Request Public Application Programming Interfaces (APIs)
*/

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Update_Status API appears in the integration repository.
****/

PROCEDURE Update_Status
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		    IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		    IN	NUMBER   := NULL,
  p_user_id		    IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_status_id		IN	NUMBER   := NULL,
  p_status		    IN	VARCHAR2 := NULL,
  p_closed_date		IN	DATE     := FND_API.G_MISS_DATE,
  p_audit_comments	     IN	VARCHAR2 := NULL,
  p_called_by_workflow	 IN	VARCHAR2 := FND_API.G_FALSE,
  p_workflow_process_id	 IN	NUMBER   := NULL,
  p_comments		     IN	VARCHAR2 := NULL,
  p_public_comment_flag	 IN	VARCHAR2 := FND_API.G_FALSE,
  p_validate_sr_closure         IN      VARCHAR2 Default 'N',
  p_auto_close_child_entities   IN      VARCHAR2 Default 'N',
  x_interaction_id		 OUT	NOCOPY NUMBER
);

-- -------------------------------------------------------------------
-- Start of comments
--  API Name	: Update_Severity
--  Type	: Public
--  Description	: Update the severity of a service request
--  Pre-reqs	: None
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--	p_return_status			OUT	VARCHAR2(1)
--	p_msg_count			OUT	NUMBER
--	p_msg_data			OUT	VARCHAR2(2000)
--
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--		Default = NULL
--	p_resp_id			IN	NUMBER		Optional
--		Default = NULL
--	p_user_id			IN	NUMBER		Optional
--		Default = NULL
--	p_login_id			IN	NUMBER		Optional
--		Default = FND_API.G_MISS_NUM

---------------------------------------------------
--      Not in the API
--      p_org_id			IN	NUMBER		Optional
--		Default = NULL
---------------------------------

--	p_request_id			IN	NUMBER		Optional
--		Default = NULL
--	p_request_number		IN	VARCHAR2	Optional
--		Default = NULL
--	p_severity_id			IN	NUMBER		Optional
--		Default = NULL
--	p_severity			IN	VARCHAR2	Optional
--		Default = NULL
--	p_audit_comments		IN	VARCHAR2	Optional
--		Default = NULL
--		Used for the audit record.
--
--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--		Service request comments or log of the conversation.
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--		Indicate whether the service request comment is public (can be
--		viewed by anyone).
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--		System generated ID of service request call
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either p_request_id or p_request_number must be non-null.
--		  If both are passed in, p_request_number will be ignored
--
--		  Either p_severity or p_severity_id must be passed in. If
--		  both are passed in, the value of p_severity will be ignore.
--
-- End of comments
-- -------------------------------------------------------------------

PROCEDURE Update_Severity
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		    IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		    IN	NUMBER   := NULL,
  p_user_id		    IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_severity_id		IN	NUMBER   := NULL,
  p_severity		IN	VARCHAR2 := NULL,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id  OUT NOCOPY NUMBER
);

-- -------------------------------------------------------------------
-- Start of comments
--  API Name	: Update_Urgency
--  Type	: Public
--  Description	: Update the urgency of a service request
--  Pre-reqs	: None
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--	p_return_status			OUT	VARCHAR2(1)
--	p_msg_count			OUT	NUMBER
--	p_msg_data			OUT	VARCHAR2(2000)
--
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--		Default = NULL
--	p_resp_id			IN	NUMBER		Optional
--		Default = NULL
--	p_user_id			IN	NUMBER		Optional
--		Default = NULL
--	p_login_id			IN	NUMBER		Optional
--		Default = FND_API.G_MISS_NUM

----------------------------------------------
--      Not in the API

--      p_org_id			IN	NUMBER		Optional
--		Default = NULL

-------------------------------------------------------
--	p_request_id			IN	NUMBER		Optional
--		Default = NULL
--	p_request_number		IN	VARCHAR2	Optional
--		Default = NULL
--	p_urgency_id			IN	NUMBER		Optional
--		Default = FND_API.G_MISS_NUM
--	p_urgency			IN	VARCHAR2	Optional
--		Default = FND_API.G_MISS_CHAR
--	p_audit_comments		IN	VARCHAR2	Optional
--		Default = NULL
--		Used for the audit record.
--
--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--		Service request comments or log of the conversation.
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--		Indicate whether the service request comment is public (can be
--		viewed by anyone).
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--		System generated ID of service request call
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either p_request_id or p_request_number must be non-null.
--		  If both are passed in, p_request_number will be ignored
--
--		  Either p_urgency or p_urgency_id must be passed in. If
--		  both are passed in, the value of p_urgency will be ignore.
--
-- End of comments
-- -------------------------------------------------------------------

PROCEDURE Update_Urgency
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		    IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		    IN	NUMBER   := NULL,
  p_user_id		    IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_urgency_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_urgency		    IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id  OUT NOCOPY NUMBER
);


-- -------------------------------------------------------------------
-- Start of comments
--  API Name	: Update_Owner
--  Type	: Public
--  Description	: Update the owner of a service request
--  Pre-reqs	: Parameter p_owner_id must be a valid employee ID of
--                an active employee in HR
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--	p_return_status			OUT	VARCHAR2(1)
--	p_msg_count			OUT	NUMBER
--	p_msg_data			OUT	VARCHAR2(2000)
--
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--		Default = NULL
--	p_resp_id			IN	NUMBER		Optional
--		Default = NULL
--	p_user_id			IN	NUMBER		Optional
--		Default = NULL
--	p_login_id			IN	NUMBER		Optional
--		Default = FND_API.G_MISS_NUM

-----------------------------------------
--     Not in the API
--      p_org_id			IN	NUMBER		Optional
--		Default = NULL
-----------------------------------------------

--	p_request_id			IN	NUMBER		Optional
--		Default = NULL
--	p_request_number		IN	VARCHAR2	Optional
--		Default = NULL
--	p_Owner_id			IN	NUMBER		Required
--		Cannot be NULL.
--	p_audit_comments		IN	VARCHAR2	Optional
--		Default = NULL
--		Used for the audit record.
--	p_called_by_workflow		IN	NUMBER		Optional
--		Default = FND_API.G_FALSE
--		Whether or not this API is being called by the active workflow
--		process of the service request.
--	p_workflow_process_id		IN	NUMBER		Optional
--		Default = NULL
--		The workflow process ID of the active workflow process.
--
--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--		Service request comments or log of the conversation.
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--		Indicate whether the service request comment is public (can be
--		viewed by anyone).
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--		System generated ID of service request call
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either p_request_id or p_request_number must be non-null.
--		  If both are passed in, p_request_number will be ignored
--
--		  The owner of the service request cannot be updated when
--		  there is an active workflow process unless the API is
--    		  being called by the process itself.  In that case, the
--      	  caller must pass in the workflow process ID of the active
--                workflow process for verification.
--
-- End of comments
-- -------------------------------------------------------------------
/*#
 * Updates both the group and the individual owner of an existing service request.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Update Service Request Owner
 * @rep:primaryinstance
 * @rep:metalink 390479.1 Oracle White Paper : Service Request Public Application Programming Interfaces (APIs)
*/

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Update_Owner API appears in the integration repository.
****/

PROCEDURE Update_Owner
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		    IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		    IN	NUMBER   := NULL,
  p_user_id		    IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_owner_id		IN	NUMBER,
  p_owner_group_id  IN   NUMBER,
  p_resource_type	IN	VARCHAR2,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_called_by_workflow	IN	VARCHAR2 := FND_API.G_FALSE,
  p_workflow_process_id	IN	NUMBER   := NULL,
  p_comments		    IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id  OUT NOCOPY NUMBER
);

-- -------------------------------------------------------------------
-- Start of comments
--  API Name	: Update_Problem_Code
--  Type	: Public
--  Description	: Update the problem code of a service request
--  Pre-reqs	: None
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--	p_return_status			OUT	VARCHAR2(1)
--	p_msg_count			OUT	NUMBER
--	p_msg_data			OUT	VARCHAR2(2000)
--
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--		Default = NULL
--	p_resp_id			IN	NUMBER		Optional
--		Default = NULL
--	p_user_id			IN	NUMBER		Optional
--		Default = NULL
--	p_login_id			IN	NUMBER		Optional
--		Default = FND_API.G_MISS_NUM

---------------------------------
--     Not in API
--      p_org_id			IN	NUMBER		Optional
--		Default = NULL

-----------------------------


--	p_request_id			IN	NUMBER		Optional
--		Default = NULL
--	p_request_number		IN	VARCHAR2	Optional
--		Default = NULL
--      p_problem_code			IN	VARCHAR2	Required
--
--  Calls IN parameters:
--	p_comments			IN	VARCHAR2(2000)	Optional
--		Service request comments or log of the conversation.
--	p_public_comment_flag		IN	VARCHAR2(1)	Optional
--		Indicate whether the service request comment is public (can be
--		viewed by anyone).
--
--  Calls OUT parameters:
--	p_call_id			OUT	NUMBER
--		System generated ID of service request call
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either p_request_id or p_request_number must be non-null.
--		  If both are passed in, p_request_number will be ignored
--
-- End of comments
-- -------------------------------------------------------------------

PROCEDURE Update_Problem_Code
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		    IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		    IN	NUMBER   := NULL,
  p_user_id		    IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_problem_code	IN	VARCHAR2,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id  OUT NOCOPY NUMBER
);


-------------------------------------------------------------------
---These APIs are owned by Shih-Hsin
-- Start of comments
--  API Name    : Link_KB_Statement
--  Type        : Public
--  Function    : Link a Knowledge Management statement with a Service Request
--  Pre-reqs    : Must a valid Service Request id and KB Element id
--
--  Parameters  :
--      IN      :
--   p_api_version            IN   NUMBER         Required
--   p_init_msg_list               IN   VARCHAR2(1)    Optional
--        Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2(1)    Optional
--        Default = FND_API.G_FALSE
--      p_request_id                    IN      NUMBER          Required
--      p_statement_id                  IN      NUMBER          Required
--      p_is_statement_true             IN      BOOLEAN         Required
--
--      OUT     :
--   x_return_status               OUT  VARCHAR2(1)
--   x_msg_count              OUT  NUMBER
--   x_msg_data               OUT  VARCHAR2(2000)
--      x_statement_link_id             OUT     NUMBER
--
--  Version     : Initial Version     1.0
--
--  Notes       : This procedure will link a statement in the knowledge
--                management system to a service request.
--
-- End of comments

PROCEDURE Link_KB_Statement
(
 p_api_version            IN     NUMBER,
 p_init_msg_list          IN     VARCHAR2      := FND_API.G_FALSE,
 p_commit                 IN     VARCHAR2      := FND_API.G_FALSE,
 p_validation_level       IN     NUMBER        := FND_API.G_VALID_LEVEL_FULL,
 x_return_status          OUT    NOCOPY VARCHAR2,
 x_msg_count              OUT    NOCOPY NUMBER,
 x_msg_data               OUT    NOCOPY VARCHAR2,
 p_request_id             IN     NUMBER,
 p_statement_id           IN     NUMBER,
 p_is_statement_true      IN     VARCHAR2,
 x_statement_link_id      OUT    NOCOPY NUMBER
);

-------------------------------------------------------------------------
-- Start of comments
--  API Name    : Link_KB_Solution
--  Type        : Public
--  Function    : Link a Knowledge Management solution with a Service Request
--  Pre-reqs    : Must a valid Service Request id and KB Set id
--
--  Parameters  :
--      IN      :
--   p_api_version            IN   NUMBER         Required
--   p_init_msg_list               IN   VARCHAR2(1)    Optional
--        Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2(1)    Optional
--        Default = FND_API.G_FALSE
--      p_request_id                    IN      NUMBER          Required
--      p_solution_id                   IN      NUMBER          Required
--      p_is_solution_true              IN      BOOLEAN         Required
--
--      OUT     :
--   x_return_status               OUT  VARCHAR2(1)
--   x_msg_count              OUT  NUMBER
--   x_msg_data               OUT  VARCHAR2(2000)
--      x_solution_link_id              OUT     NUMBER
--
--  Version     : Initial Version     1.0
--
--  Notes       : This procedure will link a solution in the knowledge
--                management system to a service request.
--
-- End of comments

/*#
 * Links an Oracle Knowledge Base solution to an existing service request.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Link Knowledge Base Solution
 * @rep:primaryinstance
 * @rep:businessevent  oracle.apps.cs.knowledge.SolutionLinked
 * @rep:metalink 390479.1 Oracle White Paper : Service Request Public Application Programming Interfaces (APIs)
*/

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Link_KB_Solution API appears in the integration repository.
****/

PROCEDURE Link_KB_Solution
(
 p_api_version            IN     NUMBER,
 p_init_msg_list          IN     VARCHAR2      := FND_API.G_FALSE,
 p_commit                 IN     VARCHAR2      := FND_API.G_FALSE,
 p_validation_level       IN     NUMBER        := FND_API.G_VALID_LEVEL_FULL,
 x_return_status          OUT    NOCOPY VARCHAR2,
 x_msg_count              OUT    NOCOPY NUMBER,
 x_msg_data               OUT    NOCOPY VARCHAR2,
 p_request_id             IN     NUMBER,
 p_solution_id            IN     NUMBER,
 p_is_solution_true       IN     VARCHAR2,
 x_solution_link_id       OUT    NOCOPY NUMBER
);

/* This is a overloaded procedure for create service request which is mainly
   created for making the changes for 1159 backward compatiable. This does not
   contain the following parameters:-
   x_individual_owner, x_group_owner, x_individual_type and p_auto_assign.
   and will call the above procedure with all these parameters and version
   as 3.0*/

PROCEDURE Create_ServiceRequest
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2      := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2      := FND_API.G_FALSE,
  x_return_status                 OUT     NOCOPY VARCHAR2,
  x_msg_count                     OUT     NOCOPY NUMBER,
  x_msg_data                      OUT     NOCOPY VARCHAR2,
  p_resp_appl_id                  IN      NUMBER                := NULL,
  p_resp_id                       IN      NUMBER                := NULL,
  p_user_id                       IN      NUMBER                := NULL,
  p_login_id                      IN      NUMBER                := NULL,
  p_org_id                        IN      NUMBER                := NULL,
  p_request_id                    IN      NUMBER                := NULL,
  p_request_number                IN      VARCHAR2              := NULL,
  p_service_request_rec           IN      SERVICE_REQUEST_REC_TYPE,
  p_notes                         IN      NOTES_TABLE,
  p_contacts                      IN      CONTACTS_TABLE,
  p_default_contract_sla_ind	  IN      VARCHAR2 Default 'N',
  x_request_id                    OUT     NOCOPY NUMBER,
  x_request_number                OUT     NOCOPY VARCHAR2,
  x_interaction_id                OUT     NOCOPY NUMBER,
  x_workflow_process_id           OUT     NOCOPY NUMBER
);

/*#
 * Updates the values of user-defined attributes (extensible attributes) for an existing service request.
 * Extensible attributes are used only by Customer Support, Service Desk, and Oracle Case Management.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Process SR Extensible Attributes
 * @rep:primaryinstance
 * @rep:metalink 390479.1 Oracle White Paper : Service Request Public Application Programming Interfaces (APIs)
*/
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
-----------------------------------------------------------

END CS_ServiceRequest_PUB;

/
