--------------------------------------------------------
--  DDL for Package MSC_ATP_EXCEPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_EXCEPTIONS" AUTHID CURRENT_USER AS
/* $Header: MSCATPXS.pls 120.1 2007/12/12 10:23:18 sbnaik ship $  */

------------ Record Type Definitions--------------

TYPE ATP_Exception_Rec_Typ is RECORD (
exception_type          number,         -- Exception type.
                                        --  15 for unconstrained plans
                                        --  24 for constrained plans
exception_group         number,         -- Exception group, always 5
plan_id                 number,         -- Plan ID
organization_id         number,         -- Organization ID
inventory_item_id       number,         -- Inventory Item ID
sr_instance_id          number,         -- Instance ID
demand_id               number,         -- Demand ID
quantity                number,         -- Quantity requested
order_number            varchar2(240),  -- Order number
customer_id             number,         -- Customer ID
customer_site_id        number,         -- Customer Site ID
demand_satisfy_date     date,           -- Date the demand is satisfied
quantity_satisfied      number          -- Quantity satisfied on demand date
);


-----------Procedure Declarations----------------

/*
bug 2795053 (ssurendr) - This procedure is not required any more.
PROCEDURE Get_Plan_Constraints (
        p_plan_id               IN              NUMBER,
        x_plan_type             OUT NOCOPY      NUMBER
);
*/

PROCEDURE Add_ATP_Exception (
        p_session_id            IN              NUMBER,
        p_exception_rec         IN OUT NOCOPY   MSC_ATP_EXCEPTIONS.ATP_Exception_Rec_Typ,
        x_return_status         OUT NOCOPY      VARCHAR2
);

----------ATP Global Variables------------------

-- Origination Field value for ATP generated SO exceptions
g_atp_exception_origin_code     CONSTANT INTEGER := 2;

END MSC_ATP_EXCEPTIONS;

/
