--------------------------------------------------------
--  DDL for Package ARP_CMERGE_ARDUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_ARDUN" AUTHID CURRENT_USER AS
/* $Header: ARPLDUNS.pls 120.2 2005/10/30 04:24:37 appldev ship $ */

  PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
end ARP_CMERGE_ARDUN;

 

/
