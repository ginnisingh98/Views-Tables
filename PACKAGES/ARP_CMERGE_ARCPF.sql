--------------------------------------------------------
--  DDL for Package ARP_CMERGE_ARCPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_ARCPF" AUTHID CURRENT_USER AS
/* $Header: ARPLCPFS.pls 115.4 2002/10/24 18:50:05 jypandey ship $ */

  PROCEDURE merge (
         req_id                   NUMBER,
         set_num                  NUMBER,
         process_mode             VARCHAR2 );

  --physically delete rows in customer tables after merging each set.
  PROCEDURE delete_rows (
         req_id                   NUMBER,
         set_num                  NUMBER );

END ARP_CMERGE_ARCPF;

 

/
