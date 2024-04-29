--------------------------------------------------------
--  DDL for Package IEM_SERVICEREQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SERVICEREQUEST_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvsrvs.pls 120.1 2006/02/10 07:33:12 pkesani noship $ */

--
--
-- Purpose: Maintain Tag Process
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  3/24/2002    Created
--  Liang Xia  8/25/2003    Create Update_Status_Wrap based on 1159 release
--                          cspsrs.pls 115.49
--                          cspsrb.pls 115.63
--                          csvsrs.pls 115.67
--                          csvsrb.pls 115.222
--  PKESANI    02/09/2006  As a part of ACSR project, added procedure IEM_CREATE_SR
--                         as a wrapper API for auto create SR.
-- ---------   ------  -----------------------------------------

-- Enter procedure, function bodies as shown below

/*GLOBAL VARIABLES AVAILABLE TO THE PUBLIC FOR CALLING
  ===================================================*/

G_PKG_NAME varchar2(255)    :='IEM_SERVICEREQUEST_PVT';
G_INITIALIZED       CONSTANT VARCHAR2(1)  := 'R';

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
     summary                    VARCHAR2(80),
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
     cp_component_id               NUMBER,
     cp_component_version_id       NUMBER,
     cp_subcomponent_id            NUMBER,
     cp_subcomponent_version_id    NUMBER,
     language_id                NUMBER,
     language                   VARCHAR2(4),
     cp_ref_number              NUMBER,
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
     inv_item_revision          VARCHAR2(3),
     inv_component_id           NUMBER,
     inv_component_version      VARCHAR2(3),
     inv_subcomponent_id        NUMBER,
     inv_subcomponent_version   VARCHAR2(3),
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
     last_update_channel        VARCHAR2(10)
------jngeorge---------------07/12/01
);


--     customer_prefix            VARCHAR2(50),
--     customer_firstname         VARCHAR2(150),
--     customer_lastname          VARCHAR2(150),
--     customer_company_name      VARCHAR2(255),


--     install_location           VARCHAR2(240),
--     install_customer           VARCHAR2(150),
--     install_country            VARCHAR2(60),
--     install_address_1          VARCHAR2(240),
--     install_address_2          VARCHAR2(240),
--     install_address_3          VARCHAR2(240),


--     bill_to_location           VARCHAR2(240),
--     bill_to_customer           VARCHAR2(150),
--     bill_country               VARCHAR2(60),
--     bill_to_address_1          VARCHAR2(240),
--     bill_to_address_2          VARCHAR2(240),
--     bill_to_address_3          VARCHAR2(240),
--     bill_to_contact            VARCHAR2(150),


--     ship_to_location           VARCHAR2(240),
--     ship_to_customer           VARCHAR2(150),
--     ship_country               VARCHAR2(60),
--     ship_to_address_1          VARCHAR2(240),
--     ship_to_address_2          VARCHAR2(240),
--     ship_to_address_3          VARCHAR2(240),
--     ship_to_contact            VARCHAR2(150),



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

TYPE contacts_rec IS RECORD (
  SR_CONTACT_POINT_ID            NUMBER            := FND_API.G_MISS_NUM,
   PARTY_ID                       NUMBER         := FND_API.G_MISS_NUM,
   CONTACT_POINT_ID               NUMBER         := FND_API.G_MISS_NUM,
   CONTACT_POINT_TYPE             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
   PRIMARY_FLAG                   VARCHAR2(1)    := FND_API.G_MISS_CHAR,
   CONTACT_TYPE                   VARCHAR2(30)   :=FND_API.G_MISS_CHAR
);

TYPE contacts_table IS TABLE OF contacts_rec INDEX BY BINARY_INTEGER;


--
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





PROCEDURE Create_ServiceRequest_Wrap
( p_api_version			  IN      NUMBER,
  p_init_msg_list		  IN      VARCHAR2 	:= null,
  p_commit			       IN      VARCHAR2 	:= null,
  x_return_status		  OUT  NOCOPY   VARCHAR2,
  x_msg_count			  OUT  NOCOPY   NUMBER,
  x_msg_data			  OUT  NOCOPY   VARCHAR2,
  p_resp_appl_id		  IN      NUMBER		:= NULL,
  p_resp_id			      IN      NUMBER		:= NULL,
  p_user_id			      IN      NUMBER		:= NULL,
  p_login_id			  IN      NUMBER		:= NULL,
  p_org_id			      IN      NUMBER		:= NULL,
  p_request_id            IN      NUMBER                := NULL,
  p_request_number		  IN      VARCHAR2		:= NULL,
  p_service_request_rec           IN      service_request_rec_type,
  p_notes                         IN      notes_table,
  p_contacts                      IN      contacts_table,
  x_request_id			  OUT  NOCOPY   NUMBER,
  x_request_number		  OUT  NOCOPY   VARCHAR2,
  x_interaction_id        OUT   NOCOPY  NUMBER,
  x_workflow_process_id   OUT   NOCOPY  NUMBER
);


--------------------------------------------------------------------------
-- Start of comments
--  API name	: Update_ServiceRequest_Wrap
--  Type	: Public
--  Function	: Calling  CS_ServiceRequest_PUB.Update_ServiceRequest to
--                updates a service request in the table CS_INCIDENTS_ALL.
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
--	cp_ref_number		  NUMBER	 Optional
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

PROCEDURE Update_ServiceRequest_Wrap(
  p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2      := null,
  p_commit                 IN     VARCHAR2      := null,
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
  p_last_update_login      IN     NUMBER        := NULL,
  p_last_update_date       IN     DATE,
  p_service_request_rec    IN     service_request_rec_type,
  p_notes                  IN     notes_table,
  p_contacts               IN     contacts_table,
  p_called_by_workflow     IN     VARCHAR2      := FND_API.G_FALSE,
  p_workflow_process_id    IN     NUMBER        := NULL,
  x_workflow_process_id    OUT    NOCOPY NUMBER,
  x_interaction_id         OUT    NOCOPY NUMBER
);

PROCEDURE initialize_rec(
  p_sr_record                   IN OUT NOCOPY  service_request_rec_type
);

PROCEDURE Update_Status_Wrap
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
  x_interaction_id		 OUT	NOCOPY NUMBER
);

PROCEDURE IEM_CREATE_SR
( p_api_version			  IN   NUMBER,
  p_init_msg_list		  IN   VARCHAR2 	:= FND_API.G_FALSE,
  p_commit		          IN   VARCHAR2 	:= FND_API.G_FALSE,
  p_message_id   		  IN   NUMBER,
  p_note		          IN   VARCHAR2,
  p_party_id                      IN   NUMBER,
  p_sr_type_id                    IN   NUMBER,
  p_subject                       IN   VARCHAR2,
  p_employee_flag                 IN   VARCHAR2,
  p_note_type                     IN   VARCHAR2,
  p_contact_id                    IN   NUMBER             := NULL,
  p_contact_point_id              IN   NUMBER             := NULL,
  x_return_status		  OUT  NOCOPY   VARCHAR2,
  x_msg_count			  OUT  NOCOPY  NUMBER,
  x_msg_data			  OUT  NOCOPY  VARCHAR2,
  x_request_id                    OUT  NOCOPY  NUMBER
);

END;

 

/
