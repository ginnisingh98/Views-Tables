--------------------------------------------------------
--  DDL for Package Body PAY_IE_BIK_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_BIK_CHECK" AS
/* $Header: pyiebikp.pkb 120.1 2006/09/19 09:44:37 mgettins noship $ */
--
-----------------------------------------------------------------------------
----------------------purge delete function------------------------------
----------------------------------------------------------------------------
--
--There are any claims that spans across any date cannot be purged.
--
FUNCTION purge_veh_alloc
                (p_assignment_id     IN  NUMBER
                ,p_effective_date    IN  DATE
		,p_vehicle_allocation_id IN NUMBER
		) RETURN NUMBER IS

-- Bug 3466513 Changed the cursor to get the count based on vehicle allocation id
/*CURSOR c_claim_count_cursor
IS
     SELECT count(*)
      FROM pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
   WHERE pel.element_type_id =pet.element_type_id
     AND pee.assignment_id   = p_assignment_id
     AND pel.element_link_id = pee.element_link_id
     AND pet.legislation_code = 'IE'
     AND pet.element_name =('IE BIK Company Vehicle');*/

CURSOR c_claim_count_cursor
IS
     SELECT count(*)
     FROM pay_element_types_f pet
	,pay_element_links_f pel
	,pay_element_entries_f pee
	,pay_input_values_f piv
	,pay_element_entry_values_f peev
     WHERE pel.element_type_id =pet.element_type_id
     AND pee.assignment_id   = p_assignment_id
     AND pel.element_link_id = pee.element_link_id
     AND pet.legislation_code = 'IE'
     AND piv.element_type_id = pet.element_type_id
     AND peev.element_entry_id = pee.element_entry_id
     AND peev.input_value_id = piv.input_value_id
     AND pet.element_name =('IE BIK Company Vehicle')
     AND piv.name = 'Vehicle Allocation'
     AND peev.screen_entry_value = p_vehicle_allocation_id;

 l_alloc_count         NUMBER ;

BEGIN

  OPEN c_claim_count_cursor;
  FETCH c_claim_count_cursor INTO l_alloc_count;
  CLOSE c_claim_count_cursor;
  --Check claims existence check

   IF l_alloc_count > 0 THEN
        RETURN -1 ;
    END IF;
  RETURN 0;
END purge_veh_alloc;
-- end function
-----------------------------------------------------------------------------
----------------------End date delete----------------------------------------
-----------------------------------------------------------------------------
--
--There are no pending claims that spans across this date
--
FUNCTION enddate_veh_alloc
                   (p_assignment_id     IN  NUMBER
                    ,p_effective_date    IN  DATE
		   ) RETURN NUMBER IS
--Get the claim count for future and current date tracks
CURSOR c_claim_count_cursor IS
SELECT count(*)
      FROM pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
   WHERE pel.element_type_id =pet.element_type_id
     AND pee.assignment_id   = p_assignment_id
     AND pel.element_link_id = pee.element_link_id
     AND pet.legislation_code = 'IE'
     AND pet.element_name =('IE BIK Company Vehicle')
     AND p_effective_date < pee.effective_end_date;

 l_alloc_count         NUMBER ;
BEGIN

  OPEN c_claim_count_cursor;
  FETCH c_claim_count_cursor INTO l_alloc_count;
  CLOSE c_claim_count_cursor;
  --Check claims existence check
   IF l_alloc_count > 0 THEN
        RETURN -1 ;
    END IF;
   RETURN 0;
END enddate_veh_alloc;
-- end function

PROCEDURE CHECK_BIK_ENTRY
  (p_assignment_id_o IN  NUMBER
  ,p_vehicle_allocation_id  in number  --Bug 3466513 New parameter added
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72);
  l_return_status NUMBER ;
  l_message VARCHAR2(2500) ;
  l_assignment_id       pqp_vehicle_allocations_f.assignment_id%TYPE;
--
Begin
  l_proc := 'PAY_IE_BIK_CHECK.CHECK_BIK_ENTRY';
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN
    --
    --Checking the vehicle availability before delete or purge.
    IF p_datetrack_mode = 'ZAP' THEN
      --This is for purge
      l_return_status := purge_veh_alloc
                             (p_assignment_id   => p_assignment_id_o
                             ,p_effective_date  =>p_effective_date
			     ,p_vehicle_allocation_id => p_vehicle_allocation_id);
      hr_utility.set_location('Purge delete status:'||l_return_status,2);
      IF l_return_status = -1 THEN
        fnd_message.set_name('PQP', 'PQP_230724_DEL_ALLOC_RESTRICT');
        fnd_message.raise_error;
      END IF;
  /*Commented for Bug No. 3745749*/
 /* ELSIF p_datetrack_mode = 'DELETE' THEN
       --This is for enddate
       l_return_status := enddate_veh_alloc
                              ( p_assignment_id   => p_assignment_id_o
                               ,p_effective_date  =>p_effective_date);
       hr_utility.set_location('End date delete status :'||l_return_status,3);
       IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230700_CANCEL_INFO');
         fnd_message.raise_error;
       END IF;*/
    END IF;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc,4);
  Exception
   when app_exception.application_exception then
   IF hr_multi_message.exception_add
         (
	  p_same_associated_columns => 'Y'
	) then
      raise;
  END IF;
End CHECK_BIK_ENTRY;
--
END PAY_IE_BIK_CHECK;

/
