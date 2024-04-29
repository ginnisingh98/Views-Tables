--------------------------------------------------------
--  DDL for Package ARP_CMERGE_ARTRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_ARTRX" AUTHID CURRENT_USER AS
/* $Header: ARPLTRXS.pls 120.2 2005/10/30 04:24:50 appldev ship $ */

  PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END ARP_CMERGE_ARTRX;

 

/
