--------------------------------------------------------
--  DDL for Package PQH_REFRESH_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_REFRESH_DATA" AUTHID CURRENT_USER AS
/* $Header: pqrefdat.pkh 120.0 2005/05/29 02:26:31 appldev noship $ */

-- record to hold data from the 3 tables

TYPE t_refresh_struct_type IS RECORD
( column_name   all_tab_columns.column_name%TYPE,
  column_type    VARCHAR2(1),
  attribute_name VARCHAR2(100),
  refresh_flag   VARCHAR2(1),
  txn_val        VARCHAR2(8000),
  shadow_val     VARCHAR2(8000),
  main_val       VARCHAR2(8000),
  updt_flag      VARCHAR2(1)
);

-- PL/SQL based on the above structure

TYPE t_refresh_tab IS TABLE OF t_refresh_struct_type
  INDEX BY BINARY_INTEGER;

-- Sub Type for WHERE clause
 SUBTYPE t_where_clause_typ  IS VARCHAR2(8000);


-- global variables for the PL/SQL table of record defined above
   g_refresh_tab    t_refresh_tab;
   g_refresh_tab_all    t_refresh_tab; -- for use by replace_where_params
   g_refresh_bak    t_refresh_tab; -- for FORM purpose ONLY

-- global variables
   g_txn_category_id pqh_txn_category_attributes.transaction_category_id%TYPE;


PROCEDURE refresh_data
     ( p_txn_category_id        IN pqh_transaction_categories.transaction_category_id%TYPE,
       p_txn_id                 IN number,
       p_refresh_criteria       IN varchar2,
       p_items_changed          OUT NOCOPY varchar2
      );




PROCEDURE build_dynamic_select
  ( p_flag           IN  VARCHAR2,
    p_select_stmt    OUT NOCOPY t_where_clause_typ,
    p_tot_columns    OUT NOCOPY NUMBER );


FUNCTION ret_value_from_glb_table(p_index in number)
RETURN VARCHAR2;
--
FUNCTION get_value_from_array ( p_column_name  IN  pqh_attributes.column_name%TYPE )
  RETURN VARCHAR2 ;

FUNCTION get_value_from_array_purge( p_column_name  IN  pqh_attributes.column_name%TYPE )
  RETURN VARCHAR2 ;


PROCEDURE replace_where_params
 ( p_where_clause_in  IN     pqh_table_route.where_clause%TYPE,
   p_txn_tab_flag     IN     VARCHAR2,
   p_txn_id           IN     number,
   p_where_clause_out OUT NOCOPY    pqh_table_route.where_clause%TYPE );

PROCEDURE replace_where_params_purge
 ( p_where_clause_in  IN     pqh_table_route.where_clause%TYPE,
   p_txn_tab_flag     IN     VARCHAR2,
   p_txn_id           IN     number,
   p_where_clause_out OUT NOCOPY    pqh_table_route.where_clause%TYPE );


PROCEDURE get_all_rows
(p_select_stmt      IN   t_where_clause_typ,
 p_from_clause      IN   pqh_table_route.from_clause%TYPE,
 p_where_clause     IN   pqh_table_route.where_clause%TYPE,
 p_total_columns    IN   NUMBER,
 p_total_rows       OUT NOCOPY  NUMBER,
 p_all_txn_rows     OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE );


PROCEDURE compute_updt_flag;


PROCEDURE update_tables
(p_column_name           IN pqh_attributes.column_name%TYPE,
 p_column_type           IN pqh_attributes.column_type%TYPE,
 p_column_val            IN VARCHAR2,
 p_from_clause_txn       IN pqh_table_route.from_clause%TYPE,
 p_from_clause_shd       IN pqh_table_route.from_clause%TYPE,
 p_rep_where_clause_shd  IN pqh_table_route.where_clause%TYPE );


-- String Parsing functions and Procedures
/*
|| PL/SQL table structures to hold atomics retrieved by parse_string.
|| This includes the table type definition, a table (though you can
|| declare your own as well, and an empty table, which you can use
|| to clear out your table which contains atomics.
*/
TYPE atoms_tabtype IS TABLE OF VARCHAR2(8000) INDEX BY BINARY_INTEGER;
g_atoms_table atoms_tabtype;

/*
|| The standard list of delimiters. You can over-ride these with
|| your own list when you call the procedures and functions below.
|| This list is a pretty standard set of delimiters, though.
*/
std_delimiters VARCHAR2 (50) := ' ';

/*
|| The parse_string procedure: puts all atomics into a PL/SQL table.
*/
PROCEDURE parse_string
	(p_string_in IN pqh_table_route.where_clause%TYPE,
	 p_atomics_list_out OUT NOCOPY atoms_tabtype,
	 p_num_atomics_out IN OUT NOCOPY NUMBER,
	 p_delimiters_in IN VARCHAR2 := std_delimiters);


-- end string Parsing functions and Procedures


/*
  Following procedures are written for PQHPCTXN form implememnation ONLY
*/


-- global variable based on prvcalc_tab for PQHPCTXN implementation
   g_attrib_prv_tab  pqh_prvcalc.t_attname_priv;


PROCEDURE count_changed
(p_count  OUT NOCOPY  number );


PROCEDURE get_row_prv_calc
( p_row                IN    number,
  p_form_column_name   OUT NOCOPY   pqh_txn_category_attributes.form_column_name%TYPE,
  p_mode_flag          OUT NOCOPY   varchar2,
  p_reqd_flag          OUT NOCOPY   varchar2
);


END;
 -- Package Specification PQH_REFRESH_DATA

 

/
