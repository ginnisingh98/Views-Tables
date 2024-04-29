--------------------------------------------------------
--  DDL for Package Body PER_IN_PERSON_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_PERSON_LEG_HOOK" AS
/* $Header: peinlhpe.pkb 120.10.12010000.2 2009/06/15 08:40:34 lnagaraj ship $ */

g_package CONSTANT VARCHAR2(100) := 'per_in_person_leg_hook.';
g_debug BOOLEAN;
p_token_name pay_in_utils.char_tab_type;
p_token_value pay_in_utils.char_tab_type;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_PAN_FORMAT                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the validity of the format of the PAN    --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information4          VARCHAR2                --
--                : p_per_information_category  VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------

PROCEDURE validate_pan_format(
                             p_per_information_category IN VARCHAR2
                            ,p_per_information4         IN VARCHAR2
                             ) IS
BEGIN

NULL ;

END  validate_pan_format;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PAN_AND_PAN_AF                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks that either the PAN field or the PAN Applied --
--                  For field is null.                                  --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category  VARCHAR2                --
--                  p_per_information4          VARCHAR2                --
--                : p_per_information5          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------

PROCEDURE check_pan_and_pan_af(
         p_per_information_category IN VARCHAR2
        ,p_per_information4         IN VARCHAR2 DEFAULT NULL
        ,p_per_information5         IN VARCHAR2 DEFAULT NULL
        ) IS
BEGIN

NULL;

END check_pan_and_pan_af;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_UNIQUE_NUMBER_INSERT                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the create_employee user hook.                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category       VARCHAR2           --
--                : p_business_group_id              NUMBER             --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------


 PROCEDURE check_unique_number_insert(
          p_per_information_category IN VARCHAR2
         ,p_business_group_id        IN NUMBER
         ,p_per_information4         IN VARCHAR2 DEFAULT NULL
         ,p_per_information8         IN VARCHAR2 DEFAULT NULL
         ,p_per_information9         IN VARCHAR2 DEFAULT NULL
         ,p_per_information10        IN VARCHAR2 DEFAULT NULL
         ,p_per_information11        IN VARCHAR2 DEFAULT NULL
         ,p_per_information12        IN VARCHAR2 DEFAULT NULL
         ,p_per_information13        IN VARCHAR2 DEFAULT NULL
        ) IS
BEGIN

NULL ;

END check_unique_number_insert;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_UNIQUE_NUMBER_UPDATE                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the update_person user hook.                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date                 DATE               --
--                : p_per_information_category       VARCHAR2           --
--                : p_person_id                      NUMBER             --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------

PROCEDURE check_unique_number_update(
         p_effective_date           IN DATE
        ,p_per_information_category IN VARCHAR2
        ,p_person_id                IN NUMBER
        ,p_per_information4         IN VARCHAR2 DEFAULT NULL
        ,p_per_information8         IN VARCHAR2 DEFAULT NULL
        ,p_per_information9         IN VARCHAR2 DEFAULT NULL
        ,p_per_information10        IN VARCHAR2 DEFAULT NULL
        ,p_per_information11        IN VARCHAR2 DEFAULT NULL
        ,p_per_information12        IN VARCHAR2 DEFAULT NULL
        ,p_per_information13        IN VARCHAR2 DEFAULT NULL
        ) IS
BEGIN

NULL ;

END check_unique_number_update;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EMPLOYEE                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_type_id                 NUMBER             --
--                : p_per_information_category       VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_hire_date                      DATE               --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04-Feb-05  lnagaraj    Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------
PROCEDURE check_employee(p_person_type_id           IN NUMBER
                        ,p_per_information_category IN VARCHAR2
                        ,p_per_information7         IN VARCHAR2
                        ,p_hire_date                IN DATE
                         ) IS
BEGIN

NULL ;

END check_employee;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PERSON                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_type_id                 NUMBER             --
--                  p_person_id                      NUMBER             --
--                : p_per_information_category       VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_effective_date                 DATE               --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04-Feb-05  lnagaraj    Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------
PROCEDURE check_person(p_person_id                IN NUMBER
                      ,p_person_type_id           IN NUMBER
                      ,p_per_information_category IN VARCHAR2
                      ,p_per_information7         IN VARCHAR2
                      ,p_effective_date           IN DATE
                      ) IS
BEGIN

NULL;

END check_person;




--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHK_PERSON_TYPE                                     --
-- Type           : Function                                            --
-- Access         : Public                                             --
-- Description    : Returns true/false IF p_code is a valid Person Type --
-- Parameters     :                                                     --
--             IN : p_code VARCHAR2                                     --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this function                    --
--------------------------------------------------------------------------
FUNCTION chk_person_type (p_code in VARCHAR2)
RETURN BOOLEAN
IS
   TYPE t_pt_tbl  IS TABLE OF HR_LOOKUPS.LOOKUP_CODE%TYPE index by binary_integer;
   l_person_type         t_pt_tbl;
   l_loop_count          NUMBER ;
   l_procedure           VARCHAR2(100);
   l_message             VARCHAR2(250);

BEGIN

  l_procedure := g_package||'chk_person_type';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('p_code',p_code);
   END IF;

-- Change here in case any new PTs to be included

   l_person_type(1)    := 'EMP';
   l_person_type(2)    := 'EX_EMP';
   l_person_type(3)    := 'APL_EX_EMP';
   l_person_type(4)    := 'EMP_APL';
   l_person_type(5)    := 'EX_EMP_APL';
   l_person_type(6)    := 'CWK';

   l_loop_count  := 6;

-- Changes above this only.

  FOR i IN 1..l_loop_count
  LOOP
    IF l_person_type(i) = p_code then
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
      RETURN TRUE;
    END IF;
  END LOOP;
  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
  RETURN FALSE;

END chk_person_type;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_UNIQUE_NUMBER                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number     --
--                                                                      --
-- Parameters                                                           --
--           IN   : p_business_group_id        NUMBER                   --
--           IN   : p_person_id                NUMBER                   --
--           IN   : p_field                    VARCHAR2                 --
--           IN   : p_value                    VARCHAR2                 --
--           OUT  : P_message_name             VARCHAR2                 --
--           OUT  : p_token_name               VARCHAR2                 --
--           OUT  : p_token_value              VARCHAR2                 --
--                                                                      --
--                                                                      --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.1   19/01/06   abhjain    Added check for PAN Ref Number           --
-- 1.2   10/07/07   sivanara   Added check for NSSN(PF Monthly Returns) --
-- 1.3   16/11/07   rsaharay   Added check to check the identifier      --
--                             uniqueness                               --
-- 1.4   15/01/09   lnagaraj   Added FULL HINT in csr_number            --
--------------------------------------------------------------------------

PROCEDURE check_unique_number(p_business_group_id        IN NUMBER
                             ,p_person_id                IN NUMBER
                             ,p_field                    IN VARCHAR2
                             ,p_value                    IN VARCHAR2
                             ,p_message_name             OUT NOCOPY VARCHAR2
                             ,p_token_name               OUT NOCOPY pay_in_utils.char_tab_type
                             ,p_token_value              OUT NOCOPY pay_in_utils.char_tab_type
)
IS

     CURSOR csr_check
     IS
     SELECT NVL(org_information3,'Y') FROM hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    ORG_INFORMATION_CONTEXT = 'PER_IN_STAT_SETUP_DF';

   /* Cursor to fire only when customer sets Uniqueness validation as required at BG level*/
     CURSOR csr_number
     IS
      SELECT /*+ FULL(PER_PEOPLE_F)*/ 1 FROM per_people_f
            WHERE business_group_id = p_business_group_id
            AND per_information_category = 'IN'
                AND (person_id <> p_person_id OR p_person_id is null)
                AND decode(p_field,'PAN',per_information4
                                  ,'PF Number',per_information8
                                  ,'ESI Number',per_information9
                                  ,'Super Annuation Number',per_information10
                                  ,'Group Insurance Number',per_information11
                                  ,'Gratuity Number',per_information12
                                  ,'Pension Number',per_information13
                                  ,'PAN Reference Number',per_information14
				  ,'NSSN',per_information15) = p_value;


  l_count            NUMBER;
  l_check            VARCHAR2(1) := 'Y';
  l_procedure        VARCHAR2(100);
  l_message          VARCHAR2(250);

BEGIN

   l_procedure := g_package||'check_unique_number';
   g_debug := hr_utility.debug_enabled;
   pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_business_group_id',p_business_group_id);
       pay_in_utils.trace('p_person_id        ',p_person_id        );
       pay_in_utils.trace('p_field            ',p_field            );
       pay_in_utils.trace('p_value            ',p_value            );
       pay_in_utils.trace('p_message_name     ',p_message_name     );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

   p_message_name := 'SUCCESS';

   OPEN  csr_check;
   FETCH csr_check INTO l_check;
   CLOSE csr_check;

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('l_check              ',l_check);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

   IF l_check = 'Y' THEN

    OPEN csr_number;
    FETCH csr_number
    INTO  l_count;
    CLOSE csr_number;
    pay_in_utils.set_location(g_debug,l_procedure,20);

    IF l_count <> 0 THEN
      p_message_name := 'PER_IN_NON_UNIQUE_VALUE';
      p_token_name(1) := 'NUMBER_CATEGORY';
      p_token_value(1) := p_field;

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
      RETURN;
    END IF;

   END IF ;

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_message_name        ',p_message_name);
      pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);

END  check_unique_number;




--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PAN_FORMAT                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the validity of the format of the PAN    --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pan                                   VARCHAR2    --
--                : p_pan_af                                VARCHAR2    --
--                : p_panref_number                         VARCHAR2    --
--                : p_message_name                          VARCHAR2    --
--            OUT : p_token_name                            VARCHAR2    --
--                : p_token_value                           VARCHAR2    --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.1   19/01/06   abhjain    Added p_panref_number                    --
-- 1.2   27/01/06   lnagaraj   Modified check for numeric part in PAN   --
--------------------------------------------------------------------------

PROCEDURE check_pan_format( p_pan           IN VARCHAR2
                           ,p_pan_af        IN VARCHAR2
                           ,p_panref_number IN VARCHAR2
                           ,p_message_name  OUT NOCOPY VARCHAR2
                           ,p_token_name    OUT NOCOPY pay_in_utils.char_tab_type
                           ,p_token_value   OUT NOCOPY pay_in_utils.char_tab_type
                            )
IS

  l_num_string           NUMBER ;
  l_char_string          VARCHAR2(5);
  l_char6_9_string       VARCHAR2(4);
  E_INVALID_FORMAT_ERR   EXCEPTION;

  l_procedure        VARCHAR2(100);
  l_message          VARCHAR2(250);

BEGIN
  l_procedure := g_package||'check_pan_format';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_pan          ',p_pan          );
       pay_in_utils.trace('p_pan_af       ',p_pan_af       );
       pay_in_utils.trace('p_panref_number',p_panref_number);
       pay_in_utils.trace('p_message_name ',p_message_name );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  -- PAN format - XXXXX9999X
  -- Check for the length
  IF NOT length(p_pan) = 10 THEN
      p_message_name   := 'PER_IN_INVALID_FORMAT';
      p_token_name(1)  := 'FIELD';
      p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN');
      p_token_name(2)  := 'FORMAT';
      p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_FORMAT');
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      RETURN;
  END IF;

  -- Check for the number part

  BEGIN
    l_num_string :=  substr(p_pan, 6, 4); /*decimal numbers in format '12.3' will still be considered valid, but this shouldn't be the case*/

    l_char6_9_string := substr(p_pan, 6, 4);

     FOR l_count in 1..4 LOOP
    -- Check for the numeric part.
       IF NOT ascii(substr(l_char6_9_string, l_count, 1) ) BETWEEN ASCII('0') AND ASCII('9') THEN
         p_message_name   := 'PER_IN_INVALID_FORMAT';
         p_token_name(1)  := 'FIELD';
         p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN');
         p_token_name(2)  := 'FORMAT';
         p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_FORMAT');

         IF g_debug THEN
           pay_in_utils.trace('**************************************************','********************');
           pay_in_utils.trace('p_message_name        ',p_message_name);
           pay_in_utils.trace('**************************************************','********************');
         END IF;

         pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
         RETURN;
       END IF ;
     END LOOP ;

  EXCEPTION
  WHEN OTHERS THEN
      p_message_name   := 'PER_IN_INVALID_FORMAT';
      p_token_name(1)  := 'FIELD';
      p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN');
      p_token_name(2)  := 'FORMAT';
      p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_FORMAT');

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
      RETURN;
  END;
  --
  --
  -- Check for the alphabatical part
  l_char_string  :=  substr(p_pan, 10, 1)  ;
  IF NOT ascii(l_char_string) BETWEEN ASCII('A') AND ASCII('Z') THEN
      p_message_name   := 'PER_IN_INVALID_FORMAT';
      p_token_name(1)  := 'FIELD';
      p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN');
      p_token_name(2)  := 'FORMAT';
      p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_FORMAT');

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
      RETURN;
  END IF ;
  --
  --
  l_char_string  :=    substr(p_pan,1,5)  ;
  FOR l_count in 1..5 LOOP
    -- Check for the first 5 alphabats
    IF NOT ascii( substr(l_char_string, l_count, 1) ) BETWEEN ASCII('A') AND ASCII('Z') THEN
      p_message_name   := 'PER_IN_INVALID_FORMAT';
      p_token_name(1)  := 'FIELD';
      p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN');
      p_token_name(2)  := 'FORMAT';
      p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_FORMAT');

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
      RETURN;
    END IF ;
  END LOOP ;

  --Checks that either the PAN field or the PAN Applied For field is null.
 IF p_pan IS NOT NULL AND p_pan_af IS NOT NULL THEN
      p_message_name   := 'PER_IN_TWO_FIELD_MISMATCH';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_AF');

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
      RETURN;
  END IF;

  --Checks that either the PAN field or the PAN Ref Number For field is null.
 IF p_pan IS NOT NULL AND p_panref_number IS NOT NULL THEN
      p_message_name   := 'PER_IN_TWO_FIELD_MISMATCH';
      p_token_name(1)  := 'FIELD1';
      p_token_value(1) :=  hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN');
      p_token_name(2)  := 'FIELD2';
      p_token_value(2) :=  hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_REF');

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
      RETURN;
  END IF;
  p_message_name:='SUCCESS';

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_message_name        ',p_message_name);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);


END check_pan_format;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_IN_PERSON_INT                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    :                                                     --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id                 NUMBER          --
--                : p_person_type_id                    NUMBER          --
--                : p_person_id                         NUMBER          --
--                : p_effective_date                    DATE            --
--                : p_pan                               VARCHAR2        --
--                : p_pan_af                            VARCHAR2        --
--                : p_military_status                   VARCHAR2        --
--                : p_resident_status                   VARCHAR2        --
--                : p_pf_number                         VARCHAR2        --
--                : p_esi_number                        VARCHAR2        --
--                : p_sa_number                         VARCHAR2        --
--                : p_group_ins_number                  VARCHAR2        --
--                : p_gratuity_number                   VARCHAR2        --
--                : p_pension_number                    VARCHAR2        --
--                : p_panref_number                     VARCHAR2        --
--                : p_NSSN                              VARCHAR2        --
--            OUT : p_message_name                      VARCHAR2        --
--            OUT : p_token_name                        VARCHAR2        --
--            OUT : p_token_value                       VARCHAR2        --
--                                                                      --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.0   14/12/05   abhjain    Added p_panref_number                    --
-- 1.2   10/07/07   sivanara   Added parameter p_NSSN and code to check --
--                             NSSN PF Monthly Returns) format          --
--------------------------------------------------------------------------

PROCEDURE check_in_person_int
        (p_business_group_id        IN NUMBER
        ,p_person_type_id           IN NUMBER
        ,p_person_id                IN NUMBER
        ,p_effective_date           IN DATE
        ,p_pan                      IN VARCHAR2
        ,p_pan_af                   IN VARCHAR2
        ,p_military_status          IN VARCHAR2
        ,p_resident_status          IN VARCHAR2
        ,p_pf_number                IN VARCHAR2
        ,p_esi_number               IN VARCHAR2
        ,p_sa_number                IN VARCHAR2
        ,p_group_ins_number         IN VARCHAR2
        ,p_gratuity_number          IN VARCHAR2
        ,p_pension_number           IN VARCHAR2
        ,p_panref_number            IN VARCHAR2
	,p_NSSN                     IN VARCHAR2
        ,p_message_name             OUT NOCOPY VARCHAR2
        ,p_token_name               OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value              OUT NOCOPY pay_in_utils.char_tab_type
        )
IS

  CURSOR csr_pt
  IS
   SELECT system_person_type
   FROM   per_person_types
   WHERE  business_group_id = p_business_group_id
   AND    person_type_id = p_person_type_id;

  CURSOR csr_ptu
  IS
  SELECT ppt.system_person_type
    FROM per_person_type_usages_f pptu
        ,per_person_types   ppt
  WHERE  pptu.person_type_id  = ppt.person_type_id
    AND  pptu.person_id       = p_person_id
    AND  ppt.business_group_id = p_business_group_id
    AND  p_effective_date BETWEEN pptu.effective_start_date
    AND  pptu.effective_end_date;

  l_person_type         per_person_types.system_person_type%TYPE;
  l_value               hr_lookups.meaning%TYPE;
  l_pan_af              hr_lookups.lookup_code%TYPE;
  l_military_status     hr_lookups.lookup_code%TYPE;
  l_resident_status     hr_lookups.lookup_code%TYPE;
  l_procedure           VARCHAR2(100);
  l_message             VARCHAR2(250);


BEGIN



   l_procedure := g_package||'check_in_person_int';
   g_debug := hr_utility.debug_enabled;
   pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
        hr_utility.trace ('IN Legislation not installed. Not performing the validations');
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
        RETURN;
   END IF;

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_business_group_id ',p_business_group_id );
       pay_in_utils.trace('p_person_type_id    ',p_person_type_id    );
       pay_in_utils.trace('p_person_id         ',p_person_id         );
       pay_in_utils.trace('p_effective_date    ',p_effective_date    );
       pay_in_utils.trace('p_pan               ',p_pan               );
       pay_in_utils.trace('p_pan_af            ',p_pan_af            );
       pay_in_utils.trace('p_military_status   ',p_military_status   );
       pay_in_utils.trace('p_resident_status   ',p_resident_status   );
       pay_in_utils.trace('p_pf_number         ',p_pf_number         );
       pay_in_utils.trace('p_esi_number        ',p_esi_number        );
       pay_in_utils.trace('p_sa_number         ',p_sa_number         );
       pay_in_utils.trace('p_group_ins_number  ',p_group_ins_number  );
       pay_in_utils.trace('p_gratuity_number   ',p_gratuity_number   );
       pay_in_utils.trace('p_pension_number    ',p_pension_number    );
       pay_in_utils.trace('p_panref_number     ',p_panref_number     );
       pay_in_utils.trace('p_NSSN              ',p_NSSN              );
       pay_in_utils.trace('p_message_name      ',p_message_name      );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

--
-- Check for mandatory arguments
--
   IF p_person_id IS NULL THEN
     --
     -- This means we are calling from insert
     --
     IF p_person_type_id IS NOT NULL THEN
        OPEN csr_pt ;
        FETCH csr_pt INTO l_person_type;
        IF csr_pt%NOTFOUND THEN
          p_message_name := 'PER_IN_INVALID_LOOKUP_VALUE';
          p_token_name(1) := 'VALUE';
          p_token_value(1) := p_person_type_id;
          p_token_name(2) := 'FIELD';
          p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PERSON_TYPE');

          IF g_debug THEN
             pay_in_utils.trace('p_message_name        ',p_message_name);
          END IF;

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
          RETURN;
        END IF ;
     END IF ;
  ELSE
    --
    -- This means we are updating
    --
    IF p_person_type_id IS NULL THEN
        p_message_name := 'HR_7207_API_MANDATORY_ARG';
        p_token_name(1) := 'API_NAME';
        p_token_value(1) := l_procedure;
        p_token_name(2) := 'ARGUMENT';
        p_token_value(2) := 'P_PERSON_TYPE_ID';

        IF g_debug THEN
           pay_in_utils.trace('**************************************************','********************');
           pay_in_utils.trace('p_message_name        ',p_message_name);
           pay_in_utils.trace('**************************************************','********************');
        END IF;

        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
        RETURN ;
    ELSE
        OPEN csr_ptu ;
        FETCH csr_ptu INTO l_person_type;
        IF csr_ptu%NOTFOUND THEN
          CLOSE csr_ptu;
          p_message_name := 'PER_IN_INVALID_LOOKUP_VALUE';
          p_token_name(1) := 'VALUE';
          p_token_value(1) := p_person_type_id;
          p_token_name(2) := 'FIELD';
          p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PERSON_TYPE');

          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name        ',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
          RETURN ;
        ELSE
          CLOSE csr_ptu;
        END IF;
     END IF ;
   END IF;
--
-- Proceed with validations only if it is a approved person type
--
   IF NOT chk_person_type (l_person_type)

   THEN
     IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_message_name        ',p_message_name);
        pay_in_utils.trace('**************************************************','********************');
     END IF;

     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 60);
     RETURN ;
   END IF;

--
-- Check Mandatory Arguments
--
   IF p_resident_status IS NULL
   THEN

      p_message_name := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'API_NAME';
          p_token_value(1) := l_procedure;
          p_token_name(2) := 'ARGUMENT';
          p_token_value(2) := 'P_RESIDENT_STATUS';

          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name        ',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 70);
          RETURN;
   END IF;

--
-- Check valid value from lookup

  IF (p_pan_af IS NOT NULL )THEN
   l_value := hr_general.decode_lookup('YES_NO',p_pan_af);
   IF l_value IS NULL THEN

          p_message_name := 'PER_IN_INVALID_LOOKUP_VALUE';
          p_token_name(1) := 'VALUE';
          p_token_value(1) := p_pan_af;
          p_token_name(2) := 'FIELD';
          p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_AF');

          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name        ',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 80);
          RETURN;
   END IF;
 END IF;



IF (p_military_status IS NOT NULL )THEN
l_value := hr_general.decode_lookup('YES_NO',p_military_status);
   IF l_value IS NULL THEN

          p_message_name := 'PER_IN_INVALID_LOOKUP_VALUE';
          p_token_name(1) := 'VALUE';
          p_token_value(1) := p_military_status;
          p_token_name(2) := 'FIELD';
          p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','EX_SERVICE');

          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name        ',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 90);
          RETURN;
    END IF;
  END IF;


      l_value := hr_general.decode_lookup('IN_RESIDENTIAL_STATUS',p_resident_status);

        IF l_value IS NULL THEN
          p_message_name := 'PER_IN_INVALID_LOOKUP_VALUE';
          p_token_name(1) := 'VALUE';
          p_token_value(1) := p_resident_status;
          p_token_name(2) := 'FIELD';
          p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','RESIDENTIAL_STATUS');

          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name        ',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 100);
          RETURN;

  END IF ;

--
-- Validate PAN Number

   check_pan_format( p_pan           => p_pan
                    ,p_pan_af        => p_pan_af
                    ,p_panref_number => p_panref_number
                    ,p_message_name  => p_message_name
                    ,p_token_name    => p_token_name
                    ,p_token_value   => p_token_value
                     );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 110);
       RETURN;
    END IF;


-- Check for the NSSN Format
  IF NOT length(p_NSSN) = 14 THEN
      p_message_name   := 'PER_IN_INVALID_FORMAT';
      p_token_name(1)  := 'FIELD';
      p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','NSSN');
      p_token_name(2)  := 'FORMAT';
      p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','NSSN_FORMAT');
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 115);

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      RETURN;
  END IF;
IF instr(p_NSSN,'.') > 0 THEN
p_message_name   := 'PER_IN_INVALID_FORMAT';
      p_token_name(1)  := 'FIELD';
      p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','NSSN');
      p_token_name(2)  := 'FORMAT';
      p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','NSSN_FORMAT');
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 115);

      IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name        ',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
      END IF;

      RETURN;
END IF;
--
-- Check Uniqueness
--


   -- IF p_pan IS NOT NULL THEN

    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'PAN'
             ,p_value              => p_pan
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

   -- END IF;

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 120);
       RETURN;
    END IF;

    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'PF Number'
             ,p_value              => p_pf_number
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 130);
       RETURN;
    END IF;


    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'ESI Number'
             ,p_value              => p_esi_number
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 140);
       RETURN;
    END IF;

    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'Super Annuation Number'
             ,p_value              => p_sa_number
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
       RETURN;
    END IF;

    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'Group Insurance Number'
             ,p_value              => p_group_ins_number
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 160);
       RETURN;
    END IF;

    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'Pension Number'
             ,p_value              => p_pension_number
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 170);
       RETURN;
    END IF;

    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'Gratuity Number'
             ,p_value              => p_gratuity_number
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 180);
       RETURN;
    END IF;

    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'PAN Reference Number'
             ,p_value              => p_panref_number
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 190);
       RETURN;
    END IF;

    --Check uniqueness for the PF National Social Security Number
    check_unique_number
             (
              p_business_group_id  => p_business_group_id
             ,p_person_id          => p_person_id
             ,p_field              => 'NSSN'
             ,p_value              => p_NSSN
             ,p_message_name       => p_message_name
             ,p_token_name         => p_token_name
             ,p_token_value        => p_token_value
             );

    IF p_message_name <> 'SUCCESS' then

       IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name        ',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 130);
       RETURN;
    END IF;

    IF g_debug THEN
       pay_in_utils.trace('p_message_name        ',p_message_name);
    END IF;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 200);


END check_in_person_int;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_IN_PERSON_INSERT                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the create_employee user hook.                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category       VARCHAR2           --
--                : p_business_group_id              NUMBER             --
--                : p_person_type_id                 NUMBER             --
--                : p_hire_date                      DATE               --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information5               VARCHAR2           --
--                : p_per_information6               VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                : p_per_information14              VARCHAR2           --
--                : p_per_information15              VARCHAR2           --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.1   14/12/05   abhjain    Added p_per_information14                --
-- 1.2   10/07/07   sivanara   Added parameter p_per_information15 for  --
--                             NSSN(PF Monthly Retunrs).                --
--------------------------------------------------------------------------

PROCEDURE check_in_person_insert
        (
         p_per_information_category IN VARCHAR2
        ,p_business_group_id        IN NUMBER
        ,p_person_type_id           IN NUMBER
        ,p_hire_date                IN DATE
        ,p_per_information4         IN VARCHAR2
        ,p_per_information5         IN VARCHAR2
        ,p_per_information6         IN VARCHAR2
        ,p_per_information7         IN VARCHAR2
        ,p_per_information8         IN VARCHAR2
        ,p_per_information9         IN VARCHAR2
        ,p_per_information10        IN VARCHAR2
        ,p_per_information11        IN VARCHAR2
        ,p_per_information12        IN VARCHAR2
        ,p_per_information13        IN VARCHAR2
        ,p_per_information14        IN VARCHAR2
        ,p_per_information15        IN VARCHAR2
        )

IS
   l_procedure    VARCHAR2(100);
   l_message      VARCHAR2(250);
   p_message_name VARCHAR2(100);
   p_person_id    NUMBER := NULL;


BEGIN

   l_procedure := g_package||'check_in_person_insert';
   g_debug := hr_utility.debug_enabled;
   pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_per_information_category',p_per_information_category);
       pay_in_utils.trace('p_business_group_id       ',p_business_group_id       );
       pay_in_utils.trace('p_person_type_id          ',p_person_type_id          );
       pay_in_utils.trace('p_hire_date               ',p_hire_date               );
       pay_in_utils.trace('p_per_information4        ',p_per_information4        );
       pay_in_utils.trace('p_per_information5        ',p_per_information5        );
       pay_in_utils.trace('p_per_information6        ',p_per_information6        );
       pay_in_utils.trace('p_per_information7        ',p_per_information7        );
       pay_in_utils.trace('p_per_information8        ',p_per_information8        );
       pay_in_utils.trace('p_per_information9        ',p_per_information9        );
       pay_in_utils.trace('p_per_information10       ',p_per_information10       );
       pay_in_utils.trace('p_per_information11       ',p_per_information11       );
       pay_in_utils.trace('p_per_information12       ',p_per_information12       );
       pay_in_utils.trace('p_per_information13       ',p_per_information13       );
       pay_in_utils.trace('p_per_information14       ',p_per_information14       );
       pay_in_utils.trace('p_per_information15       ',p_per_information15       );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

   p_message_name := 'SUCCESS';
   IF p_per_information_category <> 'IN' then
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
      RETURN;
   END IF;

    check_in_person_int
        (p_business_group_id        => p_business_group_id
        ,p_person_type_id           => p_person_type_id
        ,p_person_id                => p_person_id
        ,p_effective_date           => p_hire_date
        ,p_pan                      => p_per_information4
        ,p_pan_af                   => p_per_information5
        ,p_military_status          => p_per_information6
        ,p_resident_status          => p_per_information7
        ,p_pf_number                => p_per_information8
        ,p_esi_number               => p_per_information9
        ,p_sa_number                => p_per_information10
        ,p_group_ins_number         => p_per_information11
        ,p_gratuity_number          => p_per_information12
        ,p_pension_number           => p_per_information13
        ,p_panref_number            => p_per_information14
	,p_NSSN                     => p_per_information15
        ,p_message_name             => p_message_name
        ,p_token_name               => p_token_name
        ,p_token_value              => p_token_value
        );

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
   IF p_message_name <> 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(800,p_message_name, p_token_name, p_token_value);
   ELSE
      pay_in_utils.raise_message(801,p_message_name, p_token_name, p_token_value);
   END IF;

END check_in_person_insert;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_IN_PERSON_UPDATE                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the create_employee user hook.                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category       VARCHAR2           --
--                : p_person_id                      NUMBER             --
--                : p_effective_date                 DATE               --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information5               VARCHAR2           --
--                : p_per_information6               VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                : p_per_information14              VARCHAR2           --
--                : p_per_information15              VARCHAR2           --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.1   14/12/05   abhjain    Added p_per_information14                --
-- 1.2   10/07/07   sivanara   Added parameter p_per_information15 for  --
--                             NSSN(PF Monthly Retunrs).                --
--------------------------------------------------------------------------

PROCEDURE check_in_person_update
        (
         p_per_information_category IN VARCHAR2
        ,p_person_type_id           IN NUMBER
        ,p_person_id                IN NUMBER
        ,p_effective_date           IN DATE
        ,p_per_information4         IN VARCHAR2
        ,p_per_information5         IN VARCHAR2
        ,p_per_information6         IN VARCHAR2
        ,p_per_information7         IN VARCHAR2
        ,p_per_information8         IN VARCHAR2
        ,p_per_information9         IN VARCHAR2
        ,p_per_information10        IN VARCHAR2
        ,p_per_information11        IN VARCHAR2
        ,p_per_information12        IN VARCHAR2
        ,p_per_information13        IN VARCHAR2
        ,p_per_information14        IN VARCHAR2
        ,p_per_information15        IN VARCHAR2
        )


IS
       l_procedure               VARCHAR2(100);
       p_message_name            VARCHAR2(100);
       l_business_group_id       per_all_people_f.business_group_id%TYPE;
       l_message   VARCHAR2(250);

   CURSOR csr_person IS
      SELECT per_information4
            ,per_information5
            ,per_information6
            ,per_information7
            ,per_information8
            ,per_information9
            ,per_information10
            ,per_information11
            ,per_information12
            ,per_information13
            ,per_information14
            ,per_information15
            ,business_group_id
      FROM  per_people_f
      WHERE p_effective_date BETWEEN effective_start_date
                             AND effective_end_date
      AND   person_id = p_person_id;

   l_per_information4      per_all_people_f.per_information4%TYPE;
   l_per_information5      per_all_people_f.per_information5%TYPE;
   l_per_information6      per_all_people_f.per_information6%TYPE;
   l_per_information7      per_all_people_f.per_information7%TYPE;
   l_per_information8      per_all_people_f.per_information8%TYPE;
   l_per_information9      per_all_people_f.per_information9%TYPE;
   l_per_information10     per_all_people_f.per_information10%TYPE;
   l_per_information11     per_all_people_f.per_information11%TYPE;
   l_per_information12     per_all_people_f.per_information12%TYPE;
   l_per_information13     per_all_people_f.per_information13%TYPE;
   l_per_information14     per_all_people_f.per_information14%TYPE;
   l_per_information15     per_all_people_f.per_information15%TYPE;

BEGIN

   l_procedure := g_package||'check_in_person_update';
   g_debug := hr_utility.debug_enabled;
   pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_per_information_category',p_per_information_category);
       pay_in_utils.trace('p_person_type_id          ',p_person_type_id          );
       pay_in_utils.trace('p_person_id               ',p_person_id               );
       pay_in_utils.trace('p_effective_date          ',p_effective_date          );
       pay_in_utils.trace('p_per_information4        ',p_per_information4        );
       pay_in_utils.trace('p_per_information5        ',p_per_information5        );
       pay_in_utils.trace('p_per_information6        ',p_per_information6        );
       pay_in_utils.trace('p_per_information7        ',p_per_information7        );
       pay_in_utils.trace('p_per_information8        ',p_per_information8        );
       pay_in_utils.trace('p_per_information9        ',p_per_information9        );
       pay_in_utils.trace('p_per_information10       ',p_per_information10       );
       pay_in_utils.trace('p_per_information11       ',p_per_information11       );
       pay_in_utils.trace('p_per_information12       ',p_per_information12       );
       pay_in_utils.trace('p_per_information13       ',p_per_information13       );
       pay_in_utils.trace('p_per_information14       ',p_per_information14       );
       pay_in_utils.trace('p_per_information15       ',p_per_information15       );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

   p_message_name := 'SUCCESS';

   IF p_per_information_category <> 'IN' then
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
      RETURN;
   END IF;

   OPEN csr_person;
   FETCH csr_person
   INTO  l_per_information4
        ,l_per_information5
        ,l_per_information6
        ,l_per_information7
        ,l_per_information8
        ,l_per_information9
        ,l_per_information10
        ,l_per_information11
        ,l_per_information12
        ,l_per_information13
        ,l_per_information14
        ,l_per_information15
        ,l_business_group_id;
   CLOSE csr_person;

   IF NVL (p_per_information4,'X') <> hr_api.g_varchar2 THEN
      l_per_information4 := p_per_information4;
   END IF;

   IF NVL(p_per_information5,'X') <> hr_api.g_varchar2 THEN
      l_per_information5 := p_per_information5;
   END IF;

   IF p_per_information6 <> hr_api.g_varchar2 THEN
      l_per_information6 := p_per_information6;
   END IF;

   IF p_per_information7 <> hr_api.g_varchar2 THEN
      l_per_information7 := p_per_information7;
   END IF;

   IF p_per_information8 <> hr_api.g_varchar2 THEN
      l_per_information8 := p_per_information8;
   END IF;

   IF p_per_information9 <> hr_api.g_varchar2 THEN
      l_per_information9 := p_per_information9;
   END IF;

   IF p_per_information10 <> hr_api.g_varchar2 THEN
      l_per_information10 := p_per_information10;
   END IF;

   IF p_per_information11 <> hr_api.g_varchar2 THEN
      l_per_information11 := p_per_information11;
   END IF;

   IF p_per_information12 <> hr_api.g_varchar2 THEN
      l_per_information12 := p_per_information12;
   END IF;

   IF p_per_information13 <> hr_api.g_varchar2 THEN
      l_per_information13 := p_per_information13;
   END IF;

   IF NVL(p_per_information14,'X') <> hr_api.g_varchar2 THEN
      l_per_information14 := p_per_information14;
   END IF;

   IF NVL(p_per_information15,'X') <> hr_api.g_varchar2 THEN
      l_per_information15 := p_per_information15;
   END IF;

    check_in_person_int
        (p_business_group_id        => l_business_group_id
        ,p_person_type_id           => p_person_type_id
        ,p_person_id                => p_person_id
        ,p_effective_date           => p_effective_date
        ,p_pan                      => l_per_information4
        ,p_pan_af                   => l_per_information5
        ,p_military_status          => l_per_information6
        ,p_resident_status          => l_per_information7
        ,p_pf_number                => l_per_information8
        ,p_esi_number               => l_per_information9
        ,p_sa_number                => l_per_information10
        ,p_group_ins_number         => l_per_information11
        ,p_gratuity_number          => l_per_information12
        ,p_pension_number           => l_per_information13
        ,p_panref_number            => l_per_information14
	,p_NSSN                     => l_per_information15
        ,p_message_name             => p_message_name
        ,p_token_name               => p_token_name
        ,p_token_value              => p_token_value
        );

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
   IF p_message_name <> 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(800,p_message_name, p_token_name, p_token_value);
   ELSE
      pay_in_utils.raise_message(801,p_message_name, p_token_name, p_token_value);
   END IF;

END check_in_person_update;


END  per_in_person_leg_hook;

/
