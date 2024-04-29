--------------------------------------------------------
--  DDL for Package EDW_DROP_INDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DROP_INDEX" AUTHID CURRENT_USER AS
/* $Header: EDWDRNDS.pls 115.2 2002/12/06 01:51:30 jwen noship $*/
procedure edw_drop_btree_ind (owner VARCHAR2, table_name VARCHAR2);
END EDW_DROP_INDEX;

 

/
