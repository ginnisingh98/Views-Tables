--------------------------------------------------------
--  DDL for Package Body PER_CN_ADD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_ADD_LEG_HOOK" AS
/* $Header: pecnlhpa.pkb 115.8 2004/01/14 04:32:35 sshankar noship $ */
--
--
   g_trace boolean;

--------------------------------------------------------------------------
-- Name           : CHECK_ADDRESS                                       --
-- Type           : Procedure                                           --
-- Access         : Public                                             --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the address.                                     --
--                  This procedure is the hook procedure for the        --
--                  address.                                            --
-- Parameters     :                                                     --
--             IN :       p_address_line1       IN VARCHAR2             --
--                        p_town_or_city        IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--                        p_postal_code         IN VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this procedure                    --
-- 1.1   10/04/03   statkar   Nulled out this procedure - 2893334       --
--------------------------------------------------------------------------
PROCEDURE check_address(p_address_line1      IN VARCHAR2
                       ,p_town_or_city       IN VARCHAR2
                       ,p_country            IN VARCHAR2
                       ,p_postal_code        IN VARCHAR2)
AS
BEGIN
--
-- bug 2893334: Need to change the script to handle address style
-- However, the address leg hook seeding script (pecnpadd.sql) calls
-- CHECK_ADDRESS. This procedure is kept here for allowing compatibility
-- with that procedure. This procedure does nothing and is replaced with
-- CHECK_ADDRESS_UPD and CHECK_ADDRESS_INS for calls through the resp. APIS

   NULL;

END check_address;

--------------------------------------------------------------------------
-- Name           : CHECK_ADDRESS                                       --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the address.                                     --
--                  This procedure is the hook procedure for the        --
--                  address.                                            --
-- Parameters     :                                                     --
--             IN :       p_style               IN VARCHAR2             --
--                        p_address_line1       IN VARCHAR2             --
--                        p_town_or_city        IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--                        p_postal_code         IN VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   09/04/03   bramajey  Created this procedure                    --
-- 1.1   19/09/03   statkar   Added the hr_utility.chk_product_install  --
--                            check for installed CN leg (3145322)      --
-- 1.2   31/10/03   bramajey  Changed value of token LOW in message     --
--                            HR_374603_INVALID_RANGE from 100000 to    --
--                            000001 for bug 3226285                    --
--------------------------------------------------------------------------
PROCEDURE check_address(p_style              IN VARCHAR2
                       ,p_address_line1      IN VARCHAR2
                       ,p_town_or_city       IN VARCHAR2
                       ,p_country            IN VARCHAR2
                       ,p_postal_code        IN VARCHAR2) AS

     l_proc             VARCHAR2(72) := g_package||'check_address';
     l_territory_code   fnd_territories_vl.territory_code%TYPE;

     CURSOR csr_country (p_country VARCHAR2) IS
            SELECT territory_code
            FROM   fnd_territories_vl
            WHERE  territory_code = p_country;

  BEGIN

    g_trace := hr_cn_person_address_api.g_trace;

    hr_cn_api.set_location(g_trace,'Entering: '||l_proc,10);

--
-- Bug 3145322 Check the leg-specific validations only if the legislation
--             is installed
--
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'CN') THEN
       hr_utility.trace ('CN Legislation not installed. Not performing the validations');
       hr_cn_api.set_location(g_trace,'Leaving: '||l_proc, 15);
       RETURN;
  END IF;

  if p_style = 'CN_GLB' then
--
-- Check for the mandatory values
--
    hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_ADDRESS_LINE1',
            p_argument_value   => p_address_line1
           );

    hr_cn_api.set_location (g_trace, l_proc, 20);
    hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_COUNTRY',
            p_argument_value   => p_country
           );

    hr_cn_api.set_location (g_trace, l_proc, 30);
    hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_PROVINCE_CITY_SAR',
            p_argument_value   => p_town_or_city
           );

    hr_cn_api.set_location (g_trace, l_proc, 30);
    hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'P_POSTAL_CODE',
            p_argument_value   => p_postal_code
           );
--
-- Check the valid values for country
--
    hr_cn_api.set_location (g_trace, l_proc, 40);
    IF p_country <> hr_api.g_varchar2 THEN
    OPEN csr_country(p_country);
    FETCH csr_country INTO l_territory_code;
    IF csr_country%NOTFOUND THEN
       hr_cn_api.set_location (g_trace, l_proc, 50);
       CLOSE csr_country;
       hr_utility.set_message(800,'HR_374602_INVALID_VALUE');
       hr_utility.set_message_token('VALUE',p_country);
       hr_utility.set_message_token('FIELD','P_COUNTRY');
       hr_utility.raise_error;
    END IF;
    END IF;
--
-- Check the valid lookup values
--
    hr_cn_api.set_location (g_trace, l_proc, 60);
    IF p_town_or_city <> hr_api.g_varchar2 THEN
     hr_cn_api.check_lookup (
            p_lookup_type     => 'CN_PROVINCE',
            p_argument        => 'P_PROVINCE_CITY_SAR',
            p_argument_value  => p_town_or_city
           );
    END IF;

    hr_cn_api.set_location (g_trace, l_proc, 90);
    IF p_postal_code <> hr_api.g_varchar2 THEN
    IF NOT hr_cn_api.is_valid_postal_code(p_postal_code) THEN
       hr_cn_api.set_location (g_trace, l_proc, 100);
       hr_utility.set_message(800,'HR_374603_INVALID_RANGE');
       hr_utility.set_message_token('NUMBER','P_POSTAL_CODE');
 -- Bug 3226285
       hr_utility.set_message_token('LOW','000001');
       hr_utility.set_message_token('HIGH','999999');
       hr_utility.raise_error;
    END IF;
    END IF;

  END IF;

  hr_cn_api.set_location (g_trace, 'Leaving: '||l_proc, 100);

EXCEPTION
  WHEN OTHERS THEN
       IF csr_country%ISOPEN THEN
          CLOSE csr_country;
       END IF;
  RAISE;

END check_address;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS_INS                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the applicant.                                   --
--                  This procedure is the hook procedure for the        --
--                  address when address is inserted.                   --
-- Parameters     :                                                     --
--             IN :       p_style               IN VARCHAR2             --
--                        p_address_line1       IN VARCHAR2             --
--                        p_town_or_city        IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--                        p_postal_code         IN VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   09/04/03   bramajey  Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE check_address_ins(p_style               IN VARCHAR2
                           ,p_address_line1       IN VARCHAR2
                           ,p_town_or_city        IN VARCHAR2
                           ,p_country             IN VARCHAR2
                           ,p_postal_code         IN VARCHAR2)
IS
BEGIN

   check_address (p_style              => p_style
                 ,p_address_line1      => p_address_line1
                 ,p_town_or_city       => p_town_or_city
                 ,p_country            => p_country
                 ,p_postal_code        => p_postal_code);

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS_UPD                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the applicant.                                   --
--                  This procedure is the hook procedure for the        --
--                  address when address is updated.                    --
-- Parameters     :                                                     --
--             IN :       p_address_id          IN NUMBER               --
--                        p_address_line1       IN VARCHAR2             --
--                        p_town_or_city        IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--                        p_postal_code         IN VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   09/04/03   bramajey  Created this procedure                    --
-- 1.1   14/01/04   sshankar  Added parameter 'address_id' to procedure --
--                            and created cursor csr_addr_style to      --
--                            fetch address style.(Bug 3371417)         --
--------------------------------------------------------------------------
PROCEDURE check_address_upd
                         (p_address_id          IN NUMBER
                         ,p_address_line1       IN VARCHAR2
                         ,p_town_or_city        IN VARCHAR2
                         ,p_country             IN VARCHAR2
                         ,p_postal_code         IN VARCHAR2)
IS

     l_style     per_addresses.style%TYPE := 'CN_GLB';

--
-- Bug 3371417
-- Added Cursor to fetch addres style from per_addresses
--
     l_proc      VARCHAR2(72) := g_package||'check_address_upd';

     CURSOR csr_addr_style(p_address_id NUMBER)IS
            SELECT addr.style
            FROM   per_addresses addr
            WHERE  addr.address_id = p_address_id ;


BEGIN

--
-- Bug 3371417
-- Changes Starts
-- Added code to fetch address style.
--
   g_trace := hr_cn_person_address_api.g_trace;

   hr_cn_api.set_location(g_trace,'Entering: '||l_proc,10);

   OPEN csr_addr_style(p_address_id);
   FETCH csr_addr_style INTO l_style;

   IF csr_addr_style%NOTFOUND THEN
      l_style := 'CN_GLB';
   END IF;

   CLOSE csr_addr_style;

--
-- Bug 3371417
-- Changes End
--

   check_address (p_style              => l_style
                 ,p_address_line1      => p_address_line1
                 ,p_town_or_city       => p_town_or_city
                 ,p_country            => p_country
                 ,p_postal_code        => p_postal_code);

   hr_cn_api.set_location(g_trace,'Leaving: '||l_proc,20);

END check_address_upd;


END per_cn_add_leg_hook;

/
