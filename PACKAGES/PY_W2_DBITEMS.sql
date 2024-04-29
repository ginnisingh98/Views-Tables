--------------------------------------------------------
--  DDL for Package PY_W2_DBITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_W2_DBITEMS" AUTHID CURRENT_USER as
/* $Header: pymagdbi.pkh 115.1 99/09/29 14:44:07 porting ship  $ */

 /*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

     Date             Name                 Description
     ----             ----                 -----------
     30-JUL-1996      J. ALLOUN            Added error handling.
     08-AUG-1998      A. Chauhan           Added create_eoy_archive_dbi.

 ============================================================================*/
TYPE char240_data_type_table IS TABLE OF VARCHAR2(250)
                                  INDEX BY BINARY_INTEGER;
TYPE numeric_data_type_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;

 procedure create_dbi;
 procedure create_archive_route;
 procedure create_archive_dbi(
           p_item_name varchar2 );
 procedure create_eoy_archive_dbi(
           p_item_name varchar2 );
end py_w2_dbitems;


 

/
