--------------------------------------------------------
--  DDL for Package Body PER_CN_EMP_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_EMP_LEG_HOOK" AS
/* $Header: pecnlhpp.pkb 120.1 2006/02/06 01:46:25 rpalli noship $ */
--
--
   g_trace BOOLEAN DEFAULT false;
--
--
--
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_INT_EMPLOYEE                                  --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the employee.                                    --
-- Parameters     :                                                     --
--             IN :   p_hukou_type                 VARCHAR2             --
--                    p_hukou_location             VARCHAR2             --
--                    p_highest_education_level    VARCHAR2             --
--                    p_number_of_children         VARCHAR2             --
--                    p_expatriate_indicator       VARCHAR2             --
--                    p_health_status              VARCHAR2             --
--                    p_tax_exemption_indicator    VARCHAR2             --
--                    p_percentage                 VARCHAR2             --
--                    p_race_ethnic_origin         VARCHAR2             --
--                    p_business_group_id          NUMBER               --
--                    p_national_identifier        VARCHAR              --
--                    p_person_type_id             NUMBER,              --
--                    p_effective_date             DATE,                --
--                    p_person_id                  NUMBER               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this procedure                    --
-- 1.1   20/12/02   statkar   Made changes as per ver 115.0             --
-- 1.2   09/01/03   statkar   Made changes as per ver 115.1             --
-- 1.3   10/01/03   statkar   Changed the name to CHECK_INT_EMPLOYEE    --
--                            and made procedure PRIVATE                --
-- 1.4   31/01/03   statkar   Added code to remove validation for       --
--                            defaulting values. Bug 2676440            --
--                            Added validation for PTU.                 --
-- 1.5   05/02/03   statkar   Added check for additional PTU (2782045)  --
-- 1.6   14/04/03   statkar   Removed mandatory checks for certain PTU  --
--                            Bug 2902744                               --
-- 1.7   07/08/03   saikrish  Removed p_given_han_yu_pin_yin_name,      --
--                            p_family_han_yu_pin_yin_name. Removed call--
--                            hr_cn_api.check_name_dependence(3075230)  --
-- 1.8   19/09/03   statkar   Added the hr_utility.chk_product_install  --
--                            check for installed CN leg (3145322)      --
-- 1.9   24/09/03   saikrish  Changed the checks for person_type(2902659)-
-- 1.10  07/01/04   bramajey  Bug 3342105 Changes.                      --
-- 1.11  06/02/06   rpalli   Bug 4756920 Changes. Hukou Type and Hukou  --
--                           Location should be made conditionally      --
--                           mandatory                                  --
--------------------------------------------------------------------------
 PROCEDURE check_int_employee( p_business_group_id             IN NUMBER
		              ,p_national_identifier           IN VARCHAR2
   		              ,p_person_type_id                IN NUMBER
   		              ,p_effective_date                IN DATE
			      ,p_person_id                     IN NUMBER
                              ,p_hukou_type                    IN VARCHAR2
                              ,p_hukou_location                IN VARCHAR2
                              ,p_highest_education_level       IN VARCHAR2
                              ,p_number_of_children            IN VARCHAR2
                              ,p_expatriate_indicator          IN VARCHAR2
                              ,p_health_status                 IN VARCHAR2
                              ,p_tax_exemption_indicator       IN VARCHAR2
                              ,p_percentage                    IN VARCHAR2
                              ,p_race_ethnic_origin            IN VARCHAR2)
IS

  --Declare local varialbles
  l_return_number   NUMBER(1);
  l_proc            VARCHAR2(72) := g_package||'check_int_employee';
  --
  -- Changed the cursor definition for bug 4756920.
  --
  CURSOR csr_ptu (p_person_type_id IN NUMBER, p_business_group_id IN NUMBER)
          IS        SELECT system_person_type
                    FROM   per_person_types
                  WHERE  business_group_id = p_business_group_id
                  AND    person_type_id    = p_person_type_id ;

  l_person_type    per_person_types.system_person_type%TYPE;

BEGIN
--
   IF hr_cn_employee_api.g_trace OR hr_cn_applicant_api.g_trace THEN
       g_trace:=true;
   END IF;
--
-- Bug 3145322 Check the leg-specific validations only if the legislation
--             is installed
--
   IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'CN') THEN
       hr_utility.trace ('CN Legislation not installed. Not performing the validations');
       hr_cn_api.set_location(g_trace,'Leaving: '||l_proc, 15);
       RETURN;
   END IF;

--
--
-- Get the PT
-- Changed for bug 2902659, person type will contain system person type based on
-- the person type id of person type usages.
--
    OPEN csr_ptu (p_person_type_id, p_business_group_id);
    FETCH csr_ptu INTO l_person_type;
    IF csr_ptu%NOTFOUND THEN
      CLOSE csr_ptu;
      hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_PERSON_TYPE_ID',
            p_argument_value   =>  p_person_type_id
           );
    ELSE
      CLOSE csr_ptu;
    END IF;



--
-- Check for the mandatory arguments
--
--
    IF hr_cn_api.chk_person_type (l_person_type)
    THEN


      -- Bug 3342105 Changes.
      -- Moved the Expat Indicator and CIN check to this IF block

      hr_cn_api.set_location(g_trace,l_proc,10);
      hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_EXPATRIATE_INDICATOR',
            p_argument_value   => p_expatriate_indicator
           );

    IF p_expatriate_indicator ='N' THEN
      hr_cn_api.set_location(g_trace,l_proc,20);
      hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_HUKOU_TYPE',
            p_argument_value   => p_hukou_type
           );

      hr_cn_api.set_location(g_trace,l_proc,30);
      hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_HUKOU_LOCATION',
            p_argument_value   => p_hukou_location
           );
     END IF;
    --
    -- Validate the CIN based on EXPATRIATE_INDICATOR and PERSON_TYPE
    -- Bug 2737913 -- Ver 115.1 -- statkar
    -- Bug 2782045 -- In place of p_person_type_id, we call check_cin
    --                with l_person_type for ease in checking.
    -- Bug 2902659 -- Tested p_national_identifier for NULL condition
    --
      IF (p_national_identifier <> hr_api.g_varchar2) OR (p_national_identifier IS NULL) THEN
        hr_cn_api.check_cin
                (  p_business_group_id     => p_business_group_id,
                   p_national_identifier   => p_national_identifier,
                   p_person_type_id        => p_person_type_id,
                   p_expatriate_indicator  => p_expatriate_indicator,
                   p_effective_date        => p_effective_date,
                   p_person_id             => p_person_id
                );
       END IF;
    END IF;

--
-- Check for the valid lookup values
--
    hr_cn_api.set_location(g_trace,l_proc,40);

    IF p_hukou_type IS NOT NULL and p_hukou_type <> hr_api.g_varchar2 THEN
	hr_cn_api.check_lookup (
                p_lookup_type     => 'CN_HUKOU_TYPE',
                p_argument        => 'P_HUKOU_TYPE',
                p_argument_value  =>  p_hukou_type
               );
    END IF;

    hr_cn_api.set_location(g_trace,l_proc,50);
    IF p_hukou_location IS NOT NULL and p_hukou_location <> hr_api.g_varchar2 THEN
        hr_cn_api.check_lookup (
                p_lookup_type     => 'CN_HUKOU_LOCN',
                p_argument        => 'P_HUKOU_LOCATION',
                p_argument_value  =>  p_hukou_location
               );
    END IF;

    hr_cn_api.set_location(g_trace,l_proc,60);
    IF p_expatriate_indicator <> hr_api.g_varchar2  THEN
        hr_cn_api.check_lookup (
                p_lookup_type     => 'YES_NO',
                p_argument        => 'P_EXPATRIATE_INDICATOR',
                p_argument_value  =>  p_expatriate_indicator
               );
    END IF;

    hr_cn_api.set_location(g_trace,l_proc,70);
    IF p_race_ethnic_origin is not null AND p_race_ethnic_origin <> hr_api.g_varchar2
    THEN
        hr_cn_api.check_lookup (
                    p_lookup_type     => 'CN_RACE',
                    p_argument        => 'P_RACE_ETHNIC_ORGIN',
                    p_argument_value  =>  p_race_ethnic_origin
                   );
    END IF;

    hr_cn_api.set_location(g_trace,l_proc,80);
    IF p_highest_education_level is not null AND p_highest_education_level <> hr_api.g_varchar2
    THEN
         hr_cn_api.check_lookup (
                p_lookup_type     => 'CN_HIGH_EDU_LEVEL',
                p_argument        => 'P_HIGHEST_EDUCATION_LEVEL',
                p_argument_value  =>  p_highest_education_level
               );
    END IF;

    hr_cn_api.set_location(g_trace,l_proc,90);
    IF p_health_status is not null AND p_health_status <> hr_api.g_varchar2
    THEN
       hr_cn_api.check_lookup (
                p_lookup_type     => 'CN_HEALTH_STATUS',
                p_argument        => 'P_HEALTH_STATUS',
                p_argument_value  =>  p_health_status
               );
    END IF;

    hr_cn_api.set_location(g_trace,l_proc,100);
    IF p_tax_exemption_indicator is not null AND p_tax_exemption_indicator <> hr_api.g_varchar2
    THEN
           hr_cn_api.check_lookup (
                    p_lookup_type     => 'YES_NO',
                    p_argument        => 'P_TAX_EXEMPTION_INDICATOR',
                    p_argument_value  =>  p_tax_exemption_indicator
                   );
    END IF;


--
-- Validation for Number of Children
--
   hr_cn_api.set_location(g_trace,l_proc,110);
   IF p_number_of_children is not null AND p_number_of_children <> hr_api.g_varchar2
   THEN
   --
      IF hr_cn_api.is_number(p_number_of_children) THEN
      --
   	hr_cn_api.set_location(g_trace,l_proc,120);
        IF NOT hr_cn_api.is_positive_integer(to_number(p_number_of_children)) THEN
	--
	    hr_cn_api.set_location(g_trace,l_proc,130);
     	    hr_utility.set_message(800,'HR_374602_INVALID_VALUE');
     	    hr_utility.set_message_token('VALUE', p_number_of_children);
     	    hr_utility.set_message_token('FIELD','P_NUMBER_OF_CHILDREN');
     	    hr_utility.raise_error;
  	END IF;
   --
      ELSE
   --
        hr_cn_api.set_location(g_trace,l_proc,140);
  	hr_utility.set_message(800,'HR_374602_INVALID_VALUE');
     	hr_utility.set_message_token('VALUE', p_number_of_children);
     	hr_utility.set_message_token('FIELD','P_NUMBER_OF_CHILDREN');
     	hr_utility.raise_error;
   --
      END IF;
   --
   END IF;


--
-- Check for the tax dependence.
--
   hr_cn_api.set_location(g_trace,l_proc,150);
   hr_cn_api.check_tax_dependence(p_tax_exemption_indicator
                                 ,p_percentage
                      	         );

--
-- Validation for Tax Percentage
--
   hr_cn_api.set_location (g_trace, l_proc, 160);
   IF NOT hr_cn_api.is_number(p_percentage)
   THEN
	hr_utility.set_message(800,'HR_374602_INVALID_VALUE');
	hr_utility.set_message_token('VALUE', p_percentage);
	hr_utility.set_message_token('FIELD','P_PERCENTAGE');
    	hr_utility.raise_error;
   ELSIF NOT hr_cn_api.is_valid_percentage(to_number(p_percentage))
   THEN
        hr_utility.set_message('PER','HR_374603_INVALID_RANGE');
	hr_utility.set_message_token('NUMBER','P_PERCENTAGE');
	hr_utility.set_message_token('LOW','0');
	hr_utility.set_message_token('HIGH','100');
	hr_utility.raise_error;
   ELSIF length(substr(p_percentage,instr(p_percentage,'.',1)+1)) > 3
-- Bug 2748530 changes start
-- Check for decimal length
--
   THEN
        hr_utility.set_message('PER','HR_374607_INVALID_FORMAT');
        hr_utility.set_message_token('FIELD','P_PERCENTAGE');
        hr_utility.set_message_token('FORMAT','99.999');
        hr_utility.raise_error;
   END IF;
--
-- Bug 2748530 changes end
--
  hr_cn_api.set_location(g_trace,'Leaving:'||l_proc,220);


EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END check_int_employee;


--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EMPLOYEE                                      --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the employee.                                    --
--                  This procedure is the hook procedure for the        --
--                  employee.                                           --
-- Parameters     :                                                     --
--             IN :   p_per_information4    VARCHAR2                    --
--                    p_per_information5    VARCHAR2                    --
--                    p_per_information6    VARCHAR2                    --
--                    p_per_information7    VARCHAR2                    --
--                    p_per_information8    VARCHAR2                    --
--                    p_per_information10   VARCHAR2                    --
--                    p_per_information11   VARCHAR2                    --
--                    p_per_information12   VARCHAR2                    --
--                    p_per_information17   VARCHAR2                    --
--                    p_business_group_id    NUMBER                     --
--                    p_national_identifier  VARCHAR                    --
--                    p_person_type_id       NUMBER,                    --
--                    p_effective_date       DATE,                      --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this procedure                    --
-- 1.1   09/01/03   statkar   Made changes as per ver 115.1             --
-- 1.2   10/01/03   statkar   Changed proc to call CHECK_INT_EMPLOYEE   --
-- 1.3   07/08/03   saikrish  Removed p_per_information14,              --
--                            p_per_information15  (3075230)            --
--------------------------------------------------------------------------
 PROCEDURE check_employee (p_business_group_id    IN NUMBER
		          ,p_national_identifier  IN VARCHAR2
   		          ,p_person_type_id       IN NUMBER
   		          ,p_hire_date            IN DATE
                          ,p_per_information4     IN VARCHAR2
                          ,p_per_information5     IN VARCHAR2
                          ,p_per_information6     IN VARCHAR2
                          ,p_per_information7     IN VARCHAR2
                          ,p_per_information8     IN VARCHAR2
                          ,p_per_information10    IN VARCHAR2
                          ,p_per_information11    IN VARCHAR2
                          ,p_per_information12    IN VARCHAR2
                          ,p_per_information17    IN VARCHAR2)
 IS

  --Declare local varialbles
  l_proc            VARCHAR2(72) := g_package||'check_employee';

  BEGIN
--
   IF hr_cn_employee_api.g_trace OR hr_cn_applicant_api.g_trace THEN
       g_trace:=true;
   END IF;
--
   hr_cn_api.set_location(g_trace,'Entering:'|| l_proc,10);
--
-- Bug 3075230 Removed p_given_han_yu_pin_yin_name,p_family_han_yu_pin_yin_name
--
   check_int_employee
                  (p_business_group_id            => p_business_group_id
	          ,p_national_identifier          => p_national_identifier
	          ,p_person_type_id               => p_person_type_id
	          ,p_effective_date               => p_hire_date
		  ,p_person_id                    => NULL
                  ,p_hukou_type                   => p_per_information4
                  ,p_hukou_location               => p_per_information5
                  ,p_highest_education_level      => p_per_information6
                  ,p_number_of_children           => p_per_information7
                  ,p_expatriate_indicator         => p_per_information8
                  ,p_health_status                => p_per_information10
                  ,p_tax_exemption_indicator      => p_per_information11
                  ,p_percentage                   => p_per_information12
                  ,p_race_ethnic_origin           => p_per_information17 );

  hr_cn_api.set_location(g_trace,'Leaving:'||l_proc,200);

EXCEPTION
    WHEN OTHERS THEN
    RAISE;

END check_employee;
--


--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_APPLICANT                                     --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the applicant.                                   --
--                  This procedure is the hook procedure for the        --
--                  applicant.                                          --
-- Parameters     :                                                     --
--             IN :   p_per_information4    VARCHAR2                    --
--                    p_per_information5    VARCHAR2                    --
--                    p_per_information6    VARCHAR2                    --
--                    p_per_information7    VARCHAR2                    --
--                    p_per_information8    VARCHAR2                    --
--                    p_per_information10   VARCHAR2                    --
--                    p_per_information11   VARCHAR2                    --
--                    p_per_information12   VARCHAR2                    --
--                    p_per_information17   VARCHAR2                    --
--                    p_business_group_id    NUMBER                     --
--                    p_national_identifier  VARCHAR                    --
--                    p_person_type_id       NUMBER,                    --
--                    p_effective_date       DATE,                      --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this procedure                    --
-- 1.1   09/01/03   statkar   Made changes as per ver 115.1             --
-- 1.2   10/01/03   statkar   Changed proc to call CHECK_INT_EMPLOYEE   --
-- 1.3   07/08/03   saikrish  Removed p_per_information14,              --
--                            p_per_information15 (3075230)             --
--------------------------------------------------------------------------
 PROCEDURE check_applicant(p_business_group_id    IN NUMBER
		          ,p_national_identifier  IN VARCHAR2
   		          ,p_person_type_id       IN NUMBER
   		          ,p_date_received        IN DATE
                          ,p_per_information4     IN VARCHAR2
                          ,p_per_information5     IN VARCHAR2
                          ,p_per_information6     IN VARCHAR2
                          ,p_per_information7     IN VARCHAR2
                          ,p_per_information8     IN VARCHAR2
                          ,p_per_information10    IN VARCHAR2
                          ,p_per_information11    IN VARCHAR2
                          ,p_per_information12    IN VARCHAR2
                          ,p_per_information17    IN VARCHAR2)
 IS

  --Declare local varialbles
  l_proc            VARCHAR2(72) := g_package||'check_applicant';

  BEGIN
--
   IF hr_cn_employee_api.g_trace OR hr_cn_applicant_api.g_trace THEN
       g_trace:=true;
   END IF;
--
   hr_cn_api.set_location(g_trace,'Entering:'|| l_proc,10);

--
-- Bug 3075230 Removed p_given_han_yu_pin_yin_name,p_family_han_yu_pin_yin_name
--
   check_int_employee(p_business_group_id            => p_business_group_id
	          ,p_national_identifier          => p_national_identifier
	          ,p_person_type_id               => p_person_type_id
	          ,p_effective_date               => p_date_received
		  ,p_person_id                    => NULL
                  ,p_hukou_type                   => p_per_information4
                  ,p_hukou_location               => p_per_information5
                  ,p_highest_education_level      => p_per_information6
                  ,p_number_of_children           => p_per_information7
                  ,p_expatriate_indicator         => p_per_information8
                  ,p_health_status                => p_per_information10
                  ,p_tax_exemption_indicator      => p_per_information11
                  ,p_percentage                   => p_per_information12
                  ,p_race_ethnic_origin           => p_per_information17 );

  hr_cn_api.set_location(g_trace,'Leaving:'||l_proc,200);

EXCEPTION
    WHEN OTHERS THEN
    RAISE;

END check_applicant;
--

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PERSON                                        --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the applicant.                                   --
--                  This procedure is the hook procedure for the        --
--                  applicant.                                          --
-- Parameters     :                                                     --
--             IN :   p_per_information4    VARCHAR2                    --
--                    p_per_information5    VARCHAR2                    --
--                    p_per_information6    VARCHAR2                    --
--                    p_per_information7    VARCHAR2                    --
--                    p_per_information8    VARCHAR2                    --
--                    p_per_information10   VARCHAR2                    --
--                    p_per_information11   VARCHAR2                    --
--                    p_per_information12   VARCHAR2                    --
--                    p_per_information17   VARCHAR2                    --
--                    p_national_identifier  VARCHAR                    --
--                    p_person_type_id       NUMBER,                    --
--                    p_effective_date       DATE,                      --
--                    p_person_id            NUMBER                     --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   09/01/03   statkar   Created this procedure                    --
-- 1.2   10/01/03   statkar   Changed proc to call CHECK_INT_EMPLOYEE   --
-- 1.1   31/01/03   statkar   Added a new cursor to fetch old value     --
--                            Bug 2767440                               --
-- 1.3   04/11/03   statkar   Bug 2900110 changes for Expat Indicator   --
-- 1.4   04/11/03   statkar   Bug 2900110 added NOT NULL for Expat      --
-- 1.5   07/08/03   saikrish  Removed p_per_information14,              --
--                            p_per_information15 (3075230)             --
-- 1.6   19/09/03   statkar   Added the hr_utility.chk_product_install  --
--                            check for installed CN leg (3145322)      --
-- 1.7   30/09/03   saikrish  Retrieved national_identifier (2902659)   --
--------------------------------------------------------------------------
 PROCEDURE check_person   (p_national_identifier  IN VARCHAR2
   		          ,p_person_type_id       IN NUMBER
   		          ,p_effective_date       IN DATE
			  ,p_person_id            IN NUMBER
                          ,p_per_information4     IN VARCHAR2
                          ,p_per_information5     IN VARCHAR2
                          ,p_per_information6     IN VARCHAR2
                          ,p_per_information7     IN VARCHAR2
                          ,p_per_information8     IN VARCHAR2
                          ,p_per_information10    IN VARCHAR2
                          ,p_per_information11    IN VARCHAR2
                          ,p_per_information12    IN VARCHAR2
                          ,p_per_information17    IN VARCHAR2)
 IS

  --Declare local varialbles
  l_proc            VARCHAR2(72) := g_package||'check_person';
  l_business_group_id   per_all_people_f.business_group_id%TYPE;

  l_tax_exemption_indicator    per_all_people_f.per_information11%TYPE;
  l_expatriate_indicator    per_all_people_f.per_information8%TYPE;
  l_percentage                 per_all_people_f.per_information12%TYPE;
  l_person_type_id             per_all_people_f.person_type_id%TYPE;
  l_national_identifier        per_all_people_f.national_identifier%TYPE;

  CURSOR csr_bg_per (p_person_id per_all_people_f.person_id%type,
                     p_effective_date in DATE) IS
       SELECT business_group_id
       FROM   per_all_people_f pap
       WHERE  pap.person_id = p_person_id
       AND    p_effective_date BETWEEN pap.effective_start_date and pap.effective_end_date;
--
-- Bug 2900110: Added the segment per_information8 to the list
--
--
-- Bug 3075230: Removed per_information14,per_information15
--
-- Bug 2902659: Added national_identifier
  CURSOR csr_per IS SELECT person_type_id, per_information11, per_information12, nvl(per_information8,'N')
                          ,national_identifier
                  FROM   per_all_people_f
		  WHERE  person_id = p_person_id
		  AND    p_effective_date BETWEEN effective_start_date
		                          AND     effective_end_date;

BEGIN
--
   IF hr_cn_employee_api.g_trace OR hr_cn_applicant_api.g_trace THEN
       g_trace:=true;
   END IF;
--
   hr_cn_api.set_location(g_trace,'Entering:'|| l_proc,10);
--
-- Bug 3145322 Check the leg-specific validations only if the legislation
--             is installed
--
   IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'CN') THEN
       hr_utility.trace ('CN Legislation not installed. Not performing the validations');
       hr_cn_api.set_location(g_trace,'Leaving: '||l_proc, 15);
       RETURN;
   END IF;

   OPEN csr_bg_per (p_person_id, p_effective_date) ;
   FETCH csr_bg_per INTO l_business_group_id;
     IF csr_bg_per%NOTFOUND THEN
            CLOSE csr_bg_per;
     	    hr_utility.set_message(800,'HR_7961_PER_BUS_GRP_INVALID');
     	    hr_utility.set_message_token('LEG_CODE','CN');
     	    hr_utility.raise_error;
     END IF;
   CLOSE csr_bg_per;

   OPEN csr_per;
   -- Removed l_family_hypy_name, l_given_hypy_name w.r.t bug 3075230
   FETCH csr_per INTO l_person_type_id, l_tax_exemption_indicator, l_percentage, l_expatriate_indicator
                     ,l_national_identifier;
   CLOSE csr_per;

   IF p_per_information11 <> hr_api.g_varchar2 THEN
       l_tax_exemption_indicator := p_per_information11;
   END IF;

   IF p_per_information12 <> hr_api.g_varchar2 THEN
       l_percentage := p_per_information12;
   END IF;

   IF p_national_identifier <> hr_api.g_varchar2 THEN
       l_national_identifier := p_national_identifier;
   END IF;


--
-- Bug 2900110: Added the following IF..END IF clause for Expat Indicator
--
   IF p_per_information8 <> hr_api.g_varchar2 and p_per_information8 IS NOT NULL THEN
       l_expatriate_indicator  := p_per_information8;
   END IF;

--
-- Validation to be carried out only for certain PTs
--
   hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_PERSON_TYPE_ID',
            p_argument_value   => p_person_type_id
            );

   IF p_person_type_id <> hr_api.g_number
   THEN
     l_person_type_id := p_person_type_id;
   END IF;

--
-- Bug 3075230 removed p_given_han_yu_pin_yin_name,p_family_han_yu_pin_yin_name
--
   check_int_employee(p_business_group_id         => l_business_group_id
	          ,p_national_identifier          => l_national_identifier
	          ,p_person_type_id               => l_person_type_id
	          ,p_effective_date               => p_effective_date
		  ,p_person_id                    => p_person_id
                  ,p_hukou_type                   => p_per_information4
                  ,p_hukou_location               => p_per_information5
                  ,p_highest_education_level      => p_per_information6
                  ,p_number_of_children           => p_per_information7
		  ,p_expatriate_indicator         => l_expatriate_indicator   -- Bug 2900110
                  ,p_health_status                => p_per_information10
                  ,p_tax_exemption_indicator      => l_tax_exemption_indicator
                  ,p_percentage                   => l_percentage
                  ,p_race_ethnic_origin           => p_per_information17 );

  hr_cn_api.set_location(g_trace,'Leaving:'||l_proc,200);

EXCEPTION
    WHEN OTHERS THEN
    RAISE;

END check_person;


END per_cn_emp_leg_hook;

/
