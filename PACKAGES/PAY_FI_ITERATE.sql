--------------------------------------------------------
--  DDL for Package PAY_FI_ITERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_ITERATE" AUTHID CURRENT_USER AS
/* $Header: pyfiiter.pkh 120.0 2005/05/29 04:53:25 appldev noship $ */
 --
  FUNCTION calculate_gross_amount
 (p_element_entry_id NUMBER
 ,p_target_net       NUMBER
 ,p_tolerance        NUMBER
 ,p_current_net      NUMBER
 ,p_suggested_gross  OUT NOCOPY NUMBER
 ,p_stop_processing  OUT NOCOPY NUMBER) RETURN NUMBER;

END pay_fi_iterate;

 

/
