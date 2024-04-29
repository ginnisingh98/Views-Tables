--------------------------------------------------------
--  DDL for Package ARP_CMERGE_ARCON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_ARCON" AUTHID CURRENT_USER AS
/* $Header: ARCMCONS.pls 115.1 99/07/16 23:55:36 porting ship $ */

  PROCEDURE MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END ARP_CMERGE_ARCON;

 

/
