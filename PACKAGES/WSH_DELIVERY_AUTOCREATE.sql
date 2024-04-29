--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_AUTOCREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_AUTOCREATE" AUTHID CURRENT_USER as
/* $Header: WSHDEAUS.pls 120.3.12010000.2 2009/12/03 13:33:14 mvudugul ship $ */
--<TPA_PUBLIC_NAME=WSH_TPA_DELIVERY_PKG>
--<TPA_PUBLIC_FILE_NAME=WSHTPDE>

--
--	Package type definitions
--




--
-- Type:	Group_by_flags_rec_type
-- Definition:	Record of group by attribute flags
-- Use:		To store group by information for delivery details
--

TYPE group_by_flags_rec_type IS RECORD (
	organization_id NUMBER,
	customer        VARCHAR2(1) := 'Y',
	intmed          VARCHAR2(1) := 'Y',
	fob             VARCHAR2(1) := 'Y',
	freight_terms   VARCHAR2(1) := 'Y',
	ship_method     VARCHAR2(1) := 'Y',
	carrier         VARCHAR2(1) := 'Y',
	header          VARCHAR2(1) := 'N',
	deliver_to	VARCHAR2(1) := 'N',
	delivery_id    VARCHAR2(1) := 'N'
	);



--
-- Type:	Group_by_flags_tab_type
-- Definition:	Table of group_by_flags_rec_type
-- Use:		To store group by information for delivery details per
--		organization. This is used to obviate querying up this
--		information for each delivery detail, thereby making the
--		autocreate delivery process faster for large detail processing.
--

TYPE group_by_flags_tab_type IS TABLE OF group_by_flags_rec_type
INDEX BY BINARY_INTEGER;

group_by_info_tab       group_by_flags_tab_type;
group_by_info   group_by_flags_rec_type;

-- Variable:	Detail_Num
-- Use:		To commit changes once a maximum commit number has been
--			reached (useful when called from Pick Release)

detail_num	NUMBER := 0;

--
-- Function:      Check_Sch_Date_Match
-- Parameters:    p_delivery_id, p_del_date, p_detail_date
-- Description:   Checks if scheduled date on line matches initial pickup date on delivery
--                FOR THE PRESENT, FUNCTION SIMPLY RETURNS TRUE
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--

FUNCTION Check_Sch_Date_Match ( p_delivery_id IN NUMBER,
				p_del_date IN DATE,
                                p_detail_date IN DATE) RETURN BOOLEAN;
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

--
-- Function:      Check_Req_Date_Match
-- Parameters:    p_delivery_id, p_del_date, p_detail_date
-- Description:   Checks if requested date on line matches ultimate dropoff date on delivery
--                FOR THE PRESENT, FUNCTION SIMPLY RETURNS TRUE
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--

FUNCTION Check_Req_Date_Match ( p_delivery_id IN NUMBER,
				p_del_date IN DATE,
                                p_detail_date IN DATE) RETURN BOOLEAN;
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

--
-- Procedure:	Autocreate_deliveries
-- Parameters:	p_line_rows, p_line_info_rows, p_init_flag,
--		p_use_header_flag, p_max_detail_commit, p_del_rows
-- Description:	Used to automatically create deliveries
--		p_line_rows		- Table of delivery detail ids
--		p_init_flag		- 'Y' initializes the table of deliveries
--		p_pick_release_flag	- 'Y' means use header_id for grouping
--		p_container_flag	- 'Y' means call Autopack routine
--		p_check_flag		- 'Y' means delivery details will be
--		  		          grouped without creating deliveries
--              p_caller                - R12 introduction for Routing Guide integration
--              p_generate_carton_group_id - 'Y' means api called for generate
--                                         carton group id only
--		p_max_detail_commit	- Commits data after delivery detail
--					  count reaches this value
--              p_firm_deliveries       - 'Y' : plan the delivery at creation, when
--                                              doing autopack or auto ship confirm during
--                                              pick release , to prevent appending
--                                        'N' : do not plan the delivery at creation
--              p_get_autocreate_del_criteria  - 'Y' get the autocreate_del_criteria from
--                                               shipping parameters for grouping attributes
--                                             - 'N' do not check autocreate_del_criteria of
--                                                shipping parameters
--		p_del_rows		- Created delivery ids
--		p_grouping_rows		- returns group ids for each detail,
--					  when p_check_flag is set to 'Y'
--		x_return_status	- Status of execution


PROCEDURE autocreate_deliveries(
			p_line_rows 			IN 	wsh_util_core.id_tab_type,
			p_init_flag			IN	VARCHAR2,
			p_pick_release_flag		IN	VARCHAR2,
			p_container_flag		IN	VARCHAR2 := 'N',
			p_check_flag			IN	VARCHAR2 := 'N',
                        p_caller                        IN      VARCHAR2  DEFAULT   NULL,
			p_generate_carton_group_id	IN	VARCHAR2 := 'N',
			p_max_detail_commit		IN	NUMBER := 1000,
			x_del_rows 			OUT NOCOPY  	WSH_UTIL_CORE.id_tab_type,
			x_grouping_rows			OUT NOCOPY 	wsh_util_core.id_tab_type,
			x_return_status 		OUT NOCOPY  	VARCHAR2
			);

-- bug 1668578
--
-- Procedure:	Autocreate_del_across_orgs
-- Parameters:	p_line_rows, p_line_info_rows, p_init_flag,
--		p_use_header_flag, p_max_detail_commit, p_del_rows
-- Description:	Used to automatically create deliveries
--		p_line_rows		- Table of delivery detail ids
--		p_org_rows 		- a table of organization_ids.  If this
-- 			     		- table is not available to pass
--                     		- then pass a dummy value in. the table
-- 			     		- will get regenerated when calling
--                      		- WSH_DELIVERY_AUTOCREATE.autocreate_del_across_orgs
--		p_container_flag	- 'Y' means call Autopack routine
--		p_check_flag		- 'Y' means delivery details will be
--		  		             grouped without creating deliveries
--              p_caller                - R12 introduction for Routing Guide integration
--		p_max_detail_commit	- Commits data after delivery detail
--					       count reaches this value
--		p_del_rows		- Created delivery ids
--		p_grouping_rows	- returns group ids for each detail,
--					       when p_check_flag is set to 'Y'
--		x_return_status	- Status of execution

PROCEDURE autocreate_del_across_orgs(
			p_line_rows 			IN 	wsh_util_core.id_tab_type,
			p_org_rows 			IN 	wsh_util_core.id_tab_type,
			p_container_flag		IN	VARCHAR2 := 'N',
			p_check_flag			IN	VARCHAR2 := 'N',
                        p_caller                        IN      VARCHAR2  DEFAULT   NULL,
			p_max_detail_commit		IN	NUMBER := 1000,
			p_group_by_header_flag          IN      VARCHAR2 DEFAULT NULL,
			x_del_rows 			OUT NOCOPY  	WSH_UTIL_CORE.id_tab_type,
			x_grouping_rows			OUT NOCOPY 	wsh_util_core.id_tab_type,
			x_return_status 		OUT NOCOPY  	VARCHAR2
		    	);
-- end bug 1668578

PROCEDURE delete_empty_deliveries(
                        p_batch_id      IN NUMBER,
                        x_return_status OUT NOCOPY      VARCHAR2 );

--------------------------------------------------------------------------
--
-- Procedure:   unassign_empty_containers
-- Parameters:  p_delivery_id
--              x_return_status
--
-- Description: Used to unassign empty containers from delivery after Pick Release
--              p_delivery_ids  - table index by delivery ids
--              x_return_status - Status of execution
--------------------------------------------------------------------------
PROCEDURE unassign_empty_containers(
                        p_delivery_ids      IN WSH_PICK_LIST.unassign_delivery_id_type,
                        x_return_status     OUT NOCOPY      VARCHAR2 );


TYPE	GRP_ATTR_REC_TYPE IS RECORD (
        batch_id                        number,
        group_id                        number,
        entity_id                       number,
        entity_type                     varchar2(30),
        status_code                     varchar2(30),
        planned_flag                    varchar2(1),
	ship_to_location_id		wsh_delivery_details.ship_to_location_id%type,
	ship_from_location_id		wsh_delivery_details.ship_from_location_id%type,
	customer_id			wsh_delivery_details.customer_id%type,
	intmed_ship_to_location_id	wsh_delivery_details.intmed_ship_to_location_id%type,
	fob_code			wsh_delivery_details.fob_code%type,
	freight_terms_code		wsh_delivery_details.freight_terms_code%type,
	ship_method_code		wsh_delivery_details.ship_method_code%type,
	carrier_id			wsh_delivery_details.carrier_id%type,
	source_header_id		wsh_delivery_details.source_header_id%type,
	deliver_to_location_id		wsh_delivery_details.deliver_to_location_id%type,
	organization_id			wsh_delivery_details.organization_id%type,
	date_scheduled                  wsh_delivery_details.date_scheduled%type,
	date_requested                  wsh_delivery_details.date_requested%type,
	delivery_id                     wsh_new_deliveries.delivery_id%type,
        ignore_for_planning             wsh_delivery_details.ignore_for_planning%type DEFAULT 'N',--J TP Release
        line_direction                  wsh_delivery_details.line_direction%TYPE,     -- J-IB-NPARIKH
        shipping_control                wsh_delivery_details.shipping_control%TYPE,   -- J-IB-NPARIKH
        vendor_id                       wsh_delivery_details.vendor_id%TYPE,          -- J-IB-NPARIKH
        party_id                        wsh_delivery_details.party_id%TYPE,           -- J-IB-NPARIKH
        mode_of_transport               wsh_delivery_details.mode_of_transport%TYPE,
        service_level                   wsh_delivery_details.service_level%TYPE,
        lpn_id                          wsh_delivery_details.lpn_id%TYPE,
        inventory_item_id               wsh_delivery_details.inventory_item_id%TYPE,
        source_code                     wsh_delivery_details.source_code%TYPE,
        container_flag                  wsh_delivery_details.container_flag%TYPE,
        l1_hash_string                  varchar2(1000),
        l1_hash_value                   number,
        is_xdocked_flag                 varchar2(1) DEFAULT 'N',--X-dock
        client_id                       number -- LSP PROJECT
);

TYPE grp_attr_tab_type IS TABLE OF GRP_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------
--
-- Procedure:   Get_Group_By_Attr
-- Parameters:  p_organization_id, x_group_by_flags, x_return_status
-- Description: Gets group by attributes for the delivery organization
--              and stores this in a temporary table for future comparison
--              p_delivery_id           - Delivery ID
--        x_group_by_flags    - group by attributes record
--
-- LSP PROJECT : Added client Id parameter : Get the group by attributes from client
--          if cleint_id is not null. If client_id is null then grouping paramters
--          for the organization

-----------------------------------------------------------------------------

PROCEDURE get_group_by_attr (
                p_organization_id       IN      NUMBER,
                p_client_id             IN      NUMBER DEFAULT NULL,
                x_group_by_flags    OUT NOCOPY   group_by_flags_rec_type,
                x_return_status OUT NOCOPY      VARCHAR2,
                p_group_by_header_flag IN VARCHAR2 DEFAULT 'N');

-- Create_Hash: This API will create a hash_string and generate corresponding hash value based on the
--              grouping attributes of the input records. It will not append the ship method
--              code or its components to the hash string.
-- p_grouping_attributes: record of attributes or entity that needs hash generated.

Procedure Create_Hash(p_grouping_attributes IN OUT NOCOPY grp_attr_tab_type,
          p_group_by_header IN varchar2,
          p_action_code   IN varchar2,
          x_return_status OUT NOCOPY  VARCHAR2);



Procedure Create_Update_Hash(p_delivery_rec IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
                             x_return_status out NOCOPY varchar2);


type action_rec_type is record (action varchar2(30),
                           caller varchar2(30),
                           group_by_header_flag varchar2(1),
                           group_by_delivery_flag varchar2(1),
                           output_format_type varchar2(30),
                           output_entity_type varchar2(30),
                           check_single_grp varchar2(1));

type out_rec_type is record (query_string varchar2(4000),
                        single_group varchar2(1),
                        bind_hash_value number,
                        bind_hash_string varchar2(1000),
                        bind_batch_id number,
                        bind_header_id number,
                        bind_carrier_id number,
                        bind_mode_of_transport varchar2(30),
                        bind_service_level varchar2(30),
			bind_ship_method_code varchar2(30),  --bug6074966
                        bind_client_id number); -- LSP PROJECT




-- Find_Matching_Groups: This API will find entities (deliveries/containers) that
--                       match the grouping criteria of the input table of entities.
-- p_attr_tab: Table of entities or record of grouping criteria that need to be matched.
-- p_action_rec: Record of specific actions and their corresponding parameters.
--               check_single_grp_only:  ('Y', 'N') will  check only of the records can be
--                                       grouped together.
--               output_entity_type: ('DLVY', 'CONT') the entity type that the input records
--                                   need to be matched with.
--               output_format_type: Format of the output.
--                                   'ID_TAB': table of id's of the matched entities
--                                   'TEMP_TAB': The output will be inserted into wsh_temp (wsh_temp
--                                               needs to be cleared after this API has been used).
--                                   'SQL_STRING': Will return a SQL query to find the matching entities
--                                                 as a string and values of the variables that will
--                                                 need to be bound to the string.
-- p_target_rec: Entity or grouping attributes that need to be matched with (if necessary)
-- x_matched_entities: table of ids of the matched entities
-- x_out_rec: Record of output values based on the actions and output format.
--            query_string: String to query for matching entities. The following
--            will have to be bound to the string before executing the query.
--            bind_hash_value
--            bind_hash_string
--            bind_batch_id
--            bind_carrier_id
--            bind_mode_of_transport
--            bind_service_level
--     bind_ship_method_code
--     bind_client_id -- LSP PROJECT
-- x_return_status: 'S', 'E', 'U'.


PROCEDURE Find_Matching_Groups(p_attr_tab IN OUT NOCOPY grp_attr_tab_type,
                     p_action_rec IN action_rec_type,
                     p_target_rec IN grp_attr_rec_type,
                     p_group_tab IN OUT NOCOPY grp_attr_tab_type,
                     x_matched_entities OUT NOCOPY wsh_util_core.id_tab_type,
                     x_out_rec out NOCOPY out_rec_type,
                     x_return_status out NOCOPY varchar2);

PROCEDURE Reset_WSH_TMP;

/**________________________________________________________________________
--
-- Name:
-- Autocreate_Consol_Del
--
-- Purpose:
-- This API takes in a table of child deliveries and delivery attributes,
-- and creates a consolidation delivery. It currently assumes that
-- all the child deliveries can be grouped together and assigned to
-- a single parent delivery when called by the WSH CONSOL SRS.
-- Parameters:
-- p_del_attributes_tab: Table of deliveries and attributes that need to
-- have parent delivery autocreated.
-- p_caller: Calling entity/action
-- x_parent_del_tab: Delivery ids of the newly created parent deliveries.
-- x_return_status: status.
**/

PROCEDURE Autocreate_Consol_Delivery(
 p_del_attributes_tab IN WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
 p_caller IN VARCHAR2,
 p_trip_prefix IN VARCHAR2 DEFAULT NULL,
 x_parent_del_id OUT NOCOPY NUMBER,
 x_parent_trip_id OUT NOCOPY NUMBER,
 x_return_status OUT NOCOPY VARCHAR2);



END WSH_DELIVERY_AUTOCREATE;


/
