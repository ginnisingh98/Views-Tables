--------------------------------------------------------
--  DDL for Package MSC_SATP_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SATP_FUNC" AUTHID CURRENT_USER AS
/* $Header: MSCSATPS.pls 120.2 2007/12/12 10:39:43 sbnaik ship $  */


--Following Functions are used in calculating delivery lead time at the source

FUNCTION src_location_id(
	p_organization_id        IN     NUMBER,
	p_customer_id            IN     NUMBER,
	p_customer_site_id       IN     NUMBER
)
RETURN NUMBER;


-- savirine, Sep 24, 2001: added the parameter p_session_id and p_partner_site_id

FUNCTION src_interloc_transit_time (
	p_from_location_id 	IN 	NUMBER,
	p_to_location_id   	IN 	NUMBER,
	p_ship_method      	IN 	VARCHAR2,
        p_session_id		IN	NUMBER DEFAULT NULL,
        p_partner_site_id  	IN	NUMBER DEFAULT NULL
)
RETURN NUMBER;


-- savirine, Sep 24, 2001: added the parameter p_session_id and p_partner_site_id

FUNCTION src_default_ship_method (
	p_from_location_id 	IN 	NUMBER,
	p_to_location_id 	IN 	NUMBER,
        p_session_id		IN	NUMBER DEFAULT NULL,
        p_partner_site_id 	IN	NUMBER DEFAULT NULL
)
RETURN VARCHAR2;


-- savirine, Sep 24, 2001: added the parameter p_session_id and p_partner_site_id

FUNCTION  src_default_intransit_time (
	p_from_location_id 	IN 	NUMBER,
	p_to_location_id  	IN 	NUMBER,
        p_session_id		IN	NUMBER DEFAULT NULL,
        p_partner_site_id 	IN	NUMBER DEFAULT NULL
)
RETURN NUMBER;


FUNCTION src_ship_method (
	p_from_org_id 		IN 	NUMBER,
	p_to_org_id 		IN 	NUMBER
)
RETURN VARCHAR2;


FUNCTION src_intransit_time (
	p_from_org_id 		IN 	NUMBER,
	p_to_org_id 		IN 	NUMBER
)
RETURN NUMBER;

FUNCTION src_prev_work_day ( p_organization_id   IN NUMBER,
                             p_date              IN DATE)
return DATE;

FUNCTION src_next_work_day ( p_organization_id   IN NUMBER,
                             p_date              IN DATE)
return DATE;

-- dsting 2833417
FUNCTION src_date_offset ( p_organization_id   IN NUMBER,
                           p_date              IN DATE,
                           p_days              IN NUMBER
                         )
return DATE;

-- ngoel 7/31/2001, modified to accept p_index as a parameter to determine
-- index length by which ATP_REC_TYP needs to be extended, default is 1.

PROCEDURE Extend_Atp (
  p_atp_tab             IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2,
  p_index               IN       NUMBER  DEFAULT 1
);


PROCEDURE Assign_Atp_Input_Rec (
        p_atp_table                     IN      MRP_ATP_PUB.ATP_Rec_Typ,
        p_index                         IN      NUMBER,
        x_atp_table                     IN OUT  NOCOPY MRP_ATP_PUB.ATP_Rec_Typ,
        x_return_status                 OUT     NoCopy VARCHAR2
);

PROCEDURE Assign_Atp_Output_Rec (
        p_atp_table                     IN      MRP_ATP_PUB.ATP_Rec_Typ,
        x_atp_table                     IN OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ,
        x_return_status                 OUT     NoCopy VARCHAR2
);




PROCEDURE Extend_Atp_Period (
        p_atp_period            IN OUT NOCOPY   MRP_ATP_PUB.ATP_Period_Typ,
        x_return_status         OUT             NoCopy VARCHAR2
);


PROCEDURE Extend_Atp_Supply_Demand (
        p_atp_supply_demand     IN OUT NOCOPY   MRP_ATP_PUB.ATP_Supply_Demand_Typ,
        x_return_status         OUT             NoCopy VARCHAR2,
        p_index			IN       	NUMBER DEFAULT 1 -- added by rajjain 12/10/2002
);

-- rajjain 12/10/2002
PROCEDURE Trim_Atp_Supply_Demand (
        p_atp_supply_demand     IN OUT NOCOPY   MRP_ATP_PUB.ATP_Supply_Demand_Typ,
        x_return_status         OUT             NoCopy VARCHAR2,
        p_index			IN       	NUMBER DEFAULT 1
);

-- ngoel 9/28/2001, added this function for use in View MSC_SCATP_SOURCES_V to support
-- Region Level Sourcing.

FUNCTION Get_Session_id
RETURN NUMBER;

-- savirine, September 05, 2001: Defined the procedure Get_Regions to get the region information.  This
-- procedure can be called from the following packages: 1) MSCEATPB.pls if the ATP request is from the
-- source ERP Instance, 2) MSCGATPB.pls if the ATP request is from the destination APS Instance, and
-- 3) MSCOSCWB.pls if the ATP request is coming from Pick Sources/ Global ATP from UI ( Form ).

-- krajan: Modified name to _OLD. New wrapper added
-- See the Spec for Get_Regions for more information

/*
PROCEDURE Get_Regions_Old (
        p_customer_site_id              IN      NUMBER,
        p_calling_module                IN      number,
        p_instance_id                   IN      NUMBER,
        p_session_id                    IN      NUMBER,
        p_dblink                        IN      VARCHAR2,
        x_return_status                 OUT NOCOPY    VARCHAR2);
*/
-- For shipping
-- Uses the new regions to locations mapping table
PROCEDURE Get_Regions_Shipping (
        p_customer_site_id              IN      NUMBER,
        p_calling_module                IN      number,  -- i.e. Source (not 724) or Destination (724)
        p_instance_id                   IN      NUMBER,
        p_session_id                    IN      NUMBER,
        p_dblink                        IN      VARCHAR2,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        p_location_id                   IN      NUMBER DEFAULT NULL, -- to get location ID
        p_location_source               IN      VARCHAR2 DEFAULT NULL,  -- location source
        p_supplier_site_id              IN      NUMBER DEFAULT NULL,-- For supplier intransit LT project
        --2814895
        p_party_site_id                 IN      NUMBER DEFAULT NULL);
-- dsting
PROCEDURE get_src_transit_time (
	p_from_org_id		IN NUMBER,
	p_from_loc_id		IN NUMBER,
	p_to_org_id		IN NUMBER,
	p_to_loc_id		IN NUMBER,
	p_session_id		IN NUMBER,
	p_partner_site_id	IN NUMBER,
	x_ship_method		IN OUT NOCOPY VARCHAR2,
	x_intransit_time	OUT NOCOPY NUMBER,
        p_partner_type          IN NUMBER DEFAULT NULL ); --2814895

-- krajan : new get_regions
-- This procedure is a wrapper for Get_regions_Old and Get_regions_shipping
-- When data exists in the regions to locations mapping table, this wrapper
-- redirects the call to get_regions_shipping. Else the old API is called.
PROCEDURE Get_Regions (
        p_customer_site_id              IN      NUMBER,
        p_calling_module                IN      number,  -- i.e. Source (not 724) or Destination (724)
        p_instance_id                   IN      NUMBER,
        p_session_id                    IN      NUMBER,
        p_dblink                        IN      VARCHAR2,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        p_location_id                   IN      NUMBER DEFAULT NULL, -- to get location ID
        p_location_source               IN      VARCHAR2 DEFAULT NULL,  -- location source
        p_supplier_site_id              IN      NUMBER DEFAULT NULL,     -- For supplier intransit LT project
        --2814895
        -- Adding new address of customer and party_site
        p_postal_code                   IN      VARCHAR2 DEFAULT NULL,
        p_city                          IN      VARCHAR2 DEFAULT NULL,
        p_state                         IN      VARCHAR2 DEFAULT NULL,
        p_country                       IN      VARCHAR2 DEFAULT NULL,
        p_party_site_id                 IN      NUMBER DEFAULT NULL,
        p_order_line_ID                 IN      NUMBER DEFAULT NULL --2814895
);

procedure new_extend_atp (
        p_atp_tab               IN OUT NOCOPY   MRP_ATP_PUB.atp_rec_typ,
        p_tot_size              IN              number,
        x_return_status         OUT    NOCOPY   varchar2
);

/*--------------------------------------------------------------------------
|  Begin Functions added for ship_rec_cal project
+-------------------------------------------------------------------------*/

FUNCTION Src_Get_Calendar_Code(
			p_customer_id		IN number,
			p_customer_site_id	IN number,
			p_organization_id	IN number,
			p_ship_method_code      IN varchar2,
			p_calendar_type  	IN integer -- One of OSC, CRC or VIC
			) RETURN VARCHAR2;
FUNCTION Src_NEXT_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_calendar_date		IN date
			) RETURN DATE;

FUNCTION Src_PREV_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_calendar_date		IN date
			) RETURN DATE;

FUNCTION Src_DATE_OFFSET(
			p_calendar_code		IN varchar2,
			p_calendar_date		IN date,
			p_days_offset		IN number,
			p_offset_type           IN number
			) RETURN DATE;

FUNCTION SRC_THREE_STEP_CAL_OFFSET_DATE(
			p_input_date			IN Date,
			p_first_cal_code		IN VARCHAR2,
			p_first_cal_validation_type	IN NUMBER,
			p_second_cal_code		IN VARCHAR2,
			p_offset_days			IN NUMBER,
			p_second_cal_validation_type	IN NUMBER,
			p_third_cal_code		IN VARCHAR2,
			p_third_cal_validation_type	IN NUMBER
			) RETURN DATE;

/*--------------------------------------------------------------------------
|  Procedure for collection enhancement
+-------------------------------------------------------------------------*/
PROCEDURE get_dblink_profile(
x_dblink                  OUT     NOCOPY VARCHAR2,
x_instance_id	 	  OUT     NOCOPY NUMBER,
x_return_status           OUT     NOCOPY VARCHAR2
);

--bug3940999 added procedure for inserting source profile values into source table.
PROCEDURE put_src_to_dstn_profiles(
p_session_id             IN NUMBER,
x_return_status          OUT   NoCopy VARCHAR2
);

--bug3940999 added procedure for getting source profile values into destination table.
PROCEDURE get_src_to_dstn_profiles(
p_dblink                 IN VARCHAR2,
p_session_id             IN NUMBER,
x_return_status          OUT   NoCopy VARCHAR2
);

END MSC_SATP_FUNC;

/
