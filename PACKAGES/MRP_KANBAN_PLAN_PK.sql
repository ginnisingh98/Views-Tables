--------------------------------------------------------
--  DDL for Package MRP_KANBAN_PLAN_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_KANBAN_PLAN_PK" AUTHID CURRENT_USER AS
/* $Header: MRPKPLNS.pls 120.1 2005/09/12 15:03:53 asuherma noship $  */

-- Declare some record types here

-- this record holds kanban plan information passed from the srs form
TYPE kanban_info_rec_type is record (
organization_id		number,
kanban_plan_id		number,
from_item   		varchar2(80),
to_item 		varchar2(80),
category_set_id		number,
category_structure_id	number,
from_category   	varchar2(80),
to_category   		varchar2(80),
bom_effectivity		date,
start_date		date,
cutoff_date		date,
replan_flag		number,
input_type		number,
input_designator 	varchar2(10)
);

-- this record holds low level codes information from mrp_low_level_codes
-- table
TYPE llc_rec_type is record (
assembly_item_id                number,
to_subinventory                 varchar2(10),
to_locator_id                   number,
component_item_id               number,
from_subinventory               varchar2(10),
from_locator_id                 number,
low_level_code                  number,
component_usage                 number,
component_yield                 number,
operation_yield                 number,
supply_source_type              number,
replenishment_lead_time         number
);

-- this record holds the exploded kanban demand information stored in
-- mrp_kanban_demand table
TYPE demand_rec_type is record (
demand_id			number,
kanban_plan_id			number,
organization_id			number,
inventory_item_id		number,
subinventory			varchar2(10),
locator_id			number,
assembly_item_id		number,
assembly_subinventory		varchar2(10),
assembly_locator_id		number,
demand_date			date,
demand_quantity			number,
order_type			number,
kanban_item_flag		varchar2(1)
);

-- Declare global constants and variables

G_PRODUCTION_KANBAN		CONSTANT NUMBER := -1;
G_PRODUCTION_SOURCE_TYPE	CONSTANT NUMBER := 4;
G_SUCCESS			CONSTANT NUMBER := 0;
G_WARNING			CONSTANT NUMBER := 1;
G_ERROR				CONSTANT NUMBER := 2;
G_CALC_KANBAN_SIZE		CONSTANT NUMBER := 1;
G_CALC_KANBAN_NUMBER		CONSTANT NUMBER := 2;
G_NO_FCST_CONTROL		CONSTANT NUMBER := 3;

g_kanban_info_rec		kanban_info_rec_type;
g_debug				boolean := FALSE;
g_raise_warning			boolean := FALSE;
g_log_message			varchar2(2000);
g_stmt_num			number;

-- ========================================================================
--  This is the main procedure that controls the flow of the kanban planning
--  process.
--  ERRBUF and RETCODE are two standard parameters that any PL/SQL
--  concurrent program should have. ERRBUF is used to return any error
--  messages and RETCODE to return the completion status.  RETCODE returns
--  0 for SUCCESS, 1 for SUCCESS with WARNINGS and 2 for ERROR
-- ========================================================================

PROCEDURE PLAN_KANBAN(  ERRBUF				OUT NOCOPY	VARCHAR2,
			RETCODE				OUT NOCOPY	NUMBER,
			p_organization_id		IN NUMBER,
		      	p_kanban_plan_id		IN NUMBER,
			p_from_item			IN VARCHAR2,
			p_to_item			IN VARCHAR2,
			p_category_set_id		IN NUMBER,
			p_category_structure_id		IN NUMBER,
			p_from_category   		IN VARCHAR2,
			p_to_category   		IN VARCHAR2,
			p_bom_effectivity		IN VARCHAR2,
			p_start_date			IN VARCHAR2,
			p_cutoff_date			IN VARCHAR2,
			p_replan_flag			IN NUMBER);

-- ========================================================================
--this function gets the offset start date to be considered when we look
--at forecast demand. for example a weekly forecast demand might have
--a start date 2 days before our kanban start date and we would have to
--consider a part of this forecast demand for our kanban calculation, else
--we would be underestimating our demand
-- ========================================================================
FUNCTION Get_Offset_Date (
                p_start_date            IN date,
                p_bucket_type           IN number
)
RETURN DATE;

FUNCTION Get_Repetitive_Demand(
        p_schedule_date         IN  DATE,
        p_rate_end_date         IN  DATE,
        p_repetitive_daily_rate IN  NUMBER)
RETURN NUMBER;

function Kanban_Calculation_Pvt (
                p_average_demand                IN      NUMBER,
                p_minimum_order_quantity        IN      NUMBER,
                p_fixed_lot_multiplier          IN      NUMBER,
                p_safety_stock_days             IN      NUMBER,
                p_replenishment_lead_time       IN      NUMBER,
                p_kanban_flag                   IN      NUMBER,
                p_kanban_size                   IN OUT  NOCOPY  NUMBER,
                p_kanban_number                 IN OUT  NOCOPY  NUMBER )
RETURN BOOLEAN;


--now go ahead and define a pragma
PRAGMA RESTRICT_REFERENCES (Get_Offset_Date,WNDS,WNPS);
PRAGMA RESTRICT_REFERENCES (Get_Repetitive_Demand,WNDS,WNPS);


END MRP_KANBAN_PLAN_PK;

 

/
