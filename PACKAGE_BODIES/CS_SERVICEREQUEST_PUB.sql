--------------------------------------------------------
--  DDL for Package Body CS_SERVICEREQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICEREQUEST_PUB" AS
/* $Header: cspsrb.pls 120.7.12010000.8 2010/06/15 22:17:21 siahmed ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_ServiceRequest_PUB';
G_INITIALIZED       CONSTANT VARCHAR2(1)  := 'R';
G_SR_SUBTYPE        CONSTANT VARCHAR2(5)  := 'INC';

/* ************************************************************************* *
 *              Forward Declaration of Local Procedures                      *
 *   The following local procedures are called by the APIs in this package.  *
 * ************************************************************************* */

--------------------------------------------------------------------------
-- Type Request_Conversion_Rec_Type record
-- Description:
--   The Request_Conversion_Rec_Type record holds both Service Request
--   attribute values and IDs.
-- Notes:
--   Ideally, this record should be paired up with the Request_Rec_Type
--   (which only holds Service Request attribute IDs). But since it is not
--   passed from the caller but instead setup from within the Public API,
--   it doesn't make sense for it to include all the other fields that are
--   not value-ID based. So instead it only contains value-ID based
--   attributes to be passed to the conversion routine.
--------------------------------------------------------------------------

TYPE Request_Conversion_Rec_Type IS RECORD
( type_id			NUMBER		:= FND_API.G_MISS_NUM,
  type_name			VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
  status_id			NUMBER		:= FND_API.G_MISS_NUM,
  status_name			VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
  severity_id			NUMBER		:= FND_API.G_MISS_NUM,
  severity_name			VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
  urgency_id			NUMBER		:= FND_API.G_MISS_NUM,
  urgency_name			VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
  caller_type            	VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  employee_id			NUMBER		:= FND_API.G_MISS_NUM,
  employee_number		VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
  customer_product_id		NUMBER		:= FND_API.G_MISS_NUM,
  cp_ref_number			NUMBER		:= FND_API.G_MISS_NUM,  --3840658
  publish_flag			VARCHAR2(1)	:= FND_API.G_MISS_CHAR,
  verify_cp_flag		VARCHAR2(1)	:= FND_API.G_MISS_CHAR
);

-- Modification History
-- Date     Name     Description
----------- -------- -----------------------------------------------------------
-- 05/04/05 smisra   initialized maint_organization_id to G_MISS_NUM
--                   And removed item_serial_number initialization
--------------------------------------------------------------------------------
PROCEDURE initialize_rec(
  p_sr_record                   IN OUT NOCOPY service_request_rec_type
) AS
BEGIN
  p_sr_record.request_date               := FND_API.G_MISS_DATE;
  p_sr_record.type_id                    := FND_API.G_MISS_NUM;
  p_sr_record.type_name                  := FND_API.G_MISS_CHAR;
  p_sr_record.status_id                  := FND_API.G_MISS_NUM;
  p_sr_record.status_name                := FND_API.G_MISS_CHAR;
  p_sr_record.severity_id                := FND_API.G_MISS_NUM;
  p_sr_record.severity_name              := FND_API.G_MISS_CHAR;
  p_sr_record.urgency_id                 := FND_API.G_MISS_NUM;
  p_sr_record.urgency_name               := FND_API.G_MISS_CHAR;
  p_sr_record.closed_date                := FND_API.G_MISS_DATE;
  p_sr_record.owner_id                   := FND_API.G_MISS_NUM;
  p_sr_record.owner_group_id             := FND_API.G_MISS_NUM;
  p_sr_record.publish_flag               := FND_API.G_MISS_CHAR;
  p_sr_record.summary                    := FND_API.G_MISS_CHAR;
  p_sr_record.caller_type                := FND_API.G_MISS_CHAR;
  p_sr_record.customer_id                := FND_API.G_MISS_NUM;
  p_sr_record.customer_number            := FND_API.G_MISS_CHAR;
  p_sr_record.employee_id                := FND_API.G_MISS_NUM;
  p_sr_record.employee_number            := FND_API.G_MISS_CHAR;
  p_sr_record.verify_cp_flag             := FND_API.G_MISS_CHAR;
  p_sr_record.customer_product_id        := FND_API.G_MISS_NUM;
  p_sr_record.platform_id                := FND_API.G_MISS_NUM;
  p_sr_record.platform_version		 := FND_API.G_MISS_CHAR;
  p_sr_record.db_version		 := FND_API.G_MISS_CHAR;
  p_sr_record.platform_version_id        := FND_API.G_MISS_NUM;
  p_sr_record.cp_component_id            := FND_API.G_MISS_NUM;
  p_sr_record.cp_component_version_id    := FND_API.G_MISS_NUM;
  p_sr_record.cp_subcomponent_id         := FND_API.G_MISS_NUM;
  p_sr_record.cp_subcomponent_version_id := FND_API.G_MISS_NUM;
  p_sr_record.language_id                := FND_API.G_MISS_NUM;
  p_sr_record.language                   := FND_API.G_MISS_CHAR;
  p_sr_record.cp_ref_number              := FND_API.G_MISS_NUM;
  p_sr_record.inventory_item_id          := FND_API.G_MISS_NUM;
  p_sr_record.inventory_item_conc_segs   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment1    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment2    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment3    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment4    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment5    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment6    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment7    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment8    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment9    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment10   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment11   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment12   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment13   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment14   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment15   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment16   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment17   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment18   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment19   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment20   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_vals_or_ids := 'V';
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
 ---For ER# 2501166 added these external attributes date 1st oct 2002
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
  p_sr_record.contract_id				 := FND_API.G_MISS_NUM;  -- for BUG 2776748
  p_sr_record.contract_service_id        := FND_API.G_MISS_NUM;
  p_sr_record.contract_service_number    := FND_API.G_MISS_CHAR;
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
-- Fix for Bug# 2155981
  p_sr_record.project_number             := FND_API.G_MISS_CHAR;
-----jngeorge-----enhancements-----11.5.6-----07/12/01
  p_sr_record.tier                       := FND_API.G_MISS_CHAR;
  p_sr_record.tier_version               := FND_API.G_MISS_CHAR;
  p_sr_record.operating_system           := FND_API.G_MISS_CHAR;
  p_sr_record.operating_system_version   := FND_API.G_MISS_CHAR;
  p_sr_record.database                   := FND_API.G_MISS_CHAR;
  p_sr_record.cust_pref_lang_id          := FND_API.G_MISS_NUM;
  p_sr_record.category_id                := FND_API.G_MISS_NUM;
  p_sr_record.group_type                 := FND_API.G_MISS_CHAR;
  p_sr_record.group_territory_id         := FND_API.G_MISS_NUM;
  p_sr_record.inv_platform_org_id        := FND_API.G_MISS_NUM;
  p_sr_record.product_revision           := FND_API.G_MISS_CHAR;
  p_sr_record.component_version          := FND_API.G_MISS_CHAR;
  p_sr_record.subcomponent_version       := FND_API.G_MISS_CHAR;
  p_sr_record.comm_pref_code             := FND_API.G_MISS_CHAR;
--- Added for Post 11.5.6 Enhancements
  p_sr_record.cust_pref_lang_code        := FND_API.G_MISS_CHAR;
  p_sr_record.last_update_channel        := FND_API.G_MISS_CHAR;
  p_sr_record.category_set_id            := FND_API.G_MISS_NUM;
  p_sr_record.external_reference         := FND_API.G_MISS_CHAR;
  p_sr_record.system_id                  := FND_API.G_MISS_NUM;
-------jngeorge----07/12/01
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
-- Added for Enh# 2216664
  p_sr_record.owner                      := FND_API.G_MISS_CHAR;
  p_sr_record.group_owner                := FND_API.G_MISS_CHAR;
-- Added for Credit Card ER# 2255263 (UI ER#2208078)
  p_sr_record.cc_number                  := FND_API.G_MISS_CHAR;
  p_sr_record.cc_expiration_date         := FND_API.G_MISS_DATE;
  p_sr_record.cc_type_code               := FND_API.G_MISS_CHAR;
  p_sr_record.cc_first_name              := FND_API.G_MISS_CHAR;
  p_sr_record.cc_last_name               := FND_API.G_MISS_CHAR;
  p_sr_record.cc_middle_name             := FND_API.G_MISS_CHAR;
  p_sr_record.cc_id                      := FND_API.G_MISS_NUM;
  p_sr_record.bill_to_account_id         := FND_API.G_MISS_NUM;   -- ER# 2433831
  p_sr_record.ship_to_account_id         := FND_API.G_MISS_NUM;   -- ER# 2433831
  p_sr_record.customer_phone_id   	 := FND_API.G_MISS_NUM;   -- ER# 2463321
  p_sr_record.customer_email_id   	 := FND_API.G_MISS_NUM;   -- ER# 2463321
  p_sr_record.creation_program_code      := FND_API.G_MISS_CHAR;  -- ER source
  p_sr_record.last_update_program_code   := FND_API.G_MISS_CHAR;  -- ER source
  -- Bill_to_party, ship_to_party
  p_sr_record.bill_to_party_id           := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_party_id           := FND_API.G_MISS_NUM;
  -- Conc request related fields
  p_sr_record.program_id                 := FND_API.G_MISS_NUM;
  p_sr_record.program_application_id     := FND_API.G_MISS_NUM;
  p_sr_record.conc_request_id            := FND_API.G_MISS_NUM;
  p_sr_record.program_login_id           := FND_API.G_MISS_NUM;
  -- Bill_to_party_site, ship_to_party_site
  p_sr_record.bill_to_site_id            := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_site_id            := FND_API.G_MISS_NUM;
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
  -- Added initialization for incident location type here since Rosetta
  -- ignores default values for record type attributes --anmukher --08/29/03
  -- Changed the default value to 'HZ_LOCATION' --anmukher --09/05/03
  p_sr_record.incident_location_type	   := 'HZ_LOCATION';
  p_sr_record.coverage_type                := FND_API.G_MISS_CHAR;
   -- for cmro_Eam
  p_sr_record.owning_department_id     	   := FND_API.G_MISS_NUM;
  p_sr_record.maint_organization_id        := FND_API.G_MISS_NUM;
  p_sr_record.created_by                   := FND_API.G_MISS_NUM;
  p_sr_record.creation_date                := FND_API.G_MISS_DATE;
  /* Credit Card 9358401 */
  p_sr_record.instrument_payment_use_id    := FND_API.G_MISS_NUM;


END initialize_rec;

--------------------------------------------------------------------------
-- Procedure Default_Other_Attributes
-- Description:
--   Default missing attributes that are not in the Service Request record.
--   If the parameter is NULL, then the default value for that attribute is
--   returned; otherwise, the passed value is returned. Defaulting rules
--   are:
--   1. Defaults the responsibility application ID, responsiblity ID, user
--      ID, and login ID to the values from the FND_GLOBAL global variables.
--   2. If Multi-Org is enabled, default the operating unit ID to the value
--      from the RDBMS session-level global variable or the profile option;
--      otherwise, default to NULL.
--   3. Defaults the inventory organization ID to the value from the
--      profile option.
--------------------------------------------------------------------------

PROCEDURE Default_Other_Attributes
( p_api_name			IN	VARCHAR2,
  p_resp_appl_id		IN OUT	NOCOPY NUMBER,
  p_resp_id			IN OUT	NOCOPY NUMBER,
  p_user_id			IN OUT	NOCOPY NUMBER,
  p_login_id			IN OUT	NOCOPY NUMBER,
  p_org_id			IN OUT	NOCOPY NUMBER,
  p_inventory_org_id		IN OUT	NOCOPY NUMBER,
  p_return_status		OUT	NOCOPY VARCHAR2
);


---------------------------------------------------------------------------
-- Procedure Convert_Request_Val_To_ID
-- Description:
--   Convert type name, status name, severity name, urgency name, customer
--   name or number, CP reference number, and RMA number into their
--   internal IDs. Convert flags from G_TRUE and G_FALSE to 'Y' and 'N'
--   respectively.
-- Notes:
--   If neither the ID nor value based parameter is passed, the ID attribute
--   remains FND_API.G_MISS_NUM. If the ID paramter is not passed and the
--   value parameter is NULL, the ID attribute gets set to NULL.
--   If an error occurs (e.g. failure to resolve a value into an ID), this
--   procedure returns with an error before converting the rest of the
--   value parameters. If an unexpected error (e.g. database failure)
--   occurs, the 'OTHERS' exception may be raised and must be handled by
--   the calling procedure.
--   After calling this procedure, all the "flag" values will either be
--   converted to Y/N, or remain FND_API.G_MISS_CHAR or NULL.
---------------------------------------------------------------------------

PROCEDURE Convert_Request_Val_To_ID
( p_api_name			IN	VARCHAR2,
  p_org_id			IN	NUMBER		:= NULL,
  p_request_conv_rec		IN OUT	NOCOPY Request_Conversion_Rec_Type,
  p_return_status		OUT	NOCOPY VARCHAR2
);


--------------------------------------------------------------------------
-- Procedure Convert_Key_Flex_To_ID
-- Description:
--   Find the code combination ID number for the given set of key flexfield
--   segment values.
-- Notes:
--   p_attribute_segments_tbl is required because the FND_FLEX_EXT package
--   does not provide a "missing table" global variable. Instead, the
--   caller must pass in either an empty table, or a table with "missing"
--   strings.
--------------------------------------------------------------------------

PROCEDURE Convert_Key_Flex_To_ID
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_key_flex_code		IN	VARCHAR2,
  p_structure_number		IN	NUMBER,
  p_attribute_id		IN	NUMBER		:= FND_API.G_MISS_NUM,
  p_attribute_conc_segs		IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
  p_attribute_segments_tbl	IN	FND_FLEX_EXT.SegmentArray,
  p_attribute_n_segments	IN	NUMBER		:= 0,
  p_attribute_vals_or_ids	IN	VARCHAR2	:= 'V',
  p_data_set			IN	NUMBER		:= NULL,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  p_user_id			IN	NUMBER		:= NULL,
  p_attribute_id_out		OUT	NOCOPY NUMBER,
  p_return_status		OUT	NOCOPY VARCHAR2
);


/*** Moved this procedure to csusrb.pls as this is being used in PVT API too
1/28/2004 smisra
--------------------------------------------------------------------------
-- Procedure Validate_Desc_Flex
-- Description:
--   Validate descriptive flexfield segment IDs and context.
-- Notes:
--   This procedure currently does not accept a concatenated string of
--   segment IDs as input, since the descriptive flexfield API does not
--   allow access to the segment column names in the same order that the
--   segment IDs are returned. In other words, there is no way to breakup
--   the concatenated segments into 15 attribute column values.
--------------------------------------------------------------------------
PROCEDURE Validate_Desc_Flex
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_desc_flex_name		IN	VARCHAR2,
  p_desc_segment1		IN	VARCHAR2,
  p_desc_segment2		IN	VARCHAR2,
  p_desc_segment3		IN	VARCHAR2,
  p_desc_segment4		IN	VARCHAR2,
  p_desc_segment5		IN	VARCHAR2,
  p_desc_segment6		IN	VARCHAR2,
  p_desc_segment7		IN	VARCHAR2,
  p_desc_segment8		IN	VARCHAR2,
  p_desc_segment9		IN	VARCHAR2,
  p_desc_segment10		IN	VARCHAR2,
  p_desc_segment11		IN	VARCHAR2,
  p_desc_segment12		IN	VARCHAR2,
  p_desc_segment13		IN	VARCHAR2,
  p_desc_segment14		IN	VARCHAR2,
  p_desc_segment15		IN	VARCHAR2,
  p_desc_context		IN	VARCHAR2,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  p_return_status		OUT	NOCOPY VARCHAR2
);
*****/

--------------------------------------------------------------------------
-- Procedure Validate_Strings
-- Description:
--   Verify that all VARCHAR2 parameters have string lengths less than or
--   equal to the corresponding database column lengths; truncate when
--   necessary.
--------------------------------------------------------------------------

PROCEDURE Validate_Strings
( p_api_name			IN	VARCHAR2,
  p_summary			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_customer_name		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_customer_number		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_name		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_area_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_telephone		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_extension		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_fax_area_code	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_fax_number		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_email_address	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_name			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_area_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_telephone		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_extension		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_fax_area_code	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_fax_number		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_email		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_current_serial_number	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_purchase_order_num		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_problem_description		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_location		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_customer		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_address_line_1	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_address_line_2	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_address_line_3	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_location		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_customer		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_address_line_1	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_address_line_2	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_address_line_3	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_contact		IN  	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_location		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_customer		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_address_line_1	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_address_line_2	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_address_line_3	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_contact		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_problem_resolution		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_audit_comments		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_inv_item_revision	    	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_inv_component_version	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_inv_subcomponent_version    IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_summary_out			OUT	NOCOPY VARCHAR2,
  p_customer_name_out		OUT	NOCOPY VARCHAR2,
  p_customer_number_out		OUT	NOCOPY VARCHAR2,
  p_contact_name_out		OUT	NOCOPY VARCHAR2,
  p_contact_area_code_out	OUT	NOCOPY VARCHAR2,
  p_contact_telephone_out	OUT	NOCOPY VARCHAR2,
  p_contact_extension_out	OUT	NOCOPY VARCHAR2,
  p_contact_fax_area_code_out	OUT	NOCOPY VARCHAR2,
  p_contact_fax_number_out	OUT	NOCOPY VARCHAR2,
  p_contact_email_address_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_name_out		OUT	NOCOPY VARCHAR2,
  p_rep_by_area_code_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_telephone_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_extension_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_fax_area_code_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_fax_number_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_email_out		OUT	NOCOPY VARCHAR2,
  p_current_serial_number_out	OUT	NOCOPY VARCHAR2,
  p_purchase_order_num_out	OUT	NOCOPY VARCHAR2,
  p_problem_description_out	OUT	NOCOPY VARCHAR2,
  p_install_location_out	OUT	NOCOPY VARCHAR2,
  p_install_customer_out	OUT	NOCOPY VARCHAR2,
  p_install_address_line_1_out	OUT	NOCOPY VARCHAR2,
  p_install_address_line_2_out	OUT	NOCOPY VARCHAR2,
  p_install_address_line_3_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_location_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_customer_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_address_line_1_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_address_line_2_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_address_line_3_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_contact_out		OUT	NOCOPY VARCHAR2,
  p_ship_to_location_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_customer_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_address_line_1_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_address_line_2_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_address_line_3_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_contact_out		OUT	NOCOPY VARCHAR2,
  p_problem_resolution_out	OUT	NOCOPY VARCHAR2,
  p_audit_comments_out		OUT	NOCOPY VARCHAR2,
  p_inv_item_revision_out	OUT	NOCOPY VARCHAR2,
  p_inv_component_version_out	OUT	NOCOPY VARCHAR2,
  p_inv_subcomponent_version_out OUT	NOCOPY VARCHAR2
);


--------------------------------------------------------------------------
-- Procedure Get_Default_Values
-- Description:
--   This procedure is, and should be called from all of the Update APIs.
--   If checks to make sure that either request ID or request Number is
--   passed into the API, and converts the request number into ID when
--   necessary.  It also retrives the applications internal IDs such as
--   user ID, login ID, ..., etc.
--------------------------------------------------------------------------

  PROCEDURE Get_Default_Values(
		p_api_name		IN	VARCHAR,
		p_org_id		IN OUT	NOCOPY NUMBER,
		p_resp_appl_id		IN OUT  NOCOPY NUMBER,
		p_resp_id		IN OUT  NOCOPY NUMBER,
		p_user_id		IN OUT	NOCOPY NUMBER,
		p_login_id		IN OUT	NOCOPY NUMBER,
		p_inventory_org_id	IN OUT  NOCOPY NUMBER,
		p_request_id		IN	NUMBER,
		p_request_number	IN	VARCHAR2,
		p_request_id_out	OUT	NOCOPY NUMBER,
		p_return_status		OUT	NOCOPY VARCHAR2 );

--------------------------------------------------------------------------
-- Procedure Log_SR_PUB_Parameters
-- Description:
--   This procedure used to log the parameters of service_request_type_rec,
--   Notes table and the Contacts table
--   This procedure is only going to be called from the Create_ServiceRequest
--   and Update_ServiceRequest procedure.
--------------------------------------------------------------------------

 PROCEDURE Log_SR_PUB_Parameters
( p_service_request_rec   	  IN         service_request_rec_type
,p_notes                 	  IN         notes_table
,p_contacts              	  IN         contacts_table
);


/* ************************************************************************* *
 *                            API Procedure Bodies                           *
 * ************************************************************************* */
--------------------------------------------------------------------------
-- Create_ServiceRequest
--------------------------------------------------------------------------

----------------anmukher--------------07/31/03
-- Overloaded procedure added for backward compatibility in 11.5.10
-- since several new OUT parameters have been added to the 11.5.9 signature
-- in the form of a new record type, sr_create_out_rec_type
PROCEDURE Create_ServiceRequest
( p_api_version			  IN      NUMBER,
  p_init_msg_list		  IN      VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			  IN      VARCHAR2 	:= FND_API.G_FALSE,
  x_return_status		  OUT     NOCOPY VARCHAR2,
  x_msg_count			  OUT     NOCOPY NUMBER,
  x_msg_data			  OUT     NOCOPY VARCHAR2,
  p_resp_appl_id		  IN      NUMBER	:= NULL,
  p_resp_id			  IN      NUMBER	:= NULL,
  p_user_id			  IN      NUMBER	:= NULL,
  p_login_id			  IN      NUMBER	:= NULL,
  p_org_id			  IN      NUMBER	:= NULL,
  p_request_id                    IN      NUMBER        := NULL,
  p_request_number		  IN      VARCHAR2	:= NULL,
  p_service_request_rec           IN      service_request_rec_type,
  p_notes                         IN      notes_table,
  p_contacts                      IN      contacts_table,
  -- Added for Assignment Manager 11.5.9 change
  p_auto_assign                   IN      VARCHAR2  Default 'N',
  p_default_contract_sla_ind	  IN      VARCHAR2 Default 'N',
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
  -- Added for making call to 11.5.10 signature of Create SR public API
  l_sr_create_out_rec		sr_create_out_rec_type;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Create_ServiceRequest_PUB;

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
  END IF;

 -- Initialize API return status to success
  l_return_status := FND_API.G_RET_STS_SUCCESS;

 CS_ServiceRequest_PUB.Create_ServiceRequest
    ( p_api_version                  => 4.0,
      p_init_msg_list                => p_init_msg_list,
      p_commit                       => p_commit,
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
      p_service_request_rec          => p_service_request_rec,
      p_notes                        => p_notes,
      p_contacts                     => p_contacts,
      p_auto_assign                  => p_auto_assign,
      p_auto_generate_tasks	     => 'N',
      x_sr_create_out_rec      	     => l_sr_create_out_rec,
      p_default_contract_sla_ind     =>  p_default_contract_sla_ind,
      p_default_coverage_template_id => NULL
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
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Create_ServiceRequest;

----------------------------------------------------------------------------

-- Modification History
-- Date     Name     Description
----------- -------- -----------------------------------------------------------
-- 05/04/05 smisra   copied maint_organization_id to PVT API rec
--                   Removed passing of item_serial_number to PVT SR Rec
-- 03/08/05 smisra   Raised exception if item_serial_number is passed
-- 12/30/05 smisra   Bug 4869120
--                   Removed the code in defaultrequest_attributes
--                   that derives resource type. This is now part of
--                   procedure  cs_servicerequest_util.validate_owner.
--------------------------------------------------------------------------------
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
  x_sr_create_out_rec	  	  OUT NOCOPY	sr_create_out_rec_type,
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
 )
IS

-- changed the version from 3.0 to 4.0 anmukher aug 08 2003

  l_api_version	       CONSTANT	NUMBER		:= 4.0;
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Create_ServiceRequest';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
  l_resp_appl_id		NUMBER		:= p_resp_appl_id;
  l_resp_id			NUMBER		:= p_resp_id;
  l_user_id			NUMBER		:= p_user_id;
  l_login_id			NUMBER		:= p_login_id;
  l_org_id			NUMBER		:= p_org_id;

  l_request_id                  NUMBER          := p_request_id;
  l_request_number              VARCHAR2(64)    := p_request_number ;


  l_inventory_org_id		NUMBER		:= p_service_request_rec.inventory_org_id;
  l_return_status		VARCHAR2(1);
  l_request_conv_rec		Request_Conversion_Rec_Type;
  l_inventory_item_segments_tbl	FND_FLEX_EXT.SegmentArray;
  i				NUMBER := 0;		-- counter
  l_key_flex_code		VARCHAR2(30);
  l_inventory_item_id		NUMBER;
  l_request_rec			cs_servicerequest_pvt.service_request_rec_type;
  l_note_index                  BINARY_INTEGER;
  l_contact_index               BINARY_INTEGER;
  l_notes                       cs_servicerequest_pvt.notes_table;
  l_contacts                    cs_servicerequest_pvt.contacts_table;
  l_service_request_rec         service_request_rec_type DEFAULT p_service_request_rec;
  l_dummy			VARCHAR2(2000);
  p_passed_value	VARCHAR2(3);  --  2757488

  --siahmed for bug invocation_mode
  l_invocation_mode   VARCHAR2(51);

  -- Added for making call to private Create API which uses the private rec type -- anmukher -- 08/13/03
  l_sr_create_out_rec		CS_ServiceRequest_PVT.sr_create_out_rec_type;

  --------------------------------------------------------------------------
  -- Local Procedure Default_Request_Attributes
  -- Description:
  --   Default missing attributes that are in the Service Request record.
  --   If the parameter is not passed (i.e. its value is the corresponding
  --   constant defined to represent missing parameters), then the default
  --   value for that attribute is returned; otherwise, the passed value is
  --   returned.
  --   For service requests that are entered via the Internet, four special
  --   profile options are used: 'CS_DEFAULT_WEB_INC_ASSIGNEE',
  --   'CS_DEFAULT_WEB_INC_TYPE', 'CS_DEFAULT_WEB_INC_SEVERITY', and
  --   'CS_DEFAULT_WEB_INC_URGENCY'.
  -- Notes:
  --   No defaulting will be performed if the passed value is NULL
  --   (as opposed to FND_API.G_MISS_NUM).
  --   If the profile option returns NULL, the parameters are reset back to
  --   FND_API.G_MISS_... because we want to distinguish between NULL
  --   parameters and missing parameters.
  --------------------------------------------------------------------------
  PROCEDURE Default_Request_Attributes
  ( p_resp_appl_id		IN	NUMBER		:= NULL,
    p_resp_id			IN	NUMBER		:= NULL,
    p_user_id			IN	NUMBER		:= NULL,
    x_request_rec		IN OUT	NOCOPY cs_servicerequest_pvt.service_request_rec_type
  )
  IS
  BEGIN
    IF (x_request_rec.request_date = FND_API.G_MISS_DATE) THEN
      x_request_rec.request_date := SYSDATE;
    END IF;

    IF (x_request_rec.type_id = FND_API.G_MISS_NUM) THEN
      IF (NVL(x_request_rec.sr_creation_channel,'XXX') = 'WEB') THEN
          FND_PROFILE.Get('CS_DEFAULT_WEB_INC_TYPE', x_request_rec.type_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_DEFAULT_WEB_INC_TYPE :' || x_request_rec.type_id
	    );
	  END IF;
      ELSE
          FND_PROFILE.Get('INC_DEFAULT_INCIDENT_TYPE', x_request_rec.type_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile INC_DEFAULT_INCIDENT_TYPE :' || x_request_rec.type_id
	    );
	  END IF;
      END IF;
      IF (x_request_rec.type_id IS NULL) THEN
          x_request_rec.type_id := FND_API.G_MISS_NUM;
      END IF;
    END IF;

    IF (x_request_rec.status_id = FND_API.G_MISS_NUM) THEN
      x_request_rec.status_id := 1;	-- 'Open'
    END IF;

    IF (x_request_rec.severity_id = FND_API.G_MISS_NUM) THEN
      IF (NVL(x_request_rec.sr_creation_channel,'XXX') = 'WEB') THEN
          FND_PROFILE.Get('CS_DEFAULT_WEB_INC_SEVERITY', x_request_rec.severity_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_DEFAULT_WEB_INC_SEVERITY :' || x_request_rec.severity_id
	    );
	  END IF;
      ELSE
          FND_PROFILE.Get('INC_DEFAULT_INCIDENT_SEVERITY', x_request_rec.severity_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_DEFAULT_WEB_INC_SEVERITY :' || x_request_rec.severity_id
	    );
	  END IF;
      END IF;
      IF (x_request_rec.severity_id IS NULL) THEN
        x_request_rec.severity_id := FND_API.G_MISS_NUM;
      END IF;
    END IF;

    IF (x_request_rec.urgency_id = FND_API.G_MISS_NUM) THEN
      IF (NVL(x_request_rec.sr_creation_channel,'XXX') = 'WEB') THEN
          FND_PROFILE.Get('CS_DEFAULT_WEB_INC_URGENCY', x_request_rec.urgency_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_DEFAULT_WEB_INC_URGENCY :' || x_request_rec.urgency_id
	    );
	  END IF;
      ELSE
          FND_PROFILE.Get('INC_DEFAULT_INCIDENT_URGENCY', x_request_rec.urgency_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile INC_DEFAULT_INCIDENT_URGENCY :' || x_request_rec.urgency_id
	    );
	  END IF;
      END IF;
    END IF;

    IF (x_request_rec.owner_id = FND_API.G_MISS_NUM) THEN
      IF (NVL(x_request_rec.sr_creation_channel,'XXX') = 'WEB') THEN
         FND_PROFILE.Get('CS_DEFAULT_WEB_INC_ASSIGNEE', x_request_rec.owner_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_DEFAULT_WEB_INC_ASSIGNEE :' || x_request_rec.owner_id
	    );
	  END IF;
      ELSE
         FND_PROFILE.Get('INC_DEFAULT_INCIDENT_OWNER', x_request_rec.owner_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile INC_DEFAULT_INCIDENT_OWNER :' || x_request_rec.owner_id
	    );
	  END IF;
      END IF;

      IF (x_request_rec.owner_id IS NULL) THEN
		    x_request_rec.owner_id := FND_API.G_MISS_NUM;
      END IF;
    END IF;

    -- For bug 3751875 - defaulting the group owner
   IF (x_request_rec.owner_group_id = FND_API.G_MISS_NUM) THEN
      IF (NVL(x_request_rec.sr_creation_channel,'XXX') <> 'WEB') THEN
         FND_PROFILE.Get('CS_SR_DEFAULT_GROUP_OWNER', x_request_rec.owner_group_id);

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_SR_DEFAULT_GROUP_OWNER :' || x_request_rec.owner_group_id
	    );
	  END IF;
      END IF;
   END IF;

   -- Default the group type if not specified
    -- group type is based on owner group id
   IF (x_request_rec.group_type = FND_API.G_MISS_CHAR) then
     IF (x_request_rec.owner_group_id is NOT NULL and
         x_request_rec.owner_group_id <> FND_API.G_MISS_NUM) then
         x_request_rec.group_type := nvl( FND_PROFILE.value('CS_SR_DEFAULT_GROUP_TYPE'), 'RS_GROUP');

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_SR_DEFAULT_GROUP_TYPE :' || x_request_rec.group_type
	    );
	  END IF;
     END IF;
   END IF;

   -- end of change for bug 3751875

    -- Why default this ?
    -- Added extra check of IS NOT NULL for bug 2459001
/*   IF ( x_request_rec.verify_cp_flag <> FND_API.G_MISS_CHAR  OR
	 x_request_rec.verify_cp_flag IS NOT NULL ) THEN
--	 for  2757488 validating the verify_cp_flag
     IF ( x_request_rec.verify_cp_flag NOT IN ('Y','N'))  THEN
	       p_passed_value := x_request_rec.verify_cp_flag;
       IF (x_request_rec.customer_product_id <> FND_API.G_MISS_NUM) THEN
        x_request_rec.verify_cp_flag := 'Y';
       ELSE
        x_request_rec.verify_cp_flag := 'N';
       END IF;
         IF p_passed_value = FND_API.G_MISS_CHAR THEN
     	    p_passed_value := NULL;
	 END IF;
     CS_ServiceRequest_UTIL.Add_Cp_Flag_Ignored_Msg (p_token_an   => l_api_name_full,
					              p_token_ip   => p_passed_value,
						  p_token_pv	  => x_request_rec.verify_cp_flag);
      END IF;  */

      -- for bug 3333340
      p_passed_value := x_request_rec.verify_cp_flag;

      IF (x_request_rec.customer_product_id <> FND_API.G_MISS_NUM) THEN
        x_request_rec.verify_cp_flag := 'Y';
      ELSE
        x_request_rec.verify_cp_flag := 'N';
      END IF;

      if ( p_passed_value <> FND_API.G_MISS_CHAR) then
         if ( p_passed_value <> x_request_rec.verify_cp_flag) then
	     CS_ServiceRequest_UTIL.Add_Cp_Flag_Ignored_Msg (p_token_an   => l_api_name_full,
					                 p_token_ip   => p_passed_value,
						         p_token_pv   => x_request_rec.verify_cp_flag);
	 end if;
      end if;



  END Default_Request_Attributes;

  --------------------------------------------------------------------------
  -- Local Procedure Validate_Request_Attributes
  -- Description:
  --   Perform non-business-rule validation on all non-missing and defaulted
  --   attributes. Make sure all required parameters are passed in and not
  --   null.
  --
  --   When validation fails, FND_API.G_EXC_ERROR exception is raised to
  --   be handled by the API body.
  --------------------------------------------------------------------------
  PROCEDURE Validate_Request_Attributes
  ( p_api_name		IN	VARCHAR2,
    p_request_rec	IN	cs_servicerequest_pvt.service_request_rec_type
  )
  IS
 --for cmro_eam
  l_maintenance_flag    VARCHAR2(3);
  BEGIN
    -- Required parameters are request_date, type_id, status_id,
    -- severity_id, owner_id, summary, and the four flags.

    IF (p_request_rec.request_date IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'SR Request Date');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_request_rec.type_id = FND_API.G_MISS_NUM) THEN
      CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(p_api_name, 'SR Type');
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_request_rec.type_id IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'SR Type');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_request_rec.status_id IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'SR Status');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_request_rec.severity_id = FND_API.G_MISS_NUM) THEN
      CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(p_api_name, 'SR Severity');
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_request_rec.severity_id IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'SR Severity');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Summary could have been passed as NULL or FND_MISS_CHAR
    IF (p_request_rec.summary IS NULL)  OR
       (p_request_rec.summary = FND_API.G_MISS_CHAR)   THEN

       CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'SR Summary');
       RAISE FND_API.G_EXC_ERROR;

    END IF;


    -- CAller Type could have been passed as NULL or FND_MISS_CHAR
    IF (p_request_rec.caller_type IS NULL)  OR
       (p_request_rec.caller_type = FND_API.G_MISS_CHAR)       THEN
        CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name,
                                                     'SR Caller Type');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_request_rec.verify_cp_flag IS NULL) THEN
        CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'p_verify_cp_flag');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

 -- for cmro_eam
 begin
  select maintenance_flag into l_maintenance_flag
   from cs_incident_types_b where incident_type_id = p_request_rec.type_id
                                  and incident_subtype=G_SR_SUBTYPE;
 exception
   when no_data_found then
      l_maintenance_flag := NULL;
   when others then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 end;
   IF (l_maintenance_flag = 'Y' OR l_maintenance_flag = 'y') THEN
        IF (p_request_rec.inventory_org_id = FND_API.G_MISS_NUM) THEN
                CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(p_api_name, 'Inventory Org ID');
                RAISE FND_API.G_EXC_ERROR;
        ELSIF (p_request_rec.inventory_org_id IS NULL) THEN
                CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(p_api_name, 'Inventory Org ID');
                RAISE FND_API.G_EXC_ERROR;
        END IF;
   END IF;
   -- end for cmro_eam

  END Validate_Request_Attributes;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Create_ServiceRequest_PUB;

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
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
    Log_SR_PUB_Parameters
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
    , 'CS_SERVICEREQUEST_PUB.create_servicerequest'
    );
    FND_MSG_PUB.ADD_DETAIL
    ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.ITEM_SERIAL_NUMBER'
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- ------------------------------------------------------------------
  -- Default non-database attributes.
  -- This step is done because subsequent steps depend on these values.
  -- ------------------------------------------------------------------
  Default_Other_Attributes
    ( p_api_name             => l_api_name_full,
      p_resp_appl_id         => l_resp_appl_id,
      p_resp_id              => l_resp_id,
      p_user_id              => l_user_id,
      p_login_id             => l_login_id,
      p_org_id               => l_org_id,
      p_inventory_org_id     => l_inventory_org_id,
      p_return_status        => l_return_status
    );
  -- If any errors happen abort API.
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- ------------------------
  -- Convert values into IDs.
  -- ------------------------
  l_request_conv_rec.type_id   := l_service_request_rec.type_id;
  l_request_conv_rec.type_name := SUBSTRB(l_service_request_rec.type_name,1,30);
  l_request_conv_rec.status_id := l_service_request_rec.status_id;
  l_request_conv_rec.status_name := SUBSTRB(l_service_request_rec.status_name,1,30);
  l_request_conv_rec.severity_id := l_service_request_rec.severity_id;
  l_request_conv_rec.severity_name:= SUBSTRB(l_service_request_rec.severity_name, 1, 30);
  l_request_conv_rec.urgency_id             := l_service_request_rec.urgency_id;
  l_request_conv_rec.urgency_name           := SUBSTRB(l_service_request_rec.urgency_name, 1, 30);
  l_request_conv_rec.publish_flag           := SUBSTRB(l_service_request_rec.publish_flag, 1, 1);
  l_request_conv_rec.caller_type            := l_service_request_rec.caller_type;
  l_request_conv_rec.employee_id            := l_service_request_rec.employee_id;
  l_request_conv_rec.employee_number        := l_service_request_rec.employee_number;
  l_request_conv_rec.verify_cp_flag         := SUBSTRB(l_service_request_rec.verify_cp_flag, 1, 1);
  l_request_conv_rec.customer_product_id    := l_service_request_rec.customer_product_id;
  l_request_conv_rec.cp_ref_number          := l_service_request_rec.cp_ref_number;

  Convert_Request_Val_To_ID
    ( p_api_name		=> l_api_name_full,
      p_org_id			=> l_org_id,
      p_request_conv_rec	=> l_request_conv_rec,
      p_return_status           => l_return_status
    );
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- For Notes
  l_note_index := p_notes.FIRST;
  WHILE l_note_index IS NOT NULL LOOP
    l_notes(l_note_index).note                    := p_notes(l_note_index).note;
    l_notes(l_note_index).note_detail             := p_notes(l_note_index).note_detail;
    l_notes(l_note_index).note_type               := p_notes(l_note_index).note_type;
    l_notes(l_note_index).note_context_type_01    := p_notes(l_note_index).note_context_type_01;
    l_notes(l_note_index).note_context_type_id_01 := p_notes(l_note_index).note_context_type_id_01;
    l_notes(l_note_index).note_context_type_02    := p_notes(l_note_index).note_context_type_02;
    l_notes(l_note_index).note_context_type_id_02 := p_notes(l_note_index).note_context_type_id_02;
    l_notes(l_note_index).note_context_type_03    := p_notes(l_note_index).note_context_type_03;
    l_notes(l_note_index).note_context_type_id_03 := p_notes(l_note_index).note_context_type_id_03;
    l_note_index := p_notes.NEXT(l_note_index);
  END LOOP;

  -- For Contacts
  l_contact_index := p_contacts.FIRST;
  WHILE l_contact_index IS NOT NULL LOOP
    l_contacts(l_contact_index).sr_contact_point_id           := p_contacts(l_contact_index).sr_contact_point_id;
    l_contacts(l_contact_index).party_id            := p_contacts(l_contact_index).party_id;
    l_contacts(l_contact_index).contact_point_id    := p_contacts(l_contact_index).contact_point_id;
    l_contacts(l_contact_index).contact_point_type  := p_contacts(l_contact_index).contact_point_type;
    l_contacts(l_contact_index).primary_flag        := p_contacts(l_contact_index).primary_flag;
    l_contacts(l_contact_index).contact_type        := p_contacts(l_contact_index).contact_type;
    l_contacts(l_contact_index).party_role_code     := p_contacts(l_contact_index).party_role_code;
    l_contacts(l_contact_index).start_date_active   := p_contacts(l_contact_index).start_date_active;
    l_contacts(l_contact_index).end_date_active     := p_contacts(l_contact_index).end_date_active;

    l_contact_index := p_contacts.NEXT(l_contact_index);
  END LOOP;

  -- ---------------------------------------
  -- Convert Key flexfield segments into ID.
  -- ---------------------------------------

  /**************************************************************
   * Some notes on the System Items (Item Flexfield):		*
   *  Owner			: Oracle Inventory		*
   *  Flexfield Code		: MSTK				*
   *  Table Name		: MTL_SYSTEM_ITEMS		*
   *  Number of Columns		: 20				*
   *  Width of Columns		: 40				*
   *  Dynamic Inserts Possible	: No				*
   *  Unique ID Column		: INVENTORY_ITEM_ID		*
   *  Structure Column		: ORGANIZATION_ID		*
   * The System Items Flexfield supports only one structure	*
   * (default value is 101). AOL stores the set number in the	*
   * structure defining column instead of the structure number,	*
   * that's why the inventory org ID must be passed.		*
   **************************************************************/
  IF ((l_service_request_rec.inventory_item_segment1 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment1 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment1;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment2 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment2 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment2;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment3 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment3 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment3;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment4 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment4 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment4;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment5 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment5 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment5;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment6 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment6 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment6;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment7 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment7 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment7;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment8 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment8 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment8;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment9 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment9 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment9;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment10 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment10 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment10;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment11 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment11 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment11;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment12 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment12 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment12;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment13 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment13 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment13;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment14 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment14 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment14;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment15 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment15 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment15;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment16 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment16 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment16;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment17 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment17 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment17;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment18 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment18 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment18;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment19 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment19 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment19;
  END IF;
  IF ((l_service_request_rec.inventory_item_segment20 <> FND_API.G_MISS_CHAR) OR
      (l_service_request_rec.inventory_item_segment20 IS NULL)) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment20;
  END IF;

      FND_PROFILE.Get('CS_ID_FLEX_CODE', l_key_flex_code);

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
	  FND_LOG.String
	  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	  , 'The Value of profile CS_ID_FLEX_CODE :' || l_key_flex_code
	  );
	END IF;

  IF (l_key_flex_code IS NULL) THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('FND', 'PROFILES-CANNOT READ');
      FND_MESSAGE.Set_Token('OPTION', 'CS_ID_FLEX_CODE');
      FND_MESSAGE.Set_Token('ROUTINE', l_api_name_full);
      FND_MSG_PUB.Add;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Convert_Key_Flex_To_ID
    ( p_api_name               => l_api_name_full,
      p_application_short_name => 'INV',
      p_key_flex_code          => l_key_flex_code,
      p_structure_number       => 101,
      p_attribute_id           => l_service_request_rec.inventory_item_id,
      p_attribute_conc_segs    => l_service_request_rec.inventory_item_conc_segs,
      p_attribute_segments_tbl => l_inventory_item_segments_tbl,
      p_attribute_n_segments   => i,
      p_attribute_vals_or_ids  => l_service_request_rec.inventory_item_vals_or_ids,
      p_data_set               => l_inventory_org_id,
      p_resp_appl_id           => l_resp_appl_id,
      p_resp_id                => l_resp_id,
      p_user_id                => l_user_id,
      p_attribute_id_out       => l_inventory_item_id,
      p_return_status          => l_return_status
    );
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- ----------------------------------------
  -- Validate descriptive flexfield segments.
  -- ----------------------------------------
  -- this part of the code was not there
  --
  -- Validate the descriptive flexfields
  --
  IF NOT (( l_service_request_rec.request_context    = FND_API.G_MISS_CHAR)  AND
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

    IF (l_service_request_rec.request_context = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_context := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_1 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_1 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_2 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_2 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_3 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_3 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_4 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_4 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_5 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_5 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_6 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_6 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_7 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_7 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_8 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_8 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_9 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_9 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_10 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_10 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_11 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_11 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_12 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_12 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_13 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_13 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_14 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_14 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_15 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_15 := NULL;
    END IF;


  Cs_ServiceRequest_Util.Validate_Desc_Flex
    ( p_api_name               => l_api_name_full,
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
      p_resp_appl_id           => l_resp_appl_id,
      p_resp_id                => l_resp_id,
      p_return_status          => l_return_status
    );

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END IF;

  -- -------------------------------------------------------------------
  -- Validate the external descriptive flexfield segments.
  -- For ER# 2501166 added these external attributes date 1st oct 2002
  -- -------------------------------------------------------------------
  -- this part of the code was not there
  --
  -- Validate the external descriptive flexfields
  --
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

    IF (l_service_request_rec.external_context = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_context := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_1 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_1 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_2 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_2 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_3 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_3 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_4 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_4 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_5 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_5 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_6 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_6 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_7 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_7 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_8 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_8 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_9 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_9 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_10 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_10 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_11 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_11 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_12 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_12 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_13 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_13 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_14 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_14 := NULL;
    END IF;
    IF (l_service_request_rec.external_attribute_15 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.external_attribute_15 := NULL;
    END IF;

/************ Changed this call to CS_ServiceRequest_UTIL.Validate_External_Desc_Flex
              Bug # 5216510.

 Validate_external_Desc_Flex
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
     p_resp_appl_id             => l_resp_appl_id,
     p_resp_id                  => l_resp_id,
     p_return_status            => l_return_status
    );
*******************************************************************************/

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
     p_resp_appl_id             => l_resp_appl_id,
     p_resp_id                  => l_resp_id,
     p_return_status            => l_return_status);


  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END IF;

  -- -----------------------------------------
  -- Populate the l_request_rec record fields.
  -- -----------------------------------------
  CS_ServiceRequest_PVT.initialize_rec(l_request_rec);
  l_request_rec.request_date               := l_service_request_rec.request_date;
  l_request_rec.type_id                    := l_request_conv_rec.type_id;
  l_request_rec.status_id                  := l_request_conv_rec.status_id;
  l_request_rec.severity_id                := l_request_conv_rec.severity_id;
  l_request_rec.urgency_id                 := l_request_conv_rec.urgency_id;
  l_request_rec.closed_date                := l_service_request_rec.closed_date;
  l_request_rec.owner_id                   := l_service_request_rec.owner_id;
  l_request_rec.owner_group_id             := l_service_request_rec.owner_group_id;
  l_request_rec.publish_flag               := l_request_conv_rec.publish_flag;
  l_request_rec.summary                    := l_service_request_rec.summary;
  l_request_rec.caller_type                := l_service_request_rec.caller_type;
  l_request_rec.customer_id                := l_service_request_rec.customer_id;
  l_request_rec.customer_number            := l_service_request_rec.customer_number;
  l_request_rec.employee_id                := l_request_conv_rec.employee_id;
  l_request_rec.verify_cp_flag		   := l_request_conv_rec.verify_cp_flag;
  l_request_rec.customer_product_id	   := l_request_conv_rec.customer_product_id;
  l_request_rec.platform_id                := l_service_request_rec.platform_id;
  l_request_rec.platform_version	   := l_service_request_rec.platform_version;
  l_request_rec.db_version		   := l_service_request_rec.db_version;
  l_request_rec.platform_version_id        := l_service_request_rec.platform_version_id;
  l_request_rec.cp_component_id               := l_service_request_rec.cp_component_id;
  l_request_rec.cp_component_version_id       := l_service_request_rec.cp_component_version_id;
  l_request_rec.cp_subcomponent_id            := l_service_request_rec.cp_subcomponent_id;
  l_request_rec.cp_subcomponent_version_id    := l_service_request_rec.cp_subcomponent_version_id;
  l_request_rec.language_id                := l_service_request_rec.language_id;
  l_request_rec.language                   := l_service_request_rec.language;
  l_request_rec.inventory_item_id          := l_inventory_item_id;
  l_request_rec.inventory_org_id           := l_inventory_org_id;
  l_request_rec.current_serial_number      := l_service_request_rec.current_serial_number;
  l_request_rec.original_order_number      := l_service_request_rec.original_order_number;
  l_request_rec.purchase_order_num         := l_service_request_rec.purchase_order_num;
  l_request_rec.problem_code               := l_service_request_rec.problem_code;
  l_request_rec.exp_resolution_date        := l_service_request_rec.exp_resolution_date;
  l_request_rec.install_site_use_id        := l_service_request_rec.install_site_use_id;
  l_request_rec.request_attribute_1        := l_service_request_rec.request_attribute_1;
  l_request_rec.request_attribute_2        := l_service_request_rec.request_attribute_2;
  l_request_rec.request_attribute_3        := l_service_request_rec.request_attribute_3;
  l_request_rec.request_attribute_4        := l_service_request_rec.request_attribute_4;
  l_request_rec.request_attribute_5        := l_service_request_rec.request_attribute_5;
  l_request_rec.request_attribute_6        := l_service_request_rec.request_attribute_6;
  l_request_rec.request_attribute_7        := l_service_request_rec.request_attribute_7;
  l_request_rec.request_attribute_8        := l_service_request_rec.request_attribute_8;
  l_request_rec.request_attribute_9        := l_service_request_rec.request_attribute_9;
  l_request_rec.request_attribute_10       := l_service_request_rec.request_attribute_10;
  l_request_rec.request_attribute_11       := l_service_request_rec.request_attribute_11;
  l_request_rec.request_attribute_12       := l_service_request_rec.request_attribute_12;
  l_request_rec.request_attribute_13       := l_service_request_rec.request_attribute_13;
  l_request_rec.request_attribute_14       := l_service_request_rec.request_attribute_14;
  l_request_rec.request_attribute_15       := l_service_request_rec.request_attribute_15;
  l_request_rec.request_context            := l_service_request_rec.request_context;
  l_request_rec.bill_to_site_use_id        := l_service_request_rec.bill_to_site_use_id;
  l_request_rec.bill_to_contact_id         := l_service_request_rec.bill_to_contact_id;
  l_request_rec.ship_to_site_use_id        := l_service_request_rec.ship_to_site_use_id;
  l_request_rec.ship_to_contact_id         := l_service_request_rec.ship_to_contact_id;
  l_request_rec.resolution_code            := l_service_request_rec.resolution_code;
  l_request_rec.act_resolution_date        := l_service_request_rec.act_resolution_date;
  l_request_rec.public_comment_flag        := l_service_request_rec.public_comment_flag;
  l_request_rec.parent_interaction_id      := l_service_request_rec.parent_interaction_id;
  l_request_rec.contract_id        		   := l_service_request_rec.contract_id; -- for BUG 2776748
  l_request_rec.contract_service_id        := l_service_request_rec.contract_service_id;
  l_request_rec.qa_collection_plan_id      := l_service_request_rec.qa_collection_plan_id;
  l_request_rec.account_id                 := l_service_request_rec.account_id;
  l_request_rec.resource_type              := l_service_request_rec.resource_type;
  l_request_rec.resource_subtype_id        := l_service_request_rec.resource_subtype_id;
  l_request_rec.cust_po_number             := l_service_request_rec.cust_po_number;
  l_request_rec.cust_ticket_number         := l_service_request_rec.cust_ticket_number;
  l_request_rec.sr_creation_channel        := l_service_request_rec.sr_creation_channel;
  l_request_rec.obligation_date            := l_service_request_rec.obligation_date;
  l_request_rec.time_zone_id               := l_service_request_rec.time_zone_id;
  l_request_rec.time_difference            := l_service_request_rec.time_difference;
  l_request_rec.site_id                    := l_service_request_rec.site_id;
  l_request_rec.customer_site_id           := l_service_request_rec.customer_site_id;
  l_request_rec.territory_id               := l_service_request_rec.territory_id ;
  l_request_rec.cp_revision_id              := l_service_request_rec.cp_revision_id ;
  l_request_rec.inv_item_revision           := l_service_request_rec.inv_item_revision ;
  l_request_rec.inv_component_id            := l_service_request_rec.inv_component_id   ;
  l_request_rec.inv_component_version       := l_service_request_rec.inv_component_version ;
  l_request_rec.inv_subcomponent_id         := l_service_request_rec.inv_subcomponent_id  ;
  l_request_rec.inv_subcomponent_version    := l_service_request_rec.inv_subcomponent_version  ;
--- Fix for Bug# 2155981
  l_request_rec.project_number              := l_service_request_rec.project_number;
 ------Enhancements 11.5.6--------07/12/01
  l_request_rec.tier                        := l_service_request_rec.tier;

  l_request_rec.tier_version                := l_service_request_rec.tier_version;
  l_request_rec.operating_system            := l_service_request_rec.operating_system;
  l_request_rec.operating_system_version    := l_service_request_rec.operating_system_version;
  l_request_rec.database                    := l_service_request_rec.database;
  l_request_rec.cust_pref_lang_id           := l_service_request_rec.cust_pref_lang_id;
--Added for Post 11.5.6 Enhancement
  l_request_rec.cust_pref_lang_code         := l_service_request_rec.cust_pref_lang_code;
  l_request_rec.last_update_channel         := l_service_request_rec.last_update_channel;
------
  l_request_rec.category_id                 := l_service_request_rec.category_id;
  l_request_rec.group_type                  := l_service_request_rec.group_type;
  l_request_rec.group_territory_id          := l_service_request_rec.group_territory_id;
  l_request_rec.inv_platform_org_id         := l_service_request_rec.inv_platform_org_id;
  l_request_rec.product_revision            := l_service_request_rec.product_revision;
  l_request_rec.component_version           := l_service_request_rec.component_version;
  l_request_rec.subcomponent_version        := l_service_request_rec.subcomponent_version;
  l_request_rec.comm_pref_code              := l_service_request_rec.comm_pref_code;
  l_request_rec.category_set_id             := l_service_request_rec.category_set_id;
  l_request_rec.external_reference          := l_service_request_rec.external_reference;
  l_request_rec.system_id                   := l_service_request_rec.system_id;
  l_request_rec.created_by                  := l_service_request_rec.created_by;
  l_request_rec.creation_date               := l_service_request_rec.creation_date;

------jngeorge--------07/12/01
 l_request_rec.error_code                   :=  l_service_request_rec.error_code;
 l_request_rec.incident_occurred_date := l_service_request_rec.incident_occurred_date;
 l_request_rec.incident_resolved_date := l_service_request_rec.incident_resolved_date;
 l_request_rec.inc_responded_by_date := l_service_request_rec.inc_responded_by_date;

 l_request_rec.resolution_summary           := l_service_request_rec.resolution_summary ;
 l_request_rec.incident_location_id         := l_service_request_rec.incident_location_id ;
 l_request_rec.incident_address             := l_service_request_rec.incident_address ;
 l_request_rec.incident_city                := l_service_request_rec.incident_city;
 l_request_rec.incident_state               := l_service_request_rec.incident_state;
 l_request_rec.incident_country             := l_service_request_rec.incident_country;
 l_request_rec.incident_province            := l_service_request_rec.incident_province;
 l_request_rec.incident_postal_code         := l_service_request_rec.incident_postal_code;
 l_request_rec.incident_county              := l_service_request_rec.incident_county;
-- Added for Enh# 2216664
 l_request_rec.owner                        := l_service_request_rec.owner;
 l_request_rec.group_owner                  := l_service_request_rec.group_owner;

---- Added for Credit Card ER# 2255263 (UI ER#2208078)
   l_request_rec.cc_number                  := l_service_request_rec.cc_number;
   l_request_rec.cc_expiration_date         := l_service_request_rec.cc_expiration_date;
   l_request_rec.cc_type_code               := l_service_request_rec.cc_type_code;
   l_request_rec.cc_first_name              := l_service_request_rec.cc_first_name;
   l_request_rec.cc_last_name               := l_service_request_rec.cc_last_name;
   l_request_rec.cc_middle_name             := l_service_request_rec.cc_middle_name;
   l_request_rec.cc_id                      := l_service_request_rec.cc_id;

  ---For ER# 2501166 added these external attributes date 1st oct 2002

  l_request_rec.external_attribute_1        := l_service_request_rec.external_attribute_1;
  l_request_rec.external_attribute_2        := l_service_request_rec.external_attribute_2;
  l_request_rec.external_attribute_3        := l_service_request_rec.external_attribute_3;
  l_request_rec.external_attribute_4        := l_service_request_rec.external_attribute_4;
  l_request_rec.external_attribute_5        := l_service_request_rec.external_attribute_5;
  l_request_rec.external_attribute_6        := l_service_request_rec.external_attribute_6;
  l_request_rec.external_attribute_7        := l_service_request_rec.external_attribute_7;
  l_request_rec.external_attribute_8        := l_service_request_rec.external_attribute_8;
  l_request_rec.external_attribute_9        := l_service_request_rec.external_attribute_9;
  l_request_rec.external_attribute_10       := l_service_request_rec.external_attribute_10;
  l_request_rec.external_attribute_11       := l_service_request_rec.external_attribute_11;
  l_request_rec.external_attribute_12       := l_service_request_rec.external_attribute_12;
  l_request_rec.external_attribute_13       := l_service_request_rec.external_attribute_13;
  l_request_rec.external_attribute_14       := l_service_request_rec.external_attribute_14;
  l_request_rec.external_attribute_15       := l_service_request_rec.external_attribute_15;
  l_request_rec.external_context            := l_service_request_rec.external_context;
  --- Added following attributes for Misc. ERs.
  -- Removing the coverage type shijain 06dec 2002
  --l_request_rec.coverage_type               := l_service_request_rec.coverage_type;       -- ER# 2320056
  l_request_rec.customer_phone_id     	    := l_service_request_rec.customer_phone_id;   -- ER# 2463321
  l_request_rec.customer_email_id     	    := l_service_request_rec.customer_email_id;   -- ER# 2463321
  l_request_rec.bill_to_account_id          := l_service_request_rec.bill_to_account_id;  -- ER# 2433831
  l_request_rec.ship_to_account_id          := l_service_request_rec.ship_to_account_id;  -- ER# 2433831
  -- Added these for ER for source 1159, by shijain oct 11 2002
  l_request_rec.creation_program_code       := l_service_request_rec.creation_program_code;
  -- Bill_to_party, ship_to_party
  l_request_rec.bill_to_party_id            := l_service_request_rec.bill_to_party_id;
  l_request_rec.ship_to_party_id            := l_service_request_rec.ship_to_party_id;
  -- Conc request related fields
  l_request_rec.program_id                  := l_service_request_rec.program_id;
  l_request_rec.program_application_id      := l_service_request_rec.program_application_id;
  l_request_rec.conc_request_id             := l_service_request_rec.conc_request_id;
  l_request_rec.program_login_id            := l_service_request_rec.program_login_id;
  -- Bill_to_site, ship_to_site
  l_request_rec.bill_to_site_id             := l_service_request_rec.bill_to_site_id;
  l_request_rec.ship_to_site_id             := l_service_request_rec.ship_to_site_id;

  -- Added these address related columns for 11.5.9 by shijain 2002 dec 4th

  l_request_rec.incident_point_of_interest   := l_service_request_rec.incident_point_of_interest;
  l_request_rec.incident_cross_street        := l_service_request_rec.incident_cross_street;
  l_request_rec.incident_direction_qualifier := l_service_request_rec.incident_direction_qualifier;
  l_request_rec.incident_distance_qualifier  := l_service_request_rec.incident_distance_qualifier;
  l_request_rec.incident_distance_qual_uom   := l_service_request_rec.incident_distance_qual_uom;
  l_request_rec.incident_address2            := l_service_request_rec.incident_address2;
  l_request_rec.incident_address3            := l_service_request_rec.incident_address3;
  l_request_rec.incident_address4            := l_service_request_rec.incident_address4;
  l_request_rec.incident_address_style       := l_service_request_rec.incident_address_style;
  l_request_rec.incident_addr_lines_phonetic := l_service_request_rec.incident_addr_lines_phonetic;
  l_request_rec.incident_po_box_number       := l_service_request_rec.incident_po_box_number;
  l_request_rec.incident_house_number        := l_service_request_rec.incident_house_number;
  l_request_rec.incident_street_suffix       := l_service_request_rec.incident_street_suffix;
  l_request_rec.incident_street              := l_service_request_rec.incident_street;
  l_request_rec.incident_street_number       := l_service_request_rec.incident_street_number;
  l_request_rec.incident_floor               := l_service_request_rec.incident_floor;
  l_request_rec.incident_suite               := l_service_request_rec.incident_suite;
  l_request_rec.incident_postal_plus4_code   := l_service_request_rec.incident_postal_plus4_code;
  l_request_rec.incident_position            := l_service_request_rec.incident_position;
  l_request_rec.incident_location_directions := l_service_request_rec.incident_location_directions;
  l_request_rec.incident_location_description:= l_service_request_rec.incident_location_description;
  l_request_rec.install_site_id              := l_service_request_rec.install_site_id;

-- for cmro_eam
  l_request_rec.owning_dept_id     	     := l_service_request_rec.owning_department_id;

   -- Added for Misc ERs project of 11.5.10 --anmukher --08/26/03
  l_request_rec.incident_location_type       := l_service_request_rec.incident_location_type;

  -- Added on 09/09/03 - spusegao
  l_request_rec.coverage_type                := l_service_request_rec.coverage_type;
  l_request_rec.maint_organization_id        := l_service_request_rec.maint_organization_id;

  --12.1.2 Dev -- shramana
  l_request_rec.site_number		     := l_service_request_rec.site_number;
  l_request_rec.site_name		     := l_service_request_rec.site_name;
  l_request_rec.addressee	             := l_service_request_rec.addressee;
  /*Credit Card 9358401 */
  l_request_rec.instrument_payment_use_id  :=
                              l_service_request_rec.instrument_payment_use_id;


  -- ---------------------------
  -- Default missing attributes.
  -- ---------------------------
  Default_Request_Attributes
    ( p_resp_appl_id          => l_resp_appl_id,
      p_resp_id               => l_resp_id,
      p_user_id               => l_user_id,
      x_request_rec           => l_request_rec
    );
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- --------------------------------------------------
  -- Validate all non-missing and defaulted attributes.
  -- --------------------------------------------------
  Validate_Request_Attributes
    ( p_api_name      => l_api_name_full,
      p_request_rec   => l_request_rec
    );
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- ---------------------------------------------------------------------
  -- At this point, no attributes should be "missing" (value equivalent to
  -- the "missing" constants). All attributes that are not passed in by
  -- the caller should either be defaulted or initialized to NULLs,
  -- because when a parameter is missing it should be inserted as a NULL.
  -- ---------------------------------------------------------------------
  IF (l_request_rec.publish_flag = FND_API.G_MISS_CHAR) THEN
    l_request_rec.publish_flag := NULL;
  END IF;
  IF (l_request_rec.customer_id = FND_API.G_MISS_NUM) THEN
    l_request_rec.customer_id := NULL;
  END IF;
  IF (l_request_rec.customer_number = FND_API.G_MISS_CHAR) THEN
    l_request_rec.customer_number := NULL;
  END IF;
  IF (l_request_rec.employee_id = FND_API.G_MISS_NUM) THEN
    l_request_rec.employee_id := NULL;
  END IF;
  IF (l_request_rec.customer_product_id = FND_API.G_MISS_NUM) THEN
    l_request_rec.customer_product_id := NULL;
  END IF;
  IF (l_request_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
    l_request_rec.inventory_item_id := NULL;
  END IF;

  -- for bug 3333340 - raising an ignore message for the ib
  -- realted fields if the verify cp flag is N


  if (l_request_rec.verify_cp_flag = 'N') then

	if (l_request_rec.cp_component_id <> FND_API.G_MISS_NUM AND
	    l_request_rec.cp_component_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_component_id' );

		l_request_rec.cp_component_id := NULL;
	end if;

        if (l_request_rec.cp_component_version_id <> FND_API.G_MISS_NUM AND
	    l_request_rec.cp_component_version_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_component_version_id' );

		l_request_rec.cp_component_version_id := NULL;
	end if;

	if (l_request_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM AND
	    l_request_rec.cp_subcomponent_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_subcomponent_id' );

		l_request_rec.cp_subcomponent_id := NULL;
	end if;

	if (l_request_rec.cp_subcomponent_version_id <> FND_API.G_MISS_NUM AND
	    l_request_rec.cp_subcomponent_version_id IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_subcomponent_version_id' );

		l_request_rec.cp_subcomponent_version_id := NULL;
	end if;

	if (l_request_rec.cp_revision_id  <> FND_API.G_MISS_NUM AND
	    l_request_rec.cp_revision_id  IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_cp_revision_id' );

		l_request_rec.cp_revision_id := NULL;
	end if;

	if (l_request_rec.product_revision  <> FND_API.G_MISS_CHAR AND
	    l_request_rec.product_revision  IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_product_revision' );

		l_request_rec.product_revision := NULL;
	end if;

	if (l_request_rec.component_version <> FND_API.G_MISS_CHAR AND
	    l_request_rec.component_version IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_component_version' );

		l_request_rec.component_version := NULL;
	end if;

	if (l_request_rec.subcomponent_version <> FND_API.G_MISS_CHAR AND
	    l_request_rec.subcomponent_version IS NOT NULL) then
	        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_subcomponent_version' );

		l_request_rec.subcomponent_version := NULL;
	end if;
  end if;

  -- For bug 3541718 - ignore message for contract_number
  if ( l_service_request_rec.contract_service_number <> FND_API.G_MISS_CHAR AND
        l_service_request_rec.contract_service_number IS NOT NULL) then
	   CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_contract_number' );
  end if;
  -- ----------------------------------------------------------------------
  -- Perform business rule validation and the database operation by calling
  -- the Private API.
  -- ----------------------------------------------------------------------
  --Have passed p_commit parameter value from PUB to PVT, instead of
  --FALSE because the workflow process would fail if we pass FALSE to
  --the PVT API.

-- hardcoded the version 3.0 shijain nov 27 2002

  --siahmed bug fix for 9494021 where invocation mode is not being passed via public API
  l_invocation_mode:=FND_PROFILE.VALUE('CSM_HA_MODE');

  if ((l_invocation_mode <> 'HA_APPLY') OR (l_invocation_mode IS NULL) OR (l_invocation_mode = FND_API.G_MISS_CHAR)) THEN
      l_invocation_mode := 'NORMAL';
  ELSE
      l_invocation_mode := 'REPLAY';
  END IF;
 --siahmed end of bug fix

  CS_ServiceRequest_PVT.Create_ServiceRequest
    ( p_api_version                  => 4.0,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => p_commit,
      p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_resp_appl_id                 => l_resp_appl_id,
      p_resp_id                      => l_resp_id,
      p_user_id                      => l_user_id,
      p_login_id                     => l_login_id,
      p_org_id                       => l_org_id,
      p_request_id                   => l_request_id,
      p_request_number               => l_request_number,
      p_invocation_mode		     => l_invocation_mode,
      p_service_request_rec          => l_request_rec,
      p_notes                        => l_notes,
      p_contacts                     => l_contacts,
      p_auto_assign                  => p_auto_assign,
      -----------------anmukher----------------08/06/03
      -- Added for 11.5.10 projects
      p_auto_generate_tasks		=> p_auto_generate_tasks,
      p_default_contract_sla_ind	=> p_default_contract_sla_ind,
      p_default_coverage_template_id	=> p_default_coverage_template_id,
      -- OUT rec type to be used instead of individual OUT params
      x_sr_create_out_rec		=> l_sr_create_out_rec
      -- The following OUT params are now part of the OUT rec type
      -- x_request_id                   => x_request_id,
      -- x_request_number               => x_request_number,
      -- x_interaction_id	        => x_interaction_id,
      -- x_workflow_process_id          => x_workflow_process_id,
      -- These 3 parameters are added for Assignment Manager 115.9 changes.
      -- x_individual_owner             => x_individual_owner,
      -- x_group_owner                  => x_group_owner,
      -- x_individual_type              => x_individual_type
    );


  -- Assign the returned values to the OUT rec --anmukher -- 08/13/03
  x_sr_create_out_rec.request_id		:= l_sr_create_out_rec.request_id;
  x_sr_create_out_rec.request_number		:= l_sr_create_out_rec.request_number;
  x_sr_create_out_rec.interaction_id		:= l_sr_create_out_rec.interaction_id;
  x_sr_create_out_rec.workflow_process_id	:= l_sr_create_out_rec.workflow_process_id;
  x_sr_create_out_rec.individual_owner		:= l_sr_create_out_rec.individual_owner;
  x_sr_create_out_rec.group_owner		:= l_sr_create_out_rec.group_owner;
  x_sr_create_out_rec.individual_type		:= l_sr_create_out_rec.individual_type;
  x_sr_create_out_rec.auto_task_gen_status	:= l_sr_create_out_rec.auto_task_gen_status;
  x_sr_create_out_rec.auto_task_gen_attempted	:= l_sr_create_out_rec.auto_task_gen_attempted;
  x_sr_create_out_rec.field_service_task_created := l_sr_create_out_rec.field_service_task_created;
  x_sr_create_out_rec.contract_service_id	:= l_sr_create_out_rec.contract_service_id;
  x_sr_create_out_rec.resolve_by_date		:= l_sr_create_out_rec.resolve_by_date;
  x_sr_create_out_rec.respond_by_date		:= l_sr_create_out_rec.respond_by_date;
  x_sr_create_out_rec.resolved_on_date		:= l_sr_create_out_rec.resolved_on_date;
  x_sr_create_out_rec.responded_on_date		:= l_sr_create_out_rec.responded_on_date;

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_ServiceRequest_PUB;
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
-- Update_ServiceRequest
--------------------------------------------------------------------------
--  p_org_id                 IN     NUMBER        := NULL,

----------------anmukher---------------08/08/2003
-- Added overloaded SR Update API for backward compatibility with 11.5.9
-- This will call the 11.5.10 version of the API
PROCEDURE Update_ServiceRequest
(
  p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2      := FND_API.G_FALSE,
  p_commit                 IN     VARCHAR2      := FND_API.G_FALSE,
  x_return_status          OUT    NOCOPY VARCHAR2,
  x_msg_count              OUT    NOCOPY NUMBER,
  x_msg_data               OUT    NOCOPY VARCHAR2,
  p_request_id             IN     NUMBER        := NULL,
  p_request_number         IN     VARCHAR2      := NULL,
  p_audit_comments         IN     VARCHAR2      := NULL,
  p_object_version_number  IN     NUMBER,
  p_resp_appl_id           IN     NUMBER        := NULL,
  p_resp_id                IN     NUMBER        := NULL,
  p_last_updated_by        IN     NUMBER,
  p_last_update_login      IN     NUMBER         :=NULL,
  p_last_update_date       IN     DATE,
  p_service_request_rec    IN     service_request_rec_type,
  p_notes                  IN     notes_table,
  p_contacts               IN     contacts_table,
  p_called_by_workflow     IN     VARCHAR2      := FND_API.G_FALSE,
  p_workflow_process_id    IN     NUMBER        := NULL,
  p_default_contract_sla_ind    IN      VARCHAR2 Default 'N',
  x_workflow_process_id    OUT    NOCOPY NUMBER,
  x_interaction_id         OUT    NOCOPY NUMBER
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
  SAVEPOINT Update_ServiceRequest_PUB;

  -- Standard call to check for call compatibility
  -- Added the and condition for backward compatibility project, now
  -- both the version 2.0 and 3.0 are valid as this procedure can be called
  -- from both 1158 or 1159 env.

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  AND NOT FND_API.Compatible_API_Call(l_api_version_back, p_api_version, l_api_name, G_PKG_NAME) THEN
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
  END IF;

   -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Call 11.5.10 version of the Update SR API
  CS_ServiceRequest_PUB.Update_ServiceRequest
    ( p_api_version           => 4.0,
      p_init_msg_list	      => FND_API.G_FALSE,
      p_commit		      => p_commit,
      x_return_status	      => x_return_status,
      x_msg_count	      => x_msg_count,
      x_msg_data	      => x_msg_data,
      p_request_id	      => p_request_id,
      p_request_number	      => p_request_number,
      p_audit_comments	      => p_audit_comments,
      p_object_version_number => p_object_version_number,
      p_resp_appl_id          => p_resp_appl_id,
      p_resp_id               => p_resp_id,
      p_last_updated_by	      => p_last_updated_by,
      p_last_update_login     => p_last_update_login,
      p_last_update_date      => p_last_update_date,
      p_service_request_rec   => p_service_request_rec,
      p_notes                 => p_notes,
      p_contacts              => p_contacts,
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

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Update_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Update_ServiceRequest;

------------------------------
-- 11.5.10 Update API
------------------------------
-- Modification History
-- Date     Name     Description
----------- -------- -----------------------------------------------------------
-- 05/04/05 smisra   copied maint_organization_id to PVT API rec
--                   Removed passing of item_serial_number to PVT SR Rec
-- 03/08/05 smisra   Raised exception if item_serial_number is passed
-- 12/30/05 smisra   Bug 4773215.
--                   Removed raising error message when resource type is Null
--                   but owner id is not null
--                   Removed raising error message when sr creation channel
--                   is NULL
--------------------------------------------------------------------------------
PROCEDURE Update_ServiceRequest
(
  p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2      := FND_API.G_FALSE,
  p_commit                 IN     VARCHAR2      := FND_API.G_FALSE,
  x_return_status          OUT    NOCOPY VARCHAR2,
  x_msg_count              OUT    NOCOPY NUMBER,
  x_msg_data               OUT    NOCOPY VARCHAR2,
  p_request_id             IN     NUMBER        := NULL,
  p_request_number         IN     VARCHAR2      := NULL,
  p_audit_comments         IN     VARCHAR2      := NULL,
  p_object_version_number  IN     NUMBER,
  p_resp_appl_id           IN     NUMBER        := NULL,
  p_resp_id                IN     NUMBER        := NULL,
  p_last_updated_by        IN     NUMBER,
  p_last_update_login      IN     NUMBER         :=NULL,
  p_last_update_date       IN     DATE,
  p_service_request_rec    IN     service_request_rec_type,
  p_notes                  IN     notes_table,
  p_contacts               IN     contacts_table,
  p_called_by_workflow     IN     VARCHAR2      := FND_API.G_FALSE,
  p_workflow_process_id    IN     NUMBER        := NULL,
  -- Commented out since these are now part of the out rec type --anmukher--08/08/03
  -- x_workflow_process_id    	OUT NOCOPY NUMBER,
  -- x_interaction_id         	OUT NOCOPY NUMBER,
  ----------------anmukher--------------------08/08/03
  -- Added for 11.5.10 projects
  p_auto_assign		    	IN	VARCHAR2 Default 'N',
  p_validate_sr_closure	    	IN	VARCHAR2 Default 'N',
  p_auto_close_child_entities	IN	VARCHAR2 Default 'N',
  p_default_contract_sla_ind    IN      VARCHAR2 Default 'N',
  x_sr_update_out_rec		OUT NOCOPY	sr_update_out_rec_type
)
IS

-- changed the version from 3.0 to 4.0 anmukher aug 08 2003

  l_api_version	       CONSTANT	NUMBER		:= 4.0;
  l_api_version_back   CONSTANT	NUMBER		:= 3.0;
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Update_ServiceRequest';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);

  l_notes                       cs_servicerequest_pvt.notes_table;
  l_contacts                    cs_servicerequest_pvt.contacts_table;


  l_note_index                  BINARY_INTEGER;
  l_contact_index               BINARY_INTEGER;

  l_service_request_rec         service_request_rec_type DEFAULT p_service_request_rec;
  l_request_rec                 cs_servicerequest_pvt.service_request_rec_type;

  l_resp_appl_id		NUMBER		:= p_resp_appl_id;
  l_resp_id			NUMBER		:= p_resp_id;
  l_user_id			NUMBER		:= p_last_updated_by;
  l_login_id			NUMBER		:= p_last_update_login;
  l_org_id			NUMBER		;
  l_inventory_org_id		NUMBER := l_service_request_rec.inventory_org_id;

  l_inventory_item_id		NUMBER;
  l_update_desc_flex		VARCHAR2(1) := FND_API.G_FALSE;
  l_request_id			NUMBER;

  l_request_conv_rec		Request_Conversion_Rec_Type;
  l_inventory_item_segments_tbl	FND_FLEX_EXT.SegmentArray;
  i				NUMBER := 0;		-- counter
  l_key_flex_code		VARCHAR2(30);

  -- Added for making call to private Update API which uses the private rec type -- anmukher -- 08/13/03
  l_sr_update_out_rec		CS_ServiceRequest_PVT.sr_update_out_rec_type;

  --siahmed
  l_invocation_mode            VARCHAR2(51);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Update_ServiceRequest_PUB;

  -- Standard call to check for call compatibility
  -- Added the and condition for backward compatibility project, now
  -- both the version 2.0 and 3.0 are valid as this procedure can be called
  -- from both 1158 or 1159 env.

  --BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
  -- Support for previous version, 3.0, not required as overloaded procedure supports that version --anmukher --08/12/03
  -- AND NOT FND_API.Compatible_API_Call(l_api_version_back, p_api_version, l_api_name, G_PKG_NAME)
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
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
    Log_SR_PUB_Parameters
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
    , 'CS_SERVICEREQUEST_PUB.update_servicerequest'
    );
    FND_MSG_PUB.ADD_DETAIL
    ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.ITEM_SERIAL_NUMBER'
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- ------------------------------------------------------------
  -- First get the default information
  -- ------------------------------------------------------------
  Get_Default_Values(
		p_api_name		=>  l_api_name_full,
		p_org_id		=>  l_org_id,
		p_resp_appl_id		=>  l_resp_appl_id,
		p_resp_id		=>  l_resp_id,
		p_user_id		=>  l_user_id,
		p_login_id		=>  l_login_id,
		p_inventory_org_id	=>  l_inventory_org_id,
		p_request_id		=>  p_request_id,
		p_request_number	=>  p_request_number,
		p_request_id_out	=>  l_request_id,
		p_return_status		=>  l_return_status );

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    raise FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Convert values into IDs.  Note that we don't convert the customer
  -- name or number into customer_id here because we don't know if this
  -- is a verified or non-verified request.  The conversion will be
  -- done in the private API if necessary
  --
  l_request_conv_rec.type_id		        := l_service_request_rec.type_id;
  l_request_conv_rec.type_name	        := l_service_request_rec.type_name;
  l_request_conv_rec.status_id	        := l_service_request_rec.status_id;
  l_request_conv_rec.status_name	        := l_service_request_rec.status_name;
  l_request_conv_rec.severity_id	        := l_service_request_rec.severity_id;
  l_request_conv_rec.severity_name	        := l_service_request_rec.severity_name;
  l_request_conv_rec.urgency_id	        := l_service_request_rec.urgency_id;
  l_request_conv_rec.urgency_name	        := l_service_request_rec.urgency_name;
  l_request_conv_rec.publish_flag	        := substrb(l_service_request_rec.publish_flag, 1, 1);
  l_request_conv_rec.caller_type            := l_service_request_rec.caller_type;
  l_request_conv_rec.employee_id            := l_service_request_rec.employee_id;
  l_request_conv_rec.employee_number        := l_service_request_rec.employee_number;
  l_request_conv_rec.verify_cp_flag	   := substrb(l_service_request_rec.verify_cp_flag, 1, 1);
  l_request_conv_rec.customer_product_id   := l_service_request_rec.customer_product_id;
  l_request_conv_rec.cp_ref_number	        := l_service_request_rec.cp_ref_number;

  Convert_Request_Val_To_ID(
    p_api_name                => l_api_name_full,
    p_org_id                  => l_org_id,
    p_request_conv_rec        => l_request_conv_rec,
    p_return_status           => l_return_status
  );

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    raise FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- For Notes
  l_note_index := p_notes.FIRST;
  WHILE l_note_index IS NOT NULL LOOP
    l_notes(l_note_index).note                    := p_notes(l_note_index).note;
    l_notes(l_note_index).note_detail             := p_notes(l_note_index).note_detail;
    l_notes(l_note_index).note_type               := p_notes(l_note_index).note_type;
    l_notes(l_note_index).note_context_type_01    := p_notes(l_note_index).note_context_type_01;
    l_notes(l_note_index).note_context_type_id_01 := p_notes(l_note_index).note_context_type_id_01;
    l_notes(l_note_index).note_context_type_02    := p_notes(l_note_index).note_context_type_02;
    l_notes(l_note_index).note_context_type_id_02 := p_notes(l_note_index).note_context_type_id_02;
    l_notes(l_note_index).note_context_type_03    := p_notes(l_note_index).note_context_type_03;
    l_notes(l_note_index).note_context_type_id_03 := p_notes(l_note_index).note_context_type_id_03;
    l_note_index := p_notes.NEXT(l_note_index);
  END LOOP;


  -- For Contacts
  l_contact_index := p_contacts.FIRST;
  WHILE l_contact_index IS NOT NULL LOOP

    l_contacts(l_contact_index).sr_contact_point_id   := p_contacts(l_contact_index).sr_contact_point_id ;
    l_contacts(l_contact_index).party_id            := p_contacts(l_contact_index).party_id;
    l_contacts(l_contact_index).contact_point_id    := p_contacts(l_contact_index).contact_point_id;
    l_contacts(l_contact_index).contact_point_type  := p_contacts(l_contact_index).contact_point_type;
    l_contacts(l_contact_index).primary_flag        := p_contacts(l_contact_index).primary_flag;
    l_contacts(l_contact_index).contact_type        := p_contacts(l_contact_index).contact_type;
    l_contacts(l_contact_index).party_role_code     := p_contacts(l_contact_index).party_role_code;
    l_contacts(l_contact_index).start_date_active   := p_contacts(l_contact_index).start_date_active;
    l_contacts(l_contact_index).end_date_active     := p_contacts(l_contact_index).end_date_active;
    l_contact_index := p_contacts.NEXT(l_contact_index);
  END LOOP;


  --
  --cs_servicerequest_pvt.initialize_rec(l_request_rec);
  --

  --
  -- Make sure the caller does not set the required fields
  -- to NULL
  --
  IF (l_request_conv_rec.type_id IS NULL) THEN
    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_type_id' );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_request_conv_rec.status_id IS NULL) THEN
    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_status_id' );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_request_conv_rec.severity_id IS NULL) THEN
    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_severity_id' );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_service_request_rec.summary IS NULL) THEN
    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_summary' );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_request_conv_rec.verify_cp_flag IS NULL) THEN
    CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_verify_cp_flag' );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_service_request_rec.owner_id IS NULL THEN
        IF (l_service_request_rec.resource_type IS NOT NULL AND
            l_service_request_rec.resource_type <> FND_API.G_MISS_CHAR ) THEN

            CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
                          p_token_an        =>  l_api_name_full,
                          p_token_np        =>  'p_owner_id' );
            RAISE FND_API.G_EXC_ERROR;

        ELSIF l_service_request_rec.resource_type = FND_API.G_MISS_CHAR THEN
               l_service_request_rec.resource_type := NULL;
        END IF ;

  ELSIF l_service_request_rec.owner_id = FND_API.G_MISS_NUM THEN
         l_service_request_rec.resource_type := FND_API.G_MISS_CHAR;
  END IF ;

  IF (l_service_request_rec.owner_group_id IS NOT NULL AND
      l_service_request_rec.owner_group_id <> FND_API.G_MISS_NUM) THEN

     IF (l_service_request_rec.group_type IS NULL OR
         l_service_request_rec.group_type = FND_API.G_MISS_CHAR) THEN

                   CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
                          p_token_an        =>  l_api_name_full,
                          p_token_np        =>  'p_group_type' );

                   RAISE FND_API.G_EXC_ERROR;
     END IF ;

  ELSIF l_service_request_rec.owner_group_id IS NULL THEN
        IF (l_service_request_rec.group_type IS NOT NULL AND
            l_service_request_rec.group_type <> FND_API.G_MISS_CHAR) THEN
            CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
                          p_token_an        =>  l_api_name_full,
                          p_token_np        =>  'p_group_id' );

                   RAISE FND_API.G_EXC_ERROR;
        ELSIF l_service_request_rec.group_type = FND_API.G_MISS_CHAR THEN
               l_service_request_rec.group_type := NULL;
        END IF ;

  ELSIF l_service_request_rec.owner_group_id = FND_API.G_MISS_NUM THEN
         l_service_request_rec.group_type := FND_API.G_MISS_CHAR;
  END IF ;


/*
Check to see if a value is passed for Caller_Type as it is not updateable - for BUG 2754987 .
*/
IF (l_service_request_rec.caller_type <> FND_API.G_MISS_CHAR) THEN
CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_caller_type' );

END IF;
  --
  -- Validate Key Flexfields and get the inventory_item_id
  --
  IF (l_service_request_rec.inventory_item_segment1 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment1 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment1;
  END IF;
  IF (l_service_request_rec.inventory_item_segment2 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment2 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment2;
  END IF;
  IF (l_service_request_rec.inventory_item_segment3 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment3 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment3;
  END IF;
  IF (l_service_request_rec.inventory_item_segment4 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment4 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment4;
  END IF;
  IF (l_service_request_rec.inventory_item_segment5 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment5 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment5;
  END IF;
  IF (l_service_request_rec.inventory_item_segment6 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment6 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment6;
  END IF;
  IF (l_service_request_rec.inventory_item_segment7 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment7 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment7;
  END IF;
  IF (l_service_request_rec.inventory_item_segment8 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment8 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment8;
  END IF;
  IF (l_service_request_rec.inventory_item_segment9 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment9 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i)  := l_service_request_rec.inventory_item_segment9;
  END IF;
  IF (l_service_request_rec.inventory_item_segment10 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment10 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment10;
  END IF;
  IF (l_service_request_rec.inventory_item_segment11 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment11 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment11;
  END IF;
  IF (l_service_request_rec.inventory_item_segment12 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment12 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment12;
  END IF;
  IF (l_service_request_rec.inventory_item_segment13 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment13 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment13;
  END IF;
  IF (l_service_request_rec.inventory_item_segment14 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment14 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment14;
  END IF;
  IF (l_service_request_rec.inventory_item_segment15 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment15 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment15;
  END IF;
  IF (l_service_request_rec.inventory_item_segment16 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment16 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment16;
  END IF;
  IF (l_service_request_rec.inventory_item_segment17 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment17 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment17;
  END IF;
  IF (l_service_request_rec.inventory_item_segment18 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment18 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment18;
  END IF;
  IF (l_service_request_rec.inventory_item_segment19 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment19 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment19;
  END IF;
  IF (l_service_request_rec.inventory_item_segment20 <> FND_API.G_MISS_CHAR) OR
     (l_service_request_rec.inventory_item_segment20 IS NULL) THEN
    i := i + 1;
    l_inventory_item_segments_tbl(i) := l_service_request_rec.inventory_item_segment20;
  END IF;

  ---l_key_flex_code := FND_PROFILE.Value_Specific('CS_ID_FLEX_CODE', l_user_id, l_resp_id, l_resp_appl_id );

	 FND_PROFILE.Get('CS_ID_FLEX_CODE', l_key_flex_code) ;

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'The Value of profile CS_ID_FLEX_CODE :' || l_key_flex_code
	    );
	  END IF;


  IF l_key_flex_code IS NULL THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('FND', 'PROFILES-CANNOT READ');
      FND_MESSAGE.Set_Token('OPTION', 'CS_ID_FLEX_CODE');
      FND_MESSAGE.Set_Token('ROUTINE', l_api_name_full);
      FND_MSG_PUB.Add;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Convert_Key_Flex_To_ID
    ( p_api_name               => l_api_name_full,
      p_application_short_name => 'INV',
      p_key_flex_code          => l_key_flex_code,
      p_structure_number       => 101,
      p_attribute_id           => l_service_request_rec.inventory_item_id,
      p_attribute_conc_segs    => l_service_request_rec.inventory_item_conc_segs,
      p_attribute_segments_tbl => l_inventory_item_segments_tbl,
      p_attribute_n_segments   => i,
      p_attribute_vals_or_ids  => l_service_request_rec.inventory_item_vals_or_ids,
      p_data_set               => l_inventory_org_id,
      p_resp_appl_id           => l_resp_appl_id,
      p_resp_id                => l_resp_id,
      p_user_id                => l_user_id,
      p_attribute_id_out       => l_inventory_item_id,
      p_return_status          => l_return_status
    );
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    raise FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Validate the descriptive flexfields
  --
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
  /**** Transferred this portion to csvsrb.pls 01/23/04 smisra
  Reason: if g_miss values are passed to any segment then old value should be
  copied from service request record. Since old values are available in csvsrb.pls
  so code is moved there.

    IF (l_service_request_rec.request_context = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_context := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_1 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_1 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_2 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_2 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_3 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_3 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_4 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_4 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_5 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_5 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_6 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_6 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_7 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_7 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_8 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_8 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_9 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_9 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_10 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_10 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_11 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_11 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_12 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_12 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_13 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_13 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_14 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_14 := NULL;
    END IF;
    IF (l_service_request_rec.request_attribute_15 = FND_API.G_MISS_CHAR) THEN
      l_service_request_rec.request_attribute_15 := NULL;
    END IF;

    Validate_Desc_Flex(
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
      	p_resp_appl_id           => l_resp_appl_id,
      	p_resp_id                => l_resp_id,
      	p_return_status          => l_return_status );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ******/

    l_update_desc_flex := FND_API.G_TRUE;

  END IF;

  -- -------------------------------------------------------------------
  -- Validate the external descriptive flexfield segments.
  -- For ER# 2501166 added these external attributes date 1st oct 2002
  -- -------------------------------------------------------------------
  -- this part of the code was not there
  --
  -- Validate the external descriptive flexfields
  --
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

    l_update_desc_flex := FND_API.G_TRUE;

  END IF;

  -- -----------------------------------------
  -- Populate the l_request_rec record fields.
  -- -----------------------------------------
  CS_ServiceRequest_PVT.initialize_rec(l_request_rec);
  l_request_rec.request_date               := l_service_request_rec.request_date;
  l_request_rec.type_id                    := l_request_conv_rec.type_id;
  l_request_rec.status_id                  := l_request_conv_rec.status_id;
  l_request_rec.severity_id                := l_request_conv_rec.severity_id;
  l_request_rec.urgency_id                 := l_request_conv_rec.urgency_id;
  l_request_rec.closed_date                := l_service_request_rec.closed_date;
  l_request_rec.owner_id                   := l_service_request_rec.owner_id;
  l_request_rec.owner_group_id             := l_service_request_rec.owner_group_id;
  l_request_rec.publish_flag               := l_request_conv_rec.publish_flag;
  l_request_rec.summary                    := l_service_request_rec.summary;
  l_request_rec.caller_type                := l_service_request_rec.caller_type;
  l_request_rec.customer_id                := l_service_request_rec.customer_id;
  l_request_rec.customer_number            := l_service_request_rec.customer_number;

--   l_request_rec.customer_prefix            := l_service_request_rec.customer_prefix;
--   l_request_rec.customer_firstname         := l_service_request_rec.customer_firstname;
--   l_request_rec.customer_lastname          := l_service_request_rec.customer_lastname;
--   l_request_rec.customer_company_name      := l_service_request_rec.customer_company_name;

  l_request_rec.employee_id                := l_request_conv_rec.employee_id;
  l_request_rec.verify_cp_flag		   := l_request_conv_rec.verify_cp_flag;
  l_request_rec.customer_product_id	   := l_request_conv_rec.customer_product_id;
  l_request_rec.platform_id                := l_service_request_rec.platform_id;
  l_request_rec.platform_version           := l_service_request_rec.platform_version;
  l_request_rec.db_version                 := l_service_request_rec.db_version;
  l_request_rec.platform_version_id        := l_service_request_rec.platform_version_id;
  l_request_rec.cp_component_id               := l_service_request_rec.cp_component_id;
  l_request_rec.cp_component_version_id       := l_service_request_rec.cp_component_version_id;
  l_request_rec.cp_subcomponent_id            := l_service_request_rec.cp_subcomponent_id;
  l_request_rec.cp_subcomponent_version_id    := l_service_request_rec.cp_subcomponent_version_id;
  l_request_rec.language_id                := l_service_request_rec.language_id;
  l_request_rec.language                   := l_service_request_rec.language;
  l_request_rec.inventory_item_id          := l_inventory_item_id;
  l_request_rec.inventory_org_id           := l_inventory_org_id;
  l_request_rec.current_serial_number      := l_service_request_rec.current_serial_number;
  l_request_rec.original_order_number      := l_service_request_rec.original_order_number;
  l_request_rec.purchase_order_num         := l_service_request_rec.purchase_order_num;
  l_request_rec.problem_code               := l_service_request_rec.problem_code;
  l_request_rec.exp_resolution_date        := l_service_request_rec.exp_resolution_date;
  l_request_rec.install_site_use_id        := l_service_request_rec.install_site_use_id;

--   l_request_rec.install_location           := l_service_request_rec.install_location;
--   l_request_rec.install_customer           := l_service_request_rec.install_customer;
--   l_request_rec.install_country            := l_service_request_rec.install_country;
--   l_request_rec.install_address_1          := l_service_request_rec.install_address_1;
--   l_request_rec.install_address_2          := l_service_request_rec.install_address_2;
--   l_request_rec.install_address_3          := l_service_request_rec.install_address_3;


  l_request_rec.request_attribute_1        := l_service_request_rec.request_attribute_1;
  l_request_rec.request_attribute_2        := l_service_request_rec.request_attribute_2;
  l_request_rec.request_attribute_3        := l_service_request_rec.request_attribute_3;
  l_request_rec.request_attribute_4        := l_service_request_rec.request_attribute_4;
  l_request_rec.request_attribute_5        := l_service_request_rec.request_attribute_5;
  l_request_rec.request_attribute_6        := l_service_request_rec.request_attribute_6;
  l_request_rec.request_attribute_7        := l_service_request_rec.request_attribute_7;
  l_request_rec.request_attribute_8        := l_service_request_rec.request_attribute_8;
  l_request_rec.request_attribute_9        := l_service_request_rec.request_attribute_9;
  l_request_rec.request_attribute_10       := l_service_request_rec.request_attribute_10;
  l_request_rec.request_attribute_11       := l_service_request_rec.request_attribute_11;
  l_request_rec.request_attribute_12       := l_service_request_rec.request_attribute_12;
  l_request_rec.request_attribute_13       := l_service_request_rec.request_attribute_13;
  l_request_rec.request_attribute_14       := l_service_request_rec.request_attribute_14;
  l_request_rec.request_attribute_15       := l_service_request_rec.request_attribute_15;
  l_request_rec.request_context            := l_service_request_rec.request_context;
  l_request_rec.bill_to_site_use_id        := l_service_request_rec.bill_to_site_use_id;
  l_request_rec.bill_to_contact_id         := l_service_request_rec.bill_to_contact_id;

--   l_request_rec.bill_to_location           := l_service_request_rec.bill_to_location;
--   l_request_rec.bill_to_customer           := l_service_request_rec.bill_to_customer;
--   l_request_rec.bill_country               := l_service_request_rec.bill_country;
--   l_request_rec.bill_to_address_1          := l_service_request_rec.bill_to_address_1;
--   l_request_rec.bill_to_address_2          := l_service_request_rec.bill_to_address_2;
--   l_request_rec.bill_to_address_3          := l_service_request_rec.bill_to_address_3;
--   l_request_rec.bill_to_contact            := l_service_request_rec.bill_to_contact;


  l_request_rec.ship_to_site_use_id        := l_service_request_rec.ship_to_site_use_id;
  l_request_rec.ship_to_contact_id         := l_service_request_rec.ship_to_contact_id;

--   l_request_rec.ship_to_location           := l_service_request_rec.ship_to_location;
--   l_request_rec.ship_to_customer           := l_service_request_rec.ship_to_customer;
--   l_request_rec.ship_country               := l_service_request_rec.ship_country;
--   l_request_rec.ship_to_address_1          := l_service_request_rec.ship_to_address_1;
--   l_request_rec.ship_to_address_2          := l_service_request_rec.ship_to_address_2;
--  l_request_rec.ship_to_address_3          := l_service_request_rec.ship_to_address_3;
--   l_request_rec.ship_to_contact            := l_service_request_rec.ship_to_contact;


  l_request_rec.resolution_code            := l_service_request_rec.resolution_code;
  l_request_rec.act_resolution_date        := l_service_request_rec.act_resolution_date;
  l_request_rec.public_comment_flag        := l_service_request_rec.public_comment_flag;
  l_request_rec.parent_interaction_id      := l_service_request_rec.parent_interaction_id;
  l_request_rec.contract_id        		   := l_service_request_rec.contract_id;  -- for BUG 2776748
  l_request_rec.contract_service_id        := l_service_request_rec.contract_service_id;
  l_request_rec.qa_collection_plan_id      := l_service_request_rec.qa_collection_plan_id;
  l_request_rec.account_id                 := l_service_request_rec.account_id;
  l_request_rec.resource_type              := l_service_request_rec.resource_type;
  l_request_rec.resource_subtype_id        := l_service_request_rec.resource_subtype_id;
  l_request_rec.cust_po_number             := l_service_request_rec.cust_po_number;
  l_request_rec.cust_ticket_number         := l_service_request_rec.cust_ticket_number;
  l_request_rec.sr_creation_channel        := l_service_request_rec.sr_creation_channel;
  l_request_rec.obligation_date            := l_service_request_rec.obligation_date;
  l_request_rec.time_zone_id               := l_service_request_rec.time_zone_id;
  l_request_rec.time_difference            := l_service_request_rec.time_difference;
  l_request_rec.site_id                    := l_service_request_rec.site_id;
  l_request_rec.customer_site_id           := l_service_request_rec.customer_site_id;
  l_request_rec.territory_id               := l_service_request_rec.territory_id ;

  l_request_rec.cp_revision_id              := l_service_request_rec.cp_revision_id ;
  l_request_rec.inv_item_revision           := l_service_request_rec.inv_item_revision ;
  l_request_rec.inv_component_id            := l_service_request_rec.inv_component_id   ;
  l_request_rec.inv_component_version       := l_service_request_rec.inv_component_version ;
  l_request_rec.inv_subcomponent_id         := l_service_request_rec.inv_subcomponent_id  ;
  l_request_rec.inv_subcomponent_version    := l_service_request_rec.inv_subcomponent_version  ;
-- Fix for Bug# 2155981
  l_request_rec.project_number              := l_service_request_rec.project_number;

--------Enhancements 11.5.6------------07/12/01
  l_request_rec.tier                        := l_service_request_rec.tier  ;
  l_request_rec.tier_version                := l_service_request_rec.tier_version  ;
  l_request_rec.operating_system            := l_service_request_rec.operating_system  ;
  l_request_rec.operating_system_version    := l_service_request_rec.operating_system_version  ;
  l_request_rec.database                    := l_service_request_rec.database  ;
  l_request_rec.cust_pref_lang_id           := l_service_request_rec.cust_pref_lang_id  ;
--Added for Post 11.5.6 Enhancement
  l_request_rec.cust_pref_lang_code         := l_service_request_rec.cust_pref_lang_code;
  l_request_rec.last_update_channel         := l_service_request_rec.last_update_channel;
------
  l_request_rec.category_id                 := l_service_request_rec.category_id;
  l_request_rec.group_type                  := l_service_request_rec.group_type;
  l_request_rec.group_territory_id          := l_service_request_rec.group_territory_id;
  l_request_rec.inv_platform_org_id         := l_service_request_rec.inv_platform_org_id;
  l_request_rec.product_revision            := l_service_request_rec.product_revision;
  l_request_rec.component_version           := l_service_request_rec.component_version;
  l_request_rec.subcomponent_version        := l_service_request_rec.subcomponent_version;
  l_request_rec.comm_pref_code              := l_service_request_rec.comm_pref_code;
  l_request_rec.category_set_id             := l_service_request_rec.category_set_id;
  l_request_rec.external_reference          := l_service_request_rec.external_reference;
  l_request_rec.system_id                   := l_service_request_rec.system_id;

-------jngeorge-----------07/12/01
 l_request_rec.error_code                   :=  l_service_request_rec.error_code;
 l_request_rec.incident_occurred_date       := l_service_request_rec.incident_occurred_date;
 l_request_rec.incident_resolved_date       := l_service_request_rec.incident_resolved_date;
 l_request_rec.inc_responded_by_date        := l_service_request_rec.inc_responded_by_date;
 l_request_rec.resolution_summary           := l_service_request_rec.resolution_summary ;
 l_request_rec.incident_location_id         := l_service_request_rec.incident_location_id ;
 l_request_rec.incident_address             := l_service_request_rec.incident_address ;
 l_request_rec.incident_city                := l_service_request_rec.incident_city;
 l_request_rec.incident_state               := l_service_request_rec.incident_state;
 l_request_rec.incident_country             := l_service_request_rec.incident_country;
 l_request_rec.incident_province            := l_service_request_rec.incident_province;
 l_request_rec.incident_postal_code         := l_service_request_rec.incident_postal_code;
 l_request_rec.incident_county              := l_service_request_rec.incident_county;
-- Added for Enh# 2216664
 l_request_rec.owner                        := l_service_request_rec.owner;
 l_request_rec.group_owner                  := l_service_request_rec.group_owner;

---- Added for Credit Card ER# 2255263 (UI ER#2208078)
   l_request_rec.cc_number                  := l_service_request_rec.cc_number;
   l_request_rec.cc_expiration_date         := l_service_request_rec.cc_expiration_date;
   l_request_rec.cc_type_code               := l_service_request_rec.cc_type_code;
   l_request_rec.cc_first_name              := l_service_request_rec.cc_first_name;
   l_request_rec.cc_last_name               := l_service_request_rec.cc_last_name;
   l_request_rec.cc_middle_name             := l_service_request_rec.cc_middle_name;
   l_request_rec.cc_id                      := l_service_request_rec.cc_id;

   ---For ER# 2501166 added these external attributes date 1st oct 2002

  l_request_rec.external_attribute_1        := l_service_request_rec.external_attribute_1;
  l_request_rec.external_attribute_2        := l_service_request_rec.external_attribute_2;
  l_request_rec.external_attribute_3        := l_service_request_rec.external_attribute_3;
  l_request_rec.external_attribute_4        := l_service_request_rec.external_attribute_4;
  l_request_rec.external_attribute_5        := l_service_request_rec.external_attribute_5;
  l_request_rec.external_attribute_6        := l_service_request_rec.external_attribute_6;
  l_request_rec.external_attribute_7        := l_service_request_rec.external_attribute_7;
  l_request_rec.external_attribute_8        := l_service_request_rec.external_attribute_8;
  l_request_rec.external_attribute_9        := l_service_request_rec.external_attribute_9;
  l_request_rec.external_attribute_10       := l_service_request_rec.external_attribute_10;
  l_request_rec.external_attribute_11       := l_service_request_rec.external_attribute_11;
  l_request_rec.external_attribute_12       := l_service_request_rec.external_attribute_12;
  l_request_rec.external_attribute_13       := l_service_request_rec.external_attribute_13;
  l_request_rec.external_attribute_14       := l_service_request_rec.external_attribute_14;
  l_request_rec.external_attribute_15       := l_service_request_rec.external_attribute_15;
  l_request_rec.external_context            := l_service_request_rec.external_context;
  --- Added following attributes for Misc. ERs.
  -- Removing the coverage type shijain 06dec 2002
  -- l_request_rec.coverage_type               := l_service_request_rec.coverage_type;       -- ER# 2320056
  l_request_rec.bill_to_account_id          := l_service_request_rec.bill_to_account_id;  -- ER# 2433831
  l_request_rec.ship_to_account_id          := l_service_request_rec.ship_to_account_id;  -- ER# 2433831
  l_request_rec.customer_phone_id    	    := l_service_request_rec.customer_phone_id;   -- ER# 2463321
  l_request_rec.customer_email_id    	    := l_service_request_rec.customer_email_id;   -- ER# 2463321
  -- Added for ER for source for 1159 by shijain oct 11 2002
  l_request_rec.last_update_program_code    := l_service_request_rec.last_update_program_code;
  -- Bill_to_party, ship_to_party
  l_request_rec.bill_to_party_id            := l_service_request_rec.bill_to_party_id;
  l_request_rec.ship_to_party_id            := l_service_request_rec.ship_to_party_id;
  -- Conc request related fields
  l_request_rec.program_id                  := l_service_request_rec.program_id;
  l_request_rec.program_application_id      := l_service_request_rec.program_application_id;
  l_request_rec.conc_request_id             := l_service_request_rec.conc_request_id;
  l_request_rec.program_login_id            := l_service_request_rec.program_login_id;
  -- Bill_to_site, ship_to_site
  l_request_rec.bill_to_site_id             := l_service_request_rec.bill_to_site_id;
  l_request_rec.ship_to_site_id             := l_service_request_rec.ship_to_site_id;
   -- Added these address related columns for 11.5.9 by shijain 2002 dec 4th

  l_request_rec.incident_point_of_interest  := l_service_request_rec.incident_point_of_interest;
  l_request_rec.incident_cross_street       := l_service_request_rec.incident_cross_street;
  l_request_rec.incident_direction_qualifier:= l_service_request_rec.incident_direction_qualifier;
  l_request_rec.incident_distance_qualifier := l_service_request_rec.incident_distance_qualifier;
  l_request_rec.incident_distance_qual_uom  := l_service_request_rec.incident_distance_qual_uom;
  l_request_rec.incident_address2           := l_service_request_rec.incident_address2;
  l_request_rec.incident_address3           := l_service_request_rec.incident_address3;
  l_request_rec.incident_address4           := l_service_request_rec.incident_address4;
  l_request_rec.incident_address_style      := l_service_request_rec.incident_address_style;
  l_request_rec.incident_addr_lines_phonetic:= l_service_request_rec.incident_addr_lines_phonetic;
  l_request_rec.incident_po_box_number      := l_service_request_rec.incident_po_box_number;
  l_request_rec.incident_house_number       := l_service_request_rec.incident_house_number;
  l_request_rec.incident_street_suffix      := l_service_request_rec.incident_street_suffix;
  l_request_rec.incident_street             := l_service_request_rec.incident_street;
  l_request_rec.incident_street_number      := l_service_request_rec.incident_street_number;
  l_request_rec.incident_floor              := l_service_request_rec.incident_floor;
  l_request_rec.incident_suite              := l_service_request_rec.incident_suite;
  l_request_rec.incident_postal_plus4_code  := l_service_request_rec.incident_postal_plus4_code;
  l_request_rec.incident_position           := l_service_request_rec.incident_position;
  l_request_rec.incident_location_directions:= l_service_request_rec.incident_location_directions;
  l_request_rec.incident_location_description:= l_service_request_rec.incident_location_description;
  l_request_rec.install_site_id             := l_service_request_rec.install_site_id;
  -- Added incident_location_type for Misc ER project (11.5.10) --anmukher --08/29/03
  l_request_rec.incident_location_type      := l_service_request_rec.incident_location_type;
  l_request_rec.coverage_type               := l_service_request_rec.coverage_type;
  -- cmro_eam
  l_request_rec.owning_dept_id              := l_service_request_rec.owning_department_id;
  l_request_rec.maint_organization_id       := l_service_request_rec.maint_organization_id;
  --12.1.2 Dev
  l_request_rec.site_number		     := l_service_request_rec.site_number;
  l_request_rec.site_name		     := l_service_request_rec.site_name;
  l_request_rec.addressee	             := l_service_request_rec.addressee;

   /*Credit Card 9358401 */
  l_request_rec.instrument_payment_use_id :=
                              l_service_request_rec.instrument_payment_use_id;

  --
  -- Perform business rule validation and the database operation
  -- by calling the Private API.
  --
  --      p_org_id		      => l_org_id,

  --Have passed p_commit parameter value from PUB to PVT, instead of
  --FALSE because the workflow process would fail if we pass FALSE to
  --the PVT API.

-- hardcoded the version 4.0 anmukher aug 11 2003

-- For bug 3474365 - passed l_resp_id

   --siahmed bug fix for 9494021 where invocation mode is not being passed via public API
  l_invocation_mode:=FND_PROFILE.VALUE('CSM_HA_MODE');

  if ((l_invocation_mode <> 'HA_APPLY') OR (l_invocation_mode IS NULL) OR (l_invocation_mode = FND_API.G_MISS_CHAR)) THEN
      l_invocation_mode := 'NORMAL';
  ELSE
      l_invocation_mode := 'REPLAY';
  END IF;
 --siahmed end of bug fix

  CS_ServiceRequest_PVT.Update_ServiceRequest
    ( p_api_version           => 4.0,
      p_init_msg_list	      => FND_API.G_FALSE,
      p_commit		      => p_commit,
      p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
      x_return_status	      => x_return_status,
      x_msg_count	      => x_msg_count,
      x_msg_data	      => x_msg_data,
      p_request_id	      => l_request_id,
      p_object_version_number => p_object_version_number,
      p_resp_appl_id          => p_resp_appl_id,
      p_resp_id               => l_resp_id,
      p_last_updated_by	      => l_user_id,
      p_last_update_login     => l_login_id,
      p_last_update_date      => p_last_update_date,
      p_service_request_rec   => l_request_rec,
      p_invocation_mode       => l_invocation_mode,
      p_update_desc_flex      => l_update_desc_flex,
      p_notes                 => l_notes,
      p_contacts              => l_contacts,
      p_audit_comments        => p_audit_comments,
      p_called_by_workflow    => p_called_by_workflow,
      p_workflow_process_id   => p_workflow_process_id,
      -- x_workflow_process_id   => x_sr_update_out_rec.workflow_process_id,
      -- x_interaction_id	 => x_sr_update_out_rec.interaction_id
      -- Added for 11.5.10
      p_auto_assign	      => p_auto_assign,
      p_validate_sr_closure   => p_validate_sr_closure,
      p_auto_close_child_entities => p_auto_close_child_entities,
      p_default_contract_sla_ind  => p_default_contract_sla_ind,
      x_sr_update_out_rec     => l_sr_update_out_rec
    );

  -- Assign returned values to OUT rec
  x_sr_update_out_rec.interaction_id		:= l_sr_update_out_rec.interaction_id;
  x_sr_update_out_rec.workflow_process_id	:= l_sr_update_out_rec.workflow_process_id;
  x_sr_update_out_rec.individual_owner		:= l_sr_update_out_rec.individual_owner;
  x_sr_update_out_rec.group_owner		:= l_sr_update_out_rec.group_owner;
  x_sr_update_out_rec.individual_type		:= l_sr_update_out_rec.individual_type;
  x_sr_update_out_rec.resolved_on_date		:= l_sr_update_out_rec.resolved_on_date;
  x_sr_update_out_rec.responded_on_date		:= l_sr_update_out_rec.responded_on_date;
  x_sr_update_out_rec.status_id                 := l_sr_update_out_rec.status_id;
  x_sr_update_out_rec.close_date                := l_sr_update_out_rec.close_date;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    raise FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Update_ServiceRequest_PUB;
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

PROCEDURE Update_Status
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		IN	NUMBER   := NULL,
  p_user_id		IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_status_id		IN	NUMBER   := NULL,
  p_status		IN	VARCHAR2 := NULL,
  p_closed_date		IN	DATE     := FND_API.G_MISS_DATE,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_called_by_workflow	IN	VARCHAR2 := FND_API.G_FALSE,
  p_workflow_process_id	IN	NUMBER   := NULL,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  -- for bug 3326813
  p_validate_sr_closure           IN          VARCHAR2 Default 'N',
  p_auto_close_child_entities     IN          VARCHAR2 Default 'N',
  x_interaction_id	OUT	NOCOPY NUMBER
)
IS
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Update_Status';
  l_api_version	       CONSTANT	NUMBER		:= 2.0;
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
  l_return_status		VARCHAR2(1);
  l_resp_appl_id		NUMBER		:= p_resp_appl_id;
  l_resp_id			NUMBER		:= p_resp_id;
  l_user_id			NUMBER		:= p_user_id;
  l_login_id			NUMBER		:= p_login_id;
  l_org_id			NUMBER		;
  l_dummy_id			NUMBER		:= NULL;
  l_request_id			NUMBER;
  l_status_id			NUMBER;
  l_public_comment_flag		VARCHAR2(1) := p_public_comment_flag;

BEGIN
    -- ---------------------------------------
    -- Standard API stuff
    -- ---------------------------------------

    -- Establish savepoint
    SAVEPOINT Update_Status_PUB;

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
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
    , 'P_user_id:' || P_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_login_id:' || P_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_status_id:' || P_status_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_status:' || P_status
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
    , 'p_request_number:' || p_request_number
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

    -- ------------------------------------------------------------
    -- First get the default information
    -- ------------------------------------------------------------
    Get_Default_Values(
		p_api_name		=>  l_api_name_full,
		p_org_id		=>  l_org_id,
		p_resp_appl_id		=>  l_resp_appl_id,
		p_resp_id		=>  l_resp_id,
		p_user_id		=>  l_user_id,
		p_login_id		=>  l_login_id,
		p_inventory_org_id	=>  l_dummy_id,
		p_request_id		=>  p_request_id,
		p_request_number	=>  p_request_number,
		p_request_id_out	=>  l_request_id,
		p_return_status		=>  l_return_status );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- -------------------------------------------------------
    -- Make sure that either status or status ID is passed in
    -- -------------------------------------------------------
    IF (p_status_id IS NULL) THEN
      IF (p_status IS NULL) THEN

        CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_status_id' );
        RAISE FND_API.G_EXC_ERROR;

      ELSE

        CS_ServiceRequest_UTIL.Convert_Status_To_ID(
		p_api_name	 =>  l_api_name_full,
		p_parameter_name => 'p_status',
		p_status_name    =>  p_status,
		p_subtype	 =>  G_SR_Subtype,
		p_status_id	 =>  l_status_id,
		x_return_status  =>  l_return_status
	 );
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          raise FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;

    ELSE
      l_status_id := p_status_id;
      IF (p_status IS NOT NULL) THEN
	CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_ip	=>  'p_status' );
      END IF;
    END IF;

    -- Convert the public comment flag
    IF (p_public_comment_flag = FND_API.G_FALSE) THEN
      l_public_comment_flag := 'N';
    ELSIF (p_public_comment_flag = FND_API.G_TRUE) THEN
      l_public_comment_flag := 'Y';
    ELSIF (p_public_comment_flag IS NOT NULL) THEN
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(l_api_name_full,
        p_public_comment_flag, 'p_public_comment_flag');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- -------------------------------------------
    -- Call the private API to update the status
    -- -------------------------------------------
    CS_ServiceRequest_PVT.Update_Status (
          p_api_version                =>  2.0,
          p_init_msg_list              =>  FND_API.G_FALSE,
          p_commit                     =>  FND_API.G_FALSE,
          p_resp_id                    => p_resp_id,
          p_validation_level           =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status              =>  l_return_status,
          x_msg_count                  =>  x_msg_count,
          x_msg_data                   =>  x_msg_data,
          p_request_id                 =>  l_request_id,
          p_object_version_number      => p_object_version_number,
          p_status_id                  =>  l_status_id,
          p_closed_date                =>  p_closed_date,
          p_last_updated_by            =>  l_user_id,
          p_last_update_login          =>  l_login_id,
          p_last_update_date           =>  sysdate,
          p_audit_comments             =>  p_audit_comments,
          p_called_by_workflow         =>  p_called_by_workflow,
          p_comments                   =>  p_comments,
          p_public_comment_flag        =>  l_public_comment_flag,
          x_interaction_id             =>  x_interaction_id,
	  -- for bug 3326813
	  p_validate_sr_closure        =>  p_validate_sr_closure,
          p_auto_close_child_entities  =>  p_auto_close_child_entities);

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- -----------------------------
    -- Commit, if requested
    -- -----------------------------
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count 	=> x_msg_count,
			       p_data	=> x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Status_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Status_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO Update_Status_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data );

END Update_Status;

-- -------------------------------------------------------------------
-- Update_Severity
-- -------------------------------------------------------------------

PROCEDURE Update_Severity
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		IN	NUMBER   := NULL,
  p_user_id		IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_severity_id		IN	NUMBER   := NULL,
  p_severity		IN	VARCHAR2 := NULL,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id		OUT	NOCOPY NUMBER
)
IS

BEGIN
   NULL;
END Update_Severity;


-- -------------------------------------------------------------------
-- Update_Urgency
-- -------------------------------------------------------------------

PROCEDURE Update_Urgency
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		IN	NUMBER   := NULL,
  p_user_id		IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_urgency_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_urgency		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id  	OUT  NOCOPY NUMBER
)
IS
  BEGIN
      NULL;
  END Update_Urgency;

-- -------------------------------------------------------------------
-- Update_Owner
-- -------------------------------------------------------------------

PROCEDURE Update_Owner
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		IN	NUMBER   := NULL,
  p_user_id		IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_owner_id		IN	NUMBER,
  p_owner_group_id  	IN   	NUMBER,
  p_resource_type	IN	VARCHAR2,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_called_by_workflow	IN	VARCHAR2 := FND_API.G_FALSE,
  p_workflow_process_id	IN	NUMBER   := NULL,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id	OUT	NOCOPY NUMBER
)
IS
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Update_Owner';
  l_api_version	       CONSTANT	NUMBER		:= 2.0;
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
  l_return_status		VARCHAR2(1);
  l_resp_appl_id		NUMBER		:= p_resp_appl_id;
  l_resp_id			NUMBER		:= p_resp_id;
  l_user_id			NUMBER		:= p_user_id;
  l_login_id			NUMBER		:= p_login_id;
  l_org_id			NUMBER		;
  l_dummy_id			NUMBER		:= NULL;
  l_request_id			NUMBER;
  l_public_comment_flag		VARCHAR2(1)	:= p_public_comment_flag;

BEGIN
    -- ---------------------------------------
    -- Standard API stuff
    -- ---------------------------------------

    -- Establish savepoint
    SAVEPOINT Update_Owner_PUB;

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
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
    , 'P_user_id:' || P_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'P_login_id:' || P_login_id
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
    , 'p_request_number:' || p_request_number
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

    -- ------------------------------------------------------------
    -- First get the default information
    -- ------------------------------------------------------------
    Get_Default_Values(
		p_api_name		=>  l_api_name_full,
		p_org_id		=>  l_org_id,
		p_resp_appl_id		=>  l_resp_appl_id,
		p_resp_id		=>  l_resp_id,
		p_user_id		=>  l_user_id,
		p_login_id		=>  l_login_id,
		p_inventory_org_id	=>  l_dummy_id,
		p_request_id		=>  p_request_id,
		p_request_number	=>  p_request_number,
		p_request_id_out	=>  l_request_id,
		p_return_status		=>  l_return_status );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- -------------------------------------------
    -- Make sure the owner ID is not null
    -- -------------------------------------------
    IF (p_owner_id IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_owner_id' );
      raise FND_API.G_EXC_ERROR;
    END IF;

    -- Convert the public comment flag
    IF (p_public_comment_flag = FND_API.G_FALSE) THEN
      l_public_comment_flag := 'N';
    ELSIF (p_public_comment_flag = FND_API.G_TRUE) THEN
      l_public_comment_flag := 'Y';
    ELSIF (p_public_comment_flag IS NOT NULL) THEN
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(l_api_name_full,
        p_public_comment_flag, 'p_public_comment_flag');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- -------------------------------------------
    -- Call the private API to update the owner
    -- -------------------------------------------
    CS_ServiceRequest_PVT.Update_Owner (
		p_api_version		  =>  2.0,
		p_init_msg_list		=>  FND_API.G_FALSE,
		p_commit		=>  FND_API.G_FALSE,
		p_validation_level	=>  FND_API.G_VALID_LEVEL_FULL,
		x_return_status		=>  l_return_status,
		x_msg_count		=>  x_msg_count,
		x_msg_data		=>  x_msg_data,
		p_request_id  	        =>  l_request_id,
		p_object_version_number  => p_object_version_number,
		p_resp_id		=>  l_resp_id,
		p_resp_appl_id		=>  l_resp_appl_id,
		p_owner_id		=>  p_owner_id,
		p_owner_group_id    =>  p_owner_group_id,
		p_resource_type     =>  p_resource_type,
		p_last_updated_by	=>  l_user_id,
		p_last_update_login	=>  l_login_id,
		p_last_update_date	=>  sysdate,
		p_audit_comments	=>  p_audit_comments,
		p_called_by_workflow	=>  p_called_by_workflow,
		p_comments		=>  p_comments,
		p_public_comment_flag	=>  l_public_comment_flag,
		x_interaction_id		=>  x_interaction_id );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- -----------------------------
    -- Commit, if requested
    -- -----------------------------
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count 	=> x_msg_count,
			       p_data	=> x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Owner_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Owner_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO Update_Owner_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> x_msg_count,
			         p_data		=> x_msg_data );

END Update_Owner;


-- -------------------------------------------------------------------
-- Update_Problem_Code
-- -------------------------------------------------------------------

PROCEDURE Update_Problem_Code
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		IN	NUMBER   := NULL,
  p_user_id		IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_problem_code	IN	VARCHAR2,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id	OUT	NOCOPY NUMBER
)
IS
  BEGIN
    NULL;
  END Update_Problem_Code;


/***************************************************************************
 *		       Body of Local Procedures				   *
 ***************************************************************************/

-- -------------------------------------------------------------------
-- Default_Other_Attributes
-- -------------------------------------------------------------------
-- Modification History
-- Date     Name     Description
----------- -------- -----------------------------------------------------------
-- 05/04/05 smisra   Removed defaulting of ORG_ID based on client_info and
--                   profile option ORG_ID
--------------------------------------------------------------------------------
PROCEDURE Default_Other_Attributes
( p_api_name			IN	VARCHAR2,
  p_resp_appl_id		IN OUT	NOCOPY NUMBER,
  p_resp_id			IN OUT	NOCOPY NUMBER,
  p_user_id			IN OUT	NOCOPY NUMBER,
  p_login_id			IN OUT	NOCOPY NUMBER,
  p_org_id			IN OUT	NOCOPY NUMBER,
  p_inventory_org_id		IN OUT	NOCOPY NUMBER,
  p_return_status		OUT	NOCOPY VARCHAR2
)
IS
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Default_Other_Attributes';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';

BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- ----------------------------------------------------------------------
  -- FND_GLOBAL.RESP_APPL_ID, FND_GLOBAL.RESP_ID, and FND_GLOBAL.LOGIN_ID
  -- returns -1 by default, which is an invalid value. FND_GLOBAL.USER_ID
  -- is okay, because user ID -1 corresponds to user 'ANONYMOUS.'  If
  -- FND_GLOBAL returns -1, the variables are set to NULL instead.
  -- ----------------------------------------------------------------------

  IF ((p_resp_appl_id IS NULL) AND (FND_GLOBAL.RESP_APPL_ID <> -1)) THEN
    -- ID is not passed in, return the default.
    p_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The Value of profile FND_GLOBAL.RESP_APPL_ID :' || p_resp_appl_id
      );
    END IF;
  END IF;

  IF ((p_resp_id IS NULL) AND (FND_GLOBAL.RESP_ID <> -1)) THEN
    p_resp_id := FND_GLOBAL.RESP_ID;

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The Value of profile FND_GLOBAL.RESP_ID :' || p_resp_id
      );
    END IF;
  END IF;

  IF (p_user_id IS NULL) THEN
    p_user_id := FND_GLOBAL.USER_ID;

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The Value of profile FND_GLOBAL.USER_ID :' || p_user_id
      );
    END IF;
  END IF;

  IF ((p_login_id = FND_API.G_MISS_NUM) AND
      (FND_GLOBAL.LOGIN_ID NOT IN (-1,0))) THEN
    p_login_id := FND_GLOBAL.LOGIN_ID;

    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
      , 'The Value of profile FND_GLOBAL.LOGIN_ID :' || p_login_id
      );
    END IF;
  ELSE
    p_login_id := NULL;
  END IF;

-- The below has been replaced as per new changes
--    p_inventory_org_id :=
--    TO_NUMBER(FND_PROFILE.Value_Specific('SO_ORGANIZATION_ID', p_user_id, p_resp_id, p_resp_appl_id));
END Default_Other_Attributes;


-- -------------------------------------------------------------------
/* Convert_Request_Val_To_ID
   02/18/03 pkesani .
   This Procedure is called during create and update of the SR.
   Create
   		  If the Id = G_MISS_NUM
		  	 Name = Valid value -> Id for the name is saved.
			 Name = Invalid value -> Raise Error.
			 Name = NULL -> Id is set to NULL.
			 Name = G_MISS_CHAR -> Id is set to Default value.
		  If the Id = NULL
		  	 Name is ignored ,Id is set to NULL.
		  If the Id = Value
		  	 Name is ignored ,Id is validated.
   Update
   		  If the Id = G_MISS_NUM
		  	 Name = Valid value -> Id for the name is saved.
			 Name = Invalid value -> Raise Error.
			 Name = NULL -> Id is set to NULL.
			 Name = G_MISS_CHAR -> No change is made.
		  If the Id = NULL
		  	 Name is ignored ,Id is set to NULL.
		  If the Id = Value
		  	 Name is ignored ,Id is validated and Updated.
*/
-- -------------------------------------------------------------------

PROCEDURE Convert_Request_Val_To_ID
( p_api_name			IN	VARCHAR2,
  p_org_id			IN	NUMBER		:= NULL,
  p_request_conv_rec		IN OUT	NOCOPY Request_Conversion_Rec_Type,
  p_return_status		OUT	NOCOPY VARCHAR2
)
IS
  l_return_status	VARCHAR2(1);
BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ((p_request_conv_rec.type_id <> FND_API.G_MISS_NUM) OR
      (p_request_conv_rec.type_id IS NULL)) THEN
    IF (p_request_conv_rec.type_name <> FND_API.G_MISS_CHAR) THEN
      CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(p_api_name, 'p_type_name');
    END IF;
  ELSE
    IF (p_request_conv_rec.type_name <> FND_API.G_MISS_CHAR) THEN
       CS_ServiceRequest_UTIL.Convert_Type_To_ID
       ( p_api_name       => p_api_name,
        p_parameter_name => 'p_type_name',
        p_type_name      => p_request_conv_rec.type_name,
        p_subtype        => CS_ServiceRequest_PUB.G_SR_SUBTYPE,
        p_type_id        => p_request_conv_rec.type_id,
        x_return_status  => l_return_status
      	);
    	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      	   RAISE FND_API.G_EXC_ERROR;
    	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
  	ELSIF (p_request_conv_rec.type_name IS NULL) THEN
    	   p_request_conv_rec.type_id := NULL;
    END IF;
  END IF;

  IF ((p_request_conv_rec.status_id <> FND_API.G_MISS_NUM) OR
      (p_request_conv_rec.status_id IS NULL)) THEN
    IF (p_request_conv_rec.status_name <> FND_API.G_MISS_CHAR) THEN
      CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(p_api_name, 'p_status_name');
    END IF;
  ELSE
    IF (p_request_conv_rec.status_name <> FND_API.G_MISS_CHAR) THEN
       CS_ServiceRequest_UTIL.Convert_Status_To_ID
       ( p_api_name       => p_api_name,
        p_parameter_name => 'p_status_name',
        p_status_name    => p_request_conv_rec.status_name,
        p_subtype        => CS_ServiceRequest_PUB.G_SR_SUBTYPE,
        p_status_id      => p_request_conv_rec.status_id,
        x_return_status  => l_return_status
      	);
    	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      	   RAISE FND_API.G_EXC_ERROR;
    	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
    ELSIF (p_request_conv_rec.status_name IS NULL) THEN
    	   p_request_conv_rec.status_id := NULL;
    END IF;
  END IF;

  IF ((p_request_conv_rec.severity_id <> FND_API.G_MISS_NUM) OR
      (p_request_conv_rec.severity_id IS NULL)) THEN
    IF (p_request_conv_rec.severity_name <> FND_API.G_MISS_CHAR) THEN
      CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(p_api_name, 'p_severity_name');
    END IF;
  ELSE
  	IF (p_request_conv_rec.severity_name <> FND_API.G_MISS_CHAR) THEN
       CS_ServiceRequest_UTIL.Convert_Severity_To_ID
       ( p_api_name       => p_api_name,
        p_parameter_name => 'p_severity_name',
        p_severity_name  => p_request_conv_rec.severity_name,
        p_subtype        => CS_ServiceRequest_PUB.G_SR_SUBTYPE,
        p_severity_id    => p_request_conv_rec.severity_id,
        x_return_status  => l_return_status
       );
       IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSIF (p_request_conv_rec.severity_name IS NULL) THEN
    	   p_request_conv_rec.severity_id := NULL;
    END IF;
  END IF;

  IF ((p_request_conv_rec.urgency_id <> FND_API.G_MISS_NUM) OR
      (p_request_conv_rec.urgency_id IS NULL)) THEN  --- BUG 2735073
      IF (p_request_conv_rec.urgency_name <> FND_API.G_MISS_CHAR) THEN
      	 CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(p_api_name,
                                                   'p_urgency_name');
      END IF;
  ELSE
     IF (p_request_conv_rec.urgency_name <> FND_API.G_MISS_CHAR) THEN
       	  CS_ServiceRequest_UTIL.Convert_Urgency_To_ID
      	  ( p_api_name       => p_api_name,
          p_parameter_name => 'p_urgency_name',
          p_urgency_name   => p_request_conv_rec.urgency_name,
          p_urgency_id     => p_request_conv_rec.urgency_id,
          x_return_status  => l_return_status
      	  );
    	  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      	  RAISE FND_API.G_EXC_ERROR;
    	  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	  END IF;
     ELSIF (p_request_conv_rec.urgency_name IS NULL) THEN
       		  p_request_conv_rec.urgency_id := NULL;
     END IF;
  END IF;

  IF (p_request_conv_rec.publish_flag <> FND_API.G_MISS_CHAR) THEN
    IF (p_request_conv_rec.publish_flag = FND_API.G_TRUE) THEN
      p_request_conv_rec.publish_flag := 'Y';
    ELSIF (p_request_conv_rec.publish_flag = FND_API.G_FALSE) THEN
      p_request_conv_rec.publish_flag := 'N';
    ELSIF (p_request_conv_rec.publish_flag IS NOT NULL) THEN
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(p_api_name,
        p_request_conv_rec.publish_flag, 'p_publish_flag');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF ((p_request_conv_rec.employee_id <> FND_API.G_MISS_NUM) OR
      (p_request_conv_rec.employee_id IS NULL)) THEN
    IF (p_request_conv_rec.employee_number <> FND_API.G_MISS_CHAR) THEN
      CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(p_api_name, 'p_employee_number');
    END IF;
  ELSE
    IF (p_request_conv_rec.employee_number <> FND_API.G_MISS_CHAR) THEN
       CS_ServiceRequest_UTIL.Convert_Employee_To_ID
       ( p_api_name          => p_api_name,
        p_parameter_name_nb => 'p_employee_number',
        p_employee_number   => p_request_conv_rec.employee_number,
        p_employee_id       => p_request_conv_rec.employee_id,
        x_return_status     => l_return_status
       );
       IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSIF (p_request_conv_rec.employee_number IS NULL) THEN
    	   p_request_conv_rec.employee_id := NULL;
    END IF;
  END IF;

  IF ((p_request_conv_rec.customer_product_id <> FND_API.G_MISS_NUM) OR
      (p_request_conv_rec.customer_product_id IS NULL)) THEN
    IF (p_request_conv_rec.cp_ref_number <> FND_API.G_MISS_NUM) THEN
      CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(p_api_name,
                                                   'p_cp_ref_number');
    END IF;
  ELSE
    IF (p_request_conv_rec.cp_ref_number <> FND_API.G_MISS_NUM) THEN
       CS_ServiceRequest_UTIL.Convert_CP_Ref_Number_To_ID
       ( p_api_name            => p_api_name,
        p_parameter_name      => 'p_cp_ref_number',
        p_cp_ref_number       => p_request_conv_rec.cp_ref_number,
        p_org_id              => p_org_id,
        p_customer_product_id => p_request_conv_rec.customer_product_id,
        x_return_status       => l_return_status
       );
       IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSIF (p_request_conv_rec.cp_ref_number IS NULL) THEN
    	   p_request_conv_rec.customer_product_id := NULL;
    END IF;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;

END Convert_Request_Val_To_ID;


-- -------------------------------------------------------------------
-- Convert_Key_Flex_To_ID
-- -------------------------------------------------------------------

PROCEDURE Convert_Key_Flex_To_ID
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_key_flex_code		IN	VARCHAR2,
  p_structure_number		IN	NUMBER,
  p_attribute_id		IN	NUMBER		:= FND_API.G_MISS_NUM,
  p_attribute_conc_segs		IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
  p_attribute_segments_tbl	IN	FND_FLEX_EXT.SegmentArray,
  p_attribute_n_segments	IN	NUMBER		:= 0,
  p_attribute_vals_or_ids	IN	VARCHAR2	:= 'V',
  p_data_set			IN	NUMBER		:= NULL,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  p_user_id			IN	NUMBER		:= NULL,
  p_attribute_id_out		OUT	NOCOPY NUMBER,
  p_return_status		OUT	NOCOPY VARCHAR2
)
IS
  l_error_message	VARCHAR2(2000);
  l_delimiter		VARCHAR2(1);
  l_attribute_conc_segs	VARCHAR2(800);
BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ((p_attribute_id <> FND_API.G_MISS_NUM) OR
      (p_attribute_id IS NULL)) THEN
    -- If caller explicitly passed in the combination ID, return it.
    p_attribute_id_out := p_attribute_id;
  ELSIF (p_attribute_conc_segs <> FND_API.G_MISS_CHAR) THEN
    -- If caller passed in the concatenated segments, get the combination ID
    -- by using the flexfields APIs.
    IF NOT FND_FLEX_KEYVAL.Validate_Segs
             ( operation        => 'FIND_COMBINATION',
               appl_short_name  => p_application_short_name,
               key_flex_code    => p_key_flex_code,
               structure_number => p_structure_number,
               concat_segments  => p_attribute_conc_segs,
               values_or_ids    => p_attribute_vals_or_ids,
               data_set         => p_data_set,
               resp_appl_id     => p_resp_appl_id,
               resp_id          => p_resp_id,
               user_id          => p_user_id
             ) THEN
      l_error_message := FND_FLEX_KEYVAL.Error_Message;
      CS_ServiceRequest_UTIL.Add_Key_Flex_Msg(p_api_name, l_error_message);
      p_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      p_attribute_id_out := FND_FLEX_KEYVAL.Combination_ID;
    END IF;
  ELSIF (p_attribute_n_segments <> 0) THEN
    -- If caller did not pass in the concatenated segments but passed in the
    -- individual segments instead, need to first convert them into a string
    -- of concatenated segments before finding the combination ID.
    l_delimiter := FND_FLEX_EXT.Get_Delimiter
                     ( application_short_name => p_application_short_name,
                       key_flex_code          => p_key_flex_code,
                       structure_number       => p_structure_number
                     );
    l_attribute_conc_segs := FND_FLEX_EXT.Concatenate_Segments
                               ( n_segments => p_attribute_n_segments,
                                 segments   => p_attribute_segments_tbl,
                                 delimiter  => l_delimiter
                               );

    IF NOT FND_FLEX_KEYVAL.Validate_Segs
             ( operation        => 'FIND_COMBINATION',
               appl_short_name  => p_application_short_name,
               key_flex_code    => p_key_flex_code,
               structure_number => p_structure_number,
               concat_segments  => l_attribute_conc_segs,
               values_or_ids    => p_attribute_vals_or_ids,
               data_set         => p_data_set,
               resp_appl_id     => p_resp_appl_id,
               resp_id          => p_resp_id,
               user_id          => p_user_id
             ) THEN
      l_error_message := FND_FLEX_KEYVAL.Error_Message;
      CS_ServiceRequest_UTIL.Add_Key_Flex_Msg(p_api_name, l_error_message);
      p_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      p_attribute_id_out := FND_FLEX_KEYVAL.Combination_ID;
    END IF;

  ELSE
    -- The caller did not pass in anything; return FND_API.G_MISS_NUM.
    p_attribute_id_out := p_attribute_id;
  END IF;

END Convert_Key_Flex_To_ID;

/*** 1/28/2004 smisra moved this procedure to csusrs.pls
-- -------------------------------------------------------------------
-- Validate_Desc_Flex
-- -------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_desc_flex_name		IN	VARCHAR2,
  p_desc_segment1		IN	VARCHAR2,
  p_desc_segment2		IN	VARCHAR2,
  p_desc_segment3		IN	VARCHAR2,
  p_desc_segment4		IN	VARCHAR2,
  p_desc_segment5		IN	VARCHAR2,
  p_desc_segment6		IN	VARCHAR2,
  p_desc_segment7		IN	VARCHAR2,
  p_desc_segment8		IN	VARCHAR2,
  p_desc_segment9		IN	VARCHAR2,
  p_desc_segment10		IN	VARCHAR2,
  p_desc_segment11		IN	VARCHAR2,
  p_desc_segment12		IN	VARCHAR2,
  p_desc_segment13		IN	VARCHAR2,
  p_desc_segment14		IN	VARCHAR2,
  p_desc_segment15		IN	VARCHAR2,
  p_desc_context		IN	VARCHAR2,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  p_return_status		OUT	NOCOPY VARCHAR2
)
IS
  l_error_message	VARCHAR2(2000);
BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_desc_context   || p_desc_segment1  || p_desc_segment2  ||
       p_desc_segment3  || p_desc_segment4  || p_desc_segment5  ||
       p_desc_segment6  || p_desc_segment7  || p_desc_segment8  ||
       p_desc_segment9  || p_desc_segment10 || p_desc_segment11 ||
       p_desc_segment12 || p_desc_segment13 || p_desc_segment14 ||
       p_desc_segment15
     ) IS NOT NULL THEN

    FND_FLEX_DESCVAL.Set_Context_Value(p_desc_context);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_1', p_desc_segment1);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_2', p_desc_segment2);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_3', p_desc_segment3);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_4', p_desc_segment4);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_5', p_desc_segment5);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_6', p_desc_segment6);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_7', p_desc_segment7);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_8', p_desc_segment8);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_9', p_desc_segment9);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_10', p_desc_segment10);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_11', p_desc_segment11);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_12', p_desc_segment12);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_13', p_desc_segment13);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_14', p_desc_segment14);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_15', p_desc_segment15);
    IF NOT FND_FLEX_DESCVAL.Validate_Desccols
             ( appl_short_name => p_application_short_name,
               desc_flex_name  => p_desc_flex_name,
               resp_appl_id    => p_resp_appl_id,
               resp_id         => p_resp_id
             ) THEN
      l_error_message := FND_FLEX_DESCVAL.Error_Message;
      CS_ServiceRequest_UTIL.Add_Desc_Flex_Msg(p_api_name, l_error_message);
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Validate_Desc_Flex;
*******************************************************************/

-- -------------------------------------------------------------------
-- Validate_External_Desc_Flex
-- For ER# 2501166 added these external attributes date 1st oct 2002
-- -------------------------------------------------------------------
/******* Bug 5216510 Moved this procedure to CS_ServiceRequest_UTIL package.

PROCEDURE Validate_External_Desc_Flex
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_ext_desc_flex_name		IN	VARCHAR2,
  p_ext_desc_segment1		IN	VARCHAR2,
  p_ext_desc_segment2		IN	VARCHAR2,
  p_ext_desc_segment3		IN	VARCHAR2,
  p_ext_desc_segment4		IN	VARCHAR2,
  p_ext_desc_segment5		IN	VARCHAR2,
  p_ext_desc_segment6		IN	VARCHAR2,
  p_ext_desc_segment7		IN	VARCHAR2,
  p_ext_desc_segment8		IN	VARCHAR2,
  p_ext_desc_segment9		IN	VARCHAR2,
  p_ext_desc_segment10		IN	VARCHAR2,
  p_ext_desc_segment11		IN	VARCHAR2,
  p_ext_desc_segment12		IN	VARCHAR2,
  p_ext_desc_segment13		IN	VARCHAR2,
  p_ext_desc_segment14		IN	VARCHAR2,
  p_ext_desc_segment15		IN	VARCHAR2,
  p_ext_desc_context		IN	VARCHAR2,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  p_return_status		OUT	NOCOPY VARCHAR2
)
IS
  l_error_message	VARCHAR2(2000);
BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_ext_desc_context   || p_ext_desc_segment1  || p_ext_desc_segment2  ||
       p_ext_desc_segment3  || p_ext_desc_segment4  || p_ext_desc_segment5  ||
       p_ext_desc_segment6  || p_ext_desc_segment7  || p_ext_desc_segment8  ||
       p_ext_desc_segment9  || p_ext_desc_segment10 || p_ext_desc_segment11 ||
       p_ext_desc_segment12 || p_ext_desc_segment13 || p_ext_desc_segment14 ||
       p_ext_desc_segment15
     ) IS NOT NULL THEN

    FND_FLEX_DESCVAL.Set_Context_Value(p_ext_desc_context);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_1', p_ext_desc_segment1);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_2', p_ext_desc_segment2);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_3', p_ext_desc_segment3);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_4', p_ext_desc_segment4);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_5', p_ext_desc_segment5);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_6', p_ext_desc_segment6);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_7', p_ext_desc_segment7);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_8', p_ext_desc_segment8);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_9', p_ext_desc_segment9);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_10', p_ext_desc_segment10);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_11', p_ext_desc_segment11);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_12', p_ext_desc_segment12);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_13', p_ext_desc_segment13);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_14', p_ext_desc_segment14);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_15', p_ext_desc_segment15);
    IF NOT FND_FLEX_DESCVAL.Validate_Desccols
             ( appl_short_name => p_application_short_name,
               desc_flex_name  => p_ext_desc_flex_name,
               resp_appl_id    => p_resp_appl_id,
               resp_id         => p_resp_id
             ) THEN
      l_error_message := FND_FLEX_DESCVAL.Error_Message;
      CS_ServiceRequest_UTIL.Add_Desc_Flex_Msg(p_api_name, l_error_message);
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Validate_External_Desc_Flex;
************************************************************Bug 5216510***************/

-- -------------------------------------------------------------------
-- Validate_Strings
-- -------------------------------------------------------------------

PROCEDURE Validate_Strings
( p_api_name			IN	VARCHAR2,
  p_summary			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_customer_name		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_customer_number		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_name		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_area_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_telephone		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_extension		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_fax_area_code	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_fax_number		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_email_address	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_name			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_area_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_telephone		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_extension		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_fax_area_code	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_fax_number		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_rep_by_email		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_current_serial_number	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_purchase_order_num		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_problem_description		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_location		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_customer		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_address_line_1	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_address_line_2	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_install_address_line_3	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_location		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_customer		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_address_line_1	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_address_line_2	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_address_line_3	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_bill_to_contact		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_location		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_customer		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_address_line_1	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_address_line_2	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_address_line_3	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ship_to_contact		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_problem_resolution		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_audit_comments		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_inv_item_revision	    IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_inv_component_version	    IN	VARCHAR2 := FND_API.G_MISS_CHAR,
  p_inv_subcomponent_version    IN	VARCHAR2 := FND_API.G_MISS_CHAR,

  p_summary_out			OUT	NOCOPY VARCHAR2,
  p_customer_name_out		OUT	NOCOPY VARCHAR2,
  p_customer_number_out		OUT	NOCOPY VARCHAR2,
  p_contact_name_out		OUT	NOCOPY VARCHAR2,
  p_contact_area_code_out	OUT	NOCOPY VARCHAR2,
  p_contact_telephone_out	OUT	NOCOPY VARCHAR2,
  p_contact_extension_out	OUT	NOCOPY VARCHAR2,
  p_contact_fax_area_code_out	OUT	NOCOPY VARCHAR2,
  p_contact_fax_number_out	OUT	NOCOPY VARCHAR2,
  p_contact_email_address_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_name_out		OUT	NOCOPY VARCHAR2,
  p_rep_by_area_code_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_telephone_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_extension_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_fax_area_code_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_fax_number_out	OUT	NOCOPY VARCHAR2,
  p_rep_by_email_out		OUT	NOCOPY VARCHAR2,
  p_current_serial_number_out	OUT	NOCOPY VARCHAR2,
  p_purchase_order_num_out	OUT	NOCOPY VARCHAR2,
  p_problem_description_out	OUT	NOCOPY VARCHAR2,
  p_install_location_out	OUT	NOCOPY VARCHAR2,
  p_install_customer_out	OUT	NOCOPY VARCHAR2,
  p_install_address_line_1_out	OUT	NOCOPY VARCHAR2,
  p_install_address_line_2_out	OUT	NOCOPY VARCHAR2,
  p_install_address_line_3_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_location_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_customer_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_address_line_1_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_address_line_2_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_address_line_3_out	OUT	NOCOPY VARCHAR2,
  p_bill_to_contact_out		OUT	NOCOPY VARCHAR2,
  p_ship_to_location_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_customer_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_address_line_1_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_address_line_2_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_address_line_3_out	OUT	NOCOPY VARCHAR2,
  p_ship_to_contact_out		OUT	NOCOPY VARCHAR2,
  p_problem_resolution_out	OUT	NOCOPY VARCHAR2,
  p_audit_comments_out		OUT	NOCOPY VARCHAR2,
  p_inv_item_revision_out		OUT	NOCOPY VARCHAR2,
  p_inv_component_version_out		OUT	NOCOPY VARCHAR2,
  p_inv_subcomponent_version_out	OUT	NOCOPY VARCHAR2
)
IS

  --------------------------------------------------------------------------
  -- Local Function Trunc_String_Length
  -- Description:
  --   Verify that the string is shorter than the defined width of the
  --   column. If the character value is longer than the defined width of
  --   the VARCHAR2 column, truncate the value.
  --------------------------------------------------------------------------
  PROCEDURE Trunc_String_Length
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_str			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
    p_len			IN	NUMBER,
    p_str_out		OUT	NOCOPY VARCHAR2
  )
  IS
    l_len	NUMBER;
  BEGIN
    IF (p_str <> FND_API.G_MISS_CHAR) THEN
      l_len := LENGTHB(p_str);
      IF (l_len > p_len) THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_VALUE_TRUNCATED');
          FND_MESSAGE.Set_Token('API_NAME', p_api_name);
          FND_MESSAGE.Set_Token('TRUNCATED_PARAM', p_parameter_name);
          FND_MESSAGE.Set_Token('VAL_LEN', l_len);
          FND_MESSAGE.Set_Token('DB_LEN', p_len);
          FND_MSG_PUB.Add;
        END IF;
        p_str_out := SUBSTRB(p_str, 1, p_len);
      ELSE
        p_str_out := p_str;
      END IF;
    ELSE
      p_str_out := p_str;
    END IF;
  END Trunc_String_Length;

BEGIN
  Trunc_String_Length(p_api_name, 'p_summary', p_summary, 240, p_summary_out);
  Trunc_String_Length(p_api_name, 'p_customer_name', p_customer_name, 50,
                      p_customer_name_out);
  Trunc_String_Length(p_api_name, 'p_customer_number', p_customer_number, 30,
                      p_customer_number_out);
  Trunc_String_Length(p_api_name, 'p_contact_name', p_contact_name, 100,
                      p_contact_name_out);
  Trunc_String_Length(p_api_name, 'p_contact_area_code', p_contact_area_code, 10,
                      p_contact_area_code_out);
  Trunc_String_Length(p_api_name, 'p_contact_telephone', p_contact_telephone, 25,
                      p_contact_telephone_out);
  Trunc_String_Length(p_api_name, 'p_contact_extension', p_contact_extension, 20,
                      p_contact_extension_out);
  Trunc_String_Length(p_api_name, 'p_contact_fax_area_code', p_contact_fax_area_code,
                      10, p_contact_fax_area_code_out);
  Trunc_String_Length(p_api_name, 'p_contact_fax_number', p_contact_fax_number, 25,
                      p_contact_fax_number_out);
  Trunc_String_Length(p_api_name, 'p_contact_email_address', p_contact_email_address,
                      240, p_contact_email_address_out);
  Trunc_String_Length(p_api_name, 'p_represented_by_name', p_rep_by_name, 100,
                      p_rep_by_name_out);
  Trunc_String_Length(p_api_name, 'p_represented_by_area_code', p_rep_by_area_code, 10,
                      p_rep_by_area_code_out);
  Trunc_String_Length(p_api_name, 'p_represented_by_telephone', p_rep_by_telephone, 25,
                      p_rep_by_telephone_out);
  Trunc_String_Length(p_api_name, 'p_represented_by_extension', p_rep_by_extension, 20,
                      p_rep_by_extension_out);
  Trunc_String_Length(p_api_name, 'p_represented_by_fax_area_code', p_rep_by_fax_area_code, 10,
                      p_rep_by_fax_area_code_out);
  Trunc_String_Length(p_api_name, 'p_represented_by_fax_number', p_rep_by_fax_number, 25,
                      p_rep_by_fax_number_out);
  Trunc_String_Length(p_api_name, 'p_represented_by_email', p_rep_by_email, 240,
                      p_rep_by_email_out);
  Trunc_String_Length(p_api_name, 'p_current_serial_number', p_current_serial_number, 30,
                      p_current_serial_number_out);
  Trunc_String_Length(p_api_name, 'p_purchase_order_num', p_purchase_order_num,
                      50, p_purchase_order_num_out);
  Trunc_String_Length(p_api_name, 'p_problem_description', p_problem_description, 2000,
                      p_problem_description_out);
  Trunc_String_Length(p_api_name, 'p_install_location', p_install_location, 40,
                      p_install_location_out);
  Trunc_String_Length(p_api_name, 'p_install_customer', p_install_customer, 50,
                      p_install_customer_out);
  Trunc_String_Length(p_api_name, 'p_install_address_line_1', p_install_address_line_1,
                      240, p_install_address_line_1_out);
  Trunc_String_Length(p_api_name, 'p_install_address_line_2', p_install_address_line_2,
                      240, p_install_address_line_2_out);
  Trunc_String_Length(p_api_name, 'p_install_address_line_3', p_install_address_line_3,
                      240, p_install_address_line_3_out);
  Trunc_String_Length(p_api_name, 'p_bill_to_location', p_bill_to_location, 40,
                      p_bill_to_location_out);
  Trunc_String_Length(p_api_name, 'p_bill_to_customer', p_bill_to_customer, 50,
                      p_bill_to_customer_out);
  Trunc_String_Length(p_api_name, 'p_bill_to_address_line_1', p_bill_to_address_line_1,
                      240, p_bill_to_address_line_1_out);
  Trunc_String_Length(p_api_name, 'p_bill_to_address_line_2', p_bill_to_address_line_2,
                      240, p_bill_to_address_line_2_out);
  Trunc_String_Length(p_api_name, 'p_bill_to_address_line_3', p_bill_to_address_line_3,
                      240, p_bill_to_address_line_3_out);
  Trunc_String_Length(p_api_name, 'p_bill_to_contact', p_bill_to_contact, 100,
                      p_bill_to_contact_out);
  Trunc_String_Length(p_api_name, 'p_ship_to_location', p_ship_to_location, 40,
                      p_ship_to_location_out);
  Trunc_String_Length(p_api_name, 'p_ship_to_customer', p_ship_to_customer, 50,
                      p_ship_to_customer_out);
  Trunc_String_Length(p_api_name, 'p_ship_to_address_line_1', p_ship_to_address_line_1,
                      240, p_ship_to_address_line_1_out);
  Trunc_String_Length(p_api_name, 'p_ship_to_address_line_2', p_ship_to_address_line_2,
                      240, p_ship_to_address_line_2_out);
  Trunc_String_Length(p_api_name, 'p_ship_to_address_line_3', p_ship_to_address_line_3,
                      240, p_ship_to_address_line_3_out);
  Trunc_String_Length(p_api_name, 'p_ship_to_contact', p_ship_to_contact, 100,
                      p_ship_to_contact_out);
  Trunc_String_Length(p_api_name, 'p_problem_resolution', p_problem_resolution, 2000,
                      p_problem_resolution_out);
  Trunc_String_Length(p_api_name, 'p_audit_comments', p_audit_comments, 2000,
                      p_audit_comments_out);
  Trunc_String_Length(p_api_name, 'p_inv_item_revision', p_inv_item_revision, 240,
                      p_inv_item_revision_out);
  Trunc_String_Length(p_api_name, 'p_inv_component_version', p_inv_component_version, 90,
                      p_inv_component_version_out);
  Trunc_String_Length(p_api_name, 'p_inv_subcomponent_version', p_inv_subcomponent_version, 90,
                      p_inv_subcomponent_version_out);

END Validate_Strings;


-- ------------------------------------------------------
-- Get_Default_Values
-- ------------------------------------------------------

  PROCEDURE Get_Default_Values(
		p_api_name		IN	VARCHAR,
		p_org_id		IN OUT	NOCOPY NUMBER,
		p_resp_appl_id		IN OUT  NOCOPY NUMBER,
		p_resp_id		IN OUT  NOCOPY NUMBER,
		p_user_id		IN OUT	NOCOPY NUMBER,
		p_login_id		IN OUT	NOCOPY NUMBER,
		p_inventory_org_id	IN OUT  NOCOPY NUMBER,
		p_request_id		IN	NUMBER,
		p_request_number	IN	VARCHAR2,
		p_request_id_out	OUT	NOCOPY NUMBER,
		p_return_status		OUT	NOCOPY VARCHAR2 ) IS

    l_return_status	VARCHAR2(1);

  BEGIN
    -- Initialize return status
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Get default values
    --
    Default_Other_Attributes(
		p_api_name		=>  p_api_name,
  		p_resp_appl_id		=>  p_resp_appl_id,
  		p_resp_id		=>  p_resp_id,
  		p_user_id		=>  p_user_id,
  		p_login_id		=>  p_login_id,
  		p_org_id		=>  p_org_id,
  		p_inventory_org_id	=>  p_inventory_org_id,
  		p_return_status		=>  l_return_status );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    -- Get the request ID
    --
    IF (p_request_id IS NULL) THEN
      IF (p_request_number IS NULL) THEN
        CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  p_api_name,
		p_token_np	=>  'p_request_id' );
        raise FND_API.G_EXC_ERROR;
      ELSE
        CS_ServiceRequest_UTIL.Convert_Request_Number_To_ID(
		p_api_name       => p_api_name,
        	p_parameter_name => 'p_request_number',
        	p_request_number => p_request_number,
		p_org_id	 => p_org_id,
        	p_request_id     => p_request_id_out,
        	x_return_status  => l_return_status );
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          raise FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    ELSE
      p_request_id_out := p_request_id;
      IF (p_request_number IS NOT NULL) THEN
        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  p_api_name,
		p_token_ip	=>  'p_request_number' );
      END IF;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Default_Values;
------------------------------------------------------------
--These APIs are owned by ShihHsin


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
  x_statement_link_id  	   OUT    NOCOPY NUMBER
)
IS
    l_service_request_obj_code VARCHAR2(30) := 'SR';
    l_true_link		VARCHAR2(1) := 'T';
    l_false_link	VARCHAR2(1) := 'F';
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_msg_index_out	NUMBER;
    l_element_link_rec	CS_KB_ELEMENT_LINKS%ROWTYPE;
    l_element_link_id	NUMBER;
--3630159 --reverts back the changes for 3288427 -- 30th June, 2004.
    l_api_version       CONSTANT number := 1.0;
    l_api_name          CONSTANT varchar2(18) := 'LINK_KB_STATEMENT';
BEGIN

--Note :
--This procedure does not have any savepoint because it does not execute any DML directly.

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.Initialize;
     END IF;

--3630159 -- 30th June, 2004 -- Added to conform to public API coding standards
    IF NOT FND_API.Compatible_API_Call
           (
	       p_current_version_number => l_api_version,
	       p_caller_version_number  => p_api_version,
	       p_api_name               => l_api_name,
               p_pkg_name               => G_PKG_NAME
	   )
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Set up the link record
    IF FND_API.To_Boolean(p_is_statement_true) = TRUE
    THEN
      l_element_link_rec.link_type := l_true_link;
    ELSE
      l_element_link_rec.link_type := l_false_link;
    END IF;

    l_element_link_rec.object_code := l_service_request_obj_code;
    l_element_link_rec.other_id := p_request_id;
    l_element_link_rec.element_id := p_statement_id;


    -- Call the knowledge base API to actually create the link
    CS_Knowledge_GRP.Create_Element_Link
    (
      p_api_version	 => 1.0, --3630159 --30th June, 2004-- All consumer calls should have API version hardcoded
      p_init_msg_list    => p_init_msg_list,
      p_commit	         => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count	 => l_msg_count,
      x_msg_data	 => l_msg_data,
      p_element_link_rec => l_element_link_rec,
      x_element_link_id  => l_element_link_id
    );

    -- Pass through return status and messages
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;
    x_statement_link_id := l_element_link_id;

--3630159 -- 30th June, 2004.
-- Added exception blocks to handle invalid API Version error handling.

    EXCEPTION
        WHEN    FND_API.G_EXC_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN    OTHERS
        THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
END Link_KB_Statement;



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
  x_solution_link_id  	   OUT    NOCOPY NUMBER
)
IS
    l_service_request_obj_code VARCHAR2(30) := 'SR';
    l_true_link		VARCHAR2(6) := 'S';
    l_false_link	VARCHAR2(6) := 'NS';
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_msg_index_out	NUMBER;
    l_set_link_rec	CS_KB_SET_LINKS%ROWTYPE;
    l_set_link_id	NUMBER;

    l_api_name_full     VARCHAR2(70) := G_PKG_NAME || '.LINK_KB_SOLUTION';
--3630159 -- reverts changes for 3288427 to conform to coding standards
    l_api_version       CONSTANT NUMBER := 1.0;
    l_api_name          CONSTANT VARCHAR2(17) := 'LINK_KB_SOLUTION';
BEGIN
--Note :
--This procedure does not have any savepoint because it does not execute any DML directly.

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.Initialize;
     END IF;

--3630159 -- 30th June, 2004 -- Added to conform to public API coding standards
    IF NOT FND_API.Compatible_API_Call
           (
	       p_current_version_number => l_api_version,
	       p_caller_version_number  => p_api_version,
	       p_api_name               => l_api_name,
               p_pkg_name               => G_PKG_NAME
	   )
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   if ( p_is_solution_true not in ('T','F') ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      fnd_message.set_token('API_NAME',  l_api_name_full);
      fnd_message.set_token('VALUE',     p_is_solution_true);
      fnd_message.set_token('PARAMETER', 'p_is_solution_true');
      fnd_msg_pub.add;
      RETURN;
   end if;

    -- Set up the link record

    IF FND_API.To_Boolean(p_is_solution_true) = TRUE
    THEN
      l_set_link_rec.link_type := l_true_link;
    ELSE
      l_set_link_rec.link_type := l_false_link;
    END IF;

    l_set_link_rec.object_code := l_service_request_obj_code;
    l_set_link_rec.other_id := p_request_id;
    l_set_link_rec.set_id := p_solution_id;


    -- Call the knowledge base API to actually create the link
    CS_Knowledge_GRP.Create_Set_Link
    (
      p_api_version	 => 1.0, --3630159 --30th June, 2004 -- All consumer calls should have API version hardcoded
      p_init_msg_list    => p_init_msg_list,
      p_commit	         => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count	 => l_msg_count,
      x_msg_data	 => l_msg_data,
      p_set_link_rec     => l_set_link_rec,
      x_set_link_id      => l_set_link_id
    );

    -- Pass through return status and messages
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;
    x_solution_link_id := l_set_link_id;

EXCEPTION
--3630159 - 30th June, 2004 -- Handled errors should return status 'E'
    WHEN    FND_API.G_EXC_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    when others then
      x_return_status      := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;

END Link_KB_Solution;

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
  p_resp_appl_id                  IN      NUMBER        := NULL,
  p_resp_id                       IN      NUMBER        := NULL,
  p_user_id                       IN      NUMBER        := NULL,
  p_login_id                      IN      NUMBER        := NULL,
  p_org_id                        IN      NUMBER        := NULL,
  p_request_id                    IN      NUMBER        := NULL,
  p_request_number                IN      VARCHAR2      := NULL,
  p_service_request_rec           IN      SERVICE_REQUEST_REC_TYPE,
  p_notes                         IN      NOTES_TABLE,
  p_contacts                      IN      CONTACTS_TABLE,
  p_default_contract_sla_ind      IN      VARCHAR2 Default 'N',
  x_request_id                    OUT     NOCOPY NUMBER,
  x_request_number                OUT     NOCOPY VARCHAR2,
  x_interaction_id                OUT     NOCOPY NUMBER,
  x_workflow_process_id           OUT     NOCOPY NUMBER
 )
IS
  l_api_version        CONSTANT NUMBER          := 2.0;
  l_api_name           CONSTANT VARCHAR2(30)    := 'Create_ServiceRequest';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_individual_owner            NUMBER;
  l_group_owner                 NUMBER;
  l_individual_type             VARCHAR2(30);
  l_return_status               VARCHAR2(1);

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Create_ServiceRequest_PUB;

--BUG 3630159:
 --Added to clear message cache in case of API call wrong version.
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
  END IF;

 -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 CS_ServiceRequest_PUB.Create_ServiceRequest
    ( p_api_version                  => 3.0,
      p_init_msg_list                => p_init_msg_list,
      p_commit                       => p_commit,
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
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_ServiceRequest_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Create_ServiceRequest;
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
  CS_SERVICEREQUEST_PVT.process_sr_ext_attrs
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


PROCEDURE Log_SR_PUB_Parameters
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
    , 'request_date               	:' || p_service_request_rec.request_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'type_id                    	:' || p_service_request_rec.type_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'type_name                  	:' || p_service_request_rec.type_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'status_id                  	:' || p_service_request_rec.status_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'status_name                	:' || p_service_request_rec.status_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'severity_id                	:' || p_service_request_rec.severity_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'severity_name              	:' || p_service_request_rec.severity_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'urgency_id                 	:' || p_service_request_rec.urgency_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'urgency_name               	:' || p_service_request_rec.urgency_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'closed_date                	:' || p_service_request_rec.closed_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner_id                   	:' || p_service_request_rec.owner_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner_group_id             	:' || p_service_request_rec.owner_group_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'publish_flag               	:' || p_service_request_rec.publish_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'summary                    	:' || p_service_request_rec.summary
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'caller_type                	:' || p_service_request_rec.caller_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_id                	:' || p_service_request_rec.customer_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_number            	:' || p_service_request_rec.customer_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'employee_id                	:' || p_service_request_rec.employee_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'employee_number            	:' || p_service_request_rec.employee_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'verify_cp_flag             	:' || p_service_request_rec.verify_cp_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_product_id        	:' || p_service_request_rec.customer_product_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'platform_id                	:' || p_service_request_rec.platform_id
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
    , 'platform_version_id        	:' || p_service_request_rec.platform_version_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_component_id            	:' || p_service_request_rec.cp_component_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_component_version_id    	:' || p_service_request_rec.cp_component_version_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_subcomponent_id         	:' || p_service_request_rec.cp_subcomponent_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_subcomponent_version_id 	:' || p_service_request_rec.cp_subcomponent_version_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'language_id                	:' || p_service_request_rec.language_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'language                   	:' || p_service_request_rec.language
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_ref_number              	:' || p_service_request_rec.cp_ref_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_id          	:' || p_service_request_rec.inventory_item_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_conc_segs   	:' || p_service_request_rec.inventory_item_conc_segs
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment1    	:' || p_service_request_rec.inventory_item_segment1
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment2    	:' || p_service_request_rec.inventory_item_segment2
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment3    	:' || p_service_request_rec.inventory_item_segment3
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment4    	:' || p_service_request_rec.inventory_item_segment4
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment5    	:' || p_service_request_rec.inventory_item_segment5
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment6    	:' || p_service_request_rec.inventory_item_segment6
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment7    	:' || p_service_request_rec.inventory_item_segment7
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment8    	:' || p_service_request_rec.inventory_item_segment8
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment9    	:' || p_service_request_rec.inventory_item_segment9
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment10   	:' || p_service_request_rec.inventory_item_segment10
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment11   	:' || p_service_request_rec.inventory_item_segment11
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment12   	:' || p_service_request_rec.inventory_item_segment12
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment13   	:' || p_service_request_rec.inventory_item_segment13
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment14   	:' || p_service_request_rec.inventory_item_segment14
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment15   	:' || p_service_request_rec.inventory_item_segment15
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment16   	:' || p_service_request_rec.inventory_item_segment16
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment17   	:' || p_service_request_rec.inventory_item_segment17
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment18   	:' || p_service_request_rec.inventory_item_segment18
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment19   	:' || p_service_request_rec.inventory_item_segment19
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_segment20   	:' || p_service_request_rec.inventory_item_segment20
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_item_vals_or_ids 	:' || p_service_request_rec.inventory_item_vals_or_ids
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inventory_org_id           	:' || p_service_request_rec.inventory_org_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'current_serial_number      	:' || p_service_request_rec.current_serial_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'original_order_number      	:' || p_service_request_rec.original_order_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'purchase_order_num         	:' || p_service_request_rec.purchase_order_num
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'problem_code               	:' || p_service_request_rec.problem_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'exp_resolution_date        	:' || p_service_request_rec.exp_resolution_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'install_site_use_id        	:' || p_service_request_rec.install_site_use_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_1        	:' || p_service_request_rec.request_attribute_1
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_2        	:' || p_service_request_rec.request_attribute_2
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_3        	:' || p_service_request_rec.request_attribute_3
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_4        	:' || p_service_request_rec.request_attribute_4
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_5        	:' || p_service_request_rec.request_attribute_5
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_6        	:' || p_service_request_rec.request_attribute_6
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_7        	:' || p_service_request_rec.request_attribute_7
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_8        	:' || p_service_request_rec.request_attribute_8
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_9        	:' || p_service_request_rec.request_attribute_9
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_10       	:' || p_service_request_rec.request_attribute_10
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_11       	:' || p_service_request_rec.request_attribute_11
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_12       	:' || p_service_request_rec.request_attribute_12
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_13       	:' || p_service_request_rec.request_attribute_13
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_14       	:' || p_service_request_rec.request_attribute_14
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_attribute_15       	:' || p_service_request_rec.request_attribute_15
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'request_context            	:' || p_service_request_rec.request_context
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_1       	:' || p_service_request_rec.external_attribute_1
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_2       	:' || p_service_request_rec.external_attribute_2
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_3       	:' || p_service_request_rec.external_attribute_3
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_4       	:' || p_service_request_rec.external_attribute_4
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_5       	:' || p_service_request_rec.external_attribute_5
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_6       	:' || p_service_request_rec.external_attribute_6
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_7       	:' || p_service_request_rec.external_attribute_7
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_8       	:' || p_service_request_rec.external_attribute_8
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_9       	:' || p_service_request_rec.external_attribute_9
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_10      	:' || p_service_request_rec.external_attribute_10
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_11      	:' || p_service_request_rec.external_attribute_11
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_12      	:' || p_service_request_rec.external_attribute_12
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_13      	:' || p_service_request_rec.external_attribute_13
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_14      	:' || p_service_request_rec.external_attribute_14
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_attribute_15      	:' || p_service_request_rec.external_attribute_15
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_context           	:' || p_service_request_rec.external_context
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_site_use_id        	:' || p_service_request_rec.bill_to_site_use_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_contact_id         	:' || p_service_request_rec.bill_to_contact_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_site_use_id        	:' || p_service_request_rec.ship_to_site_use_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_contact_id         	:' || p_service_request_rec.ship_to_contact_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resolution_code            	:' || p_service_request_rec.resolution_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'act_resolution_date        	:' || p_service_request_rec.act_resolution_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'public_comment_flag        	:' || p_service_request_rec.public_comment_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'parent_interaction_id      	:' || p_service_request_rec.parent_interaction_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contract_service_id        	:' || p_service_request_rec.contract_service_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contract_service_number    	:' || p_service_request_rec.contract_service_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'contract_id                	:' || p_service_request_rec.contract_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'project_number            	:' || p_service_request_rec.project_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'qa_collection_plan_id      	:' || p_service_request_rec.qa_collection_plan_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'account_id                 	:' || p_service_request_rec.account_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resource_type              	:' || p_service_request_rec.resource_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resource_subtype_id        	:' || p_service_request_rec.resource_subtype_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_po_number             	:' || p_service_request_rec.cust_po_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_ticket_number         	:' || p_service_request_rec.cust_ticket_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'sr_creation_channel        	:' || p_service_request_rec.sr_creation_channel
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'obligation_date            	:' || p_service_request_rec.obligation_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'time_zone_id               	:' || p_service_request_rec.time_zone_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'time_difference            	:' || p_service_request_rec.time_difference
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'site_id                    	:' || p_service_request_rec.site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'customer_site_id           	:' || p_service_request_rec.customer_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'territory_id               	:' || p_service_request_rec.territory_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'initialize_flag            	:' || p_service_request_rec.initialize_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cp_revision_id             	:' || p_service_request_rec.cp_revision_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_item_revision          	:' || p_service_request_rec.inv_item_revision
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_component_id               	:' || p_service_request_rec.inv_component_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_component_version      	:' || p_service_request_rec.inv_component_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_subcomponent_id        	:' || p_service_request_rec.inv_subcomponent_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_subcomponent_version   	:' || p_service_request_rec.inv_subcomponent_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'tier                       	:' || p_service_request_rec.tier
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'tier_version               	:' || p_service_request_rec.tier_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'operating_system           	:' || p_service_request_rec.operating_system
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'operating_system_version   	:' || p_service_request_rec.operating_system_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'database                   	:' || p_service_request_rec.database
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_pref_lang_id          	:' || p_service_request_rec.cust_pref_lang_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'category_id                	:' || p_service_request_rec.category_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'group_type                 	:' || p_service_request_rec.group_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'group_territory_id         	:' || p_service_request_rec.group_territory_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inv_platform_org_id        	:' || p_service_request_rec.inv_platform_org_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'component_version         	:' || p_service_request_rec.component_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'subcomponent_version      	:' || p_service_request_rec.subcomponent_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'product_revision           	:' || p_service_request_rec.product_revision
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'comm_pref_code             	:' || p_service_request_rec.comm_pref_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cust_pref_lang_code        	:' || p_service_request_rec.cust_pref_lang_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'last_update_channel        	:' || p_service_request_rec.last_update_channel
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'category_set_id            	:' || p_service_request_rec.category_set_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'external_reference         	:' || p_service_request_rec.external_reference
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'system_id                  	:' || p_service_request_rec.system_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'error_code                 	:' || p_service_request_rec.error_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_occurred_date     	:' || p_service_request_rec.incident_occurred_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_resolved_date     	:' || p_service_request_rec.incident_resolved_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'inc_responded_by_date      	:' || p_service_request_rec.inc_responded_by_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'resolution_summary         	:' || p_service_request_rec.resolution_summary
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_id       	:' || p_service_request_rec.incident_location_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address          	:' || p_service_request_rec.incident_address
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_city              	:' || p_service_request_rec.incident_city
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_state             	:' || p_service_request_rec.incident_state
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_country           	:' || p_service_request_rec.incident_country
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_province          	:' || p_service_request_rec.incident_province
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_postal_code       	:' || p_service_request_rec.incident_postal_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_county            	:' || p_service_request_rec.incident_county
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owner                     	:' || p_service_request_rec.owner
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'group_owner                	:' || p_service_request_rec.group_owner
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_number                 	:' || p_service_request_rec.cc_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_expiration_date         	:' || p_service_request_rec.cc_expiration_date
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_type_code              	:' || p_service_request_rec.cc_type_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_first_name             	:' || p_service_request_rec.cc_first_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_last_name              	:' || p_service_request_rec.cc_last_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_middle_name            	:' || p_service_request_rec.cc_middle_name
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'cc_id                     	:' || p_service_request_rec.cc_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_account_id             	:' || p_service_request_rec.bill_to_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_account_id               	:' || p_service_request_rec.ship_to_account_id
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
    , 'creation_program_code      	:' || p_service_request_rec.creation_program_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'last_update_program_code   	:' || p_service_request_rec.last_update_program_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_party_id           	:' || p_service_request_rec.bill_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_party_id           	:' || p_service_request_rec.ship_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'program_id                 	:' || p_service_request_rec.program_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'program_application_id     	:' || p_service_request_rec.program_application_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'conc_request_id             	:' || p_service_request_rec.conc_request_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'program_login_id           	:' || p_service_request_rec.program_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'bill_to_site_id           	:' || p_service_request_rec.bill_to_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'ship_to_site_id           	:' || p_service_request_rec.ship_to_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_point_of_interest       	:' || p_service_request_rec.incident_point_of_interest
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_cross_street            	:' || p_service_request_rec.incident_cross_street
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_direction_qualifier      	:' || p_service_request_rec.incident_direction_qualifier
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_distance_qualifier      	:' || p_service_request_rec.incident_distance_qualifier
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_distance_qual_uom        	:' || p_service_request_rec.incident_distance_qual_uom
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address2                	:' || p_service_request_rec.incident_address2
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address3                  	:' || p_service_request_rec.incident_address3
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address4                	:' || p_service_request_rec.incident_address4
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_address_style             	:' || p_service_request_rec.incident_address_style
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_addr_lines_phonetic     	:' || p_service_request_rec.incident_addr_lines_phonetic
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_po_box_number            	:' || p_service_request_rec.incident_po_box_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_house_number              	:' || p_service_request_rec.incident_house_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_street_suffix            	:' || p_service_request_rec.incident_street_suffix
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_street                    	:' || p_service_request_rec.incident_street
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_street_number            	:' || p_service_request_rec.incident_street_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_floor                    	:' || p_service_request_rec.incident_floor
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_suite                    	:' || p_service_request_rec.incident_suite
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_postal_plus4_code        	:' || p_service_request_rec.incident_postal_plus4_code
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_position                 	:' || p_service_request_rec.incident_position
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_directions      	:' || p_service_request_rec.incident_location_directions
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_description     	:' || p_service_request_rec.incident_location_description
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'install_site_id                   	:' || p_service_request_rec.install_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'item_serial_number	:' || p_service_request_rec.item_serial_number
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'owning_department_id	:' || p_service_request_rec.owning_department_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'incident_location_type	:' || p_service_request_rec.incident_location_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'coverage_type           	:' || p_service_request_rec.coverage_type
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'maint_organization_id   	:' || p_service_request_rec.maint_organization_id
    );
/*Credit Card 9358401 */
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'instrument_payment_use_id    :' || p_service_request_rec.instrument_payment_use_id
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

END Log_SR_PUB_Parameters;


END CS_ServiceRequest_PUB;

/
