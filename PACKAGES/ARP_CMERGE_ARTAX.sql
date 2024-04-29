--------------------------------------------------------
--  DDL for Package ARP_CMERGE_ARTAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_ARTAX" AUTHID CURRENT_USER AS
/* $Header: ARPLTAXS.pls 120.2 2005/10/30 04:24:47 appldev ship $ */

  PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
end ARP_CMERGE_ARTAX;

 

/
