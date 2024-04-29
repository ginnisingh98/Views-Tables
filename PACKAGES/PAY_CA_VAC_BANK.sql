--------------------------------------------------------
--  DDL for Package PAY_CA_VAC_BANK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_VAC_BANK" AUTHID CURRENT_USER AS
/* $Header: pycavbvb.pkh 120.0 2005/05/29 03:53:45 appldev noship $ */

FUNCTION calc_years_of_service ( p_assignment_id NUMBER,
                                 p_date_earned   DATE,
                                 p_date_type     VARCHAR2 )
  RETURN NUMBER;


END pay_ca_vac_bank;

 

/
