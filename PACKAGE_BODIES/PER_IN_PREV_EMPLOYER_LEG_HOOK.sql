--------------------------------------------------------
--  DDL for Package Body PER_IN_PREV_EMPLOYER_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_PREV_EMPLOYER_LEG_HOOK" AS
/* $Header: peinlhpr.pkb 120.3 2007/11/22 10:48:19 sivanara ship $ */

   g_package      VARCHAR2(30);
   g_debug        BOOLEAN;
   g_token_name   pay_in_utils.char_tab_type;
   g_token_value  pay_in_utils.char_tab_type;
   g_message_name VARCHAR2(30);

--

--------------------------------------------------------------------------
-- Name           : validate_ltc_availed                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Dummy procedure.This has been nulled out            --
--                                                                      --
-- Bug 4065990 .The seed data script peinpped.sql had a call to this    --
-- procedure and it was already shipped.This procedure is needed        --
-- for compatibility.This procedure does nothing and has been replaced  --
--  check_prev_emp_create and check_prev_emp_update                     --

--------------------------------------------------------------------------
PROCEDURE validate_ltc_availed(
         p_pem_information_category IN VARCHAR2
        ,p_end_date                 IN DATE
        ) IS
BEGIN

   NULL;

END validate_ltc_availed;

--------------------------------------------------------------------------
-- Name           : check_prev_emp_int                                 --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the PEM Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date            IN DATE                 --
--                  p_previous_employer_id      IN NUMBER               --
--                  p_business_group_id         IN NUMBER               --
--                  p_person_id                 IN NUMBER               --
--                  p_start_date                IN DATE                 --
--                  p_end_date                  IN DATE                 --
--                  p_pem_information_category  IN VARCHAR2             --
--                  p_pem_information1..30      IN VARCHAR2             --
--                  p_calling_procedure         IN VARCHAR2             --
--            OUT : p_message_name             OUT VARCHAR2             --
--                  p_token_name               OUT pay_in_utils.char_tab_type
--                  p_token_value              OUT pay_in_utils.char_tab_type
--------------------------------------------------------------------------
PROCEDURE check_prev_emp_int(
          p_effective_date       IN DATE
         ,p_previous_employer_id IN NUMBER
	 ,p_business_group_id    IN NUMBER
	 ,p_person_id            IN NUMBER
         ,p_start_date           IN DATE
         ,p_end_date             IN DATE
         ,p_pem_information_category IN VARCHAR2
         ,p_pem_information1     IN VARCHAR2
         ,p_pem_information2     IN VARCHAR2
         ,p_pem_information3     IN VARCHAR2
         ,p_pem_information4     IN VARCHAR2
         ,p_pem_information5     IN VARCHAR2
         ,p_pem_information6     IN VARCHAR2
         ,p_pem_information7     IN VARCHAR2
         ,p_pem_information8     IN VARCHAR2
         ,p_pem_information9     IN VARCHAR2
         ,p_pem_information10    IN VARCHAR2
         ,p_pem_information11    IN VARCHAR2
         ,p_pem_information12    IN VARCHAR2
         ,p_pem_information13    IN VARCHAR2
         ,p_pem_information14    IN VARCHAR2
         ,p_pem_information15    IN VARCHAR2
         ,p_pem_information16    IN VARCHAR2
         ,p_pem_information17    IN VARCHAR2
         ,p_pem_information18    IN VARCHAR2
         ,p_pem_information19    IN VARCHAR2
         ,p_pem_information20    IN VARCHAR2
         ,p_pem_information21    IN VARCHAR2
         ,p_pem_information22    IN VARCHAR2
         ,p_pem_information23    IN VARCHAR2
         ,p_pem_information24    IN VARCHAR2
         ,p_pem_information25    IN VARCHAR2
         ,p_pem_information26    IN VARCHAR2
         ,p_pem_information27    IN VARCHAR2
         ,p_pem_information28    IN VARCHAR2
         ,p_pem_information29    IN VARCHAR2
         ,p_pem_information30    IN VARCHAR2
 	 ,p_calling_procedure    IN VARCHAR2
	 ,p_message_name        OUT NOCOPY VARCHAR2
	 ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
	 ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type)
IS
---------------------------------------------------------------------------
--APPLICATION_COLUMN_NAME        FORM_LEFT_PROMPT
------------------------------ --------------------------------------------
--PEM_INFORMATION1             Designation
--PEM_INFORMATION2             Annual Salary (Rs.)
--PEM_INFORMATION3             PF Number
--PEM_INFORMATION4             PF Establishment Code
--PEM_INFORMATION5             EPF Number
--PEM_INFORMATION6             Employer Classification
--PEM_INFORMATION7             Number of LTC Availed in Previous Block
--PEM_INFORMATION8             Number of LTC Availed in Current Block
--PEM_INFORMATION9             Leave Encashment Amount
--PEM_INFORMATION10            Gratuity Amount
--PEM_INFORMATION11            Retrenchment Amount
--PEM_INFORMATION12            VRS Amount
--PEM_INFORMATION13            Gross Earnings for Current Tax Year
--PEM_INFORMATION14            Recognized PF Deduction for Current Tax Year
--PEM_INFORMATION15            Entertainment Allowance for Current Tax Year
--PEM_INFORMATION16            Professional Tax Paid in Current Tax Year
--PEM_INFORMATION17            TDS Deducted in Current Tax Year
--PEM_INFORMATION18            Superannuation for Current Tax Year
---------------------------------------------------------------------------

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(250);

   CURSOR c_pt_ceil IS
      SELECT global_value
      FROM   ff_globals_f
      WHERE  global_name = 'IN_PTAX_CEILING'
      AND    p_effective_date between effective_start_date and effective_end_date;

 /*Cursor to get the person type of the given person id*/
   CURSOR c_person_type IS
     SELECT 'X'
     FROM   per_person_types ppt,
            per_person_type_usages_f pptu
     WHERE ppt.person_type_id = pptu.person_type_id
     AND ppt.business_group_id = p_business_group_id
     AND pptu.person_id = p_person_id
     AND p_effective_date BETWEEN pptu.effective_start_date
     AND pptu.effective_end_date AND ppt.system_person_type = 'EMP';

   l_pt_ceil    ff_globals_f.global_value%TYPE;
   l_person_type VARCHAR2(1);

BEGIN

  l_procedure := g_package||'check_prev_emp_int';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       hr_utility.trace ('IN Legislation not installed. Not performing the validations');
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date      ',p_effective_date      );
     pay_in_utils.trace('p_previous_employer_id',p_previous_employer_id);
     pay_in_utils.trace('p_business_group_id'   ,p_business_group_id);
     pay_in_utils.trace('p_preson_id'           ,p_person_id);
     pay_in_utils.trace('p_start_date          ',p_start_date          );
     pay_in_utils.trace('p_end_date            ',p_end_date            );
     pay_in_utils.trace('p_pem_information_category',p_pem_information_category);
     pay_in_utils.trace('p_pem_information1    ',p_pem_information1    );
     pay_in_utils.trace('p_pem_information2    ',p_pem_information2    );
     pay_in_utils.trace('p_pem_information3    ',p_pem_information3    );
     pay_in_utils.trace('p_pem_information4    ',p_pem_information4    );
     pay_in_utils.trace('p_pem_information5    ',p_pem_information5    );
     pay_in_utils.trace('p_pem_information6    ',p_pem_information6    );
     pay_in_utils.trace('p_pem_information7    ',p_pem_information7    );
     pay_in_utils.trace('p_pem_information8    ',p_pem_information8    );
     pay_in_utils.trace('p_pem_information9    ',p_pem_information9    );
     pay_in_utils.trace('p_pem_information10   ',p_pem_information10   );
     pay_in_utils.trace('p_pem_information11   ',p_pem_information11   );
     pay_in_utils.trace('p_pem_information12   ',p_pem_information12   );
     pay_in_utils.trace('p_pem_information13   ',p_pem_information13   );
     pay_in_utils.trace('p_pem_information14   ',p_pem_information14   );
     pay_in_utils.trace('p_pem_information15   ',p_pem_information15   );
     pay_in_utils.trace('p_pem_information16   ',p_pem_information16   );
     pay_in_utils.trace('p_pem_information17   ',p_pem_information17   );
     pay_in_utils.trace('p_pem_information18   ',p_pem_information18   );
     pay_in_utils.trace('p_pem_information19   ',p_pem_information19   );
     pay_in_utils.trace('p_pem_information20   ',p_pem_information20   );
     pay_in_utils.trace('p_pem_information21   ',p_pem_information21   );
     pay_in_utils.trace('p_pem_information22   ',p_pem_information22   );
     pay_in_utils.trace('p_pem_information23   ',p_pem_information23   );
     pay_in_utils.trace('p_pem_information24   ',p_pem_information24   );
     pay_in_utils.trace('p_pem_information25   ',p_pem_information25   );
     pay_in_utils.trace('p_pem_information26   ',p_pem_information26   );
     pay_in_utils.trace('p_pem_information27   ',p_pem_information27   );
     pay_in_utils.trace('p_pem_information28   ',p_pem_information28   );
     pay_in_utils.trace('p_pem_information29   ',p_pem_information29   );
     pay_in_utils.trace('p_pem_information30   ',p_pem_information30   );
     pay_in_utils.trace('p_calling_procedure   ',p_calling_procedure   );
     pay_in_utils.trace('p_message_name        ',p_message_name        );
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  IF p_pem_information_category <> 'IN' THEN
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
     RETURN;
  END IF;

--
-- Validations to be built in
--
-- 1. End date should not be null
-- 2. Ensure that Gross Earnings are entered before any other
--    current tax year information
-- 3. Prof Tax value should not be greater than IN_PTAX_CEILING
--
  pay_in_utils.set_location(g_debug,l_procedure,20);
--
-- 1. End date should not be null for employee
--

    OPEN c_person_type;
    FETCH c_person_type INTO l_person_type;
    CLOSE c_person_type;

   pay_in_utils.trace('l_person_type        ',l_person_type);


   IF p_end_date IS NULL AND l_person_type = 'X' THEN
     p_message_name := 'PER_IN_END_DATE_NOT_ENTERED';

     IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_message_name        ',p_message_name);
        pay_in_utils.trace('**************************************************','********************');
     END IF;

     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
     RETURN;
   END IF;

  IF p_pem_information6 IS NULL AND
    (p_pem_information9 IS NOT NULL OR
     p_pem_information10 IS NOT NULL OR
     p_pem_information15 IS NOT NULL)
  THEN
     p_message_name := 'PER_IN_MISSING_ER';

     IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_message_name        ',p_message_name);
        pay_in_utils.trace('**************************************************','********************');
     END IF;

     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
     RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,40);

  IF g_debug THEN
     pay_in_utils.trace ('Gross Earnings for Current Tax Year          :',p_pem_information13);
     pay_in_utils.trace ('Recognized PF Deduction for Current Tax Year :',p_pem_information14);
     pay_in_utils.trace ('Entertainment Allowance for Current Tax Year :',p_pem_information15);
     pay_in_utils.trace ('Professional Tax Paid in Current Tax Year    :',p_pem_information16);
     pay_in_utils.trace ('TDS Deducted in Current Tax Year             :',p_pem_information17);
     pay_in_utils.trace ('Superannuation for Current Tax Year          :',p_pem_information18);
  END IF;
--
-- 2. Ensure that Gross Earnings are entered before any other
--    current tax year information
--
  IF (p_pem_information13 IS NULL OR to_number(p_pem_information13) = 0) AND
     (p_pem_information14 IS NOT NULL OR
      p_pem_information15 IS NOT NULL OR
      p_pem_information16 IS NOT NULL OR
      p_pem_information17 IS NOT NULL OR
      p_pem_information18 IS NOT NULL )
  THEN
     p_message_name := 'PER_IN_MISSING_EARNINGS';

     IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_message_name        ',p_message_name);
        pay_in_utils.trace('**************************************************','********************');
     END IF;

     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
     RETURN;
  END IF;

--
-- 3. Prof Tax value should not be greater than IN_PTAX_CEILING
--
  OPEN c_pt_ceil;
  FETCH c_pt_ceil
  INTO  l_pt_ceil;
  IF c_pt_ceil%NOTFOUND OR l_pt_ceil IS NULL THEN
     NULL;
  ELSE
     pay_in_utils.set_location(g_debug,'P PT CEILING : '||l_pt_ceil,50);
     IF p_pem_information16 IS NOT NULL AND
        TO_NUMBER(p_pem_information16) > TO_NUMBER(l_pt_ceil)
     THEN
	p_message_name  := 'PER_IN_PT_MORE_THAN_LIMIT';
	p_token_name(1) := 'VALUE';
	p_token_value(1):= l_pt_ceil;

        IF g_debug THEN
           pay_in_utils.trace('**************************************************','********************');
           pay_in_utils.trace('p_message_name        ',p_message_name);
           pay_in_utils.trace('**************************************************','********************');
        END IF;

	pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);
	RETURN;
     END IF;
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,70);

END check_prev_emp_int;

--------------------------------------------------------------------------
-- Name           : check_prev_emp_create                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the PEM Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date            IN DATE                 --
--                  p_previous_employer_id      IN NUMBER               --
--                  p_business_group_id         IN NUMBER               --
--                  p_person_id                 IN NUMBER               --
--                  p_start_date                IN DATE                 --
--                  p_end_date                  IN DATE                 --
--                  p_pem_information_category  IN VARCHAR2             --
--                  p_pem_information1..30      IN VARCHAR2             --
--------------------------------------------------------------------------
PROCEDURE check_prev_emp_create(
          p_effective_date       IN DATE
         ,p_previous_employer_id IN NUMBER
	 ,p_business_group_id    IN NUMBER
	 ,p_person_id            IN NUMBER
         ,p_start_date           IN DATE
         ,p_end_date             IN DATE
         ,p_pem_information_category IN VARCHAR2
         ,p_pem_information1     IN VARCHAR2
         ,p_pem_information2     IN VARCHAR2
         ,p_pem_information3     IN VARCHAR2
         ,p_pem_information4     IN VARCHAR2
         ,p_pem_information5     IN VARCHAR2
         ,p_pem_information6     IN VARCHAR2
         ,p_pem_information7     IN VARCHAR2
         ,p_pem_information8     IN VARCHAR2
         ,p_pem_information9     IN VARCHAR2
         ,p_pem_information10    IN VARCHAR2
         ,p_pem_information11    IN VARCHAR2
         ,p_pem_information12    IN VARCHAR2
         ,p_pem_information13    IN VARCHAR2
         ,p_pem_information14    IN VARCHAR2
         ,p_pem_information15    IN VARCHAR2
         ,p_pem_information16    IN VARCHAR2
         ,p_pem_information17    IN VARCHAR2
         ,p_pem_information18    IN VARCHAR2
         ,p_pem_information19    IN VARCHAR2
         ,p_pem_information20    IN VARCHAR2
         ,p_pem_information21    IN VARCHAR2
         ,p_pem_information22    IN VARCHAR2
         ,p_pem_information23    IN VARCHAR2
         ,p_pem_information24    IN VARCHAR2
         ,p_pem_information25    IN VARCHAR2
         ,p_pem_information26    IN VARCHAR2
         ,p_pem_information27    IN VARCHAR2
         ,p_pem_information28    IN VARCHAR2
         ,p_pem_information29    IN VARCHAR2
         ,p_pem_information30    IN VARCHAR2)
IS

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(250);

BEGIN

  l_procedure := g_package||'check_prev_emp_create';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

  g_message_name := 'SUCCESS';
  pay_in_utils.null_message(g_token_name, g_token_value);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date       ',p_effective_date       );
     pay_in_utils.trace('p_previous_employer_id ',p_previous_employer_id );
     pay_in_utils.trace('p_start_date           ',p_start_date           );
     pay_in_utils.trace('p_end_date             ',p_end_date             );
     pay_in_utils.trace('p_pem_information_category',p_pem_information_category);
     pay_in_utils.trace('p_pem_information1     ',p_pem_information1     );
     pay_in_utils.trace('p_pem_information2     ',p_pem_information2     );
     pay_in_utils.trace('p_pem_information3     ',p_pem_information3     );
     pay_in_utils.trace('p_pem_information4     ',p_pem_information4     );
     pay_in_utils.trace('p_pem_information5     ',p_pem_information5     );
     pay_in_utils.trace('p_pem_information6     ',p_pem_information6     );
     pay_in_utils.trace('p_pem_information7     ',p_pem_information7     );
     pay_in_utils.trace('p_pem_information8     ',p_pem_information8     );
     pay_in_utils.trace('p_pem_information9     ',p_pem_information9     );
     pay_in_utils.trace('p_pem_information10    ',p_pem_information10    );
     pay_in_utils.trace('p_pem_information11    ',p_pem_information11    );
     pay_in_utils.trace('p_pem_information12    ',p_pem_information12    );
     pay_in_utils.trace('p_pem_information13    ',p_pem_information13    );
     pay_in_utils.trace('p_pem_information14    ',p_pem_information14    );
     pay_in_utils.trace('p_pem_information15    ',p_pem_information15    );
     pay_in_utils.trace('p_pem_information16    ',p_pem_information16    );
     pay_in_utils.trace('p_pem_information17    ',p_pem_information17    );
     pay_in_utils.trace('p_pem_information18    ',p_pem_information18    );
     pay_in_utils.trace('p_pem_information19    ',p_pem_information19    );
     pay_in_utils.trace('p_pem_information20    ',p_pem_information20    );
     pay_in_utils.trace('p_pem_information21    ',p_pem_information21    );
     pay_in_utils.trace('p_pem_information22    ',p_pem_information22    );
     pay_in_utils.trace('p_pem_information23    ',p_pem_information23    );
     pay_in_utils.trace('p_pem_information24    ',p_pem_information24    );
     pay_in_utils.trace('p_pem_information25    ',p_pem_information25    );
     pay_in_utils.trace('p_pem_information26    ',p_pem_information26    );
     pay_in_utils.trace('p_pem_information27    ',p_pem_information27    );
     pay_in_utils.trace('p_pem_information28    ',p_pem_information28    );
     pay_in_utils.trace('p_pem_information29    ',p_pem_information29    );
     pay_in_utils.trace('p_pem_information30    ',p_pem_information30    );
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  check_prev_emp_int(
          p_effective_date       => p_effective_date
         ,p_previous_employer_id => p_previous_employer_id
	 ,p_business_group_id    => p_business_group_id
	 ,p_person_id            => p_person_id
         ,p_start_date           => p_start_date
         ,p_end_date             => p_end_date
         ,p_pem_information_category => p_pem_information_category
         ,p_pem_information1     => p_pem_information1
         ,p_pem_information2     => p_pem_information2
         ,p_pem_information3     => p_pem_information3
         ,p_pem_information4     => p_pem_information4
         ,p_pem_information5     => p_pem_information5
         ,p_pem_information6     => p_pem_information6
         ,p_pem_information7     => p_pem_information7
         ,p_pem_information8     => p_pem_information8
         ,p_pem_information9     => p_pem_information9
         ,p_pem_information10    => p_pem_information10
         ,p_pem_information11    => p_pem_information11
         ,p_pem_information12    => p_pem_information12
         ,p_pem_information13    => p_pem_information13
         ,p_pem_information14    => p_pem_information14
         ,p_pem_information15    => p_pem_information15
         ,p_pem_information16    => p_pem_information16
         ,p_pem_information17    => p_pem_information17
         ,p_pem_information18    => p_pem_information18
         ,p_pem_information19    => p_pem_information19
         ,p_pem_information20    => p_pem_information20
         ,p_pem_information21    => p_pem_information21
         ,p_pem_information22    => p_pem_information22
         ,p_pem_information23    => p_pem_information23
         ,p_pem_information24    => p_pem_information24
         ,p_pem_information25    => p_pem_information25
         ,p_pem_information26    => p_pem_information26
         ,p_pem_information27    => p_pem_information27
         ,p_pem_information28    => p_pem_information28
         ,p_pem_information29    => p_pem_information29
         ,p_pem_information30    => p_pem_information30
         ,p_calling_procedure    => l_procedure
	 ,p_message_name         => g_message_name
	 ,p_token_name           => g_token_name
	 ,p_token_value          => g_token_value);


  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);

END check_prev_emp_create;


--------------------------------------------------------------------------
-- Name           : check_prev_emp_update                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the PEM Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date            IN DATE                 --
--                  p_previous_employer_id      IN NUMBER               --
--                  p_business_group_id         IN NUMBER               --
--                  p_person_id                 IN NUMBER               --
--                  p_start_date                IN DATE                 --
--                  p_end_date                  IN DATE                 --
--                  p_pem_information_category  IN VARCHAR2             --
--                  p_pem_information1..30      IN VARCHAR2             --
--------------------------------------------------------------------------
PROCEDURE check_prev_emp_update(
          p_effective_date       IN DATE
         ,p_previous_employer_id IN NUMBER
         ,p_start_date           IN DATE
         ,p_end_date             IN DATE
         ,p_pem_information_category IN VARCHAR2
         ,p_pem_information1     IN VARCHAR2
         ,p_pem_information2     IN VARCHAR2
         ,p_pem_information3     IN VARCHAR2
         ,p_pem_information4     IN VARCHAR2
         ,p_pem_information5     IN VARCHAR2
         ,p_pem_information6     IN VARCHAR2
         ,p_pem_information7     IN VARCHAR2
         ,p_pem_information8     IN VARCHAR2
         ,p_pem_information9     IN VARCHAR2
         ,p_pem_information10    IN VARCHAR2
         ,p_pem_information11    IN VARCHAR2
         ,p_pem_information12    IN VARCHAR2
         ,p_pem_information13    IN VARCHAR2
         ,p_pem_information14    IN VARCHAR2
         ,p_pem_information15    IN VARCHAR2
         ,p_pem_information16    IN VARCHAR2
         ,p_pem_information17    IN VARCHAR2
         ,p_pem_information18    IN VARCHAR2
         ,p_pem_information19    IN VARCHAR2
         ,p_pem_information20    IN VARCHAR2
         ,p_pem_information21    IN VARCHAR2
         ,p_pem_information22    IN VARCHAR2
         ,p_pem_information23    IN VARCHAR2
         ,p_pem_information24    IN VARCHAR2
         ,p_pem_information25    IN VARCHAR2
         ,p_pem_information26    IN VARCHAR2
         ,p_pem_information27    IN VARCHAR2
         ,p_pem_information28    IN VARCHAR2
         ,p_pem_information29    IN VARCHAR2
         ,p_pem_information30    IN VARCHAR2)
IS

   CURSOR c_pem_id IS
      SELECT business_group_id
            ,person_id
            ,start_date
	    ,end_date
	    ,pem_information_category
	    ,pem_information1
            ,pem_information2
            ,pem_information3
            ,pem_information4
            ,pem_information5
            ,pem_information6
            ,pem_information7
            ,pem_information8
            ,pem_information9
            ,pem_information10
            ,pem_information11
            ,pem_information12
            ,pem_information13
            ,pem_information14
            ,pem_information15
            ,pem_information16
            ,pem_information17
            ,pem_information18
            ,pem_information19
            ,pem_information20
            ,pem_information21
            ,pem_information22
            ,pem_information23
            ,pem_information24
	    ,pem_information25
	    ,pem_information26
	    ,pem_information27
	    ,pem_information28
	    ,pem_information29
	    ,pem_information30
      FROM   per_previous_employers
      WHERE  previous_employer_id = p_previous_employer_id;

   l_person_id           per_previous_employers.person_id%TYPE;
   l_business_group_id   per_previous_employers.business_group_id%TYPE;
   l_start_date          per_previous_employers.start_date%TYPE;
   l_end_date            per_previous_employers.end_date%TYPE;
   l_pem_information_category per_previous_employers.pem_information_category%TYPE;
   l_pem_information1    per_previous_employers.pem_information1%TYPE;
   l_pem_information2    per_previous_employers.pem_information2%TYPE;
   l_pem_information3    per_previous_employers.pem_information3%TYPE;
   l_pem_information4    per_previous_employers.pem_information4%TYPE;
   l_pem_information5    per_previous_employers.pem_information5%TYPE;
   l_pem_information6    per_previous_employers.pem_information6%TYPE;
   l_pem_information7    per_previous_employers.pem_information7%TYPE;
   l_pem_information8    per_previous_employers.pem_information8%TYPE;
   l_pem_information9    per_previous_employers.pem_information9%TYPE;
   l_pem_information10   per_previous_employers.pem_information10%TYPE;
   l_pem_information11   per_previous_employers.pem_information11%TYPE;
   l_pem_information12   per_previous_employers.pem_information12%TYPE;
   l_pem_information13   per_previous_employers.pem_information13%TYPE;
   l_pem_information14   per_previous_employers.pem_information14%TYPE;
   l_pem_information15   per_previous_employers.pem_information15%TYPE;
   l_pem_information16   per_previous_employers.pem_information16%TYPE;
   l_pem_information17   per_previous_employers.pem_information17%TYPE;
   l_pem_information18   per_previous_employers.pem_information18%TYPE;
   l_pem_information19   per_previous_employers.pem_information19%TYPE;
   l_pem_information20   per_previous_employers.pem_information20%TYPE;
   l_pem_information21   per_previous_employers.pem_information21%TYPE;
   l_pem_information22   per_previous_employers.pem_information22%TYPE;
   l_pem_information23   per_previous_employers.pem_information23%TYPE;
   l_pem_information24   per_previous_employers.pem_information24%TYPE;
   l_pem_information25   per_previous_employers.pem_information25%TYPE;
   l_pem_information26   per_previous_employers.pem_information26%TYPE;
   l_pem_information27   per_previous_employers.pem_information27%TYPE;
   l_pem_information28   per_previous_employers.pem_information28%TYPE;
   l_pem_information29   per_previous_employers.pem_information29%TYPE;
   l_pem_information30   per_previous_employers.pem_information30%TYPE;

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(250);

BEGIN
  l_procedure := g_package||'check_prev_emp_update';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);
  g_message_name := 'SUCCESS';

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date       ',p_effective_date       );
     pay_in_utils.trace('p_previous_employer_id ',p_previous_employer_id );
     pay_in_utils.trace('p_start_date           ',p_start_date           );
     pay_in_utils.trace('p_end_date             ',p_end_date             );
     pay_in_utils.trace('p_pem_information_category',p_pem_information_category);
     pay_in_utils.trace('p_pem_information1     ',p_pem_information1     );
     pay_in_utils.trace('p_pem_information2     ',p_pem_information2     );
     pay_in_utils.trace('p_pem_information3     ',p_pem_information3     );
     pay_in_utils.trace('p_pem_information4     ',p_pem_information4     );
     pay_in_utils.trace('p_pem_information5     ',p_pem_information5     );
     pay_in_utils.trace('p_pem_information6     ',p_pem_information6     );
     pay_in_utils.trace('p_pem_information7     ',p_pem_information7     );
     pay_in_utils.trace('p_pem_information8     ',p_pem_information8     );
     pay_in_utils.trace('p_pem_information9     ',p_pem_information9     );
     pay_in_utils.trace('p_pem_information10    ',p_pem_information10    );
     pay_in_utils.trace('p_pem_information11    ',p_pem_information11    );
     pay_in_utils.trace('p_pem_information12    ',p_pem_information12    );
     pay_in_utils.trace('p_pem_information13    ',p_pem_information13    );
     pay_in_utils.trace('p_pem_information14    ',p_pem_information14    );
     pay_in_utils.trace('p_pem_information15    ',p_pem_information15    );
     pay_in_utils.trace('p_pem_information16    ',p_pem_information16    );
     pay_in_utils.trace('p_pem_information17    ',p_pem_information17    );
     pay_in_utils.trace('p_pem_information18    ',p_pem_information18    );
     pay_in_utils.trace('p_pem_information19    ',p_pem_information19    );
     pay_in_utils.trace('p_pem_information20    ',p_pem_information20    );
     pay_in_utils.trace('p_pem_information21    ',p_pem_information21    );
     pay_in_utils.trace('p_pem_information22    ',p_pem_information22    );
     pay_in_utils.trace('p_pem_information23    ',p_pem_information23    );
     pay_in_utils.trace('p_pem_information24    ',p_pem_information24    );
     pay_in_utils.trace('p_pem_information25    ',p_pem_information25    );
     pay_in_utils.trace('p_pem_information26    ',p_pem_information26    );
     pay_in_utils.trace('p_pem_information27    ',p_pem_information27    );
     pay_in_utils.trace('p_pem_information28    ',p_pem_information28    );
     pay_in_utils.trace('p_pem_information29    ',p_pem_information29    );
     pay_in_utils.trace('p_pem_information30    ',p_pem_information30    );
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  /*IF p_end_date IS NULL THEN
     g_message_name := 'PER_IN_END_DATE_NOT_ENTERED';
     pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);
  END IF;*/

  OPEN c_pem_id;
  FETCH c_pem_id
  INTO l_business_group_id
       ,l_person_id
       ,l_start_date
       ,l_end_date
       ,l_pem_information_category
       ,l_pem_information1
       ,l_pem_information2
       ,l_pem_information3
       ,l_pem_information4
       ,l_pem_information5
       ,l_pem_information6
       ,l_pem_information7
       ,l_pem_information8
       ,l_pem_information9
       ,l_pem_information10
       ,l_pem_information11
       ,l_pem_information12
       ,l_pem_information13
       ,l_pem_information14
       ,l_pem_information15
       ,l_pem_information16
       ,l_pem_information17
       ,l_pem_information18
       ,l_pem_information19
       ,l_pem_information20
       ,l_pem_information21
       ,l_pem_information22
       ,l_pem_information23
       ,l_pem_information24
       ,l_pem_information25
       ,l_pem_information26
       ,l_pem_information27
       ,l_pem_information28
       ,l_pem_information29
       ,l_pem_information30;
  CLOSE c_pem_id;

  pay_in_utils.set_location(g_debug,l_procedure,20);

   IF p_start_date <> hr_api.g_date THEN
       l_start_date := p_start_date;
   END IF;

   IF  p_end_date <> hr_api.g_date THEN
       l_end_date := p_end_date;
   END IF;

   IF p_pem_information_category <> hr_api.g_varchar2 THEN
       l_pem_information_category := p_pem_information_category;
   END IF;

   IF p_pem_information1 <> hr_api.g_varchar2 THEN
       l_pem_information1 := p_pem_information1;
   END IF;

   IF p_pem_information2 <> hr_api.g_varchar2 THEN
       l_pem_information2 := p_pem_information2;
   END IF;

   IF p_pem_information3 <> hr_api.g_varchar2 THEN
       l_pem_information3 := p_pem_information3;
   END IF;

   IF p_pem_information4 <> hr_api.g_varchar2 THEN
       l_pem_information4 := p_pem_information4;
   END IF;

   IF p_pem_information5 <> hr_api.g_varchar2 THEN
       l_pem_information5 := p_pem_information5;
   END IF;

   IF p_pem_information6 <> hr_api.g_varchar2 THEN
       l_pem_information6 := p_pem_information6;
   END IF;

   IF p_pem_information7 <> hr_api.g_varchar2 THEN
       l_pem_information7 := p_pem_information7;
   END IF;

   IF p_pem_information8 <> hr_api.g_varchar2 THEN
       l_pem_information8 := p_pem_information8;
   END IF;

   IF p_pem_information9 <> hr_api.g_varchar2 THEN
       l_pem_information9 := p_pem_information9;
   END IF;

   IF p_pem_information10 <> hr_api.g_varchar2 THEN
       l_pem_information10 := p_pem_information10;
   END IF;

   IF p_pem_information11 <> hr_api.g_varchar2 THEN
       l_pem_information11 := p_pem_information11;
   END IF;

   IF p_pem_information12 <> hr_api.g_varchar2 THEN
       l_pem_information12 := p_pem_information12;
   END IF;

   IF p_pem_information13 <> hr_api.g_varchar2 THEN
       l_pem_information13 := p_pem_information13;
   END IF;

   IF p_pem_information14 <> hr_api.g_varchar2 THEN
       l_pem_information14 := p_pem_information14;
   END IF;

   IF p_pem_information15 <> hr_api.g_varchar2 THEN
       l_pem_information15 := p_pem_information15;
   END IF;

   IF p_pem_information16 <> hr_api.g_varchar2 THEN
       l_pem_information16 := p_pem_information16;
   END IF;

   IF p_pem_information17 <> hr_api.g_varchar2 THEN
       l_pem_information17 := p_pem_information17;
   END IF;

   IF p_pem_information18 <> hr_api.g_varchar2 THEN
       l_pem_information18 := p_pem_information18;
   END IF;

   IF p_pem_information19 <> hr_api.g_varchar2 THEN
       l_pem_information19 := p_pem_information19;
   END IF;

   IF p_pem_information20 <> hr_api.g_varchar2 THEN
       l_pem_information20 := p_pem_information20;
   END IF;

   IF p_pem_information21 <> hr_api.g_varchar2 THEN
       l_pem_information21 := p_pem_information21;
   END IF;

   IF p_pem_information22 <> hr_api.g_varchar2 THEN
       l_pem_information22 := p_pem_information22;
   END IF;

   IF p_pem_information23 <> hr_api.g_varchar2 THEN
       l_pem_information23 := p_pem_information23;
   END IF;

   IF p_pem_information24 <> hr_api.g_varchar2 THEN
       l_pem_information24 := p_pem_information24;
   END IF;

   IF p_pem_information25 <> hr_api.g_varchar2 THEN
       l_pem_information25 := p_pem_information25;
   END IF;

   IF p_pem_information26 <> hr_api.g_varchar2 THEN
       l_pem_information26 := p_pem_information26;
   END IF;

   IF p_pem_information27 <> hr_api.g_varchar2 THEN
       l_pem_information27 := p_pem_information27;
   END IF;

   IF p_pem_information28 <> hr_api.g_varchar2 THEN
       l_pem_information28 := p_pem_information28;
   END IF;

   IF p_pem_information29 <> hr_api.g_varchar2 THEN
       l_pem_information29 := p_pem_information29;
   END IF;

   IF p_pem_information30 <> hr_api.g_varchar2 THEN
       l_pem_information30 := p_pem_information30;
   END IF;
   IF p_end_date IS NULL THEN
   l_end_date := p_end_date;
   END if;
     pay_in_utils.set_location(g_debug,'Before call to internal proc',15);
     pay_in_utils.trace('Before call to internal proc p_person_id ',l_person_id );
     pay_in_utils.trace('Before call to internal proc p_business_group_id ',l_business_group_id );
  check_prev_emp_int(
          p_effective_date       => p_effective_date
         ,p_previous_employer_id => p_previous_employer_id
	 ,p_business_group_id    => l_business_group_id
         ,p_person_id            => l_person_id
         ,p_start_date           => l_start_date
         ,p_end_date             => l_end_date
         ,p_pem_information_category => l_pem_information_category
         ,p_pem_information1     => l_pem_information1
         ,p_pem_information2     => l_pem_information2
         ,p_pem_information3     => l_pem_information3
         ,p_pem_information4     => l_pem_information4
         ,p_pem_information5     => l_pem_information5
         ,p_pem_information6     => l_pem_information6
         ,p_pem_information7     => l_pem_information7
         ,p_pem_information8     => l_pem_information8
         ,p_pem_information9     => l_pem_information9
         ,p_pem_information10    => l_pem_information10
         ,p_pem_information11    => l_pem_information11
         ,p_pem_information12    => l_pem_information12
         ,p_pem_information13    => l_pem_information13
         ,p_pem_information14    => l_pem_information14
         ,p_pem_information15    => l_pem_information15
         ,p_pem_information16    => l_pem_information16
         ,p_pem_information17    => l_pem_information17
         ,p_pem_information18    => l_pem_information18
         ,p_pem_information19    => l_pem_information19
         ,p_pem_information20    => l_pem_information20
         ,p_pem_information21    => l_pem_information21
         ,p_pem_information22    => l_pem_information22
         ,p_pem_information23    => l_pem_information23
         ,p_pem_information24    => l_pem_information24
         ,p_pem_information25    => l_pem_information25
         ,p_pem_information26    => l_pem_information26
         ,p_pem_information27    => l_pem_information27
         ,p_pem_information28    => l_pem_information28
         ,p_pem_information29    => l_pem_information29
         ,p_pem_information30    => l_pem_information30
         ,p_calling_procedure    => l_procedure
	 ,p_message_name         => g_message_name
	 ,p_token_name           => g_token_name
	 ,p_token_value          => g_token_value);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);

END check_prev_emp_update;

BEGIN

  g_package := 'per_in_prev_employer_leg_hook.';

END  per_in_prev_employer_leg_hook;

/
