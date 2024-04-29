--------------------------------------------------------
--  DDL for Package Body PER_IN_ENTRY_VALUE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_ENTRY_VALUE_LEG_HOOK" AS
/* $Header: peinlhee.pkb 120.6 2008/03/14 13:41:43 rsaharay ship $ */
--
-- Globals
--
g_package         CONSTANT VARCHAR2(100) := 'per_in_entry_value_leg_hook.' ;
g_debug           BOOLEAN ;
g_message_name    VARCHAR2(30);
g_token_name      pay_in_utils.char_tab_type;
g_token_value     pay_in_utils.char_tab_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE_INT                               --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                              --
-- Description    : Internal Procedure for IN localization              --
-- Parameters     :                                                     --
--             IN : p_effective_date          DATE			--
--                  p_element_entry_id        NUMBER                    --
--                  p_effective_start_date    DATE                      --
--                  p_effective_end_date      DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--             OUT:							--
--                  p_message_name            VARCHAR2                  --
--                  p_token_name              PL/SQL table              --
--                  p_token_value             PL/SQL table              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   07-Oct-04  lnagaraj 3866814  Created this procedure            --
-- 1.1   17-Nov-04  aaagarwa 3997410  Added call to check_gratuity      --
--------------------------------------------------------------------------
PROCEDURE check_entry_value_int(p_effective_date       IN DATE
                               ,p_element_entry_id     IN NUMBER
		               ,p_effective_start_date IN DATE
		               ,p_effective_end_date   IN DATE
			       ,p_calling_procedure    IN VARCHAR2
			       ,p_message_name         OUT NOCOPY VARCHAR2
                               ,p_token_name           OUT NOCOPY pay_in_utils.char_tab_type
                               ,p_token_value          OUT NOCOPY pay_in_utils.char_tab_type
                              )
  IS
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(250);
BEGIN
  l_procedure := g_package||'check_entry_value_int';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_date      ',p_effective_date      );
       pay_in_utils.trace('p_element_entry_id    ',p_element_entry_id    );
       pay_in_utils.trace('p_effective_start_date',p_effective_start_date);
       pay_in_utils.trace('p_effective_end_date  ',p_effective_end_date  );
       pay_in_utils.trace('p_calling_procedure   ',p_calling_procedure   );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  pay_in_utils.null_message(g_token_name, g_token_value);
  g_message_name := 'SUCCESS';

--
-- Code for Checking element entries
--
   per_in_perquisite_pkg.check_element_entry
             (p_effective_date          => p_effective_date
             ,p_element_entry_id        => p_element_entry_id
             ,p_effective_start_date    => p_effective_start_date
	     ,p_effective_end_date      => p_effective_end_date
             ,p_calling_procedure       => p_calling_procedure
             ,p_message_name            => g_message_name
             ,p_token_name              => g_token_name
             ,p_token_value             => g_token_value);

   pay_in_utils.set_location(g_debug,l_procedure,20);
   IF g_message_name <> 'SUCCESS' then
      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('g_message_name        ',g_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
      RETURN;
   END IF;

   pay_in_termination_pkg.check_gratuity
             (p_effective_date          => p_effective_date
             ,p_element_entry_id        => p_element_entry_id
             ,p_calling_procedure       => p_calling_procedure
             ,p_message_name            => g_message_name
             ,p_token_name              => g_token_name
             ,p_token_value             => g_token_value);
  --
   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('g_message_name        ',g_message_name);
      pay_in_utils.trace('**************************************************','********************');
   END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END check_entry_value_int;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure for IN localization                       --
-- Parameters     :                                                     --
--             IN : p_effective_date          DATE			--
--                  p_element_entry_id        NUMBER                    --
--                  p_effective_start_date    DATE                      --
--                  p_effective_end_date      DATE                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   07-Oct-04  lnagaraj 3839878  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE check_entry_value(p_effective_date       IN DATE
                           ,p_element_entry_id     IN NUMBER
		           ,p_effective_start_date IN DATE
		           ,p_effective_end_date   IN DATE
		           )
 IS
  l_procedure    VARCHAR2(100);
  l_message      VARCHAR2(250);
  --

--
BEGIN
--
  l_procedure := g_package||'check_entry_value';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_date      ',p_effective_date      );
       pay_in_utils.trace('p_element_entry_id    ',p_element_entry_id    );
       pay_in_utils.trace('p_effective_start_date',p_effective_start_date);
       pay_in_utils.trace('p_effective_end_date  ',p_effective_end_date  );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  g_message_name := 'SUCCESS';
  pay_in_utils.null_message (g_token_name, g_token_value);
  --
  -- Check whether PAY is installed for India Localization
  --
  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN

     pay_in_utils.set_location(g_debug,l_procedure,20);

     check_entry_value_int(p_effective_date    => p_effective_date
                          ,p_element_entry_id  =>   p_element_entry_id
		          ,p_effective_start_date=> p_effective_start_date
		          ,p_effective_end_date =>  p_effective_end_date
			  ,p_calling_procedure =>  l_procedure
			  ,p_message_name   =>  g_message_name
                          ,p_token_name     => g_token_name
                          ,p_token_value    => g_token_value
                           );
  --
   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('g_message_name      ',g_message_name      );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

     IF g_message_name <> 'SUCCESS' THEN
        pay_in_utils.set_location(g_debug,l_procedure,30);
        pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);
     END IF;

  END IF ;
  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

  END check_entry_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE_DEL                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure for IN localization                       --
-- Parameters     :                                                     --
--             IN : p_effective_date          DATE			--
--                  p_element_entry_id        NUMBER                    --
--                  p_effective_start_date    DATE                      --
--                  p_effective_end_date      DATE                      --
--                  p_assignment_id_o         NUMBER                    --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   23-Oct-07  sivanara 6469684 Created this procedure             --
-- 2.0   25-oct-07  sivanara 6469684 Added parameter p_element_type_id_o--
-- 3.0   09-jan-07  sivanara 6391803 Check for Medical and LTC          --
--------------------------------------------------------------------------
  PROCEDURE check_entry_value_del( p_effective_date       IN DATE
                                  ,p_element_entry_id     IN NUMBER
	                          ,p_effective_start_date IN DATE
		                  ,p_effective_end_date   IN DATE
			          ,p_assignment_id_o     IN NUMBER
				  ,p_element_type_id_o    IN NUMBER
		                 )
IS
  l_procedure    VARCHAR2(100);
  l_message      VARCHAR2(250);
  l_element_entry_id NUMBER;
  l_element_name pay_element_types_f.element_name %TYPE;
  l_ele_name     pay_element_types_f.element_name %TYPE;
  l_check_assg_extra_info  NUMBER ;

  CURSOR c_element_name IS
    SELECT pet.element_information1
      FROM pay_element_types_f pet
     WHERE pet.element_type_id = p_element_type_id_o
       AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date;

  --

   CURSOR c_other_loan_element(p_element_name VARCHAR2) IS
    SELECT pee.element_entry_id
      FROM pay_element_types_f pet
          ,pay_element_entries_f pee
     WHERE pet.element_type_id =pee.element_type_id
       AND pee.assignment_id = p_assignment_id_o
       AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
       AND p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
       AND pet.element_information1 = p_element_name;

     CURSOR c_ele_name IS
    SELECT pet.element_name
      FROM pay_element_types_f pet
     WHERE pet.element_type_id = p_element_type_id_o
       AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date;


   CURSOR c_assg_extra_info IS
   SELECT 1
     FROM per_assignment_extra_info pae
    WHERE assignment_id =  p_assignment_id_o
      AND ( (pae.aei_information_category = 'PER_IN_MEDICAL_BILLS' AND pae.aei_information10 = p_element_entry_id)
         OR (pae.aei_information_category = 'PER_IN_MEDICAL_BILLS' AND pae.aei_information11 = p_element_entry_id)
         OR (pae.aei_information_category = 'PER_IN_LTC_BILLS' AND pae.aei_information11 = p_element_entry_id));
--
BEGIN
--
  l_procedure := g_package||'check_entry_value_del';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);


   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_date      ',p_effective_date      );
       pay_in_utils.trace('p_element_entry_id    ',p_element_entry_id    );
       pay_in_utils.trace('p_effective_start_date',p_effective_start_date);
       pay_in_utils.trace('p_effective_end_date  ',p_effective_end_date  );
       pay_in_utils.trace('p_assignment_id_o  ',p_assignment_id_o  );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  g_message_name := 'SUCCESS';
  pay_in_utils.null_message (g_token_name, g_token_value);
  --
  -- Check whether PAY is installed for India Localization
  --
  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN

     pay_in_utils.set_location(g_debug,l_procedure,20);


     OPEN  c_ele_name;
     FETCH c_ele_name INTO l_ele_name;
     CLOSE c_ele_name;


     OPEN c_assg_extra_info ;
     FETCH c_assg_extra_info INTO l_check_assg_extra_info ;
     IF c_assg_extra_info%FOUND THEN
         hr_utility.set_message(800, 'PER_IN_EXTRA_ASSG_INFO_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', l_ele_name);
         hr_utility.raise_error;
     END IF ;
     CLOSE c_assg_extra_info ;

     OPEN c_element_name;
     FETCH c_element_name INTO l_element_name;
     CLOSE c_element_name;


    IF l_element_name = 'Loan at Concessional Rate' THEN

    OPEN c_other_loan_element(l_element_name);
    FETCH c_other_loan_element INTO l_element_entry_id;
    CLOSE c_other_loan_element;

     IF l_element_entry_id IS NULL THEN
       RETURN;
     END IF;

    per_in_perquisite_pkg.check_element_entry
             (p_effective_date          => p_effective_date
             ,p_element_entry_id        => l_element_entry_id
             ,p_effective_start_date    => p_effective_start_date
	     ,p_effective_end_date      => p_effective_end_date
             ,p_calling_procedure       => l_procedure
             ,p_message_name            => g_message_name
             ,p_token_name              => g_token_name
             ,p_token_value             => g_token_value);

   --
     IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('g_message_name      ',g_message_name      );
       pay_in_utils.trace('**************************************************','********************');
     END IF;

     IF g_message_name <> 'SUCCESS' THEN
        pay_in_utils.set_location(g_debug,l_procedure,30);
        pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);
     END IF;
    END IF ;
  END IF ;
  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

  END check_entry_value_del;

  END per_in_entry_value_leg_hook;

/
