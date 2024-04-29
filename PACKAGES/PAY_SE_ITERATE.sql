--------------------------------------------------------
--  DDL for Package PAY_SE_ITERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_ITERATE" AUTHID CURRENT_USER AS
/* $Header: pyseiter.pkh 120.1 2005/06/28 23:03:51 atrivedi noship $ */
 --
  FUNCTION calculate_gross_amount
 (p_element_entry_id NUMBER
 ,p_target_net       NUMBER
 ,p_tolerance        NUMBER
 ,p_current_net      NUMBER
 ,p_suggested_gross  OUT NOCOPY NUMBER
 ,p_stop_processing  OUT NOCOPY NUMBER) RETURN NUMBER;

END pay_se_iterate;

 

/
