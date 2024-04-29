--------------------------------------------------------
--  DDL for Package ARP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE" AUTHID CURRENT_USER AS
/* $Header: ARPLARMS.pls 115.3 2003/02/20 09:47:38 jassing ship $ */

  procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
/* Bug 2447449, Declared the following variable to limit the buffer size */
  max_array_size CONSTANT NUMBER := 1000;
end ARP_CMERGE;

 

/
