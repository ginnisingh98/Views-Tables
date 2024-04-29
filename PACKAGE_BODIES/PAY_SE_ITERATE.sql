--------------------------------------------------------
--  DDL for Package Body PAY_SE_ITERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_ITERATE" AS
 /* $Header: pyseiter.pkb 120.1 2005/06/28 23:05:12 atrivedi noship $ */
 --
 -- The ELEMENT_ENTRY_ID currently being processed.
 g_element_entry_id NUMBER := -1;
 --
 -- Function to calculate the gross amount to be paid to achieve a target net amount.
 FUNCTION calculate_gross_amount
 (p_element_entry_id NUMBER
 ,p_target_net       NUMBER
 ,p_tolerance        NUMBER
 ,p_current_net      NUMBER
 ,p_suggested_gross  OUT NOCOPY NUMBER
 ,p_stop_processing  OUT NOCOPY NUMBER) RETURN NUMBER IS
  --
  -- Local variables
  l_diff            NUMBER;
  l_suggested_gross NUMBER;
  l_stop_processing NUMBER;
  l_dummy           NUMBER;
 BEGIN
  -- Initialise and make first guess.
  IF p_element_entry_id <> g_element_entry_id THEN

	   l_dummy := pay_iterate.initialise(p_element_entry_id, p_target_net * 2, p_target_net, p_target_net);
	   l_suggested_gross  := pay_iterate.get_interpolation_guess(p_element_entry_id, 0);
	   l_stop_processing  := 0;
	   g_element_entry_id := p_element_entry_id;
	  --
	  -- Continue iterative processing.
  ELSE
	   --
	   -- Targeted net has been reached.
	   IF ABS(p_target_net - p_current_net) <= p_tolerance THEN
		    l_suggested_gross  := 0;
		    l_stop_processing  := 1;
		    g_element_entry_id := -1;
		   --
		   -- More guessing required.
	   ELSE
		    l_diff := p_target_net - p_current_net;
		    l_suggested_gross := pay_iterate.get_interpolation_guess(p_element_entry_id, l_diff);
		    l_stop_processing := 0;
	   END IF;
  END IF;
  p_suggested_gross := l_suggested_gross;
  p_stop_processing := l_stop_processing;
  RETURN 1;
 END calculate_gross_amount;
END pay_se_iterate;

/
