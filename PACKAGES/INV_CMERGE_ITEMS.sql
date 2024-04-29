--------------------------------------------------------
--  DDL for Package INV_CMERGE_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CMERGE_ITEMS" AUTHID CURRENT_USER as
/* $Header: invcmis.pls 115.2 2003/02/18 05:56:03 rvuppala noship $ */
	procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END INV_CMERGE_ITEMS;

 

/
