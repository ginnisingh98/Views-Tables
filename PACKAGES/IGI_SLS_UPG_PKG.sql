--------------------------------------------------------
--  DDL for Package IGI_SLS_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_UPG_PKG" AUTHID CURRENT_USER AS
--$Header: igislsus.pls 120.2 2008/01/17 21:24:24 vspuli noship $

     TYPE list_of_old_tables IS  TABLE OF IGI.igi_sls_upg_itf.old_table_name%TYPE
     index BY PLS_INTEGER;

     TYPE list_of_new_tables IS  TABLE OF IGI.igi_sls_upg_itf.new_table_name%TYPE
     INDEX BY PLS_INTEGER;

      TYPE list_of_secured_groups IS  TABLE OF IGI.igi_sls_upg_itf.sls_groups%TYPE
     INDEX BY PLS_INTEGER;

     TYPE list_of_from IS  TABLE OF VARCHAR2(500) INDEX BY PLS_INTEGER;

     TYPE list_of_where IS  TABLE OF VARCHAR2(2000) INDEX BY PLS_INTEGER;

     TYPE row_id_list IS TABLE OF ROWID INDEX BY PLS_INTEGER;

     PROCEDURE populate_temp_table_old;
     FUNCTION get_sls_grps(p_table_name varchar2) RETURN VARCHAR2;

     FUNCTION  get_changed_secured_list  RETURN list_of_old_tables;
     FUNCTION  get_new_secured_list  RETURN list_of_old_tables;


     PROCEDURE get_security_groups_list(param1 IN list_of_old_tables, param2 OUT NOCOPY list_of_secured_groups);

     PROCEDURE populate_temp_table_new(param1 IN list_of_old_tables, param2 IN list_of_new_tables,  ret_code OUT NOCOPY NUMBER);
     PROCEDURE set_sls_tables_data ( param1 IN list_of_old_tables,  param2 IN list_of_new_tables);
     PROCEDURE set_sls_allocations_data( param1 IN list_of_old_tables, param2 IN list_of_new_tables);


     PROCEDURE set_query_data(param1 IN list_of_old_tables , param2 IN list_of_from, param3 IN list_of_where);

     PROCEDURE migrate_data(param1 IN list_of_old_tables, param2 IN list_of_new_tables,
                param3 IN list_of_from, param4 IN list_of_where) ;

     PROCEDURE disable_old_tables;

     PROCEDURE fnd_wait_for_request(req_id IN NUMBER, dev_status OUT NOCOPY VARCHAR2, dev_phase OUT NOCOPY VARCHAR2);

END; -- Package spec

/
