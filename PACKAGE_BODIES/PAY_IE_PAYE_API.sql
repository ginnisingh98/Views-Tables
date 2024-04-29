--------------------------------------------------------
--  DDL for Package Body PAY_IE_PAYE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PAYE_API" as
/* $Header: pyipdapi.pkb 120.4 2007/11/27 07:42:31 rsahai noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_ie_paye_api.';

-- 6015209
-- ----------------------------------------------------------------------------
-- |--------------------------< create_p46 >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_p46 ( p_effective_date IN DATE
                         , p_assignment_id IN NUMBER
                         , p_business_group_id IN NUMBER
                         , p_Tax_This_Employment IN NUMBER
				 , p_Previous_Employment_Start_Dt IN DATE
                         , p_Previous_Employment_End_Date IN DATE
				 , p_Pay_This_Employment IN NUMBER
				 , p_PAYE_Previous_Employer IN VARCHAR2
				 , p_P45P3_Or_P46 IN VARCHAR2
				 , p_Already_Submitted IN VARCHAR2
				 --, p_P45P3_Or_P46_Processed IN VARCHAR2

   ) is
  CURSOR element_csr IS
  SELECT element_type_id
  FROM   pay_element_types_f
  WHERE  element_name = 'IE P45P3_P46 Information'
  AND    nvl(business_group_id, p_business_group_id) = p_business_group_id
  AND    nvl(legislation_code, 'IE') = 'IE'
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  element_rec element_csr%ROWTYPE;
  --
  CURSOR input_val_csr(p_element_type_id IN NUMBER, p_name In VARCHAR2) IS
  SELECT input_value_id
  FROM   pay_input_values_f
  WHERE  element_type_id = p_element_type_id
  AND    name = p_name
  AND    nvl(business_group_id, p_business_group_id) = p_business_group_id
  AND    nvl(legislation_code, 'IE') = 'IE'
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  input_val_rec1 input_val_csr%ROWTYPE;
  input_val_rec2 input_val_csr%ROWTYPE;
  input_val_rec3 input_val_csr%ROWTYPE;
  input_val_rec4 input_val_csr%ROWTYPE;
  input_val_rec5 input_val_csr%ROWTYPE;
  input_val_rec6 input_val_csr%ROWTYPE;
  input_val_rec7 input_val_csr%ROWTYPE;
  input_val_rec8 input_val_csr%ROWTYPE;
  --

  CURSOR link_csr(p_element_type_id IN NUMBER) IS
   SELECT links.element_link_id
      FROM   pay_element_links_f links, per_all_assignments_f assign
      WHERE  links.element_type_id = p_element_type_id
      AND    links.business_group_id=p_business_group_id
      AND    assign.assignment_id=p_assignment_id
      AND   ((    links.payroll_id is not null
              and links.payroll_id = assign.payroll_id)
      OR     (    links.link_to_all_payrolls_flag='Y'
              and assign.payroll_id is not null)
      OR     (    links.payroll_id is null
              and links.link_to_all_payrolls_flag='N')
      OR     links.job_id=assign.job_id
      OR     links.position_id=assign.position_id
      OR     links.people_group_id=assign.people_group_id
      OR     links.organization_id=assign.organization_id
      OR     links.grade_id=assign.grade_id
      OR     links.location_id=assign.location_id
      OR     links.pay_basis_id=assign.pay_basis_id
      OR     links.employment_category=assign.employment_category)
      AND    p_effective_date BETWEEN links.effective_start_date
                              AND     links.effective_end_date;
  --
  link_rec link_csr%ROWTYPE;
  --
  l_element_entry_id NUMBER;
  l_effective_start_date DATE;
  l_effective_end_date DATE;
  l_object_version_number NUMBER;
  l_create_warning BOOLEAN := FALSE;
begin
      --
      -- Get Element information
      --
      OPEN  element_csr;
      FETCH element_csr INTO element_rec;
      CLOSE element_csr;
      --
      -- Get Input Values
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Tax This Employment');
      FETCH input_val_csr INTO input_val_rec1;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Previous Employment Start Date');
      FETCH input_val_csr INTO input_val_rec2;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Previous Employment End Date');
      FETCH input_val_csr INTO input_val_rec3;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Pay This Employment');
      FETCH input_val_csr INTO input_val_rec4;
      CLOSE input_val_csr;
      --
	OPEN  input_val_csr(element_rec.element_type_id, 'PAYE Previous Employer');
      FETCH input_val_csr INTO input_val_rec5;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'P45P3 Or P46');
      FETCH input_val_csr INTO input_val_rec6;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Already Submitted');
      FETCH input_val_csr INTO input_val_rec7;
      CLOSE input_val_csr;
      --
      /*OPEN  input_val_csr(element_rec.element_type_id, 'P45P3 Or P46 Processed');
      FETCH input_val_csr INTO input_val_rec8;
      CLOSE input_val_csr;*/
	--
      -- Get element link information
      --
      OPEN  link_csr(element_rec.element_type_id);
      FETCH link_csr INTO link_rec;
      CLOSE link_csr;

	   -- Call API To Create element entry.
	   py_element_entry_api.create_element_entry (
		p_effective_date             => p_effective_date,
		p_business_group_id          => p_business_group_id,
		--p_original_entry_id          => p_original_entry_id,          -- default
		p_assignment_id              => p_assignment_id,
		p_element_link_id            => link_rec.element_link_id,
		p_entry_type                 => 'E',
		p_creator_type               => 'F',
		p_input_value_id1            => input_val_rec1.input_value_id,
		p_input_value_id2            => input_val_rec2.input_value_id,
		p_input_value_id3            => input_val_rec3.input_value_id,
		p_input_value_id4            => input_val_rec4.input_value_id,
		p_input_value_id5            => input_val_rec5.input_value_id,
		p_input_value_id6            => input_val_rec6.input_value_id,
		p_input_value_id7            => input_val_rec7.input_value_id,
		--p_input_value_id8            => input_val_rec8.input_value_id,
		p_entry_value1               => nvl(p_Tax_This_Employment,0),
		p_entry_value2               => p_Previous_Employment_Start_Dt,
		p_entry_value3               => p_Previous_Employment_End_Date,
		p_entry_value4               => nvl(p_Pay_This_Employment,0),
		p_entry_value5               => p_PAYE_Previous_Employer,
		p_entry_value6               => nvl(p_P45P3_Or_P46,'N'),
		p_entry_value7               => nvl(p_Already_Submitted,'N'),
		--p_entry_value8               => nvl(p_P45P3_Or_P46_Processed,'N'),
		p_effective_start_date       => l_effective_start_date,
		p_effective_end_date         => l_effective_end_date,
		p_element_entry_id           => l_element_entry_id,
		p_object_version_number      => l_object_version_number,
		p_create_warning             => l_create_warning
	   );

end create_p46;
--6015209
-- ----------------------------------------------------------------------------
-- |--------------------------< update_p46 >------------------------------|
-- ----------------------------------------------------------------------------
procedure update_p46 (    p_effective_date IN DATE
				, p_assignment_id IN NUMBER
				, p_business_group_id IN NUMBER
				, p_datetrack_update_mode IN VARCHAR2
				, p_object_version_number IN OUT NOCOPY NUMBER
				, p_paye_details_id IN NUMBER
				, p_Tax_This_Employment IN NUMBER
				, p_Previous_Employment_Start_Dt IN	DATE
				, p_Previous_Employment_End_Date IN	DATE
				, p_Pay_This_Employment IN NUMBER
				, p_PAYE_Previous_Employer IN	VARCHAR2
				, p_P45P3_Or_P46 IN VARCHAR2
				, p_Already_Submitted IN VARCHAR2
				--, p_P45P3_Or_P46_Processed IN VARCHAR2
   ) is
  CURSOR element_csr IS
  SELECT element_type_id
  FROM   pay_element_types_f
  WHERE  element_name = 'IE P45P3_P46 Information'
  AND    nvl(business_group_id, p_business_group_id) = p_business_group_id
  AND    nvl(legislation_code, 'IE') = 'IE'
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  element_rec element_csr%ROWTYPE;
  --
  CURSOR input_val_csr(p_element_type_id IN NUMBER, p_name In VARCHAR2) IS
  SELECT input_value_id
  FROM   pay_input_values_f
  WHERE  element_type_id = p_element_type_id
  AND    name = p_name
  AND    nvl(business_group_id, p_business_group_id) = p_business_group_id
  AND    nvl(legislation_code, 'IE') = 'IE'
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  input_val_rec1 input_val_csr%ROWTYPE;
  input_val_rec2 input_val_csr%ROWTYPE;
  input_val_rec3 input_val_csr%ROWTYPE;
  input_val_rec4 input_val_csr%ROWTYPE;
  input_val_rec5 input_val_csr%ROWTYPE;
  input_val_rec6 input_val_csr%ROWTYPE;
  input_val_rec7 input_val_csr%ROWTYPE;
  input_val_rec8 input_val_csr%ROWTYPE;
  --
   l_tax_yr_start_date date;
   CURSOR entry_csr IS
    SELECT pee.element_entry_id, pee.effective_start_date, pee.object_version_number
      FROM pay_element_entries_f pee,
           pay_element_types_f pet,
           pay_element_links_f pel
     WHERE pee.element_link_id = pel.element_link_id AND
           pee.assignment_id = p_assignment_id AND
           --p_effective_date between pee.effective_start_date and pee.effective_end_date AND
	     --pee.effective_start_date >= l_tax_yr_start_date and
           --pee.effective_end_date <= add_months(l_tax_yr_start_date,12) AND
           pel.element_type_id = pet.element_type_id AND
           pel.business_group_id = p_business_group_id AND
           pet.element_name = 'IE P45P3_P46 Information' AND
           NVL(pet.business_group_id, p_business_group_id) = p_business_group_id AND
           pet.legislation_code = 'IE' ;

  rec_entry_csr entry_csr%rowtype;
  --
  l_element_entry_id NUMBER;
  l_effective_start_date DATE;
  l_effective_end_date DATE;
  l_update_warning BOOLEAN := FALSE;
  l_object_version_number NUMBER;
  --
/*
   CURSOR entry_csr_any IS
    SELECT pee.element_entry_id, pee.effective_start_date
      FROM pay_element_entries_f pee,
           pay_element_types_f pet,
           pay_element_links_f pel
     WHERE pee.element_link_id = pel.element_link_id AND
           pee.assignment_id = p_assignment_id AND
           --p_effective_date between pee.effective_start_date and pee.effective_end_date AND
           pel.element_type_id = pet.element_type_id AND
           pel.business_group_id = p_business_group_id AND
           pet.element_name = 'IE P45P3_P46 Information' AND
           NVL(pet.business_group_id, p_business_group_id) = p_business_group_id AND
           pet.legislation_code = 'IE' ;

  rec_entry_csr_any entry_csr_any%rowtype;
*/
  --
  CURSOR cur_p45p3_eff_start_date IS
  SELECT min(effective_start_date)
  FROM   pay_ie_paye_details_f
  WHERE  paye_details_id = p_paye_details_id;
  --AND    p_effective_date BETWEEN effective_start_date AND effective_end_date
  --AND effective_start_date >= l_tax_yr_start_date
  --AND effective_end_date <= add_months(l_tax_yr_start_date,12);
  --
  l_p45p3_eff_start_date pay_ie_paye_details_f.effective_start_date%type;
  l_datetrack_update_mode  VARCHAR2(100);

begin

	l_tax_yr_start_date := to_date('01/01/' || to_char(p_effective_date,'YYYY'),'DD/MM/YYYY');
	--
      -- Get Element information
      --
      OPEN  element_csr;
      FETCH element_csr INTO element_rec;
      CLOSE element_csr;
      --
      -- Get Input Values
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Tax This Employment');
      FETCH input_val_csr INTO input_val_rec1;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Previous Employment Start Date');
      FETCH input_val_csr INTO input_val_rec2;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Previous Employment End Date');
      FETCH input_val_csr INTO input_val_rec3;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Pay This Employment');
      FETCH input_val_csr INTO input_val_rec4;
      CLOSE input_val_csr;
      --
	OPEN  input_val_csr(element_rec.element_type_id, 'PAYE Previous Employer');
      FETCH input_val_csr INTO input_val_rec5;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'P45P3 Or P46');
      FETCH input_val_csr INTO input_val_rec6;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Already Submitted');
      FETCH input_val_csr INTO input_val_rec7;
      CLOSE input_val_csr;
	--
      /*OPEN  input_val_csr(element_rec.element_type_id, 'P45P3 Or P46 Processed');
      FETCH input_val_csr INTO input_val_rec8;
      CLOSE input_val_csr;*/
	--
	open entry_csr;
	fetch entry_csr into rec_entry_csr;
	close entry_csr;
	--
	OPEN  cur_p45p3_eff_start_date;
	FETCH cur_p45p3_eff_start_date INTO l_p45p3_eff_start_date;
	CLOSE cur_p45p3_eff_start_date;
	--

--   FOR  element_entries in entry_csr
--   LOOP
       IF rec_entry_csr.element_entry_id IS NOT NULL THEN
          -- Call Update element entry API
		-- Datetrack records are not required. so setting the mode to correction always.
		l_datetrack_update_mode := 'CORRECTION';
		l_object_version_number := rec_entry_csr.object_version_number;

		py_element_entry_api.update_element_entry
		  (p_validate				=> false
		  ,p_datetrack_update_mode		=> l_datetrack_update_mode   --p_datetrack_update_mode
		  ,p_effective_date			=> l_p45p3_eff_start_date    --p_effective_date
		  ,p_business_group_id			=> p_business_group_id
		  ,p_element_entry_id			=> rec_entry_csr.element_entry_id
		  ,p_object_version_number		=> l_object_version_number   --p_object_version_number
		  ,p_input_value_id1			=> input_val_rec1.input_value_id
		  ,p_input_value_id2			=> input_val_rec2.input_value_id
		  ,p_input_value_id3			=> input_val_rec3.input_value_id
		  ,p_input_value_id4			=> input_val_rec4.input_value_id
		  ,p_input_value_id5			=> input_val_rec5.input_value_id
		  ,p_input_value_id6			=> input_val_rec6.input_value_id
		  ,p_input_value_id7			=> input_val_rec7.input_value_id
		  --,p_input_value_id8			=> input_val_rec8.input_value_id
		  ,p_entry_value1				=> nvl(p_Tax_This_Employment,0)
		  ,p_entry_value2				=> p_Previous_Employment_Start_Dt
		  ,p_entry_value3				=> p_Previous_Employment_End_Date
		  ,p_entry_value4				=> nvl(p_Pay_This_Employment,0)
		  ,p_entry_value5				=> p_PAYE_Previous_Employer
		  ,p_entry_value6				=> nvl(p_P45P3_Or_P46,'N')
		  ,p_entry_value7				=> nvl(p_Already_Submitted,'N')
		  --,p_entry_value8				=> nvl(p_P45P3_Or_P46_Processed,'N')
		  ,p_effective_start_date		=> l_effective_start_date
		  ,p_effective_end_date			=> l_effective_end_date
		  ,p_update_warning			=> l_update_warning
		  );
	 ELSE
		--OPEN entry_csr_any;
		--FETCH entry_csr_any INTO rec_entry_csr_any;
		--IF entry_csr_any%NOTFOUND THEN
		-- if mode is Correction then create the record with same eff start date as in pay_ie_paye_details_f table
		-- if mode is updation then create the record with effective date passed.
			--
			/*
			IF p_datetrack_update_mode	= 'CORRECTION' THEN
				OPEN  cur_p45p3_eff_start_date;
				FETCH cur_p45p3_eff_start_date INTO l_p45p3_eff_start_date;
				CLOSE cur_p45p3_eff_start_date;
			ELSIF p_datetrack_update_mode	= 'UPDATE' THEN
				l_p45p3_eff_start_date := p_effective_date;
			END IF;
			*/
			--
			IF (	nvl(p_Tax_This_Employment,0) <> 0 OR
				nvl(p_Pay_This_Employment,0) <> 0 OR
				p_Previous_Employment_Start_Dt IS NOT NULL OR
				p_Previous_Employment_End_Date IS NOT NULL OR
				p_PAYE_Previous_Employer IS NOT NULL OR
				p_Already_Submitted IS NOT NULL OR
				p_P45P3_Or_P46 IS NOT NULL
			    )
			THEN
			     create_p46 ( l_p45p3_eff_start_date
						, p_assignment_id
						, p_business_group_id
						, p_Tax_This_Employment
						, p_Previous_Employment_Start_Dt
						, p_Previous_Employment_End_Date
						, p_Pay_This_Employment
						, p_PAYE_Previous_Employer
						, p_P45P3_Or_P46
						, p_Already_Submitted
						--, p_P45P3_Or_P46_Processed
						);
			END IF;
		--END IF;
		--CLOSE entry_csr_any;
	 END IF;
   --END LOOP;

end update_p46;
--6015209
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_p46 >------------------------------|
-- ----------------------------------------------------------------------------
--6015209
procedure delete_p46 (   p_effective_date IN DATE
                         , p_assignment_id IN NUMBER
                         , p_business_group_id IN NUMBER
				 , p_datetrack_delete_mode IN VARCHAR2
				 , p_object_version_number IN OUT NOCOPY NUMBER
				) is
   l_tax_yr_start_date date;
-- eff date condition is not used since we are not keeping the datetrack records.
   CURSOR entry_csr IS
    SELECT pee.element_entry_id, pee.effective_start_date, pee.object_version_number
      FROM pay_element_entries_f pee,
           pay_element_types_f pet,
           pay_element_links_f pel
     WHERE pee.element_link_id = pel.element_link_id AND
           pee.assignment_id = p_assignment_id AND
           --p_effective_date between pee.effective_start_date and pee.effective_end_date AND
           pel.element_type_id = pet.element_type_id AND
           pel.business_group_id = p_business_group_id AND
           pet.element_name = 'IE P45P3_P46 Information' AND
           NVL(pet.business_group_id, p_business_group_id) = p_business_group_id AND
           pet.legislation_code = 'IE' ;

  rec_entry_csr entry_csr%rowtype;

  l_effective_start_date DATE;
  l_effective_end_date DATE;
  l_delete_warning BOOLEAN := FALSE;

BEGIN
   -- Get ELement Entry Information
   -- derive the tax year start date givevn the effective data
   --l_tax_yr_start_date := to_date('01/01/' || to_char(p_effective_date,'YYYY'),'DD/MM/YYYY');
	open entry_csr;
	fetch entry_csr into rec_entry_csr;
	close entry_csr;
	p_object_version_number := rec_entry_csr.object_version_number;

	 --
       IF rec_entry_csr.element_entry_id IS NOT NULL THEN
          -- Call Delete element entry API
		py_element_entry_api.delete_element_entry
		(p_validate			 => false
		,p_datetrack_delete_mode => p_datetrack_delete_mode
		,p_effective_date		 => rec_entry_csr.effective_start_date
		,p_element_entry_id	 => rec_entry_csr.element_entry_id
		,p_object_version_number => p_object_version_number
		,p_effective_start_date	 => l_effective_start_date
		,p_effective_end_date	 => l_effective_end_date
		,p_delete_warning		 => l_delete_warning
		);
       END IF;
	 --
end delete_p46;
--6015209
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_bal_adj >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_adj ( p_effective_date IN DATE
                         , p_assignment_id IN NUMBER
                         , p_business_group_id IN NUMBER
                         , p_tax_deducted_to_date IN NUMBER
                         , p_pay_to_date IN NUMBER
                         , p_disability_benefit IN NUMBER
                         , p_lump_sum_payment IN NUMBER
   ) is
  CURSOR element_csr IS
  SELECT element_type_id
  FROM   pay_element_types_f
  WHERE  element_name = 'IE P45 Information'
  AND    nvl(business_group_id, p_business_group_id) = p_business_group_id
  AND    nvl(legislation_code, 'IE') = 'IE'
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  element_rec element_csr%ROWTYPE;
  --
  CURSOR input_val_csr(p_element_type_id IN NUMBER, p_name In VARCHAR2) IS
  SELECT input_value_id
  FROM   pay_input_values_f
  WHERE  element_type_id = p_element_type_id
  AND    name = p_name
  AND    nvl(business_group_id, p_business_group_id) = p_business_group_id
  AND    nvl(legislation_code, 'IE') = 'IE'
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  input_val_rec1 input_val_csr%ROWTYPE;
  input_val_rec2 input_val_csr%ROWTYPE;
  input_val_rec3 input_val_csr%ROWTYPE;
  input_val_rec4 input_val_csr%ROWTYPE;
  --
  -- BUG 2616218
  CURSOR link_csr(p_element_type_id IN NUMBER) IS
   SELECT links.element_link_id
      FROM   pay_element_links_f links, per_all_assignments_f assign
      WHERE  links.element_type_id = p_element_type_id
      AND    links.business_group_id=p_business_group_id
      AND    assign.assignment_id=p_assignment_id
      AND   ((    links.payroll_id is not null
              and links.payroll_id = assign.payroll_id)
      OR     (    links.link_to_all_payrolls_flag='Y'
              and assign.payroll_id is not null)
      OR     (    links.payroll_id is null
              and links.link_to_all_payrolls_flag='N')
      OR     links.job_id=assign.job_id
      OR     links.position_id=assign.position_id
      OR     links.people_group_id=assign.people_group_id
      OR     links.organization_id=assign.organization_id
      OR     links.grade_id=assign.grade_id
      OR     links.location_id=assign.location_id
      OR     links.pay_basis_id=assign.pay_basis_id
      OR     links.employment_category=assign.employment_category)
      AND    p_effective_date BETWEEN links.effective_start_date
                              AND     links.effective_end_date;
  --
  link_rec link_csr%ROWTYPE;
  --
  l_element_entry_id NUMBER;
  l_effective_start_date DATE;
  l_effectiver_end_date DATE;
  l_object_version_number NUMBER;
  l_create_warning BOOLEAN := FALSE;
begin
      --
      -- Get Element information
      --
      OPEN  element_csr;
      FETCH element_csr INTO element_rec;
      CLOSE element_csr;
      --
      -- Get Input Values
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Tax Deducted To Date');
      FETCH input_val_csr INTO input_val_rec1;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Pay To Date');
      FETCH input_val_csr INTO input_val_rec2;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Lump Sum Payment');
      FETCH input_val_csr INTO input_val_rec3;
      CLOSE input_val_csr;
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Disability Benefit');
      FETCH input_val_csr INTO input_val_rec4;
      CLOSE input_val_csr;
      --
      -- Get element link information
      --
      OPEN  link_csr(element_rec.element_type_id);
      FETCH link_csr INTO link_rec;
      CLOSE link_csr;
      --
      -- Call API To Create Balance Adjustment
      --
      pay_balance_adjustment_api.create_adjustment (
            p_validate                   => false,
            p_effective_date             => p_effective_date,
            p_assignment_id              => p_assignment_id,
            p_consolidation_set_id       => NULL,
            p_element_link_id            => link_rec.element_link_id,
            p_input_value_id1            => input_val_rec1.input_value_id,
            p_input_value_id2            => input_val_rec2.input_value_id,
            p_input_value_id3            => input_val_rec3.input_value_id,
            p_input_value_id4            => input_val_rec4.input_value_id,
            p_entry_value1               => nvl(p_tax_deducted_to_date,0),
            p_entry_value2               => nvl(p_pay_to_date,0),
            p_entry_value3               => nvl(p_lump_sum_payment,0),
            p_entry_value4               => nvl(p_disability_benefit,0),
            -- Element entry information.
            p_element_entry_id           => l_element_entry_id,
            p_effective_start_date       => l_effective_start_date,
            p_effective_end_date         => l_effectiver_end_date,
            p_object_version_number      => l_object_version_number,
            p_create_warning             => l_create_warning );
end create_bal_adj;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_bal_adj >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_bal_adj (p_effective_date    IN DATE
                     ,p_business_group_id IN NUMBER
                     ,p_assignment_id     IN NUMBER ) IS
/* commented to fix bug 3013304
we now delete all the balances whihc are created within the tax year
rather than just deleting the one.

   CURSOR entry_csr IS
      SELECT pee.element_entry_id
      FROM   pay_element_entries_f pee, pay_element_types_f pet, pay_element_links_f pel
      WHERE  pee.element_link_id = pel.element_link_id
      AND    pee.assignment_id = p_assignment_id
      AND    p_effective_date BETWEEN pee.effective_start_Date AND pee.effective_end_Date
      AND    pel.element_type_id = pet.element_type_id
      AND    pel.business_group_id = p_business_group_id
      AND    p_effective_date BETWEEN pel.effective_start_Date AND pel.effective_end_Date
      AND    pet.element_name = 'IE P45 Information'
      AND    nvl(pet.business_group_id, p_business_group_id) = p_business_group_id
      AND    pet.legislation_code = 'IE'
      AND    p_effective_date BETWEEN pet.effective_start_Date AND pet.effective_end_Date;
*/
   --
--   entry_rec entry_csr%ROWTYPE;
   l_tax_yr_start_date date;
   CURSOR entry_csr IS
    SELECT pee.element_entry_id, pee.effective_start_date
      FROM pay_element_entries_f pee,
           pay_element_types_f pet,
           pay_element_links_f pel
     WHERE pee.element_link_id = pel.element_link_id AND
           pee.assignment_id = p_assignment_id AND
           pee.effective_start_date >= l_tax_yr_start_date and
           pee.effective_end_date <= add_months(l_tax_yr_start_date,12) AND
           pel.element_type_id = pet.element_type_id AND
           pel.business_group_id = p_business_group_id AND
--           pet.element_name = 'IE P45 Information' AND
           pet.element_name in('IE P45 Information', 'Setup P45 Element') AND
           NVL(pet.business_group_id, p_business_group_id) = p_business_group_id AND
           pet.legislation_code = 'IE' ;
BEGIN
   -- Get ELement Entry Information
   -- derive the tax year start date givevn the effective data
   l_tax_yr_start_date := to_date('01/01/' || to_char(p_effective_date,'YYYY'),'DD/MM/YYYY');
   for  element_entries in entry_csr loop
       --
       IF element_entries.element_entry_id IS NOT NULL THEN
          -- Call Delete Adjustment API to rollback payroll action for this element entry
          pay_balance_adjustment_api.delete_adjustment (
             p_validate         => false,
             p_effective_date   => element_entries.effective_start_date,
             p_element_entry_id => element_entries.element_entry_id );
       END IF;
   end loop;
END delete_bal_adj;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ie_paye_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ie_paye_details
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_info_source                   in     varchar2
  ,p_tax_basis                     in     varchar2
  ,p_certificate_start_date        in     date
  ,p_tax_assess_basis              in     varchar2
  ,p_certificate_issue_date        in     date
  ,p_certificate_end_date          in     date
  ,p_weekly_tax_credit             in     number
  ,p_weekly_std_rate_cut_off       in     number
  ,p_monthly_tax_credit            in     number
  ,p_monthly_std_rate_cut_off      in     number
  ,p_tax_deducted_to_date          in     number
  ,p_pay_to_date                   in     number
  ,p_disability_benefit            in     number
  ,p_lump_sum_payment              in     number
  ,p_paye_details_id               out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_Tax_This_Employment	      in     Number
  ,p_Previous_Employment_Start_Dt   in	date
  ,p_Previous_Employment_End_Date	in	date
  ,p_Pay_This_Employment		in	number
  ,p_PAYE_Previous_Employer		in	varchar2
  ,p_P45P3_Or_P46				in	varchar2
  ,p_Already_Submitted			in	varchar2
  --,p_P45P3_Or_P46_Processed		in	varchar2
    ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_ie_paye_details';
  l_certificate_start_date date;
  l_certificate_issue_date date;
  l_certificate_end_date   date;
  l_paye_details_id        number;
  l_object_version_number  number;
  l_effective_start_date   date;
  l_effective_end_Date     date;
  l_comm_period_no         number;
  l_request_id             number;
  l_program_id             number;
  l_prog_appl_id           number;
  l_business_group_id      number;
  --
  CURSOR business_group_csr IS
  SELECT business_group_id
  FROM   per_all_assignments_f
  WHERE  assignment_id = p_assignment_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ie_paye_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_certificate_start_date := trunc(p_certificate_start_date);
  l_certificate_issue_date := trunc(p_certificate_issue_date);
  l_certificate_end_date := trunc(p_certificate_end_date);
  --
  -- Get business_group_id
  --
  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_ie_paye_bk1.create_ie_paye_details_b
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_info_source                   => p_info_source
      ,p_tax_basis                     => p_tax_basis
      ,p_certificate_start_date        => p_certificate_start_date
      ,p_tax_assess_basis              => p_tax_assess_basis
      ,p_certificate_issue_date        => p_certificate_issue_date
      ,p_certificate_end_date          => p_certificate_end_date
      ,p_weekly_tax_credit             => p_weekly_tax_credit
      ,p_weekly_std_rate_cut_off       => p_weekly_std_rate_cut_off
      ,p_monthly_tax_credit            => p_monthly_tax_credit
      ,p_monthly_std_rate_cut_off      => p_monthly_std_rate_cut_off
      ,p_tax_deducted_to_date          => p_tax_deducted_to_date
      ,p_pay_to_date                   => p_pay_to_date
      ,p_disability_benefit            => p_disability_benefit
      ,p_lump_sum_payment              => p_lump_sum_payment
	,p_Tax_This_Employment		   => p_Tax_This_Employment
	,p_Previous_Employment_Start_Dt  => p_Previous_Employment_Start_Dt
	,p_Previous_Employment_End_Date  => p_Previous_Employment_End_Date
	,p_Pay_This_Employment		   => p_Pay_This_Employment
	,p_PAYE_Previous_Employer	   => p_PAYE_Previous_Employer
	,p_P45P3_Or_P46			   => p_P45P3_Or_P46
	,p_Already_Submitted		   => p_Already_Submitted
	--,p_P45P3_Or_P46_Processed	   => p_P45P3_Or_P46_Processed
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ie_paye_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set parameter values
  --
  l_request_id      :=  fnd_global.conc_request_id;
  l_prog_appl_id    :=  fnd_global.prog_appl_id;
  l_program_id      :=  fnd_global.conc_program_id;
  l_comm_period_no  :=  pay_ipd_bus.get_comm_period_no(p_effective_date => p_effective_date , p_assignment_id => p_assignment_id);
  --
  -- Insert record in pay_ie_paye_details_f
  --
  pay_ipd_ins.ins
      ( p_effective_date                 =>  p_effective_date
       ,p_assignment_id                  =>  p_assignment_id
       ,p_info_source                    =>  p_info_source
       ,p_comm_period_no                 =>  l_comm_period_no
       ,p_tax_basis                      =>  p_tax_basis
       ,p_certificate_start_date         =>  p_certificate_start_Date
       ,p_tax_assess_basis               =>  p_tax_assess_basis
       ,p_certificate_end_date           =>  p_certificate_end_date
       ,p_weekly_tax_credit              =>  p_weekly_tax_credit
       ,p_weekly_std_rate_cut_off        =>  p_weekly_std_rate_cut_off
       ,p_monthly_tax_credit             =>  p_monthly_tax_credit
       ,p_monthly_std_rate_cut_off       =>  p_monthly_std_rate_cut_off
       ,p_request_id                     =>  l_request_id
       ,p_program_application_id         =>  l_prog_appl_id
       ,p_program_id                     =>  l_program_id
       ,p_program_update_date            =>  sysdate
       ,p_paye_details_id                =>  l_paye_details_id
       ,p_object_version_number          =>  l_object_version_number
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       ,p_certificate_issue_date         =>  p_certificate_issue_Date
       );
  --
  -- Check if adjustments need to be created
  IF ( nvl(p_tax_deducted_to_date,0) <> 0 OR
         nvl(p_pay_to_date,0) <> 0 OR
         nvl(p_disability_benefit,0) <> 0 OR
         nvl(p_lump_sum_payment,0) <> 0) THEN

    -- delete any bal adj entires which could have
    -- been crreated by the bal adj screen
     delete_bal_adj ( p_effective_date => P_EFFECTIVE_DATE
                     ,p_business_group_id => l_business_group_id
                     ,p_assignment_id => p_assignment_id );


     -- Create P45 Balance Adjustments
     create_bal_adj ( p_effective_date => p_effective_date
                 , p_business_group_id => l_business_group_id
                 , p_assignment_id => p_assignment_id
                 , p_tax_deducted_to_date => p_tax_deducted_to_date
                 , p_pay_to_date => p_pay_to_date
                 , p_disability_benefit => p_disability_benefit
                 , p_lump_sum_payment => p_lump_sum_payment );
  END IF;
  --
--6015209
  IF (	nvl(p_Tax_This_Employment,0) <> 0 OR
		nvl(p_Pay_This_Employment,0) <> 0 OR
		p_Previous_Employment_Start_Dt IS NOT NULL OR
		p_Previous_Employment_End_Date IS NOT NULL OR
		p_PAYE_Previous_Employer IS NOT NULL OR
		p_Already_Submitted IS NOT NULL OR
		p_P45P3_Or_P46 IS NOT NULL
     )
  THEN
     create_p46 ( p_effective_date
			, p_assignment_id
			, l_business_group_id
			, p_Tax_This_Employment
			, p_Previous_Employment_Start_Dt
			, p_Previous_Employment_End_Date
			, p_Pay_This_Employment
			, p_PAYE_Previous_Employer
			, p_P45P3_Or_P46
			, p_Already_Submitted
			--, p_P45P3_Or_P46_Processed
			);
  END IF;
--6015209

  -- Call After Process User Hook
  --
  begin
     pay_ie_paye_bk1.create_ie_paye_details_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_info_source                   => p_info_source
      ,p_tax_basis                     => p_tax_basis
      ,p_certificate_start_date        => p_certificate_start_date
      ,p_tax_assess_basis              => p_tax_assess_basis
      ,p_certificate_issue_date        => p_certificate_issue_date
      ,p_certificate_end_date          => p_certificate_end_date
      ,p_weekly_tax_credit             => p_weekly_tax_credit
      ,p_weekly_std_rate_cut_off       => p_weekly_std_rate_cut_off
      ,p_monthly_tax_credit            => p_monthly_tax_credit
      ,p_monthly_std_rate_cut_off      => p_monthly_std_rate_cut_off
      ,p_tax_deducted_to_date          => p_tax_deducted_to_date
      ,p_pay_to_date                   => p_pay_to_date
      ,p_disability_benefit            => p_disability_benefit
      ,p_lump_sum_payment              => p_lump_sum_payment
      ,p_paye_details_id               => l_paye_details_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
	,p_Tax_This_Employment	         => p_Tax_This_Employment
	,p_Previous_Employment_Start_Dt  => p_Previous_Employment_Start_Dt
	,p_Previous_Employment_End_Date  => p_Previous_Employment_End_Date
	,p_Pay_This_Employment		   => p_Pay_This_Employment
	,p_PAYE_Previous_Employer	   => p_PAYE_Previous_Employer
	,p_P45P3_Or_P46			   => p_P45P3_Or_P46
	,p_Already_Submitted		   => p_Already_Submitted
	--,p_P45P3_Or_P46_Processed	   => p_P45P3_Or_P46_Processed
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ie_paye_details'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_paye_details_id        := l_paye_details_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_Date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ie_paye_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_paye_details_id        := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ie_paye_details;
    p_paye_details_id        := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ie_paye_details;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_ie_paye_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ie_paye_details
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_info_source                   in     varchar2
  ,p_tax_basis                     in     varchar2
  ,p_certificate_start_date        in     date
  ,p_tax_assess_basis              in     varchar2
  ,p_certificate_issue_date        in     date     default null
  ,p_certificate_end_date          in     date     default null
  ,p_weekly_tax_credit             in     number   default null
  ,p_weekly_std_rate_cut_off       in     number   default null
  ,p_monthly_tax_credit            in     number   default null
  ,p_monthly_std_rate_cut_off      in     number   default null
  ,p_tax_deducted_to_date          in     number   default null
  ,p_pay_to_date                   in     number   default null
  ,p_disability_benefit            in     number   default null
  ,p_lump_sum_payment              in     number   default null
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_Tax_This_Employment	      in     Number
  ,p_Previous_Employment_Start_Dt   in	date
  ,p_Previous_Employment_End_Date	in	date
  ,p_Pay_This_Employment		in	number
  ,p_PAYE_Previous_Employer		in	varchar2
  ,p_P45P3_Or_P46				in	varchar2
  ,p_Already_Submitted			in	varchar2
  --,p_P45P3_Or_P46_Processed		in	varchar2
  ) IS
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_ie_paye_details';
  l_certificate_start_date date;
  l_certificate_issue_date date;
  l_certificate_end_date   date;
  l_object_version_number  number := p_object_version_number;
  l_effective_start_date   date;
  l_effective_end_Date     date;
  l_request_id             number;
  l_program_id             number;
  l_prog_appl_id           number;
  l_p45_effective_date     date;
  l_assignment_id          number;
  l_business_group_id      number;
  --
  CURSOR asg_csr IS
  SELECT assignment_id
  FROM   pay_ie_paye_details_f
  WHERE  paye_details_id = p_paye_details_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  CURSOR business_group_csr IS
  SELECT business_group_id
  FROM   per_all_assignments_f
  WHERE  assignment_id = l_assignment_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

  --6015209
  --l_datetrack_delete_mode VARCHAR2(100) := 'ZAP';
  l_object_version_p45p3  NUMBER;

-- Checking if any future record exist for p45 record with in the Year.
   l_tax_yr_start_date date;
/*   CURSOR future_entry_csr IS
    SELECT pee.element_entry_id, pee.effective_start_date
      FROM pay_element_entries_f pee,
           pay_element_types_f pet,
           pay_element_links_f pel
     WHERE pee.element_link_id = pel.element_link_id AND
           pee.assignment_id = l_assignment_id AND
           pee.effective_start_date >= l_tax_yr_start_date and
           pee.effective_end_date <= add_months(l_tax_yr_start_date,12) AND
	     (pee.effective_start_date > p_effective_date OR
	      p_effective_date Between pee.effective_start_date AND pee.effective_end_date) AND
           pel.element_type_id = pet.element_type_id AND
           pel.business_group_id = l_business_group_id AND
           pet.element_name in('IE P45 Information', 'Setup P45 Element') AND
           NVL(pet.business_group_id, l_business_group_id) = l_business_group_id AND
           pet.legislation_code = 'IE' ; */

	CURSOR future_entry_csr IS
	select 1
	from
	pay_payroll_actions ppa,
	pay_assignment_actions paa,
	pay_run_results prr,
	pay_run_result_values prrv,
	pay_element_types_f petf,
	pay_element_entries_f peef
	where ppa.business_group_id = l_business_group_id
	and ppa.action_type = 'B'
	and ppa.action_status = 'C'
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.assignment_id = l_assignment_id
	and prr.assignment_action_id = paa.assignment_action_id
	and prr.entry_type = 'B'
	and prr.run_result_id = prrv.run_result_id
	and prr.element_type_id = petf.element_type_id
	and NVL(petf.business_group_id, l_business_group_id) = l_business_group_id
	and petf.element_name in('IE P45 Information', 'Setup P45 Element')
	and petf.legislation_code = 'IE'
	and peef.element_type_id = petf.element_type_id
	and peef.assignment_id = paa.assignment_id
	and peef.effective_start_date >= l_tax_yr_start_date
	and peef.effective_end_date <= add_months(l_tax_yr_start_date,12)
	and peef.entry_type = 'B'
	and peef.element_entry_id = prr.element_entry_id
	and ppa.effective_date > p_effective_date;

  rec_future_entry_exist future_entry_csr%rowtype;

  --6015209
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_tax_yr_start_date := to_date('01/01/' || to_char(p_effective_date,'YYYY'),'DD/MM/YYYY'); --6015209
  --
  -- Issue a savepoint
  --
  savepoint update_ie_paye_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_certificate_start_date := trunc(p_certificate_start_date);
  l_certificate_issue_date := trunc(p_certificate_issue_date);
  l_certificate_end_date := trunc(p_certificate_end_date);
  --
  -- Get assignment_id from the cursor
  OPEN asg_csr;
  FETCH asg_csr INTO l_assignment_id;
  CLOSE asg_csr;
  --
  -- Get Business Group Id
  --
  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_utility.set_location('before pay_ie_paye_bk2.update_ie_paye_details_b', 2001);
    pay_ie_paye_bk2.update_ie_paye_details_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_business_group_id             => l_business_group_id
      ,p_paye_details_id               => p_paye_details_id
      ,p_info_source                   => p_info_source
      ,p_tax_basis                     => p_tax_basis
      ,p_certificate_start_date        => p_certificate_start_date
      ,p_tax_assess_basis              => p_tax_assess_basis
      ,p_certificate_issue_date        => p_certificate_issue_date
      ,p_certificate_end_date          => p_certificate_end_date
      ,p_weekly_tax_credit             => p_weekly_tax_credit
      ,p_weekly_std_rate_cut_off       => p_weekly_std_rate_cut_off
      ,p_monthly_tax_credit            => p_monthly_tax_credit
      ,p_monthly_std_rate_cut_off      => p_monthly_std_rate_cut_off
      ,p_tax_deducted_to_date          => p_tax_deducted_to_date
      ,p_pay_to_date                   => p_pay_to_date
      ,p_disability_benefit            => p_disability_benefit
      ,p_lump_sum_payment              => p_lump_sum_payment
      ,p_object_version_number         => l_object_version_number
	,p_Tax_This_Employment	         => p_Tax_This_Employment
	,p_Previous_Employment_Start_Dt  => p_Previous_Employment_Start_Dt
	,p_Previous_Employment_End_Date  => p_Previous_Employment_End_Date
	,p_Pay_This_Employment		   => p_Pay_This_Employment
	,p_PAYE_Previous_Employer	   => p_PAYE_Previous_Employer
	,p_P45P3_Or_P46			   => p_P45P3_Or_P46
	,p_Already_Submitted		   => p_Already_Submitted
	--,p_P45P3_Or_P46_Processed	   => p_P45P3_Or_P46_Processed
      );
    hr_utility.set_location('after pay_ie_paye_bk2.update_ie_paye_details_b', 2001);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ie_paye_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set parameter values
  --
  l_request_id      :=  fnd_global.conc_request_id;
  l_prog_appl_id    :=  fnd_global.prog_appl_id;
  l_program_id      :=  fnd_global.conc_program_id;
  --
  -- Call row handler procedure to update paye details
  --
      hr_utility.set_location('before  pay_ipd_upd.upd', 2002);
      pay_ipd_upd.upd
      ( p_effective_date                 =>  p_effective_date
       ,p_datetrack_mode                 =>  p_datetrack_update_mode
       ,p_paye_details_id                =>  p_paye_details_id
       ,p_object_version_number          =>  l_object_version_number
       ,p_info_source                    =>  p_info_source
       ,p_tax_basis                      =>  p_tax_basis
       ,p_certificate_start_date         =>  p_certificate_start_Date
       ,p_tax_assess_basis               =>  p_tax_assess_basis
       ,p_certificate_end_date           =>  p_certificate_end_date
       ,p_weekly_tax_credit              =>  p_weekly_tax_credit
       ,p_weekly_std_rate_cut_off        =>  p_weekly_std_rate_cut_off
       ,p_monthly_tax_credit             =>  p_monthly_tax_credit
       ,p_monthly_std_rate_cut_off       =>  p_monthly_std_rate_cut_off
       ,p_request_id                     =>  l_request_id
       ,p_program_application_id         =>  l_prog_appl_id
       ,p_program_id                     =>  l_program_id
       ,p_program_update_date            =>  sysdate
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       ,p_certificate_issue_date         =>  p_certificate_issue_Date
       );
      hr_utility.set_location('after  pay_ipd_upd.upd', 2002);
  --
  -- Get effective date of the P45 balance adjustment
  -- If PAYE details record first started before current fiscal year then
  -- P45 adjustment effective date is the first day of the fiscal year
  -- the below code assumed that the P45 info could be entered only via TAx form
  -- which is incorrect., it could be entered by balance adjusment form
  -- This resulted in bug 3013304
  -- we now deleet all bal adj with the effective date tax year
  /*
  SELECT min(effective_start_date)
  INTO   l_p45_effective_date
  FROM   pay_ie_paye_details_f
  WHERE  paye_details_id = p_paye_details_id;

  --
  IF l_p45_effective_date < to_date('01-JAN-'||to_char(p_effective_date,'YYYY'), 'DD/MM/YYYY') THEN
     l_p45_effective_date := to_date('01-JAN-'||to_char(p_effective_date,'YYYY'), 'DD/MM/YYYY') ;
  END IF;
  */
  --

  OPEN future_entry_csr;
  FETCH future_entry_csr INTO rec_future_entry_exist;
  IF future_entry_csr%NOTFOUND AND ( nvl(p_tax_deducted_to_date,0)	= 0 AND
					       nvl(p_pay_to_date,0)			= 0 AND
					       nvl(p_disability_benefit,0)		= 0 AND
					       nvl(p_lump_sum_payment,0)		= 0
					     )
  THEN
     delete_bal_adj ( p_effective_date => P_EFFECTIVE_DATE
			   ,p_business_group_id => l_business_group_id
			   ,p_assignment_id => l_assignment_id );
  ELSIF ( nvl(p_tax_deducted_to_date,0) <> 0 OR
          nvl(p_pay_to_date,0) <> 0 OR
	    nvl(p_disability_benefit,0) <> 0 OR
	    nvl(p_lump_sum_payment,0) <> 0) THEN
  ---Check if adjustments need to be created
	  IF ( nvl(p_tax_deducted_to_date,0) <> hr_api.g_number OR
		   nvl(p_pay_to_date,0) <> hr_api.g_number OR
		   nvl(p_disability_benefit,0) <> hr_api.g_number OR
		   nvl(p_lump_sum_payment,0) <> hr_api.g_number) THEN
	     -- Delete previous adjustments
	     delete_bal_adj ( p_effective_date => P_EFFECTIVE_DATE
				   ,p_business_group_id => l_business_group_id
				   ,p_assignment_id => l_assignment_id );
	     --
	     -- Check if new balance adjustment entry needs to be crated
	     --
	     IF ( nvl(p_tax_deducted_to_date,0) <> 0 OR
		   nvl(p_pay_to_date,0) <> 0 OR
		   nvl(p_disability_benefit,0) <> 0 OR
		   nvl(p_lump_sum_payment,0) <> 0) THEN
		  --Create new P45 Balance Adjustments
		  create_bal_adj ( p_effective_date => P_EFFECTIVE_DATE -- l_p45_effective_date
			     , p_business_group_id => l_business_group_id
			     , p_assignment_id => l_assignment_id
			     , p_tax_deducted_to_date => p_tax_deducted_to_date
			     , p_pay_to_date => p_pay_to_date
			     , p_disability_benefit => p_disability_benefit
			     , p_lump_sum_payment => p_lump_sum_payment );
	     END IF;
	  END IF;
  END IF;
  CLOSE future_entry_csr;
--END IF;

hr_utility.set_location('before  update_p46', 2003);

--6015209
  IF (	nvl(p_Tax_This_Employment,0) <> 0 OR
		nvl(p_Pay_This_Employment,0) <> 0 OR
		p_Previous_Employment_Start_Dt IS NOT NULL OR
		p_Previous_Employment_End_Date IS NOT NULL OR
		p_PAYE_Previous_Employer IS NOT NULL OR
		p_Already_Submitted IS NOT NULL OR
		p_P45P3_Or_P46 IS NOT NULL
     )
  THEN
	update_p46 (	p_effective_date
				, l_assignment_id
				, l_business_group_id
				, p_datetrack_update_mode
				, l_object_version_p45p3
				, p_paye_details_id
				, p_Tax_This_Employment
				, p_Previous_Employment_Start_Dt
				, p_Previous_Employment_End_Date
				, p_Pay_This_Employment
				, p_PAYE_Previous_Employer
				, p_P45P3_Or_P46
				, p_Already_Submitted
				--, p_P45P3_Or_P46_Processed
				);
  END IF;
--6015209

hr_utility.set_location('after  update_p46', 2003);

  --
  -- Call After Process User Hook
  --
  begin
hr_utility.set_location('before  pay_ie_paye_bk2.update_ie_paye_details_a', 2004);
     pay_ie_paye_bk2.update_ie_paye_details_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_paye_details_id               => p_paye_details_id
      ,p_info_source                   => p_info_source
      ,p_tax_basis                     => p_tax_basis
      ,p_certificate_start_date        => p_certificate_start_date
      ,p_tax_assess_basis              => p_tax_assess_basis
      ,p_certificate_issue_date        => p_certificate_issue_date
      ,p_certificate_end_date          => p_certificate_end_date
      ,p_weekly_tax_credit             => p_weekly_tax_credit
      ,p_weekly_std_rate_cut_off       => p_weekly_std_rate_cut_off
      ,p_monthly_tax_credit            => p_monthly_tax_credit
      ,p_monthly_std_rate_cut_off      => p_monthly_std_rate_cut_off
      ,p_tax_deducted_to_date          => p_tax_deducted_to_date
      ,p_pay_to_date                   => p_pay_to_date
      ,p_disability_benefit            => p_disability_benefit
      ,p_lump_sum_payment              => p_lump_sum_payment
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
	,p_Tax_This_Employment	         => p_Tax_This_Employment
	,p_Previous_Employment_Start_Dt  => p_Previous_Employment_Start_Dt
	,p_Previous_Employment_End_Date  => p_Previous_Employment_End_Date
	,p_Pay_This_Employment		   => p_Pay_This_Employment
	,p_PAYE_Previous_Employer	   => p_PAYE_Previous_Employer
	,p_P45P3_Or_P46			   => p_P45P3_Or_P46
	,p_Already_Submitted		   => p_Already_Submitted
	--,p_P45P3_Or_P46_Processed	   => p_P45P3_Or_P46_Processed
      );

hr_utility.set_location('after  pay_ie_paye_bk2.update_ie_paye_details_a', 2004);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ie_paye_details'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
hr_utility.set_location('before  p_validate', 2005);
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
hr_utility.set_location('after  p_validate', 2005);
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_Date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    hr_utility.set_location('Inside  when hr_api.validate_enabled', 2009);
    rollback to update_ie_paye_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- IN OUT parameter should be reset to its IN value
    -- therefore no need to reset p_object_version_number
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
   hr_utility.set_location('Inside  when others', 2010);
    rollback to update_ie_paye_details;
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_ie_paye_details;

--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ie_paye_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_paye_details
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ) IS
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_ie_paye_details';
  l_object_version_number  number := p_object_version_number;
  l_effective_start_date   date;
  l_effective_end_Date     date;
  l_p45_effective_date     date;
  l_assignment_id          number;
  l_business_group_id      number;
  --
  CURSOR asg_csr IS
  SELECT assignment_id
  FROM   pay_ie_paye_details_f
  WHERE  paye_details_id = p_paye_details_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  CURSOR business_group_csr IS
  SELECT business_group_id
  FROM   per_all_assignments_f
  WHERE  assignment_id = l_assignment_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
 l_object_version_p45p3  NUMBER;
--
begin
  --hr_utility.trace_on(NULL,'RSS');
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ie_paye_details;
  --
  -- Get assignment_id from the cursor
  OPEN asg_csr;
  FETCH asg_csr INTO l_assignment_id;
  CLOSE asg_csr;
  --
  -- Get Business_group_id
  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  --
  --
  -- Call Before Process User Hook
  --
  begin
  hr_utility.set_location('before pay_ie_paye_bk3.delete_ie_paye_details_b', 1000);
    pay_ie_paye_bk3.delete_ie_paye_details_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_business_group_id             => l_business_group_id
      ,p_paye_details_id               => p_paye_details_id
      ,p_object_version_number         => l_object_version_number
      );
    hr_utility.set_location('after pay_ie_paye_bk3.delete_ie_paye_details_b', 1000);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ie_paye_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --BUG NO:2683086 Moved the call to procedure after call to delete_bal_adj procedure.
  /*
  -- Process Logic
  --
  -- Call row handler procedure to update paye details
  --
      pay_ipd_del.del
      ( p_effective_date                 =>  p_effective_date
       ,p_datetrack_mode                 =>  p_datetrack_delete_mode
       ,p_paye_details_id                =>  p_paye_details_id
       ,p_object_version_number          =>  l_object_version_number
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       );
   */
  --
  -- Get effective date of the P45 balance adjustment
  -- If PAYE details record first started before current fiscal year then
  -- P45 adjustment effective date is the first day of the fiscal year
  -- the below code assumed that the P45 info could be entered only via TAx form
  -- which is incorrect., it could be entered by balance adjusment form
  -- This resulted in bug 3013304
  -- we now deleet all bal adj with the effective date tax year
/*
  SELECT min(effective_start_date)
  INTO   l_p45_effective_date
  FROM   pay_ie_paye_details_f
  WHERE  paye_details_id = p_paye_details_id;
  --
  IF l_p45_effective_date < to_date('01-JAN-'||to_char(p_effective_date,'YYYY'), 'DD/MM/YYYY') THEN
     l_p45_effective_date := to_date('01-JAN-'||to_char(p_effective_date,'YYYY'), 'DD/MM/YYYY') ;
  END IF;
*/
  --
  -- Check if adjustments need to be deleted
  IF ( p_datetrack_delete_mode = hr_api.g_zap) THEN
     -- Delete previous adjustments
     delete_bal_adj ( p_effective_date => p_effective_date -- l_p45_effective_date
                     ,p_business_group_id => l_business_group_id
                     ,p_assignment_id => l_assignment_id );

	--6015209
	hr_utility.set_location('before delete_p46', 1001);

	delete_p46 (p_effective_date
			, l_assignment_id
			, l_business_group_id
			, p_datetrack_delete_mode
			, l_object_version_p45p3
			);
	hr_utility.set_location('after delete_p46', 1001);
	--6015209
  END IF;
  --BUG NO:2683086 Moved the call to procedure after call to delete_bal_adj procedure.

    -- Process Logic
    --
    -- Call row handler procedure to update paye details
    --
hr_utility.set_location('before  pay_ipd_del.del', 1002);
	  pay_ipd_del.del
        ( p_effective_date                 =>  p_effective_date
         ,p_datetrack_mode                 =>  p_datetrack_delete_mode
         ,p_paye_details_id                =>  p_paye_details_id
         ,p_object_version_number          =>  l_object_version_number
         ,p_effective_start_date           =>  l_effective_start_date
         ,p_effective_end_date             =>  l_effective_end_date
         );
hr_utility.set_location('after  pay_ipd_del.del', 1002);
  --
  --
  -- Call After Process User Hook
  --
  begin
hr_utility.set_location('before  pay_ie_paye_bk3.delete_ie_paye_details_a', 1003);
     pay_ie_paye_bk3.delete_ie_paye_details_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_paye_details_id               => p_paye_details_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
hr_utility.set_location('after  pay_ie_paye_bk3.delete_ie_paye_details_a', 1003);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ie_paye_details'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
hr_utility.set_location('before  p_validate', 1004);
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
hr_utility.set_location('after  p_validate', 1004);
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_Date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --hr_utility.trace_off;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_ie_paye_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location('Inside when Others', 1010);
    rollback to update_ie_paye_details;
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_ie_paye_details;

end pay_ie_paye_api;

/
