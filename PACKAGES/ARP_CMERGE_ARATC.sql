--------------------------------------------------------
--  DDL for Package ARP_CMERGE_ARATC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_ARATC" AUTHID CURRENT_USER AS
/* $Header: ARPLATCS.pls 120.2 2005/10/30 04:24:16 appldev ship $ */

  PROCEDURE MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END ARP_CMERGE_ARATC;

 

/
