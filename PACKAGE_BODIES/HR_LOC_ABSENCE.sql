--------------------------------------------------------
--  DDL for Package Body HR_LOC_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOC_ABSENCE" AS
/* $Header: hrabsloc.pkb 120.12.12010000.2 2009/09/09 12:01:12 rsahai ship $ */

g_package  varchar2(33) := '  hr_loc_absence.';

/* pgopal- Added p_original_entry_id parameter*/
procedure get_element_details
  (p_absence_attendance_id      in  number
  ,p_assignment_id              in number
  ,p_element_type_id           out nocopy number
  ,p_create_entry              out nocopy  varchar2
  ,p_original_entry_id          OUT NOCOPY NUMBER  --gpopal
  ,p_input_value_id1            out nocopy number
  ,p_entry_value1               out nocopy VARCHAR2
  ,p_input_value_id2            out nocopy number
  ,p_entry_value2               out nocopy VARCHAR2
  ,p_input_value_id3            out nocopy number
  ,p_entry_value3               out nocopy VARCHAR2
  ,p_input_value_id4            out nocopy number
  ,p_entry_value4               out nocopy VARCHAR2
  ,p_input_value_id5            out nocopy number
  ,p_entry_value5               out nocopy VARCHAR2
  ,p_input_value_id6            out nocopy number
  ,p_entry_value6               out nocopy VARCHAR2
  ,p_input_value_id7            out nocopy number
  ,p_entry_value7               out nocopy VARCHAR2
  ,p_input_value_id8            out nocopy number
  ,p_entry_value8               out nocopy VARCHAR2
  ,p_input_value_id9            out nocopy number
  ,p_entry_value9               out nocopy VARCHAR2
  ,p_input_value_id10           out nocopy number
  ,p_entry_value10              out nocopy VARCHAR2
  ,p_input_value_id11           out nocopy number
  ,p_entry_value11              out nocopy VARCHAR2
  ,p_input_value_id12           out nocopy number
  ,p_entry_value12              out nocopy VARCHAR2
  ,p_input_value_id13           out nocopy number
  ,p_entry_value13              out nocopy VARCHAR2
  ,p_input_value_id14           out nocopy number
  ,p_entry_value14              out nocopy VARCHAR2
  ,p_input_value_id15           out nocopy number
  ,p_entry_value15              out nocopy VARCHAR2
  ) is



  cursor csr_get_absence_element(p_assignment_id NUMBER, p_element_type_id NUMBER) is
  select pee.element_entry_id element_entry_id
	  ,pet.processing_type processing_type
          ,pee.effective_start_date effective_start_date
          ,pee.effective_end_date effective_end_date
    from   per_absence_attendances abs
          ,per_all_assignments_f asg
          ,pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
          ,pay_element_entry_values_f peev
          ,pay_input_values_f piv
    where  abs.absence_attendance_id = p_absence_attendance_id
    and    abs.person_id = asg.person_id
    and    asg.assignment_id = p_assignment_id
    and    nvl(abs.date_start,asg.effective_end_date) <=  asg.effective_end_date
    and    nvl(abs.date_end,asg.effective_start_date) >= asg.effective_start_date
    and    pet.element_type_id = p_element_type_id
    and    nvl(abs.date_start,pet.effective_end_date) <=  pet.effective_end_date
    and    nvl(abs.date_end,pet.effective_start_date) >= pet.effective_start_date
    and    pet.element_type_id = pel.element_type_id
    and    pel.element_link_id = pee.element_link_id
    and    pee.assignment_id = asg.assignment_id
    and    pee.creator_type = 'F'
    and    pet.element_type_id = piv.element_type_id
    and    nvl(abs.date_start,piv.effective_end_date) <=  piv.effective_end_date
    and    nvl(abs.date_end,piv.effective_start_date) >= piv.effective_start_date
    and    piv.name = 'CREATOR_ID'
    and    peev.element_entry_id = pee.element_entry_id
    and    peev.input_value_id=piv.input_value_id
    and    peev.screen_entry_value = abs.absence_attendance_id;

/*
         select pee.element_entry_id element_entry_id
	  ,pet.processing_type processing_type
          ,pee.effective_start_date effective_start_date
          ,pee.effective_end_date effective_end_date
    from   per_absence_attendances abs
          ,per_all_assignments_f asg
          ,pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
    where  abs.absence_attendance_id = p_absence_attendance_id
    and    abs.person_id = asg.person_id
    and    asg.assignment_id = p_assignment_id
    and    abs.date_start <=  asg.effective_end_date
    and    abs.date_end >= asg.effective_start_date
    and    pet.element_type_id = p_element_type_id
    and    abs.date_start >= pet.effective_start_date
    and    abs.date_end   <= pet.effective_end_date
    and    pet.element_type_id = pel.element_type_id
    and    pel.element_link_id = pee.element_link_id
    and    pee.assignment_id = asg.assignment_id
    and    pee.creator_id = abs.absence_attendance_id
    and    pee.creator_type = 'F';*/

  --
  -- Get details for the absence being procesed.
  --
  CURSOR csr_absence_details(p_absence_attendance_id NUMBER) IS
   SELECT abs.business_group_id
	 ,abt.name
	 ,abs.person_id
         ,abs.date_start
         ,abs.date_end
         ,abt.absence_category
   FROM   per_absence_attendances      abs
         ,per_absence_attendance_types abt
   WHERE  abs.absence_attendance_id      = p_absence_attendance_id
     AND  abt.absence_attendance_type_id = abs.absence_attendance_type_id;
  --
  CURSOR csr_entry_values(p_element_type_id NUMBER, p_iv1_name VARCHAR2, p_iv1_value VARCHAR2, p_effective_date DATE) IS
   SELECT iv.input_value_id input_value
         ,p_iv1_value       entry_value
   FROM   pay_input_values_f iv
   WHERE  iv.element_type_id = p_element_type_id
     AND  iv.name            = p_iv1_name
     AND  p_effective_date BETWEEN iv.effective_start_date AND iv.effective_end_date;


  CURSOR csr_legislation_code (p_business_group_id NUMBER) IS
   SELECT  legislation_code
   FROM    per_business_groups_perf
   WHERE   business_group_id = p_business_group_id;

  CURSOR csr_is_record_seeded (p_legislation_code VARCHAR2,
                               p_table_name    VARCHAR2,
			       p_exact VARCHAR2) IS
   SELECT pur.legislation_code, pur.business_group_id
   FROM pay_user_tables put
       ,pay_user_rows_f pur
   WHERE user_table_name = p_table_name
   AND nvl(put.legislation_code, p_legislation_code) = p_legislation_code
   AND put.user_table_id = pur.user_table_id
   and pur.row_low_range_or_name = p_exact ;

  l_abs_rec          csr_absence_details%ROWTYPE;
  l_is_record_seeded_rec csr_is_record_seeded%ROWTYPE;


  l_legislation_code     VARCHAR2(2);

  l_entry_values_rec csr_entry_values%ROWTYPE;
  l_element_link_id  NUMBER;
  l_date_start       DATE;
  l_date_end         DATE;
  l_element_entry_id NUMBER;
  l_element_type_id  NUMBER(15);
  l_plsql_block      VARCHAR2(2000); /* := 'BEGIN <PROC_NAME>(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14
							   ,:15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26
							   ,:27, :28, :29, :30, :31, :32, :33, :34); END;';*/


  l_iv1_name          VARCHAR2(30);
  l_iv1_value         VARCHAR2(240);	   --rravi
  l_iv2_name          VARCHAR2(30);
  l_iv2_value         VARCHAR2(240);	   --rravi
  l_iv3_name          VARCHAR2(30);
  l_iv3_value         VARCHAR2(240);	   --rravi
  l_iv4_name          VARCHAR2(30);
  l_iv4_value         VARCHAR2(240);	   --rravi
  l_iv5_name          VARCHAR2(30);
  l_iv5_value         VARCHAR2(240);	   --rravi
  l_iv6_name          VARCHAR2(30);
  l_iv6_value         VARCHAR2(240);	   --rravi
  l_iv7_name          VARCHAR2(30);
  l_iv7_value         VARCHAR2(240);	   --rravi
  l_iv8_name          VARCHAR2(30);
  l_iv8_value         VARCHAR2(30);
  l_iv9_name          VARCHAR2(30);
  l_iv9_value         VARCHAR2(30);
  l_iv10_name         VARCHAR2(30);
  l_iv10_value        VARCHAR2(30);
  l_iv11_name         VARCHAR2(30);
  l_iv11_value        VARCHAR2(30);
  l_iv12_name         VARCHAR2(30);
  l_iv12_value        VARCHAR2(30);
  l_iv13_name         VARCHAR2(30);
  l_iv13_value        VARCHAR2(30);
  l_iv14_name         VARCHAR2(30);
  l_iv14_value        VARCHAR2(30);
  l_iv15_name         VARCHAR2(30);
  l_iv15_value        VARCHAR2(30);

  l_return VARCHAR2(20);
  l_entry_package VARCHAR2(60);
  l_proc varchar2(100) := g_package||'.get_element_details ';
 BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Get absence information.
  --
  OPEN  csr_absence_details(p_absence_attendance_id);
  FETCH csr_absence_details INTO l_abs_rec;
  CLOSE csr_absence_details;
  --
  --
  -- Get absence to element mapping information.
  --

 l_element_type_id := get_element_for_category(p_absence_attendance_id);
 l_entry_package   := get_package_for_category(p_absence_attendance_id);

  hr_utility.set_location('l_element_type_id '|| l_element_type_id, 15);

  --
  l_date_start := l_abs_rec.date_start;

 -- Newly added 27th Feb 2006 - Category Checking Start
if (l_abs_rec.absence_category is null or l_entry_package is null) then
   return;
else

   --
    --
    --
    -- Call the external procedure to get the values to be set on the element entry.
    --

   OPEN csr_legislation_code (l_abs_rec.business_group_id);
   FETCH csr_legislation_code INTO l_legislation_code;
   CLOSE csr_legislation_code;

   OPEN csr_is_record_seeded(l_legislation_code, l_legislation_code || '_ABSENCE_TYPE_AND_DETAILS', l_abs_rec.name);
   FETCH csr_is_record_seeded into l_is_record_seeded_rec;
   close csr_is_record_seeded;

   IF l_is_record_seeded_rec.legislation_code is null and l_is_record_seeded_rec.business_group_id is null then
	   OPEN csr_is_record_seeded(l_legislation_code, l_legislation_code || '_ABSENCE_CATEGORY_AND_DETAILS', l_abs_rec.absence_category);
	   FETCH csr_is_record_seeded into l_is_record_seeded_rec;
	   close csr_is_record_seeded;
   END IF;


/*pgopal - Added one more parameter for p_original_entry_id*/
 IF l_is_record_seeded_rec.business_group_id IS NOT NULL THEN
    /* In case user table row is not seeded and is created by users then execute the procedure*/
   l_plsql_block := 'BEGIN <PROC_NAME>(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14
                                      ,:15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26
				      ,:27, :28, :29, :30, :31, :32, :33, :34, :36); END;';

    SELECT REPLACE(l_plsql_block, '<PROC_NAME>', l_entry_package) INTO l_plsql_block FROM dual;
    --
    EXECUTE IMMEDIATE l_plsql_block
    USING l_abs_rec.person_id
         ,p_absence_attendance_id
         ,l_element_type_id
         ,l_abs_rec.absence_category
	 ,OUT p_original_entry_id   --pgopal
         ,OUT l_iv1_name
         ,OUT l_iv1_value
         ,OUT l_iv2_name
         ,OUT l_iv2_value
         ,OUT l_iv3_name
         ,OUT l_iv3_value
         ,OUT l_iv4_name
         ,OUT l_iv4_value
         ,OUT l_iv5_name
         ,OUT l_iv5_value
         ,OUT l_iv6_name
         ,OUT l_iv6_value
         ,OUT l_iv7_name
         ,OUT l_iv7_value
         ,OUT l_iv8_name
         ,OUT l_iv8_value
         ,OUT l_iv9_name
         ,OUT l_iv9_value
         ,OUT l_iv10_name
         ,OUT l_iv10_value
         ,OUT l_iv11_name
         ,OUT l_iv11_value
         ,OUT l_iv12_name
         ,OUT l_iv12_value
         ,OUT l_iv13_name
         ,OUT l_iv13_value
         ,OUT l_iv14_name
         ,OUT l_iv14_value
         ,OUT l_iv15_name
         ,OUT l_iv15_value;

  ELSE

   l_plsql_block := 'BEGIN :l_return := <FUNC_NAME>(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13,
						 :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25,
						 :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36); END;';

    hr_utility.set_location(' b4 execute imm of function ', 25);

    SELECT REPLACE(l_plsql_block, '<FUNC_NAME>', l_entry_package) INTO l_plsql_block FROM dual;
    --
    EXECUTE IMMEDIATE l_plsql_block
    USING out l_return
         ,p_assignment_id
         ,l_abs_rec.person_id
         ,p_absence_attendance_id
         ,l_element_type_id
         ,l_abs_rec.absence_category
	 ,OUT p_original_entry_id --pgopal
         ,OUT l_iv1_name
         ,OUT l_iv1_value
         ,OUT l_iv2_name
         ,OUT l_iv2_value
         ,OUT l_iv3_name
         ,OUT l_iv3_value
         ,OUT l_iv4_name
         ,OUT l_iv4_value
         ,OUT l_iv5_name
         ,OUT l_iv5_value
         ,OUT l_iv6_name
         ,OUT l_iv6_value
         ,OUT l_iv7_name
         ,OUT l_iv7_value
         ,OUT l_iv8_name
         ,OUT l_iv8_value
         ,OUT l_iv9_name
         ,OUT l_iv9_value
         ,OUT l_iv10_name
         ,OUT l_iv10_value
         ,OUT l_iv11_name
         ,OUT l_iv11_value
         ,OUT l_iv12_name
         ,OUT l_iv12_value
         ,OUT l_iv13_name
         ,OUT l_iv13_value
         ,OUT l_iv14_name
         ,OUT l_iv14_value
         ,OUT l_iv15_name
         ,OUT l_iv15_value;

    hr_utility.set_location('After execute imm of function ', 25);

  END IF;

 END IF; -- Newly added - Category Checking - End
    --
  hr_utility.set_location('After execute imm', 30);
    --
    -- Translate input value name / value pairs returned from external procedure into format to be used to create element entry.
    --
	p_create_entry := nvl(l_return,'Y');

IF nvl(l_return,'Y') = 'Y' THEN
    IF l_iv1_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv1_name, l_iv1_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id1          := l_entry_values_rec.input_value;
    p_entry_value1             := l_entry_values_rec.entry_value;

    hr_utility.set_location(' p_entry_value1: ' || l_entry_values_rec.entry_value, 35);

    IF l_iv2_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv2_name, l_iv2_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id2          := l_entry_values_rec.input_value;
    p_entry_value2             := l_entry_values_rec.entry_value;

    hr_utility.set_location(' p_entry_value2: ' || l_entry_values_rec.entry_value, 35);

    IF l_iv3_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv3_name, l_iv3_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id3          := l_entry_values_rec.input_value;
    p_entry_value3             := l_entry_values_rec.entry_value;

    hr_utility.set_location(' p_entry_value3: ' || l_entry_values_rec.entry_value, 35);


    IF l_iv4_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv4_name, l_iv4_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id4          := l_entry_values_rec.input_value;
    p_entry_value4             := l_entry_values_rec.entry_value;

    hr_utility.set_location(' p_entry_value4: ' || l_entry_values_rec.entry_value, 35);

    IF l_iv5_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv5_name, l_iv5_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id5          := l_entry_values_rec.input_value;
    p_entry_value5             := l_entry_values_rec.entry_value;

    IF l_iv6_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv6_name, l_iv6_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id6          := l_entry_values_rec.input_value;
    p_entry_value6             := l_entry_values_rec.entry_value;

    IF l_iv7_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv7_name, l_iv7_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id7          := l_entry_values_rec.input_value;
    p_entry_value7             := l_entry_values_rec.entry_value;

    IF l_iv8_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv8_name, l_iv8_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id8          := l_entry_values_rec.input_value;
    p_entry_value8             := l_entry_values_rec.entry_value;

    IF l_iv9_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv9_name, l_iv9_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id9          := l_entry_values_rec.input_value;
    p_entry_value9             := l_entry_values_rec.entry_value;

    IF l_iv10_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv10_name, l_iv10_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id10          := l_entry_values_rec.input_value;
    p_entry_value10             := l_entry_values_rec.entry_value;

    IF l_iv11_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv11_name, l_iv11_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id11          := l_entry_values_rec.input_value;
    p_entry_value11             := l_entry_values_rec.entry_value;

    IF l_iv12_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv12_name, l_iv12_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id12          := l_entry_values_rec.input_value;
    p_entry_value12             := l_entry_values_rec.entry_value;

    IF l_iv13_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv13_name, l_iv13_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id13          := l_entry_values_rec.input_value;
    p_entry_value13             := l_entry_values_rec.entry_value;

    IF l_iv14_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv14_name, l_iv14_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;

    p_input_value_id14          := l_entry_values_rec.input_value;
    p_entry_value14             := l_entry_values_rec.entry_value;

    IF l_iv15_name IS NOT NULL THEN
	    OPEN  csr_entry_values(l_element_type_id, l_iv15_name, l_iv15_value, l_date_start);
	    FETCH csr_entry_values INTO l_entry_values_rec;
	    CLOSE csr_entry_values;
    END IF;


    p_element_type_id         := l_element_type_id;
    p_input_value_id15          := l_entry_values_rec.input_value;
    p_entry_value15             := l_entry_values_rec.entry_value;

END IF;

end get_element_details;


 PROCEDURE create_absence (p_absence_attendance_id NUMBER
                             ,p_effective_date DATE
			     ,p_date_start DATE
			     ,p_date_end   DATE) IS
  --
  --
  -- Local Cursors.
  --
  --
  -- Find all assignments for the person as of a given date.
  -- Bug no 5020916. Order by clause included in the cursor
  CURSOR csr_assignments(p_person_id NUMBER, p_effective_date DATE) IS
   SELECT asg.assignment_id, asg.effective_start_date, asg.effective_end_date
   FROM   per_all_assignments_f asg,
          per_absence_attendances paa
   WHERE  paa.absence_attendance_id = p_absence_attendance_id
     and  asg.person_id = paa.person_id
     AND  nvl(paa.date_start,asg.effective_end_date) <=  asg.effective_end_date
     AND  nvl(paa.date_end,asg.effective_start_date) >= asg.effective_start_date
   ORDER BY asg.assignment_id, asg.effective_start_date, asg.effective_end_date;
  --
  -- Find all assignments for the person as of a given date.
  --
  --
  CURSOR csr_processing_type (p_element_type_id NUMBER) IS
   SELECT processing_type
   FROM   pay_element_types_f
   where  element_type_id= p_element_type_id
   AND    p_effective_date between effective_start_date and effective_end_date;

  -- Local Variables.
  --
  l_element_link_id  NUMBER;
  l_date_start       DATE;
  l_date_end         DATE;
  l_element_entry_id NUMBER;
  l_input_value_id   NUMBER(15);
  l_input_value      VARCHAR2(100);
  l_element_type_id  NUMBER(15);
  l_proc varchar2(100) := g_package||'.create_absence ';

  l_iv2_id          NUMBER(15);
  l_iv2_value       VARCHAR2(240);   --rravi
  l_iv3_id          NUMBER(15);
  l_iv3_value       VARCHAR2(30);
  l_iv4_id          NUMBER(15);
  l_iv4_value       VARCHAR2(30);
  l_iv5_id          NUMBER(15);
  l_iv5_value       VARCHAR2(30);
  l_iv6_id          NUMBER(15);
  l_iv6_value       VARCHAR2(30);
  l_iv7_id          NUMBER(15);
  l_iv7_value       VARCHAR2(30);
  l_iv8_id          NUMBER(15);
  l_iv8_value       VARCHAR2(30);
  l_iv9_id          NUMBER(15);
  l_iv9_value       VARCHAR2(30);
  l_iv10_id         NUMBER(15);
  l_iv10_value      VARCHAR2(30);
  l_iv11_id         NUMBER(15);
  l_iv11_value      VARCHAR2(30);
  l_iv12_id         NUMBER(15);
  l_iv12_value      VARCHAR2(30);
  l_iv13_id         NUMBER(15);
  l_iv13_value      VARCHAR2(30);
  l_iv14_id         NUMBER(15);
  l_iv14_value      VARCHAR2(30);
  l_iv15_id         NUMBER(15);
  l_iv15_value      VARCHAR2(30);
  l_processing_type VARCHAR2(30);
  l_create_entry    VARCHAR2(20);
  l_original_entry_id NUMBER ; --pgopal
  -- Bug no 5020916. Local variable declared to keep assignment id
  l_old_assignment  NUMBER(15);
BEGIN
  --
  -- Added for GSI Bug 5472781
  ---pgopal -Included 'NO','SE','PL' in the legislation installation check.
   IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'NO') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'SE') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'PL') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
--hr_utility.trace_on(null,'GOV_ABS');
  -- Bug no 5020916. Initialize local variable l_old_assignment as 0
  l_old_assignment := 0;
  --
  --
  -- Loop through all assignments for the person.
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  FOR l_asg_rec IN csr_assignments(p_absence_attendance_id, p_date_start) LOOP
  -- Bug no 5020916. Restricting the for loop to process one time for each assignment.
  IF l_old_assignment <> l_asg_rec.assignment_id THEN
     l_old_assignment := l_asg_rec.assignment_id;
   --
   --
  hr_utility.set_location('in for loop' , 20);
hr_utility.set_location('asg details : '||l_asg_rec.assignment_id||l_asg_rec.effective_start_date||l_asg_rec.effective_end_date , 20);
	get_element_details(p_absence_attendance_id, l_asg_rec.assignment_id, l_element_type_id , l_create_entry
			     ,l_original_entry_id --pgopal
			    ,l_input_value_id, l_input_value
			    ,l_iv2_id, l_iv2_value
			    ,l_iv3_id, l_iv3_value
			    ,l_iv4_id, l_iv4_value
			    ,l_iv5_id, l_iv5_value
			    ,l_iv6_id, l_iv6_value
			    ,l_iv7_id, l_iv7_value
			    ,l_iv8_id, l_iv8_value
			    ,l_iv9_id, l_iv9_value
			    ,l_iv10_id, l_iv10_value
			    ,l_iv11_id, l_iv11_value
			    ,l_iv12_id, l_iv12_value
			    ,l_iv13_id, l_iv13_value
			    ,l_iv14_id, l_iv14_value
			    ,l_iv15_id, l_iv15_value );

  hr_utility.set_location('after get_element_details' , 20);
    --
    --
  hr_utility.set_location('l_asg_rec.assignment_id: ' || l_asg_rec.assignment_id , 25);
  hr_utility.set_location('l_element_type_id: ' || l_element_type_id , 25);
  hr_utility.set_location('p_date_start: ' || p_date_start , 25);

-- Bug no 5020916. Commenting assignment date check while attaching absences to assignments.
--	IF p_date_start > l_asg_rec.effective_start_date THEN
		l_date_start := p_date_start;
--	ELSE
--		l_date_start := l_asg_rec.effective_start_date;
--	END IF;

--	IF p_date_end < l_asg_rec.effective_end_date THEN
		l_date_end := p_date_end;
--	ELSE
--		l_date_end := l_asg_rec.effective_end_date;
--	END IF;

  l_element_link_id := hr_entry_api.get_link(l_asg_rec.assignment_id, l_element_type_id, l_date_start);

  hr_utility.set_location('l_element_link_id: ' || l_element_link_id , 25);

    -- Create the element entry.
    --
    if l_element_link_id is not null then


	OPEN csr_processing_type (l_element_type_id);
	FETCH csr_processing_type into l_processing_type;
	CLOSE csr_processing_type;

  hr_utility.set_location('l_input_value_id ' || l_input_value_id , 25);
  hr_utility.set_location('l_input_value: ' || l_input_value , 25);
  hr_utility.set_location('l_iv2_id: ' || l_iv2_id , 25);
  hr_utility.set_location('l_iv2_value: ' || l_iv2_value , 25);


      if (l_processing_type = 'N'
          and l_date_start is not null
          and l_date_end is not null)
      or (l_processing_type = 'R'
          and l_date_start is not null)
      then


    IF l_create_entry = 'Y' THEN
    hr_entry_api.insert_element_entry
     (p_effective_start_date => l_date_start
     ,p_effective_end_date   => l_date_end
     ,p_element_entry_id     => l_element_entry_id
     ,p_assignment_id        => l_asg_rec.assignment_id
     ,p_element_link_id      => l_element_link_id
     ,p_creator_type         => 'F' -- 'A' for absence
     ,p_entry_type           => 'E'
     ,p_creator_id           => null--p_absence_attendance_id
     ,p_original_entry_id    => l_original_entry_id  --pgopal
     ,p_input_value_id1      => l_input_value_id
     ,p_entry_value1         => l_input_value
     ,p_input_value_id2      => l_iv2_id
     ,p_entry_value2         => l_iv2_value
     ,p_input_value_id3      => l_iv3_id
     ,p_entry_value3         => l_iv3_value
     ,p_input_value_id4      => l_iv4_id
     ,p_entry_value4         => l_iv4_value
     ,p_input_value_id5      => l_iv5_id
     ,p_entry_value5         => l_iv5_value
     ,p_input_value_id6      => l_iv6_id
     ,p_entry_value6         => l_iv6_value
     ,p_input_value_id7      => l_iv7_id
     ,p_entry_value7         => l_iv7_value
     ,p_input_value_id8      => l_iv8_id
     ,p_entry_value8         => l_iv8_value
     ,p_input_value_id9      => l_iv9_id
     ,p_entry_value9         => l_iv9_value
     ,p_input_value_id10      => l_iv10_id
     ,p_entry_value10         => l_iv10_value
     ,p_input_value_id11      => l_iv11_id
     ,p_entry_value11         => l_iv11_value
     ,p_input_value_id12      => l_iv12_id
     ,p_entry_value12         => l_iv12_value
     ,p_input_value_id13      => l_iv13_id
     ,p_entry_value13         => l_iv13_value
     ,p_input_value_id14      => l_iv14_id
     ,p_entry_value14         => l_iv14_value
     ,p_input_value_id15      => l_iv15_id
     ,p_entry_value15         => l_iv15_value);
    --
  hr_utility.set_location('after element_entry creation ' ||l_element_entry_id  , 80);
   END IF;
   END IF;
    --
    -- End date the element entry in line with the absence.
    --


    IF p_date_end IS NOT NULL AND l_processing_type = 'R' THEN
     hr_entry_api.delete_element_entry
      (p_dt_delete_mode       => 'DELETE'
      ,p_session_date         => p_date_end
      ,p_element_entry_id     => l_element_entry_id);
    END IF;
   END IF;
END IF;
  END LOOP;
  END IF;
END create_absence;
 --

function get_element_for_category (p_absence_attendance_id NUMBER) return NUMBER As

  CURSOR csr_absence_details(p_absence_attendance_id NUMBER) IS
   SELECT abs.business_group_id
         ,abt.name
	 ,abs.person_id
         ,abs.date_start
         ,abs.date_end
         ,abt.absence_category
   FROM   per_absence_attendances      abs
         ,per_absence_attendance_types abt
   WHERE  abs.absence_attendance_id      = p_absence_attendance_id
     AND  abt.absence_attendance_type_id = abs.absence_attendance_type_id;

  CURSOR csr_legislation_code (p_business_group_id NUMBER) IS
   SELECT  legislation_code
   FROM    per_business_groups_perf
   WHERE   business_group_id = p_business_group_id;

  l_abs_rec          csr_absence_details%ROWTYPE;

 CURSOR csr_element_details (p_element_name VARCHAR2,
			     p_business_group_id NUMBER,
			     p_legislation_code VARCHAR2) IS
  SELECT element_type_id
  FROM   pay_element_types_f pet
  WHERE  pet.element_name = p_element_name
  AND    nvl( pet.business_group_id, p_business_group_id)  = p_business_group_id
  AND    nvl( pet.legislation_code, p_legislation_code) = p_legislation_code;

   CURSOR csr_get_session_eff_date IS
   SELECT effective_date
     FROM fnd_sessions
    WHERE session_id = userenv('sessionid');

  l_element_type_id	pay_element_types_f.element_type_id%TYPE;
  l_element_name	pay_element_types_f.element_name%TYPE;
  l_proc                 varchar2(72) := g_package||'get_element_for_category';
  l_legislation_code     VARCHAR2(2);
  l_dummy_effective_date DATE;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Get absence information.
  --
  OPEN  csr_absence_details(p_absence_attendance_id);
  FETCH csr_absence_details INTO l_abs_rec;
  CLOSE csr_absence_details;

  --hruserdt.set_g_effective_date(sysdate);
  OPEN csr_legislation_code (l_abs_rec.business_group_id);
  FETCH csr_legislation_code INTO l_legislation_code;
  CLOSE csr_legislation_code;

  l_dummy_effective_date := NULL;
  OPEN csr_get_session_eff_date ;
  FETCH csr_get_session_eff_date INTO l_dummy_effective_date;
  CLOSE csr_get_session_eff_date;
  IF l_dummy_effective_date is NULL THEN
    hruserdt.set_g_effective_date(sysdate);
  END IF;


  BEGIN

  l_element_name := hruserdt.GET_TABLE_VALUE (l_abs_rec.business_group_id, 					      								l_legislation_code ||'_ABSENCE_TYPE_AND_DETAILS',
						'ELEMENT',
						l_abs_rec.name);

  hr_utility.set_location('l_element_name: '|| l_element_name, 10);
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
  END;

  IF l_element_name IS NULL THEN

	  BEGIN
	  l_element_name := hruserdt.GET_TABLE_VALUE (l_abs_rec.business_group_id, 					      							l_legislation_code ||'_ABSENCE_CATEGORY_AND_DETAILS',
							'ELEMENT',
							l_abs_rec.absence_category);
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	  END;

  END IF;

  OPEN csr_element_details (l_element_name, l_abs_rec.business_group_id, l_legislation_code );
  FETCH csr_element_details INTO l_element_type_id;
  CLOSE csr_element_details;

RETURN l_element_type_id;

END get_element_for_category;


function get_package_for_category (p_absence_attendance_id NUMBER) return varchar2 As

  CURSOR csr_absence_details(p_absence_attendance_id NUMBER) IS
   SELECT abs.business_group_id
         ,abt.name
	 ,abs.person_id
         ,abs.date_start
         ,abs.date_end
         ,abt.absence_category
   FROM   per_absence_attendances      abs
         ,per_absence_attendance_types abt
   WHERE  abs.absence_attendance_id      = p_absence_attendance_id
     AND  abt.absence_attendance_type_id = abs.absence_attendance_type_id;

  CURSOR csr_legislation_code (p_business_group_id NUMBER) IS
   SELECT  legislation_code
   FROM    per_business_groups_perf
   WHERE   business_group_id = p_business_group_id;

  l_legislation_code     VARCHAR2(2);

  l_abs_rec          csr_absence_details%ROWTYPE;


  l_package_name	 varchar2(60);
  l_proc                 varchar2(72) := g_package||'get_package_for_category';


begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Get absence information.
  --
  OPEN  csr_absence_details(p_absence_attendance_id);
  FETCH csr_absence_details INTO l_abs_rec;
  CLOSE csr_absence_details;

--  hruserdt.set_g_effective_date(sysdate);

  OPEN csr_legislation_code (l_abs_rec.business_group_id);
  FETCH csr_legislation_code INTO l_legislation_code;
  CLOSE csr_legislation_code;

  BEGIN
  l_package_name := hruserdt.GET_TABLE_VALUE (l_abs_rec.business_group_id, 					      								l_legislation_code|| '_ABSENCE_TYPE_AND_DETAILS',
						'ELEMENT_ENTRY_LOGIC',
						l_abs_rec.name);
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
  END;

  IF l_package_name IS NULL THEN
	  BEGIN
	  l_package_name := hruserdt.GET_TABLE_VALUE (l_abs_rec.business_group_id, 					      							l_legislation_code|| '_ABSENCE_CATEGORY_AND_DETAILS',
							'ELEMENT_ENTRY_LOGIC',
							l_abs_rec.absence_category);
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	  END;
  END IF;

RETURN l_package_name;

END get_package_for_category;

procedure get_absence_element
  (p_absence_attendance_id in  number
  ,p_assignment_id         in number
  ,p_effective_date        in date
  ,p_processing_type       out nocopy varchar2
  ,p_element_entry_id      out nocopy number
  ,p_effective_start_date  out nocopy date
  ,p_effective_end_date    out nocopy date) is

  cursor c_get_absence_element(p_element_type_id NUMBER) is
  select pee.element_entry_id element_entry_id
	  ,pet.processing_type processing_type
          ,pee.effective_start_date effective_start_date
          ,pee.effective_end_date effective_end_date
    from   per_absence_attendances abs
          ,per_all_assignments_f asg
          ,pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
          ,pay_element_entry_values_f peev
          ,pay_input_values_f piv
    where  abs.absence_attendance_id = p_absence_attendance_id
    and    abs.person_id = asg.person_id
    and    asg.assignment_id = p_assignment_id
    and    nvl(abs.date_start,asg.effective_end_date) <=  asg.effective_end_date
    and    nvl(abs.date_end,asg.effective_start_date) >= asg.effective_start_date
    and    pet.element_type_id = p_element_type_id
    and    p_effective_date between pet.effective_start_date and pet.effective_end_date
    and    pet.element_type_id = pel.element_type_id
    and    pel.element_link_id = pee.element_link_id
    and    pee.assignment_id = asg.assignment_id
    and    pee.creator_type = 'F'
    and    pet.element_type_id = piv.element_type_id
    and    p_effective_date between piv.effective_start_date and piv.effective_end_date
    and    piv.name = 'CREATOR_ID'
    and    peev.element_entry_id = pee.element_entry_id
    and    peev.input_value_id=piv.input_value_id
    and    peev.screen_entry_value = to_char(abs.absence_attendance_id);  --8823797


/*    select pee.element_entry_id
	  ,pet.processing_type
          ,pee.effective_start_date
          ,pee.effective_end_date
    from   per_absence_attendances abs
          ,per_all_assignments_f asg
          ,pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
    where  abs.absence_attendance_id = p_absence_attendance_id
    and    abs.person_id = asg.person_id
    and    asg.assignment_id = p_assignment_id
    and    nvl(abs.date_start,asg.effective_end_date) <=  asg.effective_end_date
    and    nvl(abs.date_end,asg.effective_start_date) >= asg.effective_start_date
    and    pet.element_type_id = p_element_type_id
    and    p_effective_date between pet.effective_start_date and pet.effective_end_date
    and    pet.element_type_id = pel.element_type_id
    and    pel.element_link_id = pee.element_link_id
    and    pee.assignment_id = asg.assignment_id
    and    pee.creator_id = abs.absence_attendance_id
    and    pee.creator_type = 'F';*/


  l_proc                 varchar2(72) := g_package||'get_absence_element';
  l_element_type_id NUMBER(15);

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_element_type_id := get_element_for_category (p_absence_attendance_id);

  hr_utility.set_location('l_element_type_id:'|| l_element_type_id, 10);

  open  c_get_absence_element(l_element_type_id);
  fetch c_get_absence_element into p_element_entry_id,
				   p_processing_type,
                                   p_effective_start_date,
                                   p_effective_end_date;
  close c_get_absence_element;


  hr_utility.set_location('Leaving:'|| l_proc, 20);
exception
  when others then
     p_element_entry_id      := null;
     p_effective_start_date  := null;
     p_effective_end_date    := null;

end get_absence_element;

procedure delete_absence_element
  (p_dt_delete_mode            in  varchar2
  ,p_session_date              in  date
  ,p_element_entry_id          in  number
  ) is


  l_proc            varchar2(72) := g_package||'delete_absence_element';
  l_input_value_id  number;
  l_entry_value     number;

begin


  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_utility.set_location('p_session_date :'|| to_char(p_session_date), 20);
  hr_utility.set_location('p_element_entry_id :'|| p_element_entry_id, 30);
  hr_utility.set_location('p_dt_delete_mode :'|| p_dt_delete_mode, 30);

  hr_entry_api.delete_element_entry
    (p_dt_delete_mode       => p_dt_delete_mode
    ,p_session_date         => p_session_date
    ,p_element_entry_id     => p_element_entry_id);


  hr_utility.set_location('Leaving:'|| l_proc, 20);

end delete_absence_element;

procedure update_absence_element
  (p_dt_update_mode            in  varchar2
  ,p_assignment_id             in  number
  ,p_session_date              in  date
  ,p_element_entry_id          in  number
  ,p_absence_attendance_id     in  number
  ) is


  l_proc            varchar2(72) := g_package||'update_absence_element';
  l_element_type_id number;
  l_input_value_id  number;
  l_entry_value     VARCHAR2(30);
  l_iv2_id          NUMBER(15);
  l_iv2_value       VARCHAR2(30);
  l_iv3_id          NUMBER(15);
  l_iv3_value       VARCHAR2(30);
  l_iv4_id          NUMBER(15);
  l_iv4_value       VARCHAR2(30);
  l_iv5_id          NUMBER(15);
  l_iv5_value       VARCHAR2(30);
  l_iv6_id          NUMBER(15);
  l_iv6_value       VARCHAR2(30);
  l_iv7_id          NUMBER(15);
  l_iv7_value       VARCHAR2(30);
  l_iv8_id          NUMBER(15);
  l_iv8_value       VARCHAR2(30);
  l_iv9_id          NUMBER(15);
  l_iv9_value       VARCHAR2(30);
  l_iv10_id         NUMBER(15);
  l_iv10_value      VARCHAR2(30);
  l_iv11_id         NUMBER(15);
  l_iv11_value      VARCHAR2(30);
  l_iv12_id         NUMBER(15);
  l_iv12_value      VARCHAR2(30);
  l_iv13_id         NUMBER(15);
  l_iv13_value      VARCHAR2(30);
  l_iv14_id         NUMBER(15);
  l_iv14_value      VARCHAR2(30);
  l_iv15_id         NUMBER(15);
  l_iv15_value      VARCHAR2(30);
  l_create_entry    VARCHAR2(20);
 l_original_entry_id NUMBER ; --pgopal
begin
--hr_utility.trace_on(null,'GOV_ABS');

  hr_utility.set_location('Entering:'|| l_proc, 10);

	get_element_details(p_absence_attendance_id, p_assignment_id,
                            l_element_type_id , l_create_entry
			    ,l_original_entry_id --pgopal
                            ,l_input_value_id, l_entry_value
			    ,l_iv2_id, l_iv2_value
			    ,l_iv3_id, l_iv3_value
			    ,l_iv4_id, l_iv4_value
			    ,l_iv5_id, l_iv5_value
			    ,l_iv6_id, l_iv6_value
			    ,l_iv7_id, l_iv7_value
			    ,l_iv8_id, l_iv8_value
			    ,l_iv9_id, l_iv9_value
			    ,l_iv10_id, l_iv10_value
			    ,l_iv11_id, l_iv11_value
			    ,l_iv12_id, l_iv12_value
			    ,l_iv13_id, l_iv13_value
			    ,l_iv14_id, l_iv14_value
			    ,l_iv15_id, l_iv15_value );


 hr_utility.set_location('Updating element', 20);
 hr_utility.set_location('Updating element create entry : '||l_create_entry, 20);

  -- We know the assignment is eligible for this element because
  -- we have the element_link_id. The entries API will handle
  -- all other validation (e.g., non-recurring entries must
  -- have a valid payroll).

  IF l_create_entry = 'Y' THEN

 hr_utility.set_location('Input value id 1 : '||l_input_value_id, 20);
 hr_utility.set_location('Input value 1 : '||l_entry_value, 20);

 hr_utility.set_location('Input value id 2 : '||l_iv2_id, 20);
 hr_utility.set_location('Input value 2 : '||l_iv2_value, 20);

 hr_utility.set_location('Input value id 3 : '||l_iv3_id, 20);
 hr_utility.set_location('Input value 3 : '||l_iv3_value, 20);

 hr_utility.set_location('Input value id 4 : '||l_iv4_id, 20);
 hr_utility.set_location('Input value 4 : '||l_iv4_value, 20);

 hr_utility.set_location('Input value id 5 : '||l_iv5_id, 20);
 hr_utility.set_location('Input value 5 : '||l_iv5_value, 20);

 hr_utility.set_location('Input value id 8 : '||l_iv8_id, 20);
 hr_utility.set_location('Input value 8 : '||l_iv8_value, 20);

 hr_utility.set_location('Dt update mode : '||p_dt_update_mode, 20);
 hr_utility.set_location('p_session_date : '||p_session_date, 20);

  hr_entry_api.update_element_entry
    (p_dt_update_mode       => p_dt_update_mode
    ,p_session_date         => p_session_date
    ,p_element_entry_id     => p_element_entry_id
    ,p_creator_type         => 'F'
    ,p_creator_id           => p_absence_attendance_id
    ,p_original_entry_id     => l_original_entry_id --pgopal
    ,p_input_value_id1      => l_input_value_id
    ,p_entry_value1         => l_entry_value
     ,p_input_value_id2      => l_iv2_id
     ,p_entry_value2         => l_iv2_value
     ,p_input_value_id3      => l_iv3_id
     ,p_entry_value3         => l_iv3_value
     ,p_input_value_id4      => l_iv4_id
     ,p_entry_value4         => l_iv4_value
     ,p_input_value_id5      => l_iv5_id
     ,p_entry_value5         => l_iv5_value
     ,p_input_value_id6      => l_iv6_id
     ,p_entry_value6         => l_iv6_value
     ,p_input_value_id7      => l_iv7_id
     ,p_entry_value7         => l_iv7_value
     ,p_input_value_id8      => l_iv8_id
     ,p_entry_value8         => l_iv8_value
     ,p_input_value_id9      => l_iv9_id
     ,p_entry_value9         => l_iv9_value
     ,p_input_value_id10      => l_iv10_id
     ,p_entry_value10         => l_iv10_value
     ,p_input_value_id11      => l_iv11_id
     ,p_entry_value11         => l_iv11_value
     ,p_input_value_id12      => l_iv12_id
     ,p_entry_value12         => l_iv12_value
     ,p_input_value_id13      => l_iv13_id
     ,p_entry_value13         => l_iv13_value
     ,p_input_value_id14      => l_iv14_id
     ,p_entry_value14         => l_iv14_value
     ,p_input_value_id15      => l_iv15_id
     ,p_entry_value15         => l_iv15_value);
   END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 30);

end update_absence_element;

procedure insert_absence_element
  (p_date_start                in  date
  ,p_assignment_id             in  number
  ,p_absence_attendance_id     in  number
  ,p_element_entry_id          out nocopy number
  ) is


  l_proc            varchar2(72) := g_package||'insert_absence_element';
  l_date_start      date := p_date_start;
  l_date_end        date;
  l_element_type_id number;
  l_element_link_id number;
  l_input_value_id  number;
  l_entry_value     VARCHAR2(30);
  l_iv2_id          NUMBER(15);
  l_iv2_value       VARCHAR2(30);
  l_iv3_id          NUMBER(15);
  l_iv3_value       VARCHAR2(30);
  l_iv4_id          NUMBER(15);
  l_iv4_value       VARCHAR2(30);
  l_iv5_id          NUMBER(15);
  l_iv5_value       VARCHAR2(30);
  l_iv6_id          NUMBER(15);
  l_iv6_value       VARCHAR2(30);
  l_iv7_id          NUMBER(15);
  l_iv7_value       VARCHAR2(30);
  l_iv8_id          NUMBER(15);
  l_iv8_value       VARCHAR2(30);
  l_iv9_id          NUMBER(15);
  l_iv9_value       VARCHAR2(30);
  l_iv10_id         NUMBER(15);
  l_iv10_value      VARCHAR2(30);
  l_iv11_id         NUMBER(15);
  l_iv11_value      VARCHAR2(30);
  l_iv12_id         NUMBER(15);
  l_iv12_value      VARCHAR2(30);
  l_iv13_id         NUMBER(15);
  l_iv13_value      VARCHAR2(30);
  l_iv14_id         NUMBER(15);
  l_iv14_value      VARCHAR2(30);
  l_iv15_id         NUMBER(15);
  l_iv15_value      VARCHAR2(30);
  l_create_entry    VARCHAR2(20);
  l_original_entry_id NUMBER ; --pgopal
begin


  hr_utility.set_location('Entering:'|| l_proc, 10);

	get_element_details(p_absence_attendance_id, p_assignment_id,
                           l_element_type_id , l_create_entry
			   ,l_original_entry_id --pgopal
                           ,l_input_value_id, l_entry_value
			    ,l_iv2_id, l_iv2_value
			    ,l_iv3_id, l_iv3_value
			    ,l_iv4_id, l_iv4_value
			    ,l_iv5_id, l_iv5_value
			    ,l_iv6_id, l_iv6_value
			    ,l_iv7_id, l_iv7_value
			    ,l_iv8_id, l_iv8_value
			    ,l_iv9_id, l_iv9_value
			    ,l_iv10_id, l_iv10_value
			    ,l_iv11_id, l_iv11_value
			    ,l_iv12_id, l_iv12_value
			    ,l_iv13_id, l_iv13_value
			    ,l_iv14_id, l_iv14_value
			    ,l_iv15_id, l_iv15_value );


 hr_utility.set_location('l_element_type_id: '||l_element_type_id, 30);
 hr_utility.set_location('Checking element link', 20);

 IF l_create_entry = 'Y' THEN
	  l_element_link_id := hr_entry_api.get_link
	    (p_assignment_id          => p_assignment_id
	    ,p_element_type_id        => l_element_type_id
	    ,p_session_date           => p_date_start);

  If l_element_link_id is null then
    -- Assignment is not eligible for the element type
    -- associated with this absence.
    fnd_message.set_name ('PAY','HR_7448_ELE_PER_NOT_ELIGIBLE');
    hr_utility.raise_error;
  end if;


 hr_utility.set_location('Inserting element', 30);

  -- We know the assignment is eligible for this element because
  -- we have the element_link_id. The entries API will handle
  -- all other validation (e.g., non-recurring entries must
  -- have a valid payroll).


  hr_entry_api.insert_element_entry
    (p_effective_start_date => l_date_start
    ,p_effective_end_date   => l_date_end
    ,p_element_entry_id     => p_element_entry_id
    ,p_assignment_id        => p_assignment_id
    ,p_element_link_id      => l_element_link_id
    ,p_creator_type         => 'F'
    ,p_entry_type           => 'E'
    ,p_creator_id           => null--p_absence_attendance_id
    ,p_original_entry_id    => l_original_entry_id --pgopal
    ,p_input_value_id1      => l_input_value_id
    ,p_entry_value1         => l_entry_value
     ,p_input_value_id2      => l_iv2_id
     ,p_entry_value2         => l_iv2_value
     ,p_input_value_id3      => l_iv3_id
     ,p_entry_value3         => l_iv3_value
     ,p_input_value_id4      => l_iv4_id
     ,p_entry_value4         => l_iv4_value
     ,p_input_value_id5      => l_iv5_id
     ,p_entry_value5         => l_iv5_value
     ,p_input_value_id6      => l_iv6_id
     ,p_entry_value6         => l_iv6_value
     ,p_input_value_id7      => l_iv7_id
     ,p_entry_value7         => l_iv7_value
     ,p_input_value_id8      => l_iv8_id
     ,p_entry_value8         => l_iv8_value
     ,p_input_value_id9      => l_iv9_id
     ,p_entry_value9         => l_iv9_value
     ,p_input_value_id10      => l_iv10_id
     ,p_entry_value10         => l_iv10_value
     ,p_input_value_id11      => l_iv11_id
     ,p_entry_value11         => l_iv11_value
     ,p_input_value_id12      => l_iv12_id
     ,p_entry_value12         => l_iv12_value
     ,p_input_value_id13      => l_iv13_id
     ,p_entry_value13         => l_iv13_value
     ,p_input_value_id14      => l_iv14_id
     ,p_entry_value14         => l_iv14_value
     ,p_input_value_id15      => l_iv15_id
     ,p_entry_value15         => l_iv15_value);
   END IF;

  hr_utility.set_location('EE ID: '|| to_char(p_element_entry_id), 40);
  hr_utility.set_location('Leaving:'|| l_proc, 50);

exception
 when others then
  p_element_entry_id    := null ;
  raise;

end insert_absence_element;

PROCEDURE update_absence(p_absence_attendance_id NUMBER,
			     p_date_start DATE,
			     p_date_end	DATE,
			     P_EFFECTIVE_DATE DATE) IS
  --
  --
  -- Local Cursors.
  --
  -- Find all assignments for the person as of a given date.
  -- Bug no 5020916. Order by clause included in the cursor
  CURSOR csr_assignments(p_person_id NUMBER, p_effective_date DATE) IS
   SELECT asg.assignment_id, asg.effective_start_date, asg.effective_end_date
   FROM   per_all_assignments_f asg,
          per_absence_attendances paa
   WHERE  paa.absence_attendance_id = p_absence_attendance_id
     and  asg.person_id = paa.person_id
     and  paa.person_id = p_person_id
     AND  nvl(paa.date_start,asg.effective_end_date) <=  asg.effective_end_date
     AND  nvl(paa.date_end,asg.effective_start_date) >= asg.effective_start_date
   ORDER BY asg.assignment_id, asg.effective_start_date, asg.effective_end_date;
  --
  -- Find all assignments for the person as of a given date.
  --
  CURSOR csr_entry_values(p_element_type_id NUMBER, p_iv1_name VARCHAR2, p_iv1_value VARCHAR2, p_effective_date DATE) IS
   SELECT iv.input_value_id input_value1
         ,p_iv1_value       entry_value1
   FROM   pay_input_values_f iv
   WHERE  iv.element_type_id = p_element_type_id
     AND  iv.name            = p_iv1_name
     AND  p_effective_date BETWEEN iv.effective_start_date AND iv.effective_end_date;

  CURSOR csr_processing_type (p_element_type_id NUMBER) IS
   SELECT processing_type
   FROM   pay_element_types_f
   where  element_type_id= p_element_type_id
   AND    p_effective_date between effective_start_date and effective_end_date;


 CURSOR csr_invalid_entries (p_element_type_id NUMBER) IS
  SELECT pee.element_entry_id, pee.effective_start_date
  FROM pay_element_entries_f pee,
       per_all_assignments_f asg1,
       per_absence_attendances paa1
  where pee.element_type_id = p_element_type_id
        AND  paa1.absence_attendance_id = p_absence_attendance_id
        AND  asg1.person_id = paa1.person_id
        AND  asg1.assignment_id not in (
            SELECT asg.assignment_id
            FROM   per_all_assignments_f asg,
                   per_absence_attendances paa
            WHERE  paa.absence_attendance_id = p_absence_attendance_id
            AND  asg.person_id = paa.person_id
            AND  nvl(paa.date_start,asg.effective_end_date) <=  asg.effective_end_date
            AND  nvl(paa.date_end,asg.effective_start_date) >= asg.effective_start_date);
  --
  --
  -- Local Variables.
  --

  cursor c_get_absence_details is
         select abs.person_id,
         abs.absence_attendance_type_id
         from   per_absence_attendances abs
         where  abs.absence_attendance_id = p_absence_attendance_id;

  l_element_type_id pay_element_types_f.element_type_id%TYPE;
  l_processing_type VARCHAR2(30);
  l_person_id        NUMBER(15);
  l_assignment_id    csr_assignments%rowtype;
  l_effective_start_date DATE;
  l_effective_end_date DATE;
  l_absence_attendance_type_id NUMBER(15);
  l_element_link_id  NUMBER;
  l_date_start       DATE;
  l_date_end         DATE;
  l_element_entry_id NUMBER;
  l_iv1_name         VARCHAR2(30);
  l_iv1_value        VARCHAR2(30);
  l_del_element_entry_warning BOOLEAN;
  l_proc                varchar2(72) := g_package||'update_person_absence';
  -- Bug no 5020916. Local variable declared to keep assignment id
  l_old_assignment  NUMBER(15);
 BEGIN
   --
   -- Added for GSI Bug 5472781
---pgopal -Included 'NO','SE','PL' in the legislation installation check.
   IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'NO') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'SE') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'PL') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
      --
  -- Bug no 5020916. Initialize local variable l_old_assignment as 0
  l_old_assignment := 0;

/* Start of Absence Element Entry Section */
  --
  -- Update or insert the absence element element. First we
  -- check if the absence type is linked to an element type.
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  /* Level 1 */
-- commented till we decide where we are going to store element type and category link.
/*  if linked_to_element
     (p_absence_attendance_id => p_absence_attendance_id)
  then*/

    --
    -- Get the person_id, assignment_id, assignment_type_id
    -- and processing type for use later
    --

    open  c_get_absence_details;
    fetch c_get_absence_details into l_person_id,
                                     l_absence_attendance_type_id;
    close c_get_absence_details;

  hr_utility.set_location('After c_get_absence_details ', 20);
    --
    -- We determine if an entry already exists.
    --*/
for l_assignment_id in csr_assignments(l_person_id, p_effective_date)  loop


-- Bug no 5020916. Commenting assignment date check while attaching absences to assignments.
--	IF p_date_start > l_assignment_id.effective_start_date THEN
		l_date_start := p_date_start;
--	ELSE
--		l_date_start := l_assignment_id.effective_start_date;
--	END IF;

--	IF p_date_end < l_assignment_id.effective_end_date THEN
		l_date_end := p_date_end;
--	ELSE
--		l_date_end := l_assignment_id.effective_end_date;
--	END IF;

    get_absence_element
      (p_absence_attendance_id => p_absence_attendance_id
      ,p_assignment_id         => l_assignment_id.assignment_id
      ,p_effective_date        => p_effective_date
      ,p_processing_type       => l_processing_type
      ,p_element_entry_id      => l_element_entry_id
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date);

  hr_utility.set_location('l_person_id: ' || l_person_id , 20);
  hr_utility.set_location('p_effective_date: ' || p_effective_date , 20);
  hr_utility.set_location('l_element_entry_id: ' || l_element_entry_id , 100);


  /* Level 2 */
    if l_element_entry_id is null then
      --
      -- Scenario 1.
      -- An entry does not already exist. Insert if we have
      -- the appropriate dates.
      --
      hr_utility.set_location('Scenario 1', 45);

 l_element_type_id := get_element_for_category(p_absence_attendance_id);

  OPEN csr_processing_type (l_element_type_id );
  FETCH csr_processing_type INTO l_processing_type;
  CLOSE csr_processing_type;



hr_utility.set_location('l_processing_type: ' || l_processing_type , 20);
hr_utility.set_location('l_date_start: ' || l_date_start , 20);
hr_utility.set_location('l_assignment_id.assignment_id: ' || l_assignment_id.assignment_id , 100);
hr_utility.set_location('l_element_type_id: ' || l_element_type_id , 100);

      if (l_processing_type = 'N'
          and l_date_start is not null
          and l_date_end is not null)
      or (l_processing_type = 'R'
          and l_date_start is not null)
      then
        -- Bug no 5020916. Restricting the for loop to process one time for each assignment.
        IF l_old_assignment <> l_assignment_id.assignment_id THEN
           l_old_assignment := l_assignment_id.assignment_id;
         insert_absence_element
           (p_date_start            => l_date_start
           ,p_assignment_id         => l_assignment_id.assignment_id
           ,p_absence_attendance_id => p_absence_attendance_id
           ,p_element_entry_id      => l_element_entry_id);
         END IF;
         if l_processing_type = 'R' and p_date_end is not null and l_element_entry_id is not null then
            --
            -- Scenario 2.
            -- If this is a recurring element entry and we have the
            -- absence end date, we date effectively delete the
            -- element immediately, otherwise it remains open until
            -- the end of time.
            --
            hr_utility.set_location('Scenario 2', 50);

            delete_absence_element
              (p_dt_delete_mode        => 'DELETE'
              ,p_session_date          => l_date_end
              ,p_element_entry_id      => l_element_entry_id);
         end if;

      end if;

    else
      --
      -- An entry already exists. Update it as appropriate.
      --
      /* Level 3 */
      hr_utility.set_location('element_entry id is not null ', 30);

      if (l_processing_type = 'R' and l_date_start is null)
      or (l_processing_type = 'N' and (l_date_start is null
                                   or   l_date_end is null)) then
         --
         -- Scenario 3.
         -- The element entry should be purged because the
         -- actual dates have been removed.
         --
         hr_utility.set_location('Scenario 3', 55);

         --
         -- Warn the user before deleting.
         --
         l_del_element_entry_warning := TRUE;

  hr_utility.set_location('before delete absence element ', 40);
         delete_absence_element
           (p_dt_delete_mode        => 'ZAP'
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id);

      elsif l_processing_type = 'N' and l_date_start not between
            l_effective_start_date and l_effective_end_date then
         --
         -- Scenario 4.
         -- The start date cannot be moved outside the entry's
         -- current period for non-recurring entries.
         --
         hr_utility.set_location('Scenario 4', 60);

         fnd_message.set_name ('PAY', 'HR_6744_ABS_DET_ENTRY_PERIOD');
         fnd_message.set_token ('PERIOD_FROM',
               fnd_date.date_to_chardate(l_effective_start_date));
         fnd_message.set_token ('PERIOD_TO',
               fnd_date.date_to_chardate(l_effective_end_date));
         fnd_message.raise_error;

      elsif l_processing_type = 'N' then
         --
         -- Scenario 5.
         -- Update the existing entry with the new input values.
         -- For simplicity, we make the update even if the value
         -- has not changed.
         --
         hr_utility.set_location('Scenario 5', 65);

         update_absence_element
           (p_dt_update_mode        => 'CORRECTION'
           ,p_assignment_id         => l_assignment_id.assignment_id
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id
           ,p_absence_attendance_id => p_absence_attendance_id);

      elsif l_processing_type = 'R'
            and l_date_start <> l_effective_start_date then

         --
         -- Scenario 6.
         -- The start date has been moved. As this is part of the
         -- primary key we must delete the entry and re-insert it.
         --
         hr_utility.set_location('Scenario 6', 70);

         delete_absence_element
           (p_dt_delete_mode        => 'ZAP'
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id);

         insert_absence_element
           (p_date_start            => l_date_start
           ,p_assignment_id         => l_assignment_id.assignment_id
           ,p_absence_attendance_id => p_absence_attendance_id
           ,p_element_entry_id      => l_element_entry_id);

         if p_date_end is not null then
            --
            -- We have the absence end date, we date effectively
            -- delete the element immediately, otherwise it
            -- remains open until the end of time.
            --

            delete_absence_element
              (p_dt_delete_mode        => 'DELETE'
              ,p_session_date          => l_date_end
              ,p_element_entry_id      => l_element_entry_id);
         end if;

      elsif l_processing_type = 'R' and
            (l_date_end is null or
             l_date_end <> l_effective_end_date) then
         --
         -- Scenario 7.
         -- The end date has:
         --  . changed
         --  . been removed
         --  . entered for the first time
         --  . still not been entered.
         --
         hr_utility.set_location('Scenario 7', 75);
         hr_utility.set_location('l_date_end: '|| l_date_end, 75);
         hr_utility.set_location('l_effective_end_date: '|| l_effective_end_date, 75);
         hr_utility.set_location('l_element_entry_id: '|| l_element_entry_id, 75);

         update_absence_element
           (p_dt_update_mode        => 'CORRECTION'
           ,p_assignment_id         => l_assignment_id.assignment_id
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id
           ,p_absence_attendance_id => p_absence_attendance_id);

         if l_effective_end_date <> hr_api.g_eot then
            --
            -- End date has been changed or removed so we
            -- remove the end date so it continues through
            -- until the end of time.
            --
            hr_utility.set_location(l_proc, 76);
		if l_effective_end_date <> l_assignment_id.effective_end_date then
        	    delete_absence_element
	              (p_dt_delete_mode        => 'DELETE_NEXT_CHANGE'
        	      ,p_session_date          => l_effective_end_date
	              ,p_element_entry_id      => l_element_entry_id);
        	end if;
         end if;

         if l_date_end is not null then
            --
            -- End date has been changed or entered for
            -- the first time. We end the element entry
            -- at the end date.
            --
            hr_utility.set_location(l_proc, 78);

            delete_absence_element
              (p_dt_delete_mode        => 'DELETE'
              ,p_session_date          => l_date_end
              ,p_element_entry_id      => l_element_entry_id);


         end if;

     elsif l_processing_type = 'R' THEN
         --
         -- Scenario 8.
         -- Update the existing entry with the new input values.
         -- For simplicity, we make the update even if the value
         -- has not changed.
         --
         hr_utility.set_location('Scenario 8', 65);

         update_absence_element
           (p_dt_update_mode        => 'CORRECTION'
           ,p_assignment_id         => l_assignment_id.assignment_id
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id
           ,p_absence_attendance_id => p_absence_attendance_id);
      /* Level 3 */
      end if;

    /* Level 2 */
    end if;
  END LOOP;

  /* Level 1 */
--  end if;

/*logic to delete the element entries which are not valid due to change in absence dates*/

l_element_type_id := get_element_for_category (p_absence_attendance_id );

	for l_invalid_entries in csr_invalid_entries(l_element_type_id) LOOP
		if l_invalid_entries.element_entry_id is not null then
		    delete_absence_element
		      (p_dt_delete_mode        => 'ZAP'
		      ,p_session_date          => l_invalid_entries.effective_start_date
		      ,p_element_entry_id      => l_invalid_entries.element_entry_id);
		end if;
	END LOOP;
  END IF;

end update_absence;

procedure delete_absence
  (p_absence_attendance_id in  number
  ) is


  CURSOR csr_assignments IS
   SELECT asg.assignment_id, asg.effective_start_date
   FROM   per_all_assignments_f asg,
          per_absence_attendances paa
   WHERE  paa.absence_attendance_id = p_absence_attendance_id
     and  asg.person_id = paa.person_id
     AND  nvl(paa.date_start,asg.effective_end_date) <=  asg.effective_end_date
     AND  nvl(paa.date_end,asg.effective_start_date) >= asg.effective_start_date;

  /*Pgopal - ADS Bug 5523013 fix, Converting abs.absence_attendance_id to char*/
  cursor csr_get_absence_element(p_assignment_id NUMBER, p_element_type_id NUMBER) is
  select pee.element_entry_id element_entry_id
	  ,pet.processing_type processing_type
          ,pee.effective_start_date effective_start_date
          ,pee.effective_end_date effective_end_date
    from   per_absence_attendances abs
          ,per_all_assignments_f asg
          ,pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
          ,pay_element_entry_values_f peev
          ,pay_input_values_f piv
    where  abs.absence_attendance_id = p_absence_attendance_id
    and    abs.person_id = asg.person_id
    and    asg.assignment_id = p_assignment_id
    and    nvl(abs.date_start,asg.effective_end_date) <=  asg.effective_end_date
    and    nvl(abs.date_end,asg.effective_start_date) >= asg.effective_start_date
    and    pet.element_type_id = p_element_type_id
    and    nvl(abs.date_start,pet.effective_end_date) <=  pet.effective_end_date
    and    nvl(abs.date_end,pet.effective_start_date) >= pet.effective_start_date
    and    pet.element_type_id = pel.element_type_id
    and    pel.element_link_id = pee.element_link_id
    and    pee.assignment_id = asg.assignment_id
    and    pee.creator_type = 'F'
    and    pet.element_type_id = piv.element_type_id
    and    nvl(abs.date_start,piv.effective_end_date) <=  piv.effective_end_date
    and    nvl(abs.date_end,piv.effective_start_date) >= piv.effective_start_date
    and    piv.name = 'CREATOR_ID'
    and    peev.element_entry_id = pee.element_entry_id
    and    peev.input_value_id=piv.input_value_id
    and    peev.screen_entry_value = to_char(abs.absence_attendance_id);
    --and    peev.screen_entry_value = abs.absence_attendance_id;



/*    select pee.element_entry_id element_entry_id
	  ,pet.processing_type processing_type
          ,pee.effective_start_date effective_start_date
          ,pee.effective_end_date effective_end_date
    from   per_absence_attendances abs
          ,per_all_assignments_f asg
          ,pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
    where  abs.absence_attendance_id = p_absence_attendance_id
    and    abs.person_id = asg.person_id
    and    asg.assignment_id = p_assignment_id
    and    nvl(abs.date_start,asg.effective_end_date) <=  asg.effective_end_date
    and    nvl(abs.date_end,asg.effective_start_date) >= asg.effective_start_date
    and    pet.element_type_id = p_element_type_id
    and    nvl(abs.date_start,pet.effective_start_date) >= pet.effective_start_date
    and    nvl(abs.date_end,pet.effective_end_date)   <= pet.effective_end_date
    and    pet.element_type_id = pel.element_type_id
    and    pel.element_link_id = pee.element_link_id
    and    pee.assignment_id = asg.assignment_id
    and    pee.creator_id = abs.absence_attendance_id
    and    pee.creator_type = 'F';
*/


rec_assignments csr_assignments%rowtype;
rec_absence_element csr_get_absence_element%rowtype;
l_element_type_id NUMBER(15);

l_flag varchar2(1);
BEGIN
  --
  -- Added for GSI Bug 5472781
---pgopal -Included 'NO','SE','PL' in the legislation installation check.
   IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'NO') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'SE') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'PL') OR
      hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
    --
    hr_utility.set_location('Start of absence element deletion section', 30);
    --
    FOR rec_assignments in csr_assignments LOOP
      --
      hr_utility.set_location(' in for loop ', 35);
      --
      l_element_type_id := get_element_for_category (p_absence_attendance_id );
      --
      hr_utility.set_location('l_element_type_id '|| l_element_type_id, 35);
      --
      l_flag := 'N';
	  --
	  open csr_get_absence_element(rec_assignments.assignment_id,l_element_type_id );
	  fetch csr_get_absence_element into rec_absence_element;
	  if csr_get_absence_element%notfound then
		l_flag := 'Y';
      end if;
	  close csr_get_absence_element;
      --
      hr_utility.set_location('rec_assignments.assignment_id '|| rec_assignments.assignment_id, 35);
      hr_utility.set_location('rec_absence_element.element_entry_id '|| rec_absence_element.element_entry_id, 35);
      if l_flag <> 'Y' then
	    if rec_absence_element.element_entry_id is not null then
	      delete_absence_element
	        (p_dt_delete_mode        => 'ZAP'
	        ,p_session_date          => rec_absence_element.effective_start_date
	        ,p_element_entry_id      => rec_absence_element.element_entry_id);
	    end if;
      end if;
	  --
      hr_utility.set_location('End of absence element deletion section', 40);
      --
    END LOOP;
  END IF;
END delete_absence;

END hr_loc_absence;

/
