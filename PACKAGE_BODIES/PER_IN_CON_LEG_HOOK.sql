--------------------------------------------------------
--  DDL for Package Body PER_IN_CON_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_CON_LEG_HOOK" AS
/* $Header: peinlhco.pkb 120.6.12010000.2 2008/08/06 09:13:39 ubhat ship $ */

   g_package      CONSTANT VARCHAR2(100) := 'per_in_con_leg_hook.';
   g_debug        BOOLEAN;
   p_token_name   pay_in_utils.char_tab_type;
   p_token_value  pay_in_utils.char_tab_type;
   p_message_name VARCHAR2(50);



-- -----------------------------------------------------------------------+
-- Name           : nominee_age_check                                   --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure does the age validation i.e          --+
--                  checks if the guardian details are entered if the   --+
--                  nominee's age is below 18                           --+
-- Parameters     :                                                     --+
--             IN : p_contact_relationship_id   NUMBER                  --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.1   16-May-2005    sukukuma        Created this procedure          --+
--------------------------------------------------------------------------+
-- vbanner, commenting out for bug 4674384.
-- sukukuma,uncommented out for bug 4674384
  PROCEDURE nominee_age_check
   ( p_contact_relationship_id  IN
   PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE)IS
   BEGIN
   NULL ;
   END nominee_age_check;

-- -----------------------------------------------------------------------+
-- Name           : nomination_share_insert_check                       --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--            OUT : N/A                                                 --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
--------------------------------------------------------------------------+

PROCEDURE nomination_share_insert_check
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        )IS

BEGIN
NULL ;
END  nomination_share_insert_check ;


-- -----------------------------------------------------------------------+
-- Name           : nomination_share_update_check                       --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--                  p_contact_extra_info_id    NUMBER                   --+
--            OUT : N/A                                                 --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
--------------------------------------------------------------------------+

PROCEDURE nomination_share_update_check
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_contact_extra_info_id    IN  PER_CONTACT_EXTRA_INFO_F.contact_extra_info_id%TYPE)IS
BEGIN
NULL ;
END nomination_share_update_check;



-- -----------------------------------------------------------------------+
-- Name           : check_nominee_age                                --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure does the age validation i.e          --+
--                  checks if the guardian details are entered if the   --+
--                  nominee's age is below 18                           --+
-- Parameters     :                                                     --+
--             IN : p_contact_relationship_id   NUMBER                  --+
--                  p_message_name              VARCHAR2                --+
--                  p_token_name                VARCHAR2                --+
--                  p_toen_value                VARCHAR2                --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   31-Mar-2004    gaugupta        Bug 3590036 fixed.              --+
-- 1.2   16-May-2005    sukukuma        updated this procedure          --+
-- 1.3   05-APR-2008    mdubasi         Bug 6871352 fixed.              --+
--------------------------------------------------------------------------+
--sukukuma, changed the name of this procedure from nominee_age_check
-- to check_nominee_age
--mdubasi, added Exception block to handle NO_DATA_FOUND Exception

PROCEDURE check_nominee_age
( p_contact_relationship_id  IN  PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
 ,p_message_name             OUT NOCOPY VARCHAR2
 ,p_token_name               OUT NOCOPY pay_in_utils.char_tab_type
 ,p_token_value              OUT NOCOPY pay_in_utils.char_tab_type)

IS
  l_birth_date           DATE;
  l_current_date         DATE;
  l_year                 NUMBER;
  l_month                NUMBER;
  l_day                  NUMBER;
  l_contact_person_id    NUMBER;
  l_legislation_code     VARCHAR2(10);
  l_guardian_detail_flag NUMBER;
  l_procedure            VARCHAR2(100);
  l_message              VARCHAR2(255);


  CURSOR c_business_group_check
         (p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE)IS

         SELECT pbg.legislation_code
           FROM per_business_groups pbg,
                per_contact_relationships pcr
          WHERE pcr.contact_relationship_id = p_contact_relationship_id
            AND pcr.business_group_id = pbg.business_group_id;

  CURSOR c_get_birth_date(l_contact_person_id IN NUMBER) IS

          SELECT DATE_OF_BIRTH from per_all_people_f
           WHERE PERSON_ID = l_contact_person_id ;

  CURSOR c_get_contact_person_id IS

         SELECT contact_person_id from PER_CONTACT_RELATIONSHIPS
          WHERE contact_relationship_id = p_contact_relationship_id;

  CURSOR c_check_guardian_details IS
         SELECT 1 from per_contact_relationships
          WHERE contact_relationship_id = p_contact_relationship_id
            AND cont_information13 is not null
            AND cont_information14 is not null
            AND cont_information15 is not null
            AND cont_information17 is not null;
BEGIN

   g_debug := hr_utility.debug_enabled ;
   l_procedure := g_package ||'check_nominee_age';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_contact_relationship_id',p_contact_relationship_id);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
    hr_utility.trace ('IN Legislation not installed. Not performing the validations');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
    RETURN;
  END IF;

  OPEN c_business_group_check(p_contact_relationship_id);
  FETCH c_business_group_check into l_legislation_code;
  CLOSE c_business_group_check;

  IF l_legislation_code = 'IN' THEN

    pay_in_utils.set_location(g_debug,l_procedure,30);

    OPEN c_get_contact_person_id;
    FETCH c_get_contact_person_id into l_contact_person_id;
    CLOSE c_get_contact_person_id;

    IF l_contact_person_id is not NULL THEN
      --Get contact person Id--
      pay_in_utils.set_location(g_debug,l_procedure,40);

      OPEN c_get_birth_date(l_contact_person_id);
      FETCH c_get_birth_date into l_birth_date;
      CLOSE c_get_birth_date;

      IF  l_birth_date is not null THEN
     ---Get the age of nominee--
      pay_in_utils.set_location(g_debug,l_procedure,50);

	BEGIN
        SELECT effective_date into l_current_date from fnd_sessions
         WHERE session_id = userenv('SESSIONID');
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
         l_current_date := trunc(sysdate);
	END;

        l_year  := to_number(to_char(l_current_date , 'yyyy')) - to_number(to_char(l_birth_date , 'yyyy'));
        l_month := to_number(to_char(l_current_date , 'mm')) - to_number(to_char(l_birth_date , 'mm'));
        l_day   := to_number(to_char(l_current_date , 'dd')) - to_number(to_char(l_birth_date , 'dd'));

        IF (l_year < 18 or ((l_year = 18) and (l_month < 0)) or ((l_year = 18) and (l_month = 0)  and (l_day < 0))) THEN
           l_guardian_detail_flag := 0;
          --check the age of nominee--
           pay_in_utils.set_location(g_debug,l_procedure,60);

           OPEN c_check_guardian_details;
           FETCH c_check_guardian_details into l_guardian_detail_flag;
           CLOSE c_check_guardian_details;

           IF l_guardian_detail_flag = 0 THEN
           ---Gardian Details---
            pay_in_utils.set_location(g_debug,l_procedure,70);

             hr_utility.set_message(800,'PER_IN_GUARDIAN_DETAILS');
	     hr_utility.raise_error;
             IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.message(LOG_LEVEL   =>FND_LOG.LEVEL_EXCEPTION
                               ,MODULE      =>'per.plsql.hr_in_contact_extra_info_api.create_in_contact_extra_info'
                               ,POP_MESSAGE => FALSE);
              END IF;
           END IF;
        END IF;
      ELSE

      pay_in_utils.set_location(g_debug,l_procedure,80);

        hr_utility.set_message(800,'PER_IN_GUARDIAN_DETAILS');

        IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.message(LOG_LEVEL   =>FND_LOG.LEVEL_EXCEPTION
                         ,MODULE      =>'per.plsql.hr_in_contact_extra_info_api.create_in_contact_extra_info'
                         ,POP_MESSAGE => FALSE);
        END IF;
      END IF;
    ELSE

           pay_in_utils.set_location(g_debug,l_procedure,90);
           p_message_name  := 'PER_IN_NO_RELATIONSHIP';
           pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,100);
            RETURN;
    END IF;
  END IF;
 pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,110);

 END check_nominee_age;




-- -----------------------------------------------------------------------+
-- Name           : get_essential_insert_value                          --+
-- Type           : Procedure                                           --+
-- Access         : Private                                             --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                : p_CEI_INFORMATION3         NUMBER                   --+
--                : p_effective_date           DATE                     --+
--                : p_contact_relationship_id  NUMBER                   --+
--                  p_message_name             VARCHAR2                 --+
--                  p_token_name               VARCHAR2                 --+
--                  p_toen_value               VARCHAR2                 --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   16-May-2005    sukukuma        Created this procedure          --+
-- 1.1   12-Jan-2006    rpalli          Bug:4895307 - Added the check   --+
--                                      for nomination share less than  --+
--                                      100                             --+
--------------------------------------------------------------------------+0

PROCEDURE get_essential_insert_value
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_message_name            OUT NOCOPY VARCHAR2
        ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type)
IS
l_nomination_share            NUMBER;
l_person_id                   NUMBER;
l_contact_relationship_id     NUMBER;
l_temp                        NUMBER;
l_legislation_code            VARCHAR2(10);
l_procedure                   VARCHAR2(200);
l_message                     VARCHAR2(255);



  CURSOR c_business_group_check
         (p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE)IS
         SELECT pbg.legislation_code
         FROM   per_business_groups pbg,
                per_contact_relationships pcr
          WHERE pcr.contact_relationship_id = p_contact_relationship_id
          AND  pcr.business_group_id = pbg.business_group_id;


  CURSOR c_get_relationship_id(l_person_id IN NUMBER) IS
         SELECT contact_relationship_id from PER_CONTACT_RELATIONSHIPS
         WHERE person_id = l_person_id
         AND   contact_relationship_id <> p_contact_relationship_id;

  CURSOR c_get_person_id IS
          SELECT person_id from PER_CONTACT_RELATIONSHIPS
          WHERE  contact_relationship_id = p_contact_relationship_id;

  CURSOR c_check_benefit IS
         SELECT 1 from PER_CONTACT_EXTRA_INFO_F
         WHERE contact_relationship_id = p_contact_relationship_id
         AND   CEI_INFORMATION3 = p_CEI_INFORMATION3
         AND   p_effective_date between effective_start_date and effective_end_date;

BEGIN

  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package ||'get_essential_insert_value';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
    hr_utility.trace ('IN Legislation not installed. Not performing the validations');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
    RETURN;
  END IF;

  OPEN c_business_group_check(p_contact_relationship_id);
  FETCH c_business_group_check into l_legislation_code;
  CLOSE c_business_group_check;

  pay_in_utils.set_location(g_debug,l_procedure,20);

    IF l_legislation_code  = 'IN' THEN
        l_nomination_share := 0;
        l_temp := 0;

    BEGIN
        OPEN  c_check_benefit;
        FETCH c_check_benefit into l_temp;
        CLOSE c_check_benefit;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL ;
    END;

    IF l_temp = 0 THEN
    --get person id--
     pay_in_utils.set_location(g_debug,l_procedure,30);

         OPEN c_get_person_id;
         FETCH c_get_person_id into l_person_id;
         CLOSE c_get_person_id;

        OPEN c_get_relationship_id(l_person_id);
        LOOP
        FETCH c_get_relationship_id into l_contact_relationship_id;
        EXIT WHEN c_get_relationship_id%NOTFOUND;
        l_nomination_share := l_nomination_share + get_nomination_share(l_contact_relationship_id ,
                                                                             p_CEI_INFORMATION3,
                                                                             p_effective_date);
        END LOOP;
       CLOSE c_get_relationship_id;

       IF g_debug then
         pay_in_utils.trace('nomination share after',l_nomination_share + to_number(p_CEI_INFORMATION2));
       END IF;

       IF l_nomination_share + to_number(p_CEI_INFORMATION2) > 100 THEN
       ---check for percentage--
	    pay_in_utils.trace('Check the value of nomination share','40');
            p_message_name  := 'PER_IN_NOM_SHARE_MORE';
            RETURN ;
        ELSIF l_nomination_share + to_number(p_CEI_INFORMATION2) < 100 THEN
       --check for percentage--
          pay_in_utils.trace('Check the value of nomination share less','50');
          p_message_name  := 'PER_IN_NOM_SHARE_LESS';
            RETURN ;
        END IF;
       ELSE

         pay_in_utils.set_location(g_debug,l_procedure,60);
          p_message_name   := 'PER_IN_CONT_ALREADY_NOMINATED';
          RETURN;
      END IF;

  END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,70);

  EXCEPTION
  WHEN NO_DATA_FOUND    THEN
  NULL;


END get_essential_insert_value;




-- -----------------------------------------------------------------------+
-- Name           : get_essential_update_value                          --+
-- Type           : Procedure                                           --+
-- Access         : Private                                             --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--                  p_contact_extra_info_id    NUMBER                   --+
--                  p_message_name             VARCHAR2                 --+
--                  p_token_name               VARCHAR2                 --+
--                  p_toen_value               VARCHAR2                 --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   16-May-2004    sukukuma      Created this procedure            --+
-- 1.1   12-Jan-2006    rpalli          Bug:4895307 - Added the check   --+
--                                      for nomination share less than  --+
--                                      100                             --+
--------------------------------------------------------------------------+0

PROCEDURE get_essential_update_value
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_contact_extra_info_id   IN  PER_CONTACT_EXTRA_INFO_F.contact_extra_info_id%TYPE
        ,p_message_name            OUT NOCOPY VARCHAR2
        ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type)
IS
  l_nomination_share            NUMBER;
  l_person_id                   NUMBER;
  l_contact_relationship_id     NUMBER;
  l_temp                        NUMBER;
  l_legislation_code            VARCHAR2(10);
  l_procedure                   VARCHAR2(200);
  l_message                     VARCHAR2(255);

  CURSOR  c_check_benefit IS
         SELECT 1 from PER_CONTACT_EXTRA_INFO_F
         WHERE  contact_relationship_id = p_contact_relationship_id
         AND    contact_extra_info_id <> p_contact_extra_info_id
         AND    CEI_INFORMATION3 = p_CEI_INFORMATION3
         AND    p_effective_date between effective_start_date and effective_end_date;

  CURSOR c_business_group_check
         (p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE)IS
         SELECT pbg.legislation_code
         FROM   per_business_groups pbg,
                per_contact_relationships pcr
         WHERE  pcr.contact_relationship_id = p_contact_relationship_id
         AND    pcr.business_group_id = pbg.business_group_id;


  CURSOR c_get_relationship_id(l_person_id IN NUMBER) IS
         SELECT contact_relationship_id from PER_CONTACT_RELATIONSHIPS
         WHERE person_id = l_person_id
         AND contact_relationship_id <> p_contact_relationship_id;

  CURSOR c_get_person_id IS
         SELECT person_id from PER_CONTACT_RELATIONSHIPS
         WHERE contact_relationship_id = p_contact_relationship_id;


BEGIN

  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package ||'get_essential_update_value';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
    hr_utility.trace ('IN Legislation not installed. Not performing the validations');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
    RETURN;
  END IF;

  OPEN c_business_group_check(p_contact_relationship_id);
  FETCH c_business_group_check into l_legislation_code;
  CLOSE c_business_group_check;

   IF l_legislation_code = 'IN' THEN

   pay_in_utils.set_location(g_debug,l_procedure,30);

         l_nomination_share := 0;
         l_temp := 0;
      BEGIN
         OPEN  c_check_benefit;
         FETCH c_check_benefit into l_temp;
         CLOSE c_check_benefit;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
         NULL ;
      END;

  IF l_temp = 0 THEN
  --Get the person Id--
  pay_in_utils.set_location(g_debug,l_procedure,40);


         OPEN  c_get_person_id;
         FETCH c_get_person_id into l_person_id;
         CLOSE c_get_person_id;

         OPEN c_get_relationship_id(l_person_id);
           LOOP
            FETCH c_get_relationship_id into l_contact_relationship_id;
            EXIT WHEN c_get_relationship_id%NOTFOUND;
            l_nomination_share := l_nomination_share + get_nomination_share(l_contact_relationship_id ,
                                                                        p_CEI_INFORMATION3,
                                                                        p_effective_date);
           END LOOP;
        CLOSE c_get_relationship_id;

	 IF g_debug then
           pay_in_utils.trace('nomination share after',l_nomination_share + to_number(p_CEI_INFORMATION2));
         END IF;
        IF l_nomination_share + to_number(p_CEI_INFORMATION2) > 100 THEN
       --check for percentage--
	  pay_in_utils.trace('Check the value of nomination share','50');
          p_message_name  := 'PER_IN_NOM_SHARE_MORE';
          RETURN ;
        ELSIF l_nomination_share + to_number(p_CEI_INFORMATION2) < 100 THEN
       --check for percentage--
	  pay_in_utils.trace('Check the value of nomination share less','60');
          p_message_name  := 'PER_IN_NOM_SHARE_LESS';
          RETURN ;
        END IF;

   ELSE
     ----check for status of the nominee------
     pay_in_utils.set_location(g_debug,l_procedure,70);
     p_message_name   := 'PER_IN_CONT_ALREADY_NOMINATED';
     RETURN ;

  END IF;

END IF;
pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);

EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL ;

END get_essential_update_value;




-- -----------------------------------------------------------------------+
-- Name           : check_in_con_int                                    --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : Internal procedure which calls the appropriate      --+
--                : procedures for Insert and Upadte                    --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--                  p_contact_extra_info_id    NUMBER                   --+
--                  p_message_name             VARCHAR2                 --+
--                  p_token_name               VARCHAR2                 --+
--                  p_toen_value               VARCHAR2                 --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   16-May-2005    sukukuma        Created this procedure          --+
--------------------------------------------------------------------------+0
PROCEDURE check_in_con_int
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_contact_extra_info_id   IN  PER_CONTACT_EXTRA_INFO_F.contact_extra_info_id%TYPE
        ,p_message_name            OUT NOCOPY VARCHAR2
        ,p_token_name               OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value              OUT NOCOPY pay_in_utils.char_tab_type)

IS
 l_procedure VARCHAR2(100);
 l_message VARCHAR2(255);
BEGIN
     g_debug := hr_utility.debug_enabled;
     l_procedure := g_package ||'check_in_con_int';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       hr_utility.trace ('IN Legislation not installed. Not performing the validations');
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
     END IF;

IF p_contact_extra_info_id IS NULL THEN
--Insert---
 pay_in_utils.set_location(g_debug,l_procedure,30);

 -------check age and guardian status-----------------

check_nominee_age(p_contact_relationship_id =>p_contact_relationship_id
                 ,p_message_name            =>p_message_name
                 ,p_token_name              => p_token_name
                 ,p_token_value             =>p_token_value);

    IF p_message_name <>'SUCCESS' THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN ;
    END IF ;


get_essential_insert_value
        (p_CEI_INFORMATION2        => p_CEI_INFORMATION2
        ,p_CEI_INFORMATION3        => p_CEI_INFORMATION3
        ,p_effective_date          => p_effective_date
        ,p_contact_relationship_id => p_contact_relationship_id
        ,p_message_name            =>p_message_name
        ,p_token_name              => p_token_name
        ,p_token_value             =>p_token_value);

    IF p_message_name <>'SUCCESS' THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);
      RETURN ;
    END IF;


ELSE
--Update--
pay_in_utils.set_location(g_debug,l_procedure,60);

get_essential_update_value
        (p_CEI_INFORMATION2        => p_CEI_INFORMATION2
        ,p_CEI_INFORMATION3        => p_CEI_INFORMATION3
        ,p_effective_date          => p_effective_date
        ,p_contact_relationship_id => p_contact_relationship_id
        ,p_contact_extra_info_id   => p_contact_extra_info_id
        ,p_message_name            => p_message_name
        ,p_token_name              => p_token_name
        ,p_token_value             => p_token_value);

    IF p_message_name <>'SUCCESS' THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,70);
      RETURN ;
    END IF;

END IF ;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);



END  check_in_con_int;





-- -----------------------------------------------------------------------+
-- Name           : check_in_con_insert                                 --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--            OUT : N/A                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
-- 1.2   12-Jan-2006    rpalli          Updated the procedure to raise  --+
--                                      no error when nomination share  --+
--                                      less than 100. The message is   --+
--                                      handled in the library          --+
--------------------------------------------------------------------------+

PROCEDURE check_in_con_insert
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        )
IS
l_procedure VARCHAR2(100);
l_message   VARCHAR2(255);

BEGIN

  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'check_in_con_insert';
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  check_in_con_int
        (p_CEI_INFORMATION2        => p_CEI_INFORMATION2
        ,p_CEI_INFORMATION3        => p_CEI_INFORMATION3
        ,p_effective_date          => p_effective_date
        ,p_contact_relationship_id => p_contact_relationship_id
        ,p_contact_extra_info_id   => NULL
        ,p_message_name            => p_message_name
        ,p_token_name              => p_token_name
        ,p_token_value             => p_token_value);


  IF p_message_name in ('PER_IN_NOM_SHARE_LESS') THEN
      pay_in_utils.trace('PER_IN_NOM_SHARE_LESS','20');
  ELSIF p_message_name <> 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  ELSE
      pay_in_utils.raise_message(801, p_message_name, p_token_name, p_token_value);
  END IF;

 pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END  check_in_con_insert ;

-- -----------------------------------------------------------------------+
-- Name           : check_in_con_update                                 --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--                  p_contact_extra_info_id    NUMBER                   --+
--            OUT : N/A                                                 --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
-- 1.2   12-Jan-2006    rpalli          Updated the procedure to raise  --+
--                                      no error when nomination share  --+
--                                      less than 100. The message is   --+
--                                      handled in the library          --+
--------------------------------------------------------------------------+

PROCEDURE check_in_con_update
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_contact_extra_info_id    IN  PER_CONTACT_EXTRA_INFO_F.contact_extra_info_id%TYPE)
IS

CURSOR c_nom_id IS
      SELECT
         CEI_INFORMATION2
        ,CEI_INFORMATION3
        ,contact_relationship_id
        FROM  PER_CONTACT_EXTRA_INFO_F
        WHERE contact_extra_info_id =p_contact_extra_info_id;


    l_CEI_INFORMATION2           PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE;
    l_CEI_INFORMATION3           PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE;
    l_contact_relationship_id    PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE;
    l_procedure                  VARCHAR2(100);
    l_message                    VARCHAR2(255);

BEGIN


   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package ||'check_in_con_update';
   p_message_name := 'SUCCESS';
   pay_in_utils.null_message(p_token_name, p_token_value);

   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  OPEN  c_nom_id;
  FETCH c_nom_id
  INTO  l_CEI_INFORMATION2
       ,l_CEI_INFORMATION3
       ,l_contact_relationship_id;
  CLOSE c_nom_id;

  pay_in_utils.set_location(g_debug,l_procedure,20);

   IF p_CEI_INFORMATION2 <> hr_api.g_varchar2 THEN
      l_CEI_INFORMATION2 := p_CEI_INFORMATION2;
   END IF;

   IF p_CEI_INFORMATION3 <> hr_api.g_varchar2 THEN
       l_CEI_INFORMATION3 := p_CEI_INFORMATION3;
   END IF;


    check_in_con_int
        (p_CEI_INFORMATION2        => l_CEI_INFORMATION2
        ,p_CEI_INFORMATION3        => l_CEI_INFORMATION3
        ,p_effective_date          => p_effective_date
        ,p_contact_relationship_id => l_contact_relationship_id
        ,p_contact_extra_info_id   => p_contact_extra_info_id
        ,p_message_name            => p_message_name
        ,p_token_name              => p_token_name
        ,p_token_value             => p_token_value
        );

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

  IF p_message_name in ('PER_IN_NOM_SHARE_LESS') THEN
      hr_utility.trace('PER_IN_NOM_SHARE_LESS');
      pay_in_utils.trace('PER_IN_NOM_SHARE_LESS','40');
  ELSIF p_message_name <> 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  ELSE
      pay_in_utils.raise_message(801, p_message_name, p_token_name, p_token_value);
  END IF;

END check_in_con_update ;

-- -----------------------------------------------------------------------+
-- Name           : get_nomination_share                                --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : This function returns the nomination share for a    --+
--                  particular combination of contact relationship id   --+
--                  effecttive date and benefit type.                   --+
-- Parameters     :                                                     --+
--             IN : p_contact_relationship_id  NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   24-Jun-2004    vgsriniv        Modified the logic.(Bug:3683622)--+
--------------------------------------------------------------------------+
FUNCTION get_nomination_share(p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE,
                              p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE,
                              p_effective_date          IN DATE)
RETURN NUMBER IS
l_nomination_share NUMBER;
l_nom NUMBER;
l_procedure                  VARCHAR2(100);
l_message                    VARCHAR2(255);

CURSOR c_nomination_share IS
   SELECT CEI_INFORMATION2
    FROM PER_CONTACT_EXTRA_INFO_F
   WHERE contact_relationship_id = p_contact_relationship_id
     AND CEI_INFORMATION3 = p_CEI_INFORMATION3
     AND  effective_end_date >= p_effective_date;


BEGIN
  g_debug := hr_utility.debug_enabled;
  l_procedure := 'get_nomination_share';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  l_nomination_share := 0;
  l_nom := 0;

  OPEN c_nomination_share;
  LOOP
    FETCH c_nomination_share INTO l_nom;
    pay_in_utils.trace('l_nom',l_nom);
    EXIT WHEN c_nomination_share%NOTFOUND;
    l_nomination_share := l_nomination_share + l_nom;
  END LOOP;
  CLOSE c_nomination_share;

  pay_in_utils.trace('l_nomination_share',l_nomination_share);
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

  RETURN l_nomination_share;

  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN 0;


END get_nomination_share;

END per_in_con_leg_hook;

/
