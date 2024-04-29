--------------------------------------------------------
--  DDL for Package ARP_TRX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_PURGE" AUTHID CURRENT_USER AS
/* $Header: ARPUPRGS.pls 115.0 99/07/17 00:07:26 porting ship $ */

  FUNCTION trx_purgeable(p_customer_trx_id IN NUMBER) RETURN BOOLEAN;
  -- The client can write this function to return TRUE (allow purge) or
  -- FALSE (prevent purge). The function template supplied with the Product
  -- returns TRUE.

END arp_trx_purge;

 

/
