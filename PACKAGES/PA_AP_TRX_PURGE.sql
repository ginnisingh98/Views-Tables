--------------------------------------------------------
--  DDL for Package PA_AP_TRX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AP_TRX_PURGE" AUTHID CURRENT_USER AS
-- $Header: PAXAPPGS.pls 120.0 2005/05/30 17:22:42 appldev noship $

  FUNCTION invoice_purgeable(x_invoice_id IN NUMBER) RETURN BOOLEAN ;
  pragma RESTRICT_REFERENCES ( invoice_purgeable, WNDS, WNPS);

END pa_ap_trx_purge;

 

/
