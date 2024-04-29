--------------------------------------------------------
--  DDL for Package ARP_EXCHANGE_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_EXCHANGE_MERGE" AUTHID CURRENT_USER as
/* $Header: AREXCHMS.pls 120.1 2005/06/16 21:06:51 jhuang ship $ */

	procedure CMERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);

END ARP_EXCHANGE_MERGE;

 

/
