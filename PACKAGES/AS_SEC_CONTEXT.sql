--------------------------------------------------------
--  DDL for Package AS_SEC_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SEC_CONTEXT" AUTHID CURRENT_USER AS
/* $Header: asseccxs.pls 115.2 2002/12/05 21:28:26 karaghav ship $ */

TYPE sec_attr_record is RECORD
     (sec_attr_name VARCHAR2(80),
      sec_attr_value VARCHAR2(80));

TYPE sec_attr_tbl IS TABLE OF sec_attr_record;

g_sec_attr_table sec_attr_tbl;


PROCEDURE set_attr_values
     (p_attr_names IN VARCHAR2_TABLE_100,
      p_attr_vals IN VARCHAR2_TABLE_100
     );

PROCEDURE set_attr_value
     (p_attr_name IN VARCHAR2,
      p_attr_value IN VARCHAR2
     );

FUNCTION get_attr_value
     ( p_attr_name VARCHAR2)
     RETURN VARCHAR2;

PROCEDURE init;


END;

 

/
