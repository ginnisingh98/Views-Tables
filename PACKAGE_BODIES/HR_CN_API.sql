--------------------------------------------------------
--  DDL for Package Body HR_CN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CN_API" AS
/* $Header: hrcnapi.pkb 120.3 2006/10/31 06:44:34 abhjain noship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : SET_LOCATION                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to set the location based on the trace    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     VARCHAR2                              --
--                  p_step        number                                --
--                  p_trace       VARCHAR2                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   30/12/02   statkar  Created this function                      --
--------------------------------------------------------------------------
PROCEDURE set_location (p_trace     IN   BOOLEAN
		       ,p_message   IN   VARCHAR2
                       ,p_step      IN   INTEGER
                       )
IS
BEGIN

     IF p_trace THEN
     	set_location(p_message, p_step);
     END IF;

END set_location;

----------------------------------------------------------------------------
--                                                                      --
-- Name           : SET_LOCATION                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to set the location irrespective of trace --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     VARCHAR2                              --
--                  p_step        number                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   30/12/02   statkar  Created this function                      --
---------------------------------------------------------------------------
PROCEDURE set_location (p_message   IN   VARCHAR2
                       ,p_step      IN   INTEGER
                       )
IS
BEGIN

     hr_utility.set_location(p_message, p_step);

END set_location;

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_LOOKUP                                        --
-- Type           : Procedure                                           --
-- Access         : Public                                            --
-- Description    : Function to validate the lookupcode in lookuptype   --
--                  Function will return true in case the lookupcode is --
--                  found in the lookuptype.Used in the check_employee. --
-- Parameters     :                                                     --
--             IN : p_value     VARCHAR2                  --
--                  p_lookup_name             VARCHAR2                  --
--         RETURN : Boolean                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01/03/03   statkar  Created this function                     --
---------------------------------------------------------------------------
PROCEDURE check_lookup (
            p_lookup_type      IN VARCHAR2,
            p_argument         IN VARCHAR2,
            p_argument_value   IN VARCHAR2
           )
IS

    l_lookup_code     hr_lookups.lookup_code%TYPE;
    --
    CURSOR csr_lookup(p_argument_value VARCHAR2,p_lookup_type VARCHAR2) IS
      SELECT lookup_code
      FROM   hr_lookups hrl
      WHERE  hrl.lookup_type = p_lookup_type
      AND    hrl.lookup_code = p_argument_value
      AND    enabled_flag    = 'Y';

BEGIN

--
-- Validation of the lookup value based on the lookup type
--

    OPEN csr_lookup(p_argument_value, p_lookup_type);
    FETCH csr_lookup INTO  l_lookup_code;

    IF csr_lookup%NOTFOUND THEN
       CLOSE csr_lookup;
       hr_utility.set_message(800,'HR_374602_INVALID_VALUE');
       hr_utility.set_message_token('VALUE',p_argument_value);
       hr_utility.set_message_token('FIELD',p_argument);
       hr_utility.raise_error;
    END IF;

    CLOSE csr_lookup;


EXCEPTION
      WHEN OTHERS THEN
        IF csr_lookup%ISOPEN  THEN
           CLOSE csr_lookup;
        END IF;
        RAISE;

END check_lookup;

--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_NUMBER                                           --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Procedure to check IF a value is numeric            --
-- Parameters     :                                                     --
--             IN : p_value                   VARCHAR2                  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   30/12/02   statkar  Created this procedure                     --
---------------------------------------------------------------------------

FUNCTION is_number
            (p_value         in      VARCHAR2)
RETURN BOOLEAN
IS
    l_number_value    number;
BEGIN
  --

  IF(p_value is NULL) THEN
    RETURN TRUE;
  ELSE
    Begin
       l_number_value := to_number(p_value);

    Exception
       WHEN VALUE_ERROR THEN
          RETURN FALSE;
    End;
    RETURN TRUE;
  END IF;
  --
END is_number;

--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_POSITIVE_INTEGER                                 --
-- Type           : Function                                            --
-- Access         : Public                                             --
-- Description    : Function to validate the char as positive integer   --
-- Parameters     :                                                     --
--             IN : p_value     VARCHAR2                  --
--         RETURN : Boolean                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this function                     --
-- 1.1   21/1/03    bramajey  changed the condition to p_value < 0 to   --
--                            allow the code flow to check for decimal  --
--------------------------------------------------------------------------
FUNCTION is_positive_integer
	(p_value IN NUMBER
        )
RETURN BOOLEAN IS

BEGIN

--
-- No validations IF the p_value is NULL
--
    IF p_value IS NULL THEN
       RETURN TRUE;
    END IF;

--
-- Check IF the number is positive
--

    IF p_value < 0 THEN
       RETURN FALSE;
    ELSE
    --
    -- Checking for decimal.
    --

       IF INSTR(p_value,'.') = 0 THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;
    --
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
           RAISE;

END is_positive_integer;
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_VALID_PERCENTAGE                                 --
-- Type           : Function                                            --
-- Access         : Public                                             --
-- Description    : Function to validate the char as positive percentage--
-- Parameters     :                                                     --
--             IN : p_value     VARCHAR2                                --
--         RETURN : Boolean                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this function                     --
-- 1.1   21/1/03    bramajey  Removed the check for decimal places      --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION is_valid_percentage
	(p_value IN NUMBER
  	)
RETURN BOOLEAN IS

BEGIN

--
-- No validations IF the p_value is NULL
--
    IF p_value IS NULL THEN
       RETURN TRUE;
    END IF;

--
-- Checking for valid range.
--

   IF ((p_value >= 0) and (p_value <=100)) THEN
       RETURN TRUE;
   ELSE
       RETURN FALSE;
   END IF;
    --
EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END is_valid_percentage;
--
--
--------------------------------------------------------------------------
-- Name           : IS_VALID_POSTAL_CODE                                --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : The function validates the postal code ,checks to   --
--                  see IF the postal code is a 6 digit value and that  --
--                  all digits are numbers,IF so returns true else false--
-- Parameters     :                                                     --
--             IN : p_value_to_be_checked     IN  VARCHAR2              --
--         RETURN : Boolean                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   vinaraya  Created this function                     --
-- 1.1   30/10/03   bramajey  Changed value of l_low_range from 100000  --
--                            to 1.                                     --
--                            Changed type of IN parameter from NUMBER  --
--                            to VARCHAR2.  (Bug 3226285)               --
--------------------------------------------------------------------------
FUNCTION is_valid_postal_code
	(p_value IN VARCHAR2
	)
RETURN BOOLEAN IS
    --
	-- Bug 3226285
    l_low_range    NUMBER;
    l_high_range   NUMBER;

BEGIN

    l_low_range  := 1;
    l_high_range := 999999;

--
-- No validations IF the p_value is NULL
--
    IF p_value IS NULL THEN
       RETURN TRUE;
    END IF;

--
-- Check IF the range is valid
--
	-- Bug 3226285
	-- added is_number conidtion
    IF is_number(p_value) AND (p_value BETWEEN l_low_range AND l_high_range) AND LENGTH(p_value) = 6  THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END is_valid_postal_code;

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
-- 1.0   14/04/03   statkar   Created this function                     --
-- 1.1   07/01/04   bramajey  Bug 3342105 Changes.                      --
--------------------------------------------------------------------------
FUNCTION chk_person_type (p_code in VARCHAR2)
RETURN BOOLEAN
IS
   TYPE t_pt_tbl  IS TABLE OF HR_LOOKUPS.LOOKUP_CODE%TYPE index by binary_integer;
   l_person_type         t_pt_tbl;
   l_loop_count          NUMBER ;

BEGIN

-- Change here in case any new PTs to be included

-- Bug 3342105
-- Removed PTs APL and EX_APL

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
    IF l_person_type(i) = p_code THEN
      RETURN TRUE;
    END IF;
  END LOOP;

  RETURN FALSE;

END chk_person_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ORGANIZATION                                  --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : The function checks IF the organization id          --
--                  belongs to the business group specIFied for the     --
--                  legislation             --
-- Parameters     :                                                     --
--             IN : p_organization_id     IN  NUMBER                    --
--                : p_business_group_id   IN  NUMBER                    --
--                  p_legislation_code    IN  NUMBER                    --
--                  p_effective_date      IN  DATE                      --
--         RETURN : Boolean                                             --
--                                                                      --
--------------------------------------------------------------------------
-- 1.0   30/12/02   statkar  Created this function                      --
-- 1.1   16/01/03   statkar  bug 2748967 added check for effective date --
---------------------------------------------------------------------------

PROCEDURE check_organization
		(p_organization_id   IN NUMBER
                ,p_business_group_id IN NUMBER
                ,p_legislation_code  IN VARCHAR2
-- Bug 2748967 changes start
		,p_effective_date    IN DATE
-- Bug 2748967 changes END
                )
IS

   CURSOR csr_org_id (p_business_group_id number, p_organization_id in number, p_effective_date in date) IS
           SELECT hou.organization_id
           FROM   hr_organization_units hou
           WHERE  hou.business_group_id = p_business_group_id
           AND    hou.organization_id   = p_organization_id
	   AND    p_effective_date   between  date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'));

   l_org_id    hr_organization_units.organization_id%type;

BEGIN

   check_bus_grp (p_business_group_id, p_legislation_code);

   OPEN csr_org_id (p_business_group_id, p_organization_id, p_effective_date);
   FETCH csr_org_id into l_org_id;
   	IF csr_org_id%NOTFOUND THEN
            CLOSE csr_org_id;
     	    hr_utility.set_message(800,'HR_374604_INVALID_ORG_CLASS');
     	    hr_utility.set_message_token('ORG',p_organization_id);
     	    hr_utility.raise_error;
        END IF;
   CLOSE csr_org_id;
EXCEPTION
      WHEN OTHERS THEN
           IF csr_org_id%ISOPEN THEN
           CLOSE csr_org_id;
           END IF;
      RAISE;
END check_organization;
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ORG_CLASS                                     --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : The function checks IF org classIFication is as per --
--                  the classIFication passed as a parameter            --
-- Parameters     :                                                     --
--             IN : p_organization_id     IN  NUMBER                    --
--                : p_classIFication      IN  VARCHAR2                  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   30/12/02   statkar   Created this function                     --
---------------------------------------------------------------------------
PROCEDURE check_org_class
		(p_organization_id   IN NUMBER
                ,p_classIFication    IN VARCHAR2
		)
IS

   CURSOR csr_org_class (p_organization_id number, p_classfication VARCHAR2) IS
          SELECT hrg.org_information_id
          FROM   hr_organization_information hrg
          WHERE  hrg.organization_id         = p_organization_id
          AND    hrg.org_information_context = p_classIFication;

   l_org_info_id  hr_organization_information.org_information_id%type;

BEGIN

    OPEN csr_org_class(p_organization_id, p_classIFication);
    FETCH csr_org_class into l_org_info_id;
	 IF csr_org_class%NOTFOUND THEN
             CLOSE csr_org_class;
	     hr_utility.set_message(800,'HR_374604_INVALID_ORG_CLASS');
   	     hr_utility.set_message_token('ORG',p_organization_id);
     	     hr_utility.raise_error;
         END IF;
    CLOSE csr_org_class;
EXCEPTION
      WHEN OTHERS THEN
           IF csr_org_class%ISOPEN THEN
           CLOSE csr_org_class;
           END IF;
      RAISE;

END check_org_class;
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ORG_TYPE                                      --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : The function checks IF org type is as per           --
--                  the type passed as a parameter                      --
-- Parameters     :                                                     --
--             IN : p_organization_id     IN  NUMBER                    --
--                : p_type                IN  VARCHAR2                  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   15/01/03   statkar   Created this function                     --
---------------------------------------------------------------------------
PROCEDURE check_org_type
		(p_organization_id   IN NUMBER
                ,p_type              IN VARCHAR2
		)
IS

   CURSOR csr_org_type (p_organization_id number, p_type VARCHAR2) IS
          SELECT hrg.org_information_id
          FROM   hr_organization_information hrg
          WHERE  hrg.organization_id         = p_organization_id
          AND    hrg.org_information1        = p_type
	  AND    hrg.org_information2        = 'Y';

   l_org_info_id  hr_organization_information.org_information_id%type;

BEGIN

    OPEN csr_org_type(p_organization_id, p_type);
    FETCH csr_org_type into l_org_info_id;
         IF csr_org_type%NOTFOUND THEN
             CLOSE csr_org_type;
	     hr_utility.set_message(800,'HR_374604_INVALID_ORG_CLASS');
   	     hr_utility.set_message_token('ORG',p_organization_id);
     	     hr_utility.raise_error;
         END IF;
    CLOSE csr_org_type;
EXCEPTION
      WHEN OTHERS THEN
           IF csr_org_type%ISOPEN THEN
           CLOSE csr_org_type;
           END IF;
      RAISE;

END check_org_type;

--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_CIN                                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the citizen identIFication num--
--                : CIN should be mandatory in case of Chinese EMP/APL  --
-- Parameters     :                                                     --
--             IN : p_business_group_id    NUMBER                       --
--                  p_national_identIFier  VARCHAR2,                    --
--                  p_person_type_id       NUMBER,                      --
--                  p_expatriate_indicator VARCHAR2,                    --
--                  p_effective_date       DATE,                        --
--                  p_person_id            NUMBER                       --
--                                                                      --
---------------------------------------------------------------------------
-- 1.0   09/01/03   statkar   Created this function                     --
-- 1.1   05/02/03   statkar   Additional PTU checks (Bug 2782045)       --
-- 1.2   14/03/03   statkar   Bug 2902744 changes for PTU               --
---------------------------------------------------------------------------
PROCEDURE check_cin
  		(  p_business_group_id      NUMBER,
		   p_national_identIFier    VARCHAR2,
   		   p_person_type_id         NUMBER,
   		   p_expatriate_indicator   VARCHAR2,
   		   p_effective_date         DATE,
   		   p_person_id              NUMBER
                 )
IS

  l_proc            VARCHAR2(50);
  l_system_person_type per_person_types.system_person_type%TYPE;

BEGIN

  l_proc  := g_package||'check_cin';

       IF p_person_type_id IS NULL THEN
--
-- This can happen only IF the procedure is called through EMPLOYEE/APPLICANT API.
-- But in such a case p_person_type_id will always be EMP/APL which is allowable
-- So only check for expat indicator
--
         IF p_expatriate_indicator ='N' AND p_national_identIFier IS NULL THEN
               hr_api.mandatory_arg_error
                     (p_api_name         => l_proc,
                      p_argument         => 'P_CITIZEN_IDENTIFICATION_NUMBER',
                      p_argument_value   => p_national_identIFier
                      );
         END IF;
--
      ELSE
--
-- This happens only IF the procedure is called through PERSON API.
-- We have ensured in CHECK_PERSON that p_person_type_id would have a valid NOT NULL value
--
           l_system_person_type := hr_person_type_usage_info.getsystempersontype (p_person_type_id);
--
-- ModIFied the 'LIKE' clause to read as 'IN' with explicit values.  10-Mar-2003 statkar.
--

           IF   hr_cn_api.chk_person_type(l_system_person_type)
	   THEN
--
		  IF p_expatriate_indicator ='N' AND p_national_identIFier IS NULL THEN
                       hr_api.mandatory_arg_error
                           (p_api_name         => l_proc,
                            p_argument         => 'P_CITIZEN_IDENTIFICATION_NUMBER',
                            p_argument_value   => p_national_identIFier
                            );
                  END IF;
--
           END IF;
       END IF;

EXCEPTION
      WHEN OTHERS THEN
         RAISE;
END check_cin;


--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_TAX_DEPENDENCE                                --
-- Type           : Procedure                                           --
-- Access         : Public                                             --
-- Description    : Procedure to validate the tax depENDence on         --
--                  the exemption indicator.                            --
--                  Exemption Indicator    Tax Percentage               --
--                  N                      Should be NULL               --
--                  Y                      Should be valid %            --
-- Parameters     :                                                     --
--             IN : p_tax_exemption_indicator VARCHAR2                  --
--                : p_percentage              VARCHAR2                  --
--            OUT : p_return_number           number                    --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this procedure                    --
-- 1.1   20/01/03   saikrish  Removed the check for value of            --
--                            Tax Exemption indicator as Y (Bug 2747251)--
--------------------------------------------------------------------------
PROCEDURE check_tax_depENDence
		( p_tax_exemption_indicator IN VARCHAR2
                 ,p_percentage              IN NUMBER
                 ) IS

    l_proc            VARCHAR2(72);

BEGIN

        l_proc := g_package||'check_tax_depENDence';

--
-- Validations IF the p_tax_exemption_indicator is NULL or 'N'
--
    IF (p_tax_exemption_indicator IS NULL) or (p_tax_exemption_indicator = 'N') THEN
       IF p_percentage IS NULL THEN
  	   RETURN;
       ELSE
           hr_utility.set_message(800,'HR_374605_INV_TAX_DEPENDENCE');
           hr_utility.raise_error;
       END IF;
    END IF;


EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END check_tax_depENDence;
--
----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_BUS_GRP                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Business Group            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id NUMBER                          --
--                  p_legislation_code  VARCHAR2                        --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01/03/03   statkar   Created this procedure                    --
--------------------------------------------------------------------------

PROCEDURE check_bus_grp (p_business_group_id IN NUMBER
                        ,p_legislation_code  IN VARCHAR2
                        )
IS

    CURSOR csr_bg IS
        SELECT legislation_code
        FROM per_business_groups pbg
        WHERE pbg.business_group_id = p_business_group_id;
      --
    l_legislation_code  per_business_groups.legislation_code%type;
BEGIN

   OPEN csr_bg;
--
     FETCH csr_bg
     INTO l_legislation_code;
--
     IF csr_bg%NOTFOUND THEN
        CLOSE csr_bg;
        hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
        hr_utility.raise_error;
      END IF;
      CLOSE csr_bg;
--
      IF l_legislation_code <> p_legislation_code THEN
        hr_utility.set_message(800, 'HR_7961_PER_BUS_GRP_INVALID');
        hr_utility.set_message_token('LEG_CODE','CN');
        hr_utility.raise_error;
      END IF;
EXCEPTION
    WHEN OTHERS THEN
       IF csr_bg%ISOPEN THEN
          CLOSE csr_bg;
       END IF;
       RAISE;

END check_bus_grp;


----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PERSON                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Business Group            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id         NUMBER                          --
--                  p_legislation_code  VARCHAR2                        --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01/03/03   statkar   Created this procedure                    --
---------------------------------------------------------------------------
PROCEDURE check_person (p_person_id         IN NUMBER
                       ,p_legislation_code  IN VARCHAR2
                       ,p_effective_date    IN DATE
                        )
IS
   l_legislation_code    per_business_groups.legislation_code%type;
   --
   CURSOR csr_emp_leg
      (c_person_id         per_people_f.person_id%TYPE,
       c_effective_date DATE
      )
   IS
      select bgp.legislation_code
      from per_people_f per,
           per_business_groups bgp
      where per.business_group_id = bgp.business_group_id
      and    per.person_id       = c_person_id
      and    c_effective_date  between per.effective_start_date and per.effective_END_date;

BEGIN

   OPEN csr_emp_leg(p_person_id, trunc(p_effective_date));
   FETCH csr_emp_leg into l_legislation_code;
   IF csr_emp_leg%notfound THEN
      CLOSE csr_emp_leg;
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
   END IF;
   CLOSE csr_emp_leg;

   --
   -- Check that the legislation of the specIFied business group is 'CN'.
   --
   IF l_legislation_code <> p_legislation_code THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','CN');
      hr_utility.raise_error;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF csr_emp_leg%ISOPEN THEN
          CLOSE csr_emp_leg;
       END IF;
          RAISE;

END check_person;

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Business Group            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_address_id         NUMBER                          --
--                  p_address_style     VARCHAR2                        --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01/03/03   statkar   Created this procedure                    --
---------------------------------------------------------------------------
PROCEDURE check_address (p_address_id  IN NUMBER
                        ,p_address_style IN VARCHAR2
                        )
IS

  l_style               per_addresses.style%TYPE;
  --
  CURSOR csr_add_style IS
    SELECT  style
    FROM    per_addresses
    WHERE   address_id = p_address_id;
  --
BEGIN

  OPEN  csr_add_style;
  FETCH csr_add_style
  INTO  l_style;
  IF csr_add_style%notfound THEN
    CLOSE csr_add_style;
    --
    hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  END IF;
    --
  CLOSE csr_add_style;
    --
  IF l_style <> p_address_style THEN
      hr_utility.set_message(801, 'HR_52505_INV_ADDRESS_STYLE');
      hr_utility.raise_error;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
       IF csr_add_style%ISOPEN THEN
          CLOSE csr_add_style;
       END IF;
          RAISE;
END check_address;


----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ASSIGNMENT                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Assignment                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id         NUMBER                       --
--                  p_legislation_code    VARCHAR2                      --
--                  p_effective_date       DATE                         --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01/03/03   statkar   Created this procedure                    --
---------------------------------------------------------------------------
PROCEDURE check_assignment
  (p_assignment_id          IN     NUMBER
  ,p_legislation_code       IN     VARCHAR2
  ,p_effective_date         IN     DATE
  )
IS
  --
  CURSOR legsel (p_assignment_id IN NUMBER, p_effective_date IN DATE) IS
    SELECT  pbg.legislation_code
    FROM    per_business_groups pbg,
            per_assignments_f   asg
    WHERE   pbg.business_group_id   = asg.business_group_id
    AND     asg.assignment_id       = p_assignment_id
    AND     p_effective_date BETWEEN asg.effective_start_date AND asg.effective_END_date;
  --
  l_legislation_code per_business_groups.legislation_code%type;
  --
BEGIN

  OPEN  legsel(p_assignment_id, trunc(p_effective_date));
  FETCH legsel
  INTO  l_legislation_code;
  --
  -- bug 2748967 modIFications start
  IF legsel%FOUND AND l_legislation_code = p_legislation_code THEN
     CLOSE legsel;
     RETURN;
  END IF;
-- bug 2748967 modIFications END

  IF legsel%notfound THEN
    CLOSE legsel;
    hr_utility.set_message(800, 'HR_7348_PPM_ASSIGNMENT_INVALID');
    hr_utility.raise_error;
  END IF;

  IF legsel%found AND l_legislation_code <> p_legislation_code THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'HR_374601_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;

  --
  CLOSE legsel;
EXCEPTION
  WHEN OTHERS THEN
    IF legsel%ISOPEN THEN
       CLOSE legsel;
    END IF;
       RAISE;

END check_assignment;

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PAYMENT_METHOD                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Payment Method            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_payment_method_id    NUMBER                       --
--                  p_legislation_code    VARCHAR2                      --
--                  p_effective_date       DATE                         --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01/03/03   statkar   Created this procedure                    --
---------------------------------------------------------------------------
PROCEDURE check_payment_method
  ( p_personal_payment_method_id    IN  NUMBER
    ,p_effective_date               IN  DATE
   , p_legislation_code             IN VARCHAR2
  )
IS

  --
  CURSOR legsel IS
    SELECT  pbg.legislation_code
    FROM    per_business_groups pbg,
            pay_personal_payment_methods_f ppm
    WHERE   pbg.business_group_id           = ppm.business_group_id
    AND     ppm.personal_payment_method_id  = p_personal_payment_method_id
    AND     p_effective_date BETWEEN ppm.effective_start_date AND ppm.effective_END_date;
--
  l_legislation_code per_business_groups.legislation_code%type;

BEGIN

  OPEN  legsel;
  FETCH legsel
  INTO  l_legislation_code;
  --
  IF legsel%notfound THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  END IF;

  IF legsel%found AND l_legislation_code <> p_legislation_code THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'HR_374601_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;
  --
  CLOSE legsel;
  --
EXCEPTION
  WHEN OTHERS THEN
    IF legsel%ISOPEN THEN
       CLOSE legsel;
    END IF;
       RAISE;

END check_payment_method;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PAY_MESSAGE                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to construct the message for FF            --
--                  This function is used to obtain a message.          --
--                  The token parameters must be of the form            --
--                  'TOKEN_NAME:TOKEN_VALUE' i.e.                       --
--                   If you want to set the value of a token called     --
--                   FUNCTION to CN_PHF_CALCULATION the token parameter --
--                   would be 'FUNCTION:CN_PHF_CALCULATION'             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message_name        VARCHAR2                      --
--                  p_token1              VARCHAR2                      --
--                  p_token2              VARCHAR2                      --
--                  p_token3              VARCHAR2                      --
--                  p_token4              VARCHAR2                      --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   20-May-03  statkar   Created this function                     --
-- 1.1   09-JUL-03  sshankar  Added fifth parameter p_token4,           --
--                            Bug 3038642                               --
-- 1.2  14-Jul-03   statkar   Bug 3047273. Changed the application_id   --
--                            from 801 to 800                           --
-- 1.3   21-Oct-03  saikrish  Bug 3198695. Truncated token value length --
--                            to 77 characters due to issues in psuedo  --
--                            translated environment                    --
---------------------------------------------------------------------------
FUNCTION get_pay_message
            (p_message_name      IN VARCHAR2
            ,p_token1            IN VARCHAR2 DEFAULT NULL
            ,p_token2            IN VARCHAR2 DEFAULT NULL
            ,p_token3            IN VARCHAR2 DEFAULT NULL
            ,p_token4            IN VARCHAR2 DEFAULT NULL  -- Bug 3038642
	    )
RETURN VARCHAR2

IS
   l_message        VARCHAR2(2000);
   l_token_name     VARCHAR2(20);
   l_token_value    VARCHAR2(80);
   l_colon_position NUMBER;
   l_proc           VARCHAR2(50);
   --
BEGIN

       l_proc := 'hr_cn_api.get_pay_message';

--
    set_location('Entered '||l_proc,5);
    set_location('.  Message Name: '||p_message_name,40);
--
-- Bug 3047273 Changed to 800 from 801
--
    hr_utility.set_message(800,p_message_name);
--
-- Truncated the token value to 77 characters, bug 3198695
--
   IF p_token1 IS NOT NULL THEN
      /* Obtain token 1 name and value */
      l_colon_position := INSTR(p_token1,':');
      l_token_name  := SUBSTR(p_token1,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token1,l_colon_position+1,LENGTH(p_token1)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location('.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
   END IF;

--
-- Truncated the token value to 77 characters, bug 3198695
--
   IF p_token2 IS NOT NULL  THEN
      /* Obtain token 2 name and value */
      l_colon_position := INSTR(p_token2,':');
      l_token_name  := SUBSTR(p_token2,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token2,l_colon_position+1,LENGTH(p_token2)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location('.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
   END IF;

--
-- Truncated the token value to 77 characters, bug 3198695
--
   IF p_token3 IS NOT NULL THEN
      /* Obtain token 3 name and value */
      l_colon_position := INSTR(p_token3,':');
      l_token_name  := SUBSTR(p_token3,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token3,l_colon_position+1,LENGTH(p_token3)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location('.  Token3: '||l_token_name||'. Value: '||l_token_value,70);
   END IF;

--
-- Added code to accomdate fourth parameter.
-- Modified by sshankar.
-- Bug 3038642
-- Start Bug 3038642
--
--
-- Truncated the token value to 77 characters, bug 3198695
--
   IF p_token4 IS NOT NULL THEN
      /* Obtain token 4 name and value */
      l_colon_position := INSTR(p_token4,':');
      l_token_name  := SUBSTR(p_token4,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token4,l_colon_position+1,LENGTH(p_token4)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location('.  Token4: '||l_token_name||'. Value: '||l_token_value,80);
   END IF;

--
-- End Bug 3038642
--

   l_message := SUBSTRB(hr_utility.get_message,1,250);

   set_location('leaving '||l_proc,100);
   RETURN l_message;

END get_pay_message;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_USER_TABLE_VALUE                                --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the user table value              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id   NUMBER                        --
--                  p_table_name          VARCHAR2                      --
--                  p_column_name         VARCHAR2                      --
--                  p_row_name            VARCHAR2                      --
--                  p_row_value           VARCHAR2                      --
--         RETURN : VARCHAR2                                            --
--            OUT : p_message             VARCHAR2                      --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   20-May-03  statkar   Created this function                     --
---------------------------------------------------------------------------
FUNCTION get_user_table_value
            (p_business_group_id      IN NUMBER
            ,p_table_name             IN VARCHAR2
            ,p_column_name            IN VARCHAR2
	    ,p_row_name               IN VARCHAR2
            ,p_row_value              IN VARCHAR2
	    ,p_effective_date         IN DATE
	    ,p_message                OUT NOCOPY VARCHAR2
	    )
RETURN VARCHAR2
IS
     l_value      pay_user_column_instances_f.value%TYPE;

BEGIN

     l_value  :=  hruserdt.get_table_value
                  ( p_bus_group_id      => p_business_group_id
		   ,p_table_name        => p_table_name
		   ,p_col_name          => p_column_name
		   ,p_row_value         => p_row_value
		   ,p_effective_date    => p_effective_date
		   );

     p_message := 'SUCCESS';
     RETURN l_value;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        p_message := hr_cn_api.get_pay_message
	            (
	             p_message_name    =>  'HR_374614_TAX_DETAILS_MISSING'
		    ,p_token1          =>  'TABLE:'||p_table_name
		    ,p_token2          =>  'VARIABLE:'||p_row_name
		    ,p_token3          =>  'VALUE:'||p_row_value
		     );
        RETURN NULL;

END get_user_table_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DFF_TL_VALUE                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the translated value              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_column_name         VARCHAR2                      --
--                  p_dff                 VARCHAR2                      --
--                  p_dff_context_code    VARCHAR2                      --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   03-Jul-03  saikrish  Created this function                     --
-- 1.1   09-Mar-06  rpalli    Modified cursor cur_prompt to resolve     --
--                            R12 perf issues. Bug 5043303              --
--------------------------------------------------------------------------
FUNCTION get_dff_tl_value(p_column_name      IN VARCHAR2
                         ,p_dff              IN VARCHAR2
			 ,p_dff_context_code IN VARCHAR2
			 )
RETURN VARCHAR2 IS

CURSOR cur_prompt IS
select t.form_left_prompt
from fnd_descr_flex_col_usage_tl t,
       fnd_descr_flex_column_usages b
where t.application_id                in (800, 801)
  and b.application_id                = t.application_id
  and t.descriptive_flexfield_name    = b.descriptive_flexfield_name
  and b.descriptive_flexfield_name    = p_dff
  and b.descriptive_flex_context_code = t.descriptive_flex_context_code
  and b.descriptive_flex_context_code = p_dff_context_code
  and b.application_column_name       = t.application_column_name
  and b.end_user_column_name          = p_column_name
  and t.language                      = userenv('LANG');

l_prompt     fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;

BEGIN

  OPEN cur_prompt;
  FETCH cur_prompt INTO l_prompt;
  CLOSE cur_prompt;

  RETURN l_prompt;

END get_dff_tl_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : RAISE_MESSAGE                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to raise the error message                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_application_id      NUMBER                        --
--                  p_message_name        VARCHAR2                      --
--                  p_token_name          HR_CN_API.CHAR_TAB_TYPE       --
--                  p_token_value         HR_CN_API.CHAR_TAB_TYPE       --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   15-Mar-05  snekkala  Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE raise_message(p_application_id IN NUMBER
		      ,p_message_name IN VARCHAR2
		      ,p_token_name   IN OUT NOCOPY hr_cn_api.char_tab_type
	              ,p_token_value  IN OUT NOCOPY hr_cn_api.char_tab_type
		      )IS
	     cnt NUMBER;
BEGIN

    IF p_message_name IS NOT NULL AND p_message_name <> 'SUCCESS' THEN
       cnt:= p_token_name.count;
       hr_utility.set_message(p_application_id, p_message_name);
       FOR i IN 1..cnt
       LOOP
           hr_utility.set_message_token(p_token_name(i),p_token_value(i));
       END LOOP;
       hr_utility.raise_error;
    END IF;

END raise_message;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_class_tl_name                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function  to raise the error message                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_classification_name      VARCHAR2                 --
--        RETURN  : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   12-May-06  lnagaraj  Created this procedure                    --
--------------------------------------------------------------------------

FUNCTION get_class_tl_name(p_classification_name IN VARCHAR2)
RETURN VARCHAR2
IS
l_trans_name pay_element_classifications_tl.classification_name%TYPE;

CURSOR csr_translated_value
IS
SELECT pectl.classification_name
FROM pay_element_classifications_tl pectl,
     pay_element_classifications pec
WHERE pec.classification_id = pectl.classification_id
  AND pectl.language =USERENV('LANG')
  AND pec.classification_name = DECODE(p_classification_name,'Voluntary Dedn','Voluntary Deductions',p_classification_name)
  AND pec.legislation_code='CN';

BEGIN
OPEN csr_translated_value;
FETCH csr_translated_value INTO l_trans_name;
CLOSE csr_translated_value;

RETURN l_trans_name ;

END get_class_tl_name;


BEGIN

     g_package := 'hr_cn_api.';

END hr_cn_api;

/
