--------------------------------------------------------
--  DDL for Package PAY_US_GET_CUMU_PERIOD_NUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GET_CUMU_PERIOD_NUM" AUTHID CURRENT_USER AS
/* $Header: pyuscfun.pkh 115.2 2002/04/16 19:49:46 pkm ship      $ */

FUNCTION CUMULATIVE_PERIOD_NUMBER(
				  p_pact_id         number,
				  p_date_earned     date,
				  p_assignment_id   number )
return number ;
end pay_us_get_cumu_period_num;

 

/
