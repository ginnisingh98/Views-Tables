--------------------------------------------------------
--  DDL for Package EDW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_UTIL" AUTHID CURRENT_USER AS
/* $Header: EDWSRGTS.pls 115.7 2002/12/05 22:20:58 arsantha ship $  */
VERSION                 CONSTANT CHAR(80) := '$Header: EDWSRGTS.pls 115.7 2002/12/05 22:20:58 arsantha ship $';

-- ------------------------
-- Public Functions
-- ------------------------

--	The function get_base_currency returns the functional currecy that is defined for
--	this organization unit.


	FUNCTION get_base_currency( p_organization_id	IN NUMBER) return VARCHAR2;


--	The function get_item_cost returns the cost price of the item as defined is
--	cst_item_costs

	FUNCTION get_item_cost( p_item_id  IN NUMBER, p_org_id	IN NUMBER)
			return NUMBER;

/*	FUNCTION get_item_price( p_item_id IN NUMBER, p_org_id	IN NUMBER,
				 p_price_list_id in number default null ,
				 p_currency in varchar2 default null) return NUMBER;
*/
	FUNCTION get_est_ship_date( p_disposition_id IN NUMBER,
				    p_organization_id	IN NUMBER,
				    p_compile_designator IN VARCHAR2) return DATE;
	FUNCTION get_pto_mmt_count(p_line_id IN NUMBER) return NUMBER;
	FUNCTION get_line_detail_count(p_line_id IN NUMBER) return NUMBER;
	FUNCTION get_party_id(p_sold_to_org_id IN NUMBER) return NUMBER;

        FUNCTION get_wh_global_currency RETURN VARCHAR2 ;

	FUNCTION get_rep_sched_scrapped_qty(rep_sched_id number,
				organization_id number) RETURN NUMBER;

	FUNCTION get_app_info return VARCHAR2 ;
	PRAGMA RESTRICT_REFERENCES (get_app_info, WNDS, WNPS);

	FUNCTION get_base_transaction_value(p_transaction_id number,
				p_transfer_transaction_id number,
				p_action_id number,
				p_quantity number) return NUMBER;
        FUNCTION get_edw_base_uom(p_uom_code IN VARCHAR2,
			          p_inventory_id IN NUMBER) RETURN VARCHAR2;
	FUNCTION get_edw_base_uom(p_uom_code IN VARCHAR2,
                     		  p_inventory_id IN NUMBER, p_instance_code IN VARCHAR2) RETURN VARCHAR2;
        FUNCTION get_uom_conv_rate(p_uom_code IN VARCHAR2,
			           p_inventory_id IN NUMBER) RETURN NUMBER;
        FUNCTION get_uom_conv_rate(p_uom_code IN VARCHAR2,
			           p_inventory_id IN NUMBER, p_instance_code IN VARCHAR2) RETURN NUMBER;
        FUNCTION get_uom_conv_rate(p_inventory_id IN NUMBER,
                           p_from_edw_base_uom_code IN VARCHAR2,
                           p_to_edw_base_uom_code IN VARCHAR2)
                           RETURN NUMBER;
        FUNCTION get_uom_conv_rate(p_inventory_id IN NUMBER,
                           p_from_edw_base_uom_code IN VARCHAR2,
                           p_to_edw_base_uom_code IN VARCHAR2, p_instance_code IN VARCHAR2)
                           RETURN NUMBER;
        FUNCTION get_edw_uom(p_uom_code IN VARCHAR2,
		             p_inventory_id IN NUMBER) RETURN VARCHAR2;
        FUNCTION get_edw_uom(p_uom_code IN VARCHAR2,
		             p_inventory_id IN NUMBER, p_instance_code IN VARCHAR2) RETURN VARCHAR2;
	FUNCTION bus_unit_id(p_type IN NUMBER,
                             p_organization_id IN NUMBER) return NUMBER;

	PRAGMA RESTRICT_REFERENCES (get_base_transaction_value,WNDS, WNPS, RNPS);

	PRAGMA RESTRICT_REFERENCES (get_rep_sched_scrapped_qty,WNDS, WNPS, RNPS);

	PRAGMA RESTRICT_REFERENCES (get_base_currency,WNDS, WNPS, RNPS);
	PRAGMA RESTRICT_REFERENCES (get_item_cost,WNDS, WNPS, RNPS);
	--PRAGMA RESTRICT_REFERENCES (get_item_price,WNDS, WNPS, RNPS);
	PRAGMA RESTRICT_REFERENCES (get_est_ship_date, WNDS, WNPS, RNPS);
	PRAGMA RESTRICT_REFERENCES (get_pto_mmt_count, WNDS, WNPS, RNPS);
	PRAGMA RESTRICT_REFERENCES (get_line_detail_count, WNDS, WNPS, RNPS);
	PRAGMA RESTRICT_REFERENCES (get_party_id, WNDS, WNPS, RNPS);
        PRAGMA RESTRICT_REFERENCES (get_wh_global_currency, WNDS, WNPS, RNPS);
        PRAGMA RESTRICT_REFERENCES (get_edw_base_uom, WNDS, WNPS, RNPS);
        PRAGMA RESTRICT_REFERENCES (get_uom_conv_rate, WNDS, WNPS, RNPS);
        PRAGMA RESTRICT_REFERENCES (get_edw_uom, WNDS, WNPS, RNPS);
        PRAGMA RESTRICT_REFERENCES (bus_unit_id, WNDS, WNPS, RNPS);


END EDW_UTIL;

 

/
