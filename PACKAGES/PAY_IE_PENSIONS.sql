--------------------------------------------------------
--  DDL for Package PAY_IE_PENSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PENSIONS" AUTHID CURRENT_USER as
/* $Header: pyiepenf.pkh 120.0 2005/06/03 06:48:01 appldev noship $ */
   FUNCTION IE_GET_MAX_PENSION_PERCENT(
      p_assgt_id NUMBER,
	  p_date_earned DATE,
      prsa2 NUMBER)
      RETURN NUMBER;
   FUNCTION GET_EARNINGS_CAP
   (p_date_earned DATE)
	  RETURN NUMBER;
    FUNCTION GET_PENSION_CONTRIBUTION
   (p_date_earned DATE,
    p_contribution_type VARCHAR2,
    p_pension_type_id NUMBER,
	p_pensionable_pay NUMBER)
	  RETURN NUMBER;
END pay_ie_pensions;

 

/
