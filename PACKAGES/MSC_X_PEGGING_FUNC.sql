--------------------------------------------------------
--  DDL for Package MSC_X_PEGGING_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_PEGGING_FUNC" AUTHID CURRENT_USER AS
/*  $Header: MSCXPEGS.pls 120.1 2005/06/07 23:29:50 appldev  $ */

   FUNCTION get_receipt_date (arg_transid IN NUMBER) RETURN date;

   FUNCTION get_days_late (arg_transid IN NUMBER) RETURN NUMBER;

   FUNCTION get_max_late (arg_transid IN NUMBER) RETURN NUMBER;

   FUNCTION get_qty_ontime (arg_transid IN NUMBER) RETURN NUMBER;

   FUNCTION get_qty_late (arg_transid IN NUMBER) RETURN NUMBER;

   FUNCTION get_intransit (arg_transid IN NUMBER) RETURN NUMBER;

   FUNCTION get_uncommitted (arg_transid IN NUMBER) RETURN NUMBER;

   FUNCTION get_child_num (arg_transid IN NUMBER) RETURN NUMBER  ;

   FUNCTION get_transids (arg_transid IN NUMBER, arg_binder IN VARCHAR2) RETURN VARCHAR2 ;

   FUNCTION get_immediate_po (arg_transid IN NUMBER, arg_order_type IN NUMBER) RETURN NUMBER;





/*   FUNCTION get_valid_transid(arg_transid IN NUMBER) RETURN NUMBER;

   FUNCTION get_date_excep(arg_transid IN NUMBER) RETURN VARCHAR2 ;

   FUNCTION get_date_excep_short(arg_transid IN NUMBER) RETURN VARCHAR2  ;

   FUNCTION get_display_date(arg_transid IN NUMBER, arg_pos IN NUMBER) RETURN DATE;

   FUNCTION get_graph_value (arg_transid IN NUMBER,
                             arg_pos IN NUMBER,
                             arg_field IN VARCHAR2) RETURN VARCHAR2 ;

   FUNCTION get_transids (arg_transid IN NUMBER, arg_binder IN VARCHAR2) RETURN VARCHAR2 ;

   FUNCTION get_scheduled_qty(arg_transid IN NUMBER) RETURN VARCHAR2 ;

   FUNCTION get_child_num (arg_transid IN NUMBER) RETURN NUMBER  ;

   FUNCTION get_excep (arg_transid IN NUMBER,
                       arg_order_type IN NUMBER,
                       arg_excep_order IN NUMBER,
                       arg_excep_type IN NUMBER) RETURN VARCHAR2 ;

   FUNCTION get_status (arg_transid IN NUMBER) RETURN VARCHAR2 ;

   FUNCTION get_receipt_date (arg_transid IN NUMBER) RETURN date;
*/
END MSC_X_PEGGING_FUNC ;

 

/
