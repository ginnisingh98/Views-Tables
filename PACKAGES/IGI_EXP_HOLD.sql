--------------------------------------------------------
--  DDL for Package IGI_EXP_HOLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_HOLD" AUTHID CURRENT_USER as
--  $Header: igiexpms.pls 115.6 2002/09/11 14:41:58 mbarrett ship $

  TYPE HoldsArray IS TABLE OF ap_holds.hold_lookup_code%TYPE
	  INDEX BY BINARY_INTEGER;

  TYPE CountArray IS TABLE OF NUMBER
	  INDEX BY BINARY_INTEGER;

  PROCEDURE place_hold ( p_invoice_id       IN NUMBER
                       , p_source           IN VARCHAR2
                       , p_cancelled_date   IN DATE
                       , p_calling_sequence IN VARCHAR2 ) ;

END igi_exp_hold ;

 

/
