--------------------------------------------------------
--  DDL for Package CS_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_STD" AUTHID CURRENT_USER as
/* $Header: csxcstds.pls 120.0.12010000.2 2009/04/17 12:36:13 sanjrao ship $ */
--
--
--
--
	procedure Get_Default_Values(flex_code               IN  VARCHAR2 DEFAULT 'MSTK',
						    mfg_org_id              IN OUT NOCOPY NUMBER,
						    appl_short_name         IN OUT NOCOPY VARCHAR2);

	procedure Get_Default_Values(flex_code               IN  VARCHAR2 DEFAULT 'MSTK',
						    mfg_org_id              IN OUT NOCOPY NUMBER,
						    mfg_org_name            IN OUT NOCOPY VARCHAR2,
						    appl_short_name         IN OUT NOCOPY VARCHAR2);

	procedure Get_Default_Values(order_by_code           IN  VARCHAR2,
						    order_by_lookup_type    IN  VARCHAR2,
						    flex_code               IN  VARCHAR2 DEFAULT 'MSTK',
						    mfg_org_id          IN    OUT NOCOPY NUMBER,
						    appl_short_name     IN    OUT NOCOPY VARCHAR2,
						    order_by            IN    OUT NOCOPY VARCHAR2);

	procedure Get_Default_Values(order_by_code           IN  VARCHAR2,
						    order_by_lookup_type    IN  VARCHAR2,
						    flex_code               IN  VARCHAR2 DEFAULT 'MSTK',
						    mfg_org_id          IN    OUT NOCOPY NUMBER,
						    appl_short_name     IN    OUT NOCOPY VARCHAR2,
						    order_by            IN    OUT NOCOPY VARCHAR2,
						    order_type IN VARCHAR2,
						    order_type_id IN OUT NOCOPY NUMBER,
						    day_uom_code IN VARCHAR2,
						    day_uom      IN OUT NOCOPY VARCHAR2,
						    month_uom_code IN VARCHAR2,
						    month_uom      IN OUT NOCOPY VARCHAR2 );

	--
	--
	--Get the coterminated end date. It assumes that p_cot_day_mth
	--is in American English DD-MON format. (even though this is not
	--NLS compliant
-- Commented the function because it not GSCC complaint

/*     function get_coterminated_end_dt
	(
		p_cot_day_mth      varchar2,
		p_start_dt         date       default sysdate
	) return date;
	pragma RESTRICT_REFERENCES (get_coterminated_end_dt,WNDS,WNPS);
	--

*/
	--Get the contact's primary phone#.
	function get_contact_phone
	(
		p_contact_id       number
	) return varchar2;
	pragma RESTRICT_REFERENCES (get_contact_phone,WNDS,WNPS);
	--
	--
	--Get the item's revision description.
	--If p_error_flag is 'FALSE', then a NULL is returned if the revision is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the revision is invalid, and it is upto the calling code to handle it.
	function get_item_rev_desc
	(
		p_org_id           number,
		p_inv_item_id      number,
		p_revision         varchar2,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2;
	pragma RESTRICT_REFERENCES (get_item_rev_desc,WNDS,WNPS);
	--
	--
	--Get the site_use_id's location.
	--If p_error_flag is 'FALSE', then a NULL is returned if the site_use is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the site_use is invalid, and it is upto the calling code to handle it.
	function get_site_use_location
	(
		p_site_use_id      number,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2;
	pragma RESTRICT_REFERENCES (get_site_use_location,WNDS,WNPS);
	--
	--
	--Get the customer name.
	--If p_error_flag is 'FALSE', then a NULL is returned if the PK is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the PK is invalid, and it is upto the calling code to handle it.
	function get_cust_name
	(
		p_customer_id      number,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2;
	pragma RESTRICT_REFERENCES (get_cust_name,WNDS,WNPS);
	--
	--
	--Get the comma-separated item_ids of the attached warranties on an item,
	--as on p_war_date. The Item-Validation-Organization of the attached
	--warranty is the same as the item's.
	--Note: Used by CSOEBAT and CSXSUDCP form as of 1/29/97.
	function get_war_item_ids
	(
		p_organization_id   number,
		p_inventory_item_id number,
		p_war_date          date    default sysdate
	) return varchar2;
        -- Bug 4321391. removed pragma restriction because bom_bill_of_materials view
        -- uses fnd_global
	--pragma RESTRICT_REFERENCES (get_war_item_ids,WNDS,WNPS);
	--
	--
	--Get the system's name.
	--If p_error_flag is 'FALSE', then a NULL is returned if the PK is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the PK is invalid, and it is upto the calling code to handle it.
	function get_system_name
	(
		p_system_id		number,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2;
	pragma RESTRICT_REFERENCES (get_system_name,WNDS,WNPS);
	--
	--
	--
	-- This function returns Y or N for warranty attached to a customer
     -- product_id
	function warranty_exists
	(
	    cp_id  NUMBER
     )  return VARCHAR2 ;
	pragma RESTRICT_REFERENCES (warranty_exists,WNDS,WNPS);

      procedure Get_Primary_Address(x_id NUMBER,
                                   x_site_use_code VARCHAR2,
                                   x_location OUT NOCOPY VARCHAR2,
                                   x_site_use_id OUT NOCOPY NUMBER,
                                   x_address1 OUT NOCOPY VARCHAR2,
                                   x_address2 OUT NOCOPY VARCHAR2,
                                   x_address3 OUT NOCOPY VARCHAR2,
                                   error_flag OUT NOCOPY NUMBER) ;

      -- CS_Get_Serviced_Status
      FUNCTION CS_Get_Serviced_Status
	( X_CP_ID IN NUMBER
	) RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES (cs_get_serviced_status,WNDS,WNPS);

/******
      procedure Output_Messages( p_return_status   VARCHAR2,
                                 p_msg_count       NUMBER) ;

******/
      procedure Get_Address_from_id(x_id NUMBER,
                                   x_location OUT NOCOPY VARCHAR2,
                                   x_address1 OUT NOCOPY VARCHAR2,
                                   x_address2 OUT NOCOPY VARCHAR2,
                                   x_address3 OUT NOCOPY VARCHAR2,
                                   error_flag OUT NOCOPY NUMBER) ;

	-- This function returns the next entry in a periodic cycle.
	-- As of 9/1/98, only 12 mth periods are supported. Thus, on subsequent
	-- invocations, this functions currently returns 1, 2, ... 12, 1, 2, ...
	-- p_reset = 1 will reset cycle.
	function GetNextValInPeriod
	(
	    p_reset  NUMBER
     ) return number ;
	pragma RESTRICT_REFERENCES (GetNextValInPeriod, WNDS, RNDS);

	-- This function returns the item category of an item in the OE
	-- category set.
	function GetItemCategory
	(
	    p_inv_item_id number,
	    p_inv_orgn_id number
     ) return varchar2;
	pragma RESTRICT_REFERENCES (GetItemCategory, WNDS, WNPS);

FUNCTION SITE_USE_ADDRESS(site_id IN NUMBER) RETURN VARCHAR2 ;

	-- This function returns the "inventory organization" ID (or whats also
	-- called the "warehouse" ID that the Service suite of products should
	-- use for validating items
	function Get_Item_Valdn_Orgzn_ID return number;
--	pragma RESTRICT_REFERENCES (Get_Item_Valdn_Orgzn_ID, WNDS, WNPS);
	pragma RESTRICT_REFERENCES (Get_Item_Valdn_Orgzn_ID, WNDS);

/* The Following Function will take address fields and Format them based on
   HZ_FORMAT_PUB. In case of error, it returns a simple concatenation of fields.*/


FUNCTION format_address( address_style IN VARCHAR2,
                         address1 IN VARCHAR2,
                         address2 IN VARCHAR2,
                         address3 IN VARCHAR2,
                         address4 IN VARCHAR2,
                         city IN VARCHAR2,
                         county IN VARCHAR2,
                         state IN VARCHAR2,
                         province IN VARCHAR2,
                         postal_code IN VARCHAR2,
                         territory_short_name IN VARCHAR2,
                         country_code IN VARCHAR2 default NULL,
                         customer_name IN VARCHAR2 default NULL,
                         first_name IN VARCHAR2 default NULL,
                         last_name IN VARCHAR2 default NULL,
                         mail_stop IN VARCHAR2 default NULL,
                         default_country_code IN VARCHAR2 default NULL,
                         default_country_desc IN VARCHAR2 default NULL,
                         print_home_country_flag IN VARCHAR2 default NULL,
                         print_default_attn_flag IN VARCHAR2 default NULL,
                         width IN NUMBER default NULL,
                         height_min IN NUMBER default NULL,
                         height_max IN NUMBER default NULL
                        )return VARCHAR2;
--pragma RESTRICT_REFERENCES (format_address, WNDS,WNPS);

FUNCTION format_address_concat( address_style IN VARCHAR2,
                         address1 IN VARCHAR2,
                         address2 IN VARCHAR2,
                         address3 IN VARCHAR2,
                         address4 IN VARCHAR2,
                         city IN VARCHAR2,
                         county IN VARCHAR2,
                         state IN VARCHAR2,
                         province IN VARCHAR2,
                         postal_code IN VARCHAR2,
                         territory_short_name IN VARCHAR2
                        )return VARCHAR2 ;
pragma RESTRICT_REFERENCES (format_address_concat, WNDS, WNPS);

-- Added for 12.1.2
function return_primary_phone
(
	party_id      number
) return varchar2;

function check_onetime
(
    incident_location_id IN number
) return varchar2;

END CS_STD;

/
