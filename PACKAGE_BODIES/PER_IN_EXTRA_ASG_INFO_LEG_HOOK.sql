--------------------------------------------------------
--  DDL for Package Body PER_IN_EXTRA_ASG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_EXTRA_ASG_INFO_LEG_HOOK" AS
/* $Header: peinlhae.pkb 120.2 2006/05/27 18:45:26 statkar noship $ */
   p_token_name   pay_in_utils.char_tab_type;
   p_token_value  pay_in_utils.char_tab_type;
   g_package          CONSTANT VARCHAR2(100) := 'per_in_extra_asg_info_leg_hook.';
   g_debug            BOOLEAN ;
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_asg_extra_info_insert                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the unique month and year of a record    --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id             NUMBER                  --
--                : p_aei_information_category  VARCHAR2                --
--                : p_aei_information1          VARCHAR2                --
--                : p_aei_information2          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01-APR-05  abhjain   Created this procedure                    --
--------------------------------------------------------------------------

PROCEDURE check_asg_extra_info_insert(
         p_assignment_id            IN NUMBER
        ,p_aei_information_category IN VARCHAR2
        ,p_aei_information1         IN VARCHAR2
        ,p_aei_information2         IN VARCHAR2
        ,p_aei_information3         IN VARCHAR2
        ,p_aei_information4         IN VARCHAR2
        ,p_aei_information5         IN VARCHAR2
        ,p_aei_information6         IN VARCHAR2
        ,p_aei_information7         IN VARCHAR2
        ,p_aei_information8         IN VARCHAR2
        ,p_aei_information9         IN VARCHAR2
        ,p_aei_information10        IN VARCHAR2
        ,p_aei_information11        IN VARCHAR2
        ,p_aei_information12        IN VARCHAR2
        ,p_aei_information13        IN VARCHAR2
        ,p_aei_information14        IN VARCHAR2
        ,p_aei_information15        IN VARCHAR2
        ,p_aei_information16        IN VARCHAR2
        ,p_aei_information17        IN VARCHAR2
        ,p_aei_information18        IN VARCHAR2
        ,p_aei_information19        IN VARCHAR2
        ,p_aei_information20        IN VARCHAR2
        ,p_aei_information21        IN VARCHAR2
        ,p_aei_information22        IN VARCHAR2
        ,p_aei_information23        IN VARCHAR2
        ,p_aei_information24        IN VARCHAR2
        ,p_aei_information25        IN VARCHAR2
        ,p_aei_information26        IN VARCHAR2
        ,p_aei_information27        IN VARCHAR2
        ,p_aei_information28        IN VARCHAR2
        ,p_aei_information29        IN VARCHAR2
        ,p_aei_information30        IN VARCHAR2
        ) IS

    l_procedure           VARCHAR2(100);
    l_message_name        VARCHAR2(255);

BEGIN

  l_procedure := g_package ||'check_asg_extra_info_insert';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
    pay_in_utils.trace('IN Legislation not installed. Not performing the validations','20');
    RETURN;
  END IF;

  l_message_name := 'SUCCESS';
  pay_in_utils.set_location(g_debug,l_procedure,30);

  check_asg_extra_info_int(
         p_assignment_id            => p_assignment_id
        ,p_aei_information_category => p_aei_information_category
        ,p_aei_information1         => p_aei_information1
        ,p_aei_information2         => p_aei_information2
        ,p_aei_information3         => p_aei_information3
        ,p_aei_information4         => p_aei_information4
        ,p_aei_information5         => p_aei_information5
        ,p_aei_information6         => p_aei_information6
        ,p_aei_information7         => p_aei_information7
        ,p_aei_information8         => p_aei_information8
        ,p_aei_information9         => p_aei_information9
        ,p_aei_information10        => p_aei_information10
        ,p_aei_information11        => p_aei_information11
        ,p_aei_information12        => p_aei_information12
        ,p_aei_information13        => p_aei_information13
        ,p_aei_information14        => p_aei_information14
        ,p_aei_information15        => p_aei_information15
        ,p_aei_information16        => p_aei_information16
        ,p_aei_information17        => p_aei_information17
        ,p_aei_information18        => p_aei_information18
        ,p_aei_information19        => p_aei_information19
        ,p_aei_information20        => p_aei_information20
        ,p_aei_information21        => p_aei_information21
        ,p_aei_information22        => p_aei_information22
        ,p_aei_information23        => p_aei_information23
        ,p_aei_information24        => p_aei_information24
        ,p_aei_information25        => p_aei_information25
        ,p_aei_information26        => p_aei_information26
        ,p_aei_information27        => p_aei_information27
        ,p_aei_information28        => p_aei_information28
        ,p_aei_information29        => p_aei_information29
        ,p_aei_information30        => p_aei_information30
        ,p_message                  => l_message_name
        ,p_token_name               => p_token_name
        ,p_token_value              => p_token_value);

  pay_in_utils.set_location(g_debug,l_procedure,40);

  IF l_message_name <> 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(800, l_message_name, p_token_name, p_token_value);
  ELSE
      pay_in_utils.raise_message(801, l_message_name, p_token_name, p_token_value);
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);

END check_asg_extra_info_insert;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_asg_extra_info_update                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the unique month and year of a record    --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_extra_info_id  NUMBER                  --
--                : p_aei_information_category  VARCHAR2                --
--                : p_aei_information1          VARCHAR2                --
--                : p_aei_information2          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01-APR-05  abhjain   Created this procedure                    --
--------------------------------------------------------------------------

PROCEDURE check_asg_extra_info_update(
         p_assignment_extra_info_id IN NUMBER
        ,p_aei_information_category IN VARCHAR2
        ,p_aei_information1         IN VARCHAR2
        ,p_aei_information2         IN VARCHAR2
        ,p_aei_information3         IN VARCHAR2
        ,p_aei_information4         IN VARCHAR2
        ,p_aei_information5         IN VARCHAR2
        ,p_aei_information6         IN VARCHAR2
        ,p_aei_information7         IN VARCHAR2
        ,p_aei_information8         IN VARCHAR2
        ,p_aei_information9         IN VARCHAR2
        ,p_aei_information10        IN VARCHAR2
        ,p_aei_information11        IN VARCHAR2
        ,p_aei_information12        IN VARCHAR2
        ,p_aei_information13        IN VARCHAR2
        ,p_aei_information14        IN VARCHAR2
        ,p_aei_information15        IN VARCHAR2
        ,p_aei_information16        IN VARCHAR2
        ,p_aei_information17        IN VARCHAR2
        ,p_aei_information18        IN VARCHAR2
        ,p_aei_information19        IN VARCHAR2
        ,p_aei_information20        IN VARCHAR2
        ,p_aei_information21        IN VARCHAR2
        ,p_aei_information22        IN VARCHAR2
        ,p_aei_information23        IN VARCHAR2
        ,p_aei_information24        IN VARCHAR2
        ,p_aei_information25        IN VARCHAR2
        ,p_aei_information26        IN VARCHAR2
        ,p_aei_information27        IN VARCHAR2
        ,p_aei_information28        IN VARCHAR2
        ,p_aei_information29        IN VARCHAR2
        ,p_aei_information30        IN VARCHAR2
        ) IS


CURSOR get_assignment_id
IS
SELECT assignment_id
      ,aei_information1
      ,aei_information2
      ,aei_information3
      ,aei_information4
      ,aei_information5
      ,aei_information6
      ,aei_information7
      ,aei_information8
      ,aei_information9
      ,aei_information10
      ,aei_information11
      ,aei_information12
      ,aei_information13
      ,aei_information14
      ,aei_information15
      ,aei_information16
      ,aei_information17
      ,aei_information18
      ,aei_information19
      ,aei_information20
      ,aei_information21
      ,aei_information22
      ,aei_information23
      ,aei_information24
      ,aei_information25
      ,aei_information26
      ,aei_information27
      ,aei_information28
      ,aei_information29
      ,aei_information30
  FROM per_assignment_extra_info
 WHERE assignment_extra_info_id = p_assignment_extra_info_id;

     l_procedure          VARCHAR2(100);
     l_message_name       VARCHAR2(255);
     l_assignment_id      per_assignment_extra_info.assignment_id%type;
     l_aei_information1   per_assignment_extra_info.aei_information1%type;
     l_aei_information2   per_assignment_extra_info.aei_information1%type;
     l_aei_information3   per_assignment_extra_info.aei_information1%type;
     l_aei_information4   per_assignment_extra_info.aei_information1%type;
     l_aei_information5   per_assignment_extra_info.aei_information1%type;
     l_aei_information6   per_assignment_extra_info.aei_information1%type;
     l_aei_information7   per_assignment_extra_info.aei_information1%type;
     l_aei_information8   per_assignment_extra_info.aei_information1%type;
     l_aei_information9   per_assignment_extra_info.aei_information1%type;
     l_aei_information10  per_assignment_extra_info.aei_information1%type;
     l_aei_information11  per_assignment_extra_info.aei_information1%type;
     l_aei_information12  per_assignment_extra_info.aei_information1%type;
     l_aei_information13  per_assignment_extra_info.aei_information1%type;
     l_aei_information14  per_assignment_extra_info.aei_information1%type;
     l_aei_information15  per_assignment_extra_info.aei_information1%type;
     l_aei_information16  per_assignment_extra_info.aei_information1%type;
     l_aei_information17  per_assignment_extra_info.aei_information1%type;
     l_aei_information18  per_assignment_extra_info.aei_information1%type;
     l_aei_information19  per_assignment_extra_info.aei_information1%type;
     l_aei_information20  per_assignment_extra_info.aei_information1%type;
     l_aei_information21  per_assignment_extra_info.aei_information1%type;
     l_aei_information22  per_assignment_extra_info.aei_information1%type;
     l_aei_information23  per_assignment_extra_info.aei_information1%type;
     l_aei_information24  per_assignment_extra_info.aei_information1%type;
     l_aei_information25  per_assignment_extra_info.aei_information1%type;
     l_aei_information26  per_assignment_extra_info.aei_information1%type;
     l_aei_information27  per_assignment_extra_info.aei_information1%type;
     l_aei_information28  per_assignment_extra_info.aei_information1%type;
     l_aei_information29  per_assignment_extra_info.aei_information1%type;
     l_aei_information30  per_assignment_extra_info.aei_information1%type;
BEGIN


  l_procedure := g_package ||'check_asg_extra_info_update';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
    pay_in_utils.trace('IN Legislation not installed. Not performing the validations','20');
    RETURN;
  END IF;

  l_message_name := 'SUCCESS';
  pay_in_utils.set_location(g_debug,l_procedure,30);

  OPEN get_assignment_id;
  FETCH get_assignment_id INTO  l_assignment_id
                               ,l_aei_information1
                               ,l_aei_information2
                               ,l_aei_information3
                               ,l_aei_information4
                               ,l_aei_information5
                               ,l_aei_information6
                               ,l_aei_information7
                               ,l_aei_information8
                               ,l_aei_information9
                               ,l_aei_information10
                               ,l_aei_information11
                               ,l_aei_information12
                               ,l_aei_information13
                               ,l_aei_information14
                               ,l_aei_information15
                               ,l_aei_information16
                               ,l_aei_information17
                               ,l_aei_information18
                               ,l_aei_information19
                               ,l_aei_information20
                               ,l_aei_information21
                               ,l_aei_information22
                               ,l_aei_information23
                               ,l_aei_information24
                               ,l_aei_information25
                               ,l_aei_information26
                               ,l_aei_information27
                               ,l_aei_information28
                               ,l_aei_information29
                               ,l_aei_information30;
  CLOSE get_assignment_id;

  pay_in_utils.set_location(g_debug,l_procedure,40);

  IF p_aei_information1 <> hr_api.g_varchar2 THEN
    l_aei_information1 := p_aei_information1;
  END IF;
  IF p_aei_information2 <> hr_api.g_varchar2 THEN
    l_aei_information2 := p_aei_information2;
  END IF;
  IF p_aei_information3 <> hr_api.g_varchar2 THEN
    l_aei_information3 := p_aei_information3;
  END IF;
  IF p_aei_information4 <> hr_api.g_varchar2 THEN
    l_aei_information4 := p_aei_information4;
  END IF;
  IF p_aei_information5 <> hr_api.g_varchar2 THEN
    l_aei_information5 := p_aei_information5;
  END IF;
  IF p_aei_information6 <> hr_api.g_varchar2 THEN
    l_aei_information6 := p_aei_information6;
  END IF;
  IF p_aei_information7 <> hr_api.g_varchar2 THEN
    l_aei_information7 := p_aei_information7;
  END IF;
  IF p_aei_information8 <> hr_api.g_varchar2 THEN
    l_aei_information8 := p_aei_information8;
  END IF;
  IF p_aei_information9 <> hr_api.g_varchar2 THEN
    l_aei_information9 := p_aei_information9;
  END IF;
  IF p_aei_information10 <> hr_api.g_varchar2 THEN
    l_aei_information10 := p_aei_information10;
  END IF;
  IF p_aei_information11 <> hr_api.g_varchar2 THEN
    l_aei_information11 := p_aei_information11;
  END IF;
  IF p_aei_information12 <> hr_api.g_varchar2 THEN
    l_aei_information12 := p_aei_information12;
  END IF;
  IF p_aei_information13 <> hr_api.g_varchar2 THEN
    l_aei_information13 := p_aei_information13;
  END IF;
  IF p_aei_information14 <> hr_api.g_varchar2 THEN
    l_aei_information14 := p_aei_information14;
  END IF;
  IF p_aei_information15 <> hr_api.g_varchar2 THEN
    l_aei_information15 := p_aei_information15;
  END IF;
  IF p_aei_information16 <> hr_api.g_varchar2 THEN
    l_aei_information16 := p_aei_information16;
  END IF;
  IF p_aei_information17 <> hr_api.g_varchar2 THEN
    l_aei_information17 := p_aei_information17;
  END IF;
  IF p_aei_information18 <> hr_api.g_varchar2 THEN
    l_aei_information18 := p_aei_information18;
  END IF;
  IF p_aei_information19 <> hr_api.g_varchar2 THEN
    l_aei_information19 := p_aei_information19;
  END IF;
  IF p_aei_information20 <> hr_api.g_varchar2 THEN
    l_aei_information20 := p_aei_information20;
  END IF;
  IF p_aei_information21 <> hr_api.g_varchar2 THEN
    l_aei_information21 := p_aei_information21;
  END IF;
  IF p_aei_information22 <> hr_api.g_varchar2 THEN
    l_aei_information22 := p_aei_information22;
  END IF;
  IF p_aei_information23 <> hr_api.g_varchar2 THEN
    l_aei_information23 := p_aei_information23;
  END IF;
  IF p_aei_information24 <> hr_api.g_varchar2 THEN
    l_aei_information24 := p_aei_information24;
  END IF;
  IF p_aei_information25 <> hr_api.g_varchar2 THEN
    l_aei_information25 := p_aei_information25;
  END IF;
  IF p_aei_information26 <> hr_api.g_varchar2 THEN
    l_aei_information26 := p_aei_information26;
  END IF;
  IF p_aei_information27 <> hr_api.g_varchar2 THEN
    l_aei_information27 := p_aei_information27;
  END IF;
  IF p_aei_information28 <> hr_api.g_varchar2 THEN
    l_aei_information28 := p_aei_information28;
  END IF;
  IF p_aei_information29 <> hr_api.g_varchar2 THEN
    l_aei_information29 := p_aei_information29;
  END IF;
  IF p_aei_information30 <> hr_api.g_varchar2 THEN
    l_aei_information30 := p_aei_information30;
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,50);
  check_asg_extra_info_int(
         p_assignment_id            => l_assignment_id
        ,p_assignment_extra_info_id => p_assignment_extra_info_id
        ,p_aei_information_category => p_aei_information_category
        ,p_aei_information1         => l_aei_information1
        ,p_aei_information2         => l_aei_information2
        ,p_aei_information3         => l_aei_information3
        ,p_aei_information4         => l_aei_information4
        ,p_aei_information5         => l_aei_information5
        ,p_aei_information6         => l_aei_information6
        ,p_aei_information7         => l_aei_information7
        ,p_aei_information8         => l_aei_information8
        ,p_aei_information9         => l_aei_information9
        ,p_aei_information10        => l_aei_information10
        ,p_aei_information11        => l_aei_information11
        ,p_aei_information12        => l_aei_information12
        ,p_aei_information13        => l_aei_information13
        ,p_aei_information14        => l_aei_information14
        ,p_aei_information15        => l_aei_information15
        ,p_aei_information16        => l_aei_information16
        ,p_aei_information17        => l_aei_information17
        ,p_aei_information18        => l_aei_information18
        ,p_aei_information19        => l_aei_information19
        ,p_aei_information20        => l_aei_information20
        ,p_aei_information21        => l_aei_information21
        ,p_aei_information22        => l_aei_information22
        ,p_aei_information23        => l_aei_information23
        ,p_aei_information24        => l_aei_information24
        ,p_aei_information25        => l_aei_information25
        ,p_aei_information26        => l_aei_information26
        ,p_aei_information27        => l_aei_information27
        ,p_aei_information28        => l_aei_information28
        ,p_aei_information29        => l_aei_information29
        ,p_aei_information30        => l_aei_information30
        ,p_message                  => l_message_name
        ,p_token_name               => p_token_name
        ,p_token_value              => p_token_value);
  pay_in_utils.set_location(g_debug,l_procedure,60);
  IF l_message_name <> 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(800, l_message_name, p_token_name, p_token_value);
  ELSE
      pay_in_utils.raise_message(801, l_message_name, p_token_name, p_token_value);
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,70);


END check_asg_extra_info_update;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_asg_extra_info_int                            --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : User hook checks                                    --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id             NUMBER                  --
--                : p_aei_information_category  VARCHAR2                --
--                : p_assignment_extra_info_id  VARCHAR2                --
--                : p_aei_information1          VARCHAR2                --
--                : p_aei_information2          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   07-APR-05  abhjain   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE check_asg_extra_info_int(
         p_assignment_id            IN NUMBER
        ,p_assignment_extra_info_id IN NUMBER   default null
        ,p_aei_information_category IN VARCHAR2
        ,p_aei_information1         IN VARCHAR2
        ,p_aei_information2         IN VARCHAR2
        ,p_aei_information3         IN VARCHAR2
        ,p_aei_information4         IN VARCHAR2
        ,p_aei_information5         IN VARCHAR2
        ,p_aei_information6         IN VARCHAR2
        ,p_aei_information7         IN VARCHAR2
        ,p_aei_information8         IN VARCHAR2
        ,p_aei_information9         IN VARCHAR2
        ,p_aei_information10        IN VARCHAR2
        ,p_aei_information11        IN VARCHAR2
        ,p_aei_information12        IN VARCHAR2
        ,p_aei_information13        IN VARCHAR2
        ,p_aei_information14        IN VARCHAR2
        ,p_aei_information15        IN VARCHAR2
        ,p_aei_information16        IN VARCHAR2
        ,p_aei_information17        IN VARCHAR2
        ,p_aei_information18        IN VARCHAR2
        ,p_aei_information19        IN VARCHAR2
        ,p_aei_information20        IN VARCHAR2
        ,p_aei_information21        IN VARCHAR2
        ,p_aei_information22        IN VARCHAR2
        ,p_aei_information23        IN VARCHAR2
        ,p_aei_information24        IN VARCHAR2
        ,p_aei_information25        IN VARCHAR2
        ,p_aei_information26        IN VARCHAR2
        ,p_aei_information27        IN VARCHAR2
        ,p_aei_information28        IN VARCHAR2
        ,p_aei_information29        IN VARCHAR2
        ,p_aei_information30        IN VARCHAR2
        ,p_message                  OUT NOCOPY VARCHAR2
        ,p_token_name               OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value              OUT NOCOPY pay_in_utils.char_tab_type) IS
CURSOR cur_check_unique_record_ins
IS
SELECT 1
  FROM PER_ASSIGNMENT_EXTRA_INFO
 WHERE assignment_id    = p_assignment_id
   AND aei_information1 = p_aei_information1
   AND aei_information2 = p_aei_information2
   AND aei_information_category = p_aei_information_category;

CURSOR cur_check_unique_record_upd
IS
SELECT 1
  FROM PER_ASSIGNMENT_EXTRA_INFO
 WHERE aei_information1 = p_aei_information1
   AND aei_information2 = p_aei_information2
   AND aei_information_category = p_aei_information_category
   AND assignment_id = p_assignment_id
   AND assignment_extra_info_id <> p_assignment_extra_info_id;

    l_procedure           VARCHAR2(100);
    l_temp                NUMBER;
    l_message_name        VARCHAR2(80);

BEGIN
  p_message := 'SUCCESS';
  l_procedure := g_package ||'check_asg_extra_info_int';
  g_debug := hr_utility.debug_enabled ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF  p_aei_information_category = 'PER_IN_PF_REMARKS'
   OR p_aei_information_category = 'PER_IN_ESI_REMARKS' THEN
    --
    IF p_assignment_extra_info_id IS NULL THEN
      OPEN cur_check_unique_record_ins;
      FETCH cur_check_unique_record_ins INTO l_temp;
      CLOSE cur_check_unique_record_ins;

      pay_in_utils.set_location(g_debug,l_procedure,20);

      IF l_temp = 1 THEN
        p_message := 'PER_IN_MULTIPLE_REMARKS';
	pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
        RETURN;
      END IF;

    ELSIF p_assignment_extra_info_id IS NOT NULL THEN
      OPEN cur_check_unique_record_upd;
      FETCH cur_check_unique_record_upd INTO l_temp;
      CLOSE cur_check_unique_record_upd;

      pay_in_utils.set_location(g_debug,l_procedure,40);

      IF l_temp = 1 THEN
        p_message := 'PER_IN_MULTIPLE_REMARKS';
	pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);
        RETURN;
      END IF;

    END IF;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

   END IF;

END check_asg_extra_info_int;

END  per_in_extra_asg_info_leg_hook;

/
