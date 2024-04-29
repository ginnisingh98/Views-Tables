--------------------------------------------------------
--  DDL for Package MRP_EPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_EPI" AUTHID CURRENT_USER AS
/* $Header: MRPCINVS.pls 120.1 2005/08/31 13:22:44 ichoudhu noship $  */

-- Globals used for the concurrent procedure
G_SUCCESS                       CONSTANT NUMBER := 0;
G_WARNING                       CONSTANT NUMBER := 1;
G_ERROR                         CONSTANT NUMBER := 2;

PROCEDURE inventory_turns(errbuf              OUT  NOCOPY VARCHAR2,
			   retcode            OUT NOCOPY NUMBER,
			   p_owning_org_id    IN NUMBER,
                           p_designator       IN VARCHAR2);

PROCEDURE mrp_calculate_revenue(plan_name          in   varchar2,
                                sched_name          in   varchar2,
                                p_org_id            in   number,
				p_owning_org_id     in   number,
				p_start_date        in   date,
				p_complete_date     in   date);

PROCEDURE mrp_resource_util(p_designator            in   varchar2,
                                p_org_id            in   number,
				p_start_date        in   date,
				p_end_date          in   date);

PROCEDURE mrp_populate_fc_sum(ERRBUF	OUT NOCOPY  VARCHAR2,
				RETCODE 	OUT NOCOPY NUMBER,
                                p_organization_id NUMBER,
                                p_from_forecast VARCHAR2,
                                p_to_forecast VARCHAR2,
                                p_from_date DATE,
                                p_to_date DATE);

FUNCTION mrp_item_selling_price(arg_item_id in number,
			     arg_org_id  in number,
			     arg_price_list_id in number default null,
			     arg_currency in varchar2 default null)
     RETURN NUMBER;

-- new function for the APS
FUNCTION mrp_item_list_price(arg_item_id in number,
			     arg_org_id  in number,
			     arg_price_list_id in number default null,
			     arg_currency in varchar2 default null)
     RETURN NUMBER;

FUNCTION mrp_item_cost(p_item_id in number,
			     p_org_id  in number)
     RETURN NUMBER;

FUNCTION mrp_resource_cost(p_item_id in number,
			     p_org_id  in number)
     RETURN NUMBER;

FUNCTION issued_values(p_designator IN VARCHAR2,
        p_org_id IN NUMBER, p_item_id IN NUMBER) RETURN NUMBER;

FUNCTION past_due_mds(p_designator IN VARCHAR2, p_org_id IN NUMBER,
	p_item_id IN NUMBER, p_date IN DATE) RETURN NUMBER;

FUNCTION inv_values(p_designator IN VARCHAR2,
        p_org_id IN NUMBER, p_item_id IN NUMBER,
	p_start_date IN DATE, p_end_date IN DATE) RETURN NUMBER;

--    Due to the OE design changes and these read/write constraints are not
-- required in 8i, the following pragma statemets are commented out.

-- PRAGMA RESTRICT_REFERENCES (issued_values, WNDS, WNPS);
-- PRAGMA RESTRICT_REFERENCES (past_due_mds, WNDS, WNPS);
-- PRAGMA RESTRICT_REFERENCES (inv_values, WNDS, WNPS);
-- PRAGMA RESTRICT_REFERENCES (mrp_item_selling_price,WNDS,WNPS);

-- Add RNPS restriction for remote procedure call
-- PRAGMA RESTRICT_REFERENCES (mrp_item_cost,WNDS,WNPS,RNPS);
-- PRAGMA RESTRICT_REFERENCES (mrp_resource_cost,WNDS,WNPS,RNPS);
-- New function for the APS
-- PRAGMA RESTRICT_REFERENCES (mrp_item_list_price,WNDS,WNPS,RNPS);


END mrp_epi;

 

/
