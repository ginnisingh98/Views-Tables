--------------------------------------------------------
--  DDL for Package POS_HEADER_INFO_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_HEADER_INFO_S" AUTHID CURRENT_USER AS
/* $Header: POSHEADS.pls 115.0 99/08/20 11:09:32 porting sh $ */


  /* GetPaymentTerms
   * ---------------
   * PL/SQL function to get the payment terms either from the po header,
   * or defaulted from the supplier site information.
   */
  FUNCTION GetPaymentTerms(p_sessionID NUMBER, p_vendorSiteID NUMBER) RETURN NUMBER;


END POS_HEADER_INFO_S;


 

/
