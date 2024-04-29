--------------------------------------------------------
--  DDL for Package Body PAY_CN_ENTRY_VALUE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_ENTRY_VALUE_LEG_HOOK" AS
/* $Header: pycnlhee.pkb 120.0.12010000.2 2009/10/01 09:05:21 dduvvuri ship $ */
--
-- Globals
--
g_package         CONSTANT VARCHAR2(100) := 'pay_cn_entry_value_leg_hook.' ;
g_debug           BOOLEAN ;
g_message_name    VARCHAR2(30);
g_token_name      hr_cn_api.char_tab_type;
g_token_value     hr_cn_api.char_tab_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EE_PHF_SI_SETUP                               --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Internal Procedure for CN localization              --
-- Parameters     :                                                     --
--             IN : p_entry_information2   IN VARCHAR2                  --
--                  p_entry_information3   IN VARCHAR2                  --
--                  p_entry_information4   IN VARCHAR2                  --
--                  p_entry_information5   IN VARCHAR2                  --
--                  p_entry_information6   IN VARCHAR2                  --
--                  p_entry_information7   IN VARCHAR2                  --
--                  p_entry_information8   IN VARCHAR2                  --
--                  p_entry_information9   IN VARCHAR2                  --
--                  p_calling_procedure    IN VARCHAR2                  --
--             OUT:                                                     --
--                  p_message_name            VARCHAR2                  --
--                  p_token_name              PL/SQL table              --
--                  p_token_value             PL/SQL table              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   07-Oct-06  abhjain  5563042  Created this procedure            --
-- 1.1   01-oct-09  dduvvuri 8838185  Raised error messages for all the validations --
--------------------------------------------------------------------------
PROCEDURE check_ee_phf_si_setup(
                           p_entry_information2   IN VARCHAR2
                          ,p_entry_information3   IN VARCHAR2
                          ,p_entry_information4   IN VARCHAR2
                          ,p_entry_information5   IN VARCHAR2
                          ,p_entry_information6   IN VARCHAR2
                          ,p_entry_information7   IN VARCHAR2
                          ,p_entry_information8   IN VARCHAR2
                          ,p_entry_information9   IN VARCHAR2
                          ,p_calling_procedure    IN VARCHAR2
                          ,p_message_name         OUT NOCOPY VARCHAR2
                          ,p_token_name           OUT NOCOPY hr_cn_api.char_tab_type
                          ,p_token_value          OUT NOCOPY hr_cn_api.char_tab_type
                        )
IS
   l_procedure VARCHAR2(100);
BEGIN

  l_procedure := g_package||'check_ee_phf_si_setup';
  g_debug := hr_utility.debug_enabled;
  hr_cn_api.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
     hr_utility.trace('====================================================================');
     hr_utility.trace('p_message_name        '||p_message_name);
     hr_utility.trace('====================================================================');
   END IF;

   IF g_debug THEN
       hr_utility.trace('====================================================================');
       hr_utility.trace('p_entry_information2  '||p_entry_information2);
       hr_utility.trace('p_entry_information3  '||p_entry_information3);
       hr_utility.trace('p_entry_information4  '||p_entry_information4);
       hr_utility.trace('p_entry_information5  '||p_entry_information5);
       hr_utility.trace('p_entry_information6  '||p_entry_information6);
       hr_utility.trace('p_entry_information7  '||p_entry_information7);
       hr_utility.trace('p_entry_information8  '||p_entry_information8);
       hr_utility.trace('p_entry_information9  '||p_entry_information9);
       hr_utility.trace('p_calling_procedure   '||p_calling_procedure );
       hr_utility.trace('====================================================================');
   END IF;

   IF (p_entry_information2 IS NOT NULL AND p_entry_information3 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,20);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('EE Rate or Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('EE Percent or Fixed', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information3 IS NOT NULL AND p_entry_information2 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,30);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('EE Percent or Fixed', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('EE Rate or Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information4 IS NOT NULL AND p_entry_information5 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,40);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('ER Rate or Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('ER Percent or Fixed', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information5 IS NOT NULL AND p_entry_information4 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,50);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('ER Percent or Fixed', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('ER Rate or Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information6 = 'FIXED' AND p_entry_information7 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,60);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('EE Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('EE Cont Base Method', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information8 = 'FIXED' AND p_entry_information9 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,70);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('ER Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('ER Cont Base Method', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information7 IS NOT NULL AND p_entry_information6 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,110);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('EE Cont Base Method', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('EE Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information9 IS NOT NULL AND p_entry_information8 IS NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,120);
      p_message_name   := 'HR_374622_DPND_FIELD_ABSENT';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('ER Cont Base Method', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_cn_api.get_dff_tl_value('ER Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information6 <> 'FIXED' AND p_entry_information7 IS NOT NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,80);
      p_message_name   := 'HR_374623_DPND_FIELD_MISMATCH';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('EE Cont Base Method', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'VALUE1';
      p_token_value(2) :=  hr_general.decode_lookup('CN_CONT_BASE_CALC_METHOD', 'FIXED');
      p_token_name(3)  := 'FIELD2';
      p_token_value(3) :=  hr_cn_api.get_dff_tl_value('EE Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

   IF (p_entry_information8 <> 'FIXED' AND p_entry_information9 IS NOT NULL) THEN
      hr_cn_api.set_location(g_debug,l_procedure,90);
      p_message_name   := 'HR_374623_DPND_FIELD_MISMATCH';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_cn_api.get_dff_tl_value('ER Cont Base Method', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');
      p_token_name(2)  := 'VALUE1';
      p_token_value(2) :=  hr_general.decode_lookup('CN_CONT_BASE_CALC_METHOD', 'FIXED');
      p_token_name(3)  := 'FIELD2';
      p_token_value(3) :=  hr_cn_api.get_dff_tl_value('ER Fixed Amount', 'Element Entry Developer DF' , 'CN_PHF AND SI INFORMATION');

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;
      /* Raised error message for bug 8838185 */
            hr_cn_api.raise_message(800
                               ,p_message_name
                               ,p_token_name
                               ,p_token_value);
   END IF;

  hr_cn_api.set_location(g_debug,'Leaving: '||l_procedure,130);
  RETURN;
END check_ee_phf_si_setup;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EFF_DATE                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Internal Procedure for CN localization              --
-- Parameters     :                                                     --
--             IN : p_effective_start_date IN DATE                      --
--                  p_entry_information2   IN VARCHAR2                  --
--                  p_entry_information3   IN VARCHAR2                  --
--                  p_entry_information4   IN VARCHAR2                  --
--                  p_entry_information5   IN VARCHAR2                  --
--                  p_entry_information6   IN VARCHAR2                  --
--                  p_entry_information7   IN VARCHAR2                  --
--                  p_entry_information8   IN VARCHAR2                  --
--                  p_entry_information9   IN VARCHAR2                  --
--                  p_calling_procedure    IN VARCHAR2                  --
--             OUT:                                                     --
--                  p_message_name            VARCHAR2                  --
--                  p_token_name              PL/SQL table              --
--                  p_token_value             PL/SQL table              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   29-Nov-06  abhjain  5686269  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE check_eff_date( p_effective_date       IN DATE
                         ,p_effective_start_date IN DATE
                         ,p_entry_information2   IN VARCHAR2
                         ,p_entry_information3   IN VARCHAR2
                         ,p_entry_information4   IN VARCHAR2
                         ,p_entry_information5   IN VARCHAR2
                         ,p_entry_information6   IN VARCHAR2
                         ,p_entry_information7   IN VARCHAR2
                         ,p_entry_information8   IN VARCHAR2
                         ,p_entry_information9   IN VARCHAR2
                         ,p_calling_procedure    IN VARCHAR2
                         ,p_message_name         OUT NOCOPY VARCHAR2
                         ,p_token_name           OUT NOCOPY hr_cn_api.char_tab_type
                         ,p_token_value          OUT NOCOPY hr_cn_api.char_tab_type
                        )
  IS

   l_procedure VARCHAR2(100);
   l_stat_upd_eff_date DATE := TO_DATE('01-01-2006', 'DD-MM-YYYY');

BEGIN
  l_procedure := g_package||'check_eff_date';
  g_debug := hr_utility.debug_enabled;
  hr_cn_api.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       hr_utility.trace('====================================================================');
       hr_utility.trace('p_effective_start_date'||p_effective_start_date);
       hr_utility.trace('p_entry_information2  '||p_entry_information2  );
       hr_utility.trace('p_entry_information3  '||p_entry_information3  );
       hr_utility.trace('p_entry_information4  '||p_entry_information4  );
       hr_utility.trace('p_entry_information5  '||p_entry_information5  );
       hr_utility.trace('p_entry_information6  '||p_entry_information6  );
       hr_utility.trace('p_entry_information7  '||p_entry_information7  );
       hr_utility.trace('p_entry_information8  '||p_entry_information8  );
       hr_utility.trace('p_entry_information9  '||p_entry_information9  );
       hr_utility.trace('p_calling_procedure   '||p_calling_procedure   );
       hr_utility.trace('====================================================================');
   END IF;

   IF ((p_entry_information2 IS NOT NULL OR
        p_entry_information3 IS NOT NULL OR
        p_entry_information4 IS NOT NULL OR
        p_entry_information5 IS NOT NULL OR
        p_entry_information6 IS NOT NULL OR
        p_entry_information7 IS NOT NULL OR
        p_entry_information8 IS NOT NULL OR
        p_entry_information9 IS NOT NULL ) AND
        p_effective_start_date < l_stat_upd_eff_date) THEN

      hr_cn_api.set_location(g_debug,l_procedure,30);
      p_message_name   := 'HR_374626_EFF_DATE_WRONG';
      p_token_name(1)  := 'DATE';
      p_token_value(1) := fnd_date.date_to_displaydate(l_stat_upd_eff_date);

      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;

      hr_cn_api.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
   END IF;

END check_eff_date;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE_INT                               --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Internal Procedure for CN localization              --
-- Parameters     :                                                     --
--             IN : p_effective_date       IN DATE                      --
--                  p_element_entry_id     IN NUMBER                    --
--                  p_effective_start_date IN DATE                      --
--                  p_effective_end_date   IN DATE                      --
--                  p_entry_information2   IN VARCHAR2                  --
--                  p_entry_information3   IN VARCHAR2                  --
--                  p_entry_information4   IN VARCHAR2                  --
--                  p_entry_information5   IN VARCHAR2                  --
--                  p_entry_information6   IN VARCHAR2                  --
--                  p_entry_information7   IN VARCHAR2                  --
--                  p_entry_information8   IN VARCHAR2                  --
--                  p_entry_information9   IN VARCHAR2                  --
--                  p_calling_procedure    IN VARCHAR2                  --
--             OUT:                                                     --
--                  p_message_name            VARCHAR2                  --
--                  p_token_name              PL/SQL table              --
--                  p_token_value             PL/SQL table              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   07-Oct-06  abhjain  5563042  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE check_entry_value_int(p_effective_date       IN DATE
                               ,p_element_entry_id     IN NUMBER
                               ,p_effective_start_date IN DATE
                               ,p_effective_end_date   IN DATE
                               ,p_entry_information2   IN VARCHAR2
                               ,p_entry_information3   IN VARCHAR2
                               ,p_entry_information4   IN VARCHAR2
                               ,p_entry_information5   IN VARCHAR2
                               ,p_entry_information6   IN VARCHAR2
                               ,p_entry_information7   IN VARCHAR2
                               ,p_entry_information8   IN VARCHAR2
                               ,p_entry_information9   IN VARCHAR2
                               ,p_calling_procedure    IN VARCHAR2
                               ,p_message_name         OUT NOCOPY VARCHAR2
                               ,p_token_name           OUT NOCOPY hr_cn_api.char_tab_type
                               ,p_token_value          OUT NOCOPY hr_cn_api.char_tab_type
                              )
  IS

CURSOR csr_check_element(p_element_entry_id NUMBER
                        ,p_effective_date   DATE)
IS

    SELECT decode(pet.element_name
                 ,'Medical Information', '1'
                 ,'PHF Information', '1'
                 ,'Pension Information', '1'
                 ,'Unemployment Insurance Information', '1'
                 ,'Injury Insurance Information', '2'
                 ,'Maternity Insurance Information', '2'
                 ,'Supplementary Medical Information', '2'
                 ,'Enterprise Annuity Information', '2'
                 ,'0')
          ,pet.element_name
      FROM pay_element_types_f pet
          ,pay_element_entries_f pee
          ,pay_element_classifications pec
     WHERE pet.element_type_id = pee.element_type_id
       AND pee.element_entry_id = p_element_entry_id
       AND pec.classification_id = pet.classification_id
       AND pec.classification_name = 'PHF and SI Information'
       AND pec.legislation_code = 'CN'
       AND pet.legislation_code = 'CN'
       AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
       AND p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

   l_procedure VARCHAR2(100);
   l_check_element NUMBER;
   l_element_name  VARCHAR2(100);

BEGIN
  l_procedure := g_package||'check_entry_value_int';
  g_debug := hr_utility.debug_enabled;
  hr_cn_api.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       hr_utility.trace('====================================================================');
       hr_utility.trace('p_effective_date      '||p_effective_date      );
       hr_utility.trace('p_element_entry_id    '||p_element_entry_id    );
       hr_utility.trace('p_effective_start_date'||p_effective_start_date);
       hr_utility.trace('p_effective_end_date  '||p_effective_end_date  );
       hr_utility.trace('p_entry_information2  '||p_entry_information2  );
       hr_utility.trace('p_entry_information3  '||p_entry_information3  );
       hr_utility.trace('p_entry_information4  '||p_entry_information4  );
       hr_utility.trace('p_entry_information5  '||p_entry_information5  );
       hr_utility.trace('p_entry_information6  '||p_entry_information6  );
       hr_utility.trace('p_entry_information7  '||p_entry_information7  );
       hr_utility.trace('p_entry_information8  '||p_entry_information8  );
       hr_utility.trace('p_entry_information9  '||p_entry_information9  );
       hr_utility.trace('p_calling_procedure   '||p_calling_procedure   );
       hr_utility.trace('====================================================================');
   END IF;
--
-- Code to check if the element will have phf and si further element info enabled
--
   l_check_element := 0;

   OPEN csr_check_element(p_element_entry_id, p_effective_date);
   FETCH csr_check_element INTO l_check_element, l_element_name;
   CLOSE csr_check_element;

   IF (l_check_element = 0) THEN
     hr_cn_api.set_location(g_debug,l_procedure,20);
     hr_cn_api.set_location(g_debug,'Leaving: '||l_procedure,25);
     RETURN;

   ELSIF (l_check_element = 2) THEN

      hr_cn_api.set_location(g_debug,l_procedure,30);
      IF (p_entry_information2 IS NOT NULL OR
          p_entry_information3 IS NOT NULL OR
          p_entry_information4 IS NOT NULL OR
          p_entry_information5 IS NOT NULL OR
          p_entry_information6 IS NOT NULL OR
          p_entry_information7 IS NOT NULL OR
          p_entry_information8 IS NOT NULL OR
          p_entry_information9 IS NOT NULL ) THEN

        p_message_name   := 'HR_374625_WRONG_ELEMENT';
        p_token_name(1)  := 'ELEMENT';
        p_token_value(1) := l_element_name;

        IF g_debug THEN
          hr_utility.trace('====================================================================');
          hr_utility.trace('p_message_name        '||p_message_name);
          hr_utility.trace('====================================================================');
        END IF;
      END IF;

   ELSIF (l_check_element = 1) THEN
       hr_cn_api.set_location(g_debug,l_procedure,30);
       check_ee_phf_si_setup(
                           p_entry_information2   => p_entry_information2
                          ,p_entry_information3   => p_entry_information3
                          ,p_entry_information4   => p_entry_information4
                          ,p_entry_information5   => p_entry_information5
                          ,p_entry_information6   => p_entry_information6
                          ,p_entry_information7   => p_entry_information7
                          ,p_entry_information8   => p_entry_information8
                          ,p_entry_information9   => p_entry_information9
                          ,p_calling_procedure    => l_procedure
                          ,p_message_name         => p_message_name
                          ,p_token_name           => p_token_name
                          ,p_token_value          => p_token_value
                        );
      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;

       check_eff_date(
                       p_effective_date       => p_effective_date
                      ,p_effective_start_date => p_effective_start_date
                      ,p_entry_information2   => p_entry_information2
                      ,p_entry_information3   => p_entry_information3
                      ,p_entry_information4   => p_entry_information4
                      ,p_entry_information5   => p_entry_information5
                      ,p_entry_information6   => p_entry_information6
                      ,p_entry_information7   => p_entry_information7
                      ,p_entry_information8   => p_entry_information8
                      ,p_entry_information9   => p_entry_information9
                      ,p_calling_procedure    => l_procedure
                      ,p_message_name         => p_message_name
                      ,p_token_name           => p_token_name
                      ,p_token_value          => p_token_value
                     );
      IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('p_message_name        '||p_message_name);
        hr_utility.trace('====================================================================');
      END IF;

   END IF;
  hr_cn_api.set_location(g_debug,'Leaving: '||l_procedure,40);
  RETURN;

END check_entry_value_int;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure for CN localization                       --
-- Parameters     :                                                     --
--             IN : p_effective_date       IN DATE                      --
--                  p_element_entry_id     IN NUMBER                    --
--                  p_effective_start_date IN DATE                      --
--                  p_effective_end_date   IN DATE                      --
--                  p_entry_information2   IN VARCHAR2                  --
--                  p_entry_information3   IN VARCHAR2                  --
--                  p_entry_information4   IN VARCHAR2                  --
--                  p_entry_information5   IN VARCHAR2                  --
--                  p_entry_information6   IN VARCHAR2                  --
--                  p_entry_information7   IN VARCHAR2                  --
--                  p_entry_information8   IN VARCHAR2                  --
--                  p_entry_information9   IN VARCHAR2                  --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   07-Oct-06  abhjain  5563042  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE check_entry_value(p_effective_date       IN DATE
                           ,p_element_entry_id     IN NUMBER
                           ,p_effective_start_date IN DATE
                           ,p_effective_end_date   IN DATE
                           ,p_entry_information2   IN VARCHAR2
                           ,p_entry_information3   IN VARCHAR2
                           ,p_entry_information4   IN VARCHAR2
                           ,p_entry_information5   IN VARCHAR2
                           ,p_entry_information6   IN VARCHAR2
                           ,p_entry_information7   IN VARCHAR2
                           ,p_entry_information8   IN VARCHAR2
                           ,p_entry_information9   IN VARCHAR2
                           )
 IS
  l_procedure    VARCHAR2(100);
  --

--
BEGIN
--
  l_procedure := g_package||'check_entry_value';
  g_debug := hr_utility.debug_enabled;
  hr_cn_api.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       hr_utility.trace('====================================================================');
       hr_utility.trace('p_effective_date      '||p_effective_date      );
       hr_utility.trace('p_element_entry_id    '||p_element_entry_id    );
       hr_utility.trace('p_effective_start_date'||p_effective_start_date);
       hr_utility.trace('p_effective_end_date  '||p_effective_end_date  );
       hr_utility.trace('p_entry_information2  '||p_entry_information2  );
       hr_utility.trace('p_entry_information3  '||p_entry_information3  );
       hr_utility.trace('p_entry_information4  '||p_entry_information4  );
       hr_utility.trace('p_entry_information5  '||p_entry_information5  );
       hr_utility.trace('p_entry_information6  '||p_entry_information6  );
       hr_utility.trace('p_entry_information7  '||p_entry_information7  );
       hr_utility.trace('p_entry_information8  '||p_entry_information8  );
       hr_utility.trace('p_entry_information9  '||p_entry_information9  );
       hr_utility.trace('====================================================================');
   END IF;

  g_message_name := 'SUCCESS';
  --
  -- Check whether PAY is installed for China Localization
  --
  IF hr_utility.chk_product_install('Oracle Payroll','CN') THEN

     hr_cn_api.set_location(g_debug,l_procedure,20);

     check_entry_value_int(p_effective_date       => p_effective_date
                          ,p_element_entry_id     => p_element_entry_id
                          ,p_effective_start_date => p_effective_start_date
                          ,p_effective_end_date   => p_effective_end_date
                          ,p_entry_information2   => p_entry_information2
                          ,p_entry_information3   => p_entry_information3
                          ,p_entry_information4   => p_entry_information4
                          ,p_entry_information5   => p_entry_information5
                          ,p_entry_information6   => p_entry_information6
                          ,p_entry_information7   => p_entry_information7
                          ,p_entry_information8   => p_entry_information8
                          ,p_entry_information9   => p_entry_information9
                          ,p_calling_procedure    => l_procedure
                          ,p_message_name         => g_message_name
                          ,p_token_name           => g_token_name
                          ,p_token_value          => g_token_value
                           );
  --
     IF g_debug THEN
        hr_utility.trace('====================================================================');
        hr_utility.trace('g_message_name      '||g_message_name      );
        hr_utility.trace('====================================================================');
     END IF;

     IF g_message_name <> 'SUCCESS' THEN
        hr_cn_api.set_location(g_debug,l_procedure,30);
        hr_cn_api.raise_message(800
                               ,g_message_name
                               ,g_token_name
                               ,g_token_value);
     END IF;

  END IF ;


  hr_cn_api.set_location(g_debug,'Leaving : '||l_procedure, 40);

END check_entry_value;

END pay_cn_entry_value_leg_hook;

/
