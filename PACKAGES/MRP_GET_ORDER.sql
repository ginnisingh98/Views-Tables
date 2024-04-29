--------------------------------------------------------
--  DDL for Package MRP_GET_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GET_ORDER" AUTHID CURRENT_USER AS
/* $Header: MRPXORDS.pls 115.0 99/07/16 12:43:45 porting ship $*/


  FUNCTION supply_order(arg_order_type IN NUMBER,
			    arg_disp_id IN NUMBER,
			    arg_compile_desig IN VARCHAR2,
			    arg_org_id IN NUMBER,
			    arg_item_id IN NUMBER,
		   	    arg_by_prod_assy_id IN NUMBER DEFAULT NULL)		            return varchar2;
 FUNCTION sales_order(arg_demand_id IN NUMBER)
                            return varchar2;

 PRAGMA RESTRICT_REFERENCES (supply_order, WNDS,WNPS);
 PRAGMA RESTRICT_REFERENCES (sales_order, WNDS, WNPS);

end mrp_get_order;

 

/
