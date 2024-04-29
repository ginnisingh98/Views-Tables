--------------------------------------------------------
--  DDL for Package Body ARP_TRX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_PURGE" AS
/* $Header: ARPUPRGB.pls 115.0 99/07/17 00:07:22 porting ship $ */

  FUNCTION trx_purgeable(p_customer_trx_id IN NUMBER) RETURN BOOLEAN IS
  allow_purge BOOLEAN := TRUE;
  BEGIN
    --
    -- Place your logic here. Set the value of allow_purge to TRUE if
    -- you want this invoice to be purge, or FALSE if you don't want it
    -- purged
    RETURN allow_purge;

  END;

END arp_trx_purge;

/
