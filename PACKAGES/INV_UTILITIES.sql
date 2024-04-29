--------------------------------------------------------
--  DDL for Package INV_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: INVUTILS.pls 120.2.12010000.4 2013/01/29 20:05:52 avrose ship $ */

-- this data type is used by the procedure parse_vector
TYPE vector_tabtype IS
   TABLE OF VARCHAR2(60)
   INDEX BY BINARY_INTEGER;

/*=====================================================================+
 | PROCEDURE
 |   DO_SQL
 |
 | PURPOSE
 |   Executes a dynamic SQL statement
 |
 | ARGUMENTS
 |   p_sql_stmt   String holding sql statement.  May be up to 8K long.
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  PROCEDURE DO_SQL(p_sql_stmt in varchar2);



 /*********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************
  * Procedure OBSOLETED. Use INV_PICK_SLIP_REPORT.RUN_DETAIL_ENGINE for Future use.  *
  *                THIS PROCEDURE WILL NOT BE SUPPORTED ANY MORE                     *
  *********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************/
 PROCEDURE RUN_DETAIL_ENGINE(p_detail_status out NOCOPY varchar2
                              ,p_org_id IN NUMBER DEFAULT NULL
                              ,p_move_order_type  NUMBER
                              ,p_transfer_order   VARCHAR2
                              ,p_source_subinv    VARCHAR2
			      ,p_source_locid     NUMBER
			      ,p_dest_subinv      VARCHAR2
			      ,p_dest_locid       NUMBER
                              ,p_requested_by     NUMBER
                              ,p_plan_tasks       IN BOOLEAN DEFAULT FALSE
                              ,p_pick_slip_group_rule_id IN NUMBER DEFAULT NULL
                             );


 /*
 -- PROCEDURE : parse_vector
 --
 -- This procedure is a work-around the limitation of not being
 -- able to pass a vector from Java to SQL. Instead of passing a vector,
 -- a string of elements separated by a delimiter is passed to SQL.
 --
 -- This procedure parses a string(varchar2) of elements delimited
 -- by a delimiter of the user's choice (e.g. comma, semicolon, colon).
 -- The output is a table of one column of type varchar.  Each row of
 -- this column corresponds to an individual string element.  These
 -- elements can then be manipulated using a loop as shown below.
 --
 -- Known limitations:
 -- The limit for the length of a varchar in SQL is 32676.  Please ensure
 -- the length of the string passed in is below this number.
 --
 --
 -- Example of usage:
 --
 -- declare
 --
 -- vector_in VARCHAR2(500);
 -- table_output inv_utilities.vector_tabtype;
 -- table_row NUMBER;
 --
 --  BEGIN
 --
 -- parse_vector (vector_in =>'elem0,elem1,elem2',
 --               delimiter =>':',
 --	         table_of_strings=> table_output);
 --
 -- FOR table_row IN 0 .. table_output.COUNT-1
 --     LOOP
 --	dbms_output.put_line('value in row'||TO_CHAR(table_row)||':'||table_output(table_row));
 --     END LOOP;
 --
 --*/
 --Added NOCOPY hint to table_of_strings OUT parameter
 --to comply with GSCC File.Sql.39 standard. Bug:4410848
 PROCEDURE parse_vector (vector_in IN VARCHAR2,
			 delimiter IN VARCHAR2,
			 table_of_strings OUT NOCOPY vector_tabtype
			 );


 FUNCTION get_conc_segments( X_org_id IN Number,
                            X_loc_id IN Number)
                            Return varchar2;

/*
 Added for bug No 7440217
 PO API for LCM
*/
FUNCTION inv_check_lcm(
         p_inventory_item_id IN NUMBER,
         p_ship_to_org_id IN NUMBER,
         p_consigned_flag IN VARCHAR2,
         p_outsource_assembly_flag IN VARCHAR2,
         p_vendor_id IN NUMBER,
         p_vendor_site_id IN NUMBER,
         p_po_line_location_id IN NUMBER DEFAULT NULL   --Bug#10279800
 )
 RETURN VARCHAR2;
/*
 END for bug No 7440217
 PO API for LCM
*/

 /*
 Added for bug No :2326247.
 Calculates the item cost based on costing.
 */
 PROCEDURE GET_ITEM_COST(v_org_id      IN   NUMBER,
                         v_item_id     IN   NUMBER,
                         v_locator_id  IN   NUMBER,
                         v_item_cost   OUT NOCOPY NUMBER);
  PROCEDURE get_sales_order_id
  /*
    ||==============================================================================||
    ||  Created By : Nalin Kumar                                                    ||
    ||  Created On : 03-May-2005                                                    ||
    ||  Purpose    : This procedure will get called from TMO. This procedure will   ||
    ||               return the Sales Order ID and Concatenated Segments. Created   ||
    ||               as part of Depot Repair Enh. Bug# 4346443                      ||
    ||                                                                              ||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who             When            What                                        ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
  */
   (p_sales_order_number               NUMBER  ,
    p_sales_order_type                 VARCHAR2,
    p_sales_order_source               VARCHAR2,
    p_concatenated_segments OUT NOCOPY VARCHAR2,
    p_source_id             OUT NOCOPY NUMBER);


	/*
	This API was created as a part of MUOM fulfillment ER.
	This will accept source_line_id as input paramter and will return the fulfillment_base
	by calling  API OE_DUAL_UOM_UTIL.get_fulfillment_base.
	*/
	PROCEDURE get_inv_fulfillment_base(
                p_source_line_id IN NUMBER,
                p_demand_source_type_id IN NUMBER,
                p_org_id IN NUMBER,
                x_fulfillment_base OUT NOCOPY VARCHAR2);


END INV_UTILITIES;

/
