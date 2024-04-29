--------------------------------------------------------
--  DDL for Package ARP_GENERIC_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_GENERIC_CMERGE" AUTHID CURRENT_USER AS
/* $Header: ARPLPMSS.pls 120.2 2005/10/30 04:24:44 appldev ship $ */

  PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END ARP_GENERIC_CMERGE;

 

/
