--------------------------------------------------------
--  DDL for Package Body PER_IN_ADD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_ADD_LEG_HOOK" AS
/* $Header: peinlhad.pkb 120.3.12010000.2 2008/08/06 09:13:28 ubhat ship $ */
  p_cnt number;
  g_debug BOOLEAN;
  g_package          CONSTANT VARCHAR2(100) := 'per_in_add_leg_hook.';
  l_message  VARCHAR2(255);

  CURSOR csr_pin_codes IS
  SELECT lookup_code,
         meaning
    FROM hr_lookups
   WHERE lookup_type='IN_PIN_CODES';


  /*--------------------------------------------------------------------------
  -- Name           : CHECK_ADDRESS                                       --
  -- Type           : Procedure                                           --
  -- Access         : Private                                             --
  -- Description    : Procedure is the driver procedure for the validation--
  --                  of the address.                                     --
  -- Parameters     :                                                     --
  --             IN :       p_style               IN VARCHAR2             --
  --                        p_add_information15   IN VARCHAR2             --
  --                        p_postal_code         IN VARCHAR2             --
  --------------------------------------------------------------------------*/

  PROCEDURE check_address(p_style              IN VARCHAR2
                         ,p_add_information15  IN VARCHAR2 -- State
                         ,p_postal_code        IN VARCHAR2) AS

    l_proc             VARCHAR2(50) ;
    l_token            VARCHAR2(80);
    g_debug            BOOLEAN;
    l_procedure        VARCHAR2(100);
    l_message          VARCHAR2(255);
  /*--------------------------------------------------------------------------
  -- Name           : validate_pin_code                                   --
  -- Type           : Function                                            --
  -- Access         : Private                                             --
  -- Description    : This is the main function that performs pin code    --
  --                  validation of the address.                          --
  --------------------------------------------------------------------------*/

    FUNCTION validate_pin_code(p_state hr_lookups.lookup_code%TYPE,
                               p_postal_code hr_lookups.meaning%TYPE)
    RETURN BOOLEAN IS
      l_postal_code hr_lookups.meaning%TYPE;
      l_func VARCHAR2(72);
      g_debug BOOLEAN;
      l_state hr_lookups.lookup_code%TYPE;

    BEGIN
      g_debug := hr_utility.debug_enabled ;
      l_procedure := g_package ||'validate_pin_code';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

      IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_state',p_state);
	pay_in_utils.trace('p_postal_code',p_postal_code);
	pay_in_utils.trace('**************************************************','********************');
      END IF;

      l_postal_code :=substr(p_postal_code,1,2);
      select decode(p_state,'JH','BR','CG','MP',p_state) into l_state from dual;

      FOR i IN 1..tab_pin_code.COUNT LOOP
      --
       IF g_debug THEN
	 pay_in_utils.set_location(g_debug,l_procedure,20);
       END IF;

        IF instr(tab_pin_code(i).state_code,l_state)>0  THEN

	  IF g_debug THEN
	    pay_in_utils.set_location(g_debug,l_procedure,30);
          END IF;

          IF instr(tab_pin_code(i).pin_code,l_postal_code) =0 THEN
          --

            IF substr(tab_pin_code(i).pin_code,1,2)=substr(tab_pin_code(i).pin_code,-2,2) THEN
              l_token :=tab_pin_code(i).pin_code;

	      IF g_debug THEN
	        pay_in_utils.set_location(g_debug,l_procedure,40);
              END IF;
            ELSE
              l_token :=rtrim(tab_pin_code(i).pin_code,substr(tab_pin_code(i).pin_code,-3,3))||' or '||substr(tab_pin_code(i).pin_code,-2,2);

	      IF g_debug THEN
	        pay_in_utils.set_location(g_debug,l_procedure,50);
              END IF;

            END IF;

	    IF g_debug THEN
              pay_in_utils.set_location(g_debug,l_procedure,60);
	      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,70);
            END IF;
          --
            RETURN  FALSE;
          ELSE
            IF g_debug THEN
	      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
	    END IF;
            RETURN TRUE;
          END IF;
        END IF;
      --
      --
      END LOOP;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,90);
      RETURN FALSE;
    EXCEPTION
      WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
       RETURN FALSE;
    END;

  BEGIN
    g_debug := hr_utility.debug_enabled ;

    IF g_debug THEN
      l_procedure := g_package ||'check_address';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_style',p_style);
      pay_in_utils.trace('p_add_information15',p_add_information15);
      pay_in_utils.trace('p_postal_code',p_postal_code);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
      IF g_debug THEN
	pay_in_utils.trace('IN Legislation not installed. Not performing the validations','20');
      END IF;

      RETURN;
    END IF;

    IF g_debug THEN
      pay_in_utils.set_location(g_debug,l_procedure,30);
    END IF;
    --
    IF p_style='IN'  THEN

      IF p_postal_code IS NOT NULL AND   p_add_information15 IS NOT NULL THEN
        IF NOT validate_pin_code(p_add_information15,p_postal_code) THEN
          hr_utility.set_message(800,'PER_IN_INVALID_PIN_CODE');
          hr_utility.set_message_token('VALUE',l_token);
          hr_utility.raise_error;
        END IF;
      END IF;

    END IF;
    IF g_debug THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
    END IF;
/*
  EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
      hr_utility.set_message(800,'PER_IN_ORACLE_GENERIC_ERROR');
      hr_utility.set_message_token('FUNCTION',l_procedure);
      hr_utility.set_message_token('SQLERRMC',sqlerrm);
      hr_utility.raise_error;*/
  END check_address;

 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_PER_ADDRESS_INS                               --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of address of a person.                             --
 --                  This procedure is the hook procedure for the        --
 --                  address when address is inserted.                   --
 -- Parameters     :                                                     --
 --             IN :       p_style               IN VARCHAR2             --
 --                        p_address_id          IN VARCHAR2             --
 --                        p_add_information14   IN VARCHAR2             --
 --                        p_add_information15   IN VARCHAR2             --
 --                        p_postal_code         IN VARCHAR2             --
---------------------------------------------------------------------------
 PROCEDURE check_per_address_ins(p_style              IN VARCHAR2
				,p_address_id         IN NUMBER
				,p_add_information14  IN VARCHAR2
                                ,p_add_information15  IN VARCHAR2 -- State
                                ,p_postal_code        IN VARCHAR2)
 IS

   l_address_type VARCHAR2(30);
   l_proc VARCHAR2(50) ;
   l_get_migrator_status varchar2(1);
   g_debug BOOLEAN;
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(255);
 BEGIN
   g_debug := hr_utility.debug_enabled ;

   IF g_debug THEN
     l_procedure := g_package ||'check_per_address_ins';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_style',p_style);
     pay_in_utils.trace('p_address_id',p_address_id);
     pay_in_utils.trace('p_add_information14',p_add_information14);
     pay_in_utils.trace('p_add_information15',p_add_information15);
     pay_in_utils.trace('p_postal_code',p_postal_code);
     pay_in_utils.trace('**************************************************','********************');
   END IF;
   check_address (p_style              => p_style
                  ,p_add_information15  => p_add_information15
                  ,p_postal_code        => p_postal_code);
   IF g_debug THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
   END IF;

   IF p_style ='IN' THEN
     l_get_migrator_status:=hr_general.g_data_migrator_mode;

     hr_general.g_data_migrator_mode:='Y';
     IF UPPER(p_add_information14) IN ('DELHI','NEW DELHI','KOLKATA','CHENNAI','MUMBAI') THEN
       UPDATE per_addresses
       SET add_information16='Y'
       WHERE address_id =p_address_id;
     ELSE
      UPDATE per_addresses
      SET add_information16='N'
      WHERE address_id =p_address_id;
     END IF;
     hr_general.g_data_migrator_mode:=l_get_migrator_status;
  END IF;

  IF g_debug THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
  END IF;
/*
 EXCEPTION
   WHEN OTHERS THEN
    l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
    pay_in_utils.trace(l_message,l_procedure);
    RAISE;*/
 END check_per_address_ins;

--------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_LOC_ADDRESS_INS                               --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of address of a location.                           --
 --                  This procedure is the hook procedure for the        --
 --                  address when address is inserted.                   --
 -- Parameters     :                                                     --
 --             IN :       p_style               IN VARCHAR2             --
 --                        p_loc_information16   IN VARCHAR2             --
 --                        p_postal_code         IN VARCHAR2             --
---------------------------------------------------------------------------
 PROCEDURE check_loc_address_ins(p_style              IN VARCHAR2
                                ,p_loc_information16  IN VARCHAR2 -- State
                                ,p_postal_code        IN VARCHAR2)
 IS
 l_proc VARCHAR2(50);
 g_debug BOOLEAN;
 l_procedure VARCHAR2(100);
 l_message   VARCHAR2(255);
 BEGIN
   g_debug := hr_utility.debug_enabled ;

   IF g_debug THEN
     l_procedure := g_package ||'check_loc_address_ins';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_style',p_style);
     pay_in_utils.trace('p_loc_information16',p_loc_information16);
     pay_in_utils.trace('p_postal_code',p_postal_code);
     pay_in_utils.trace('**************************************************','********************');
   END IF;

   check_address (p_style              => p_style
                 ,p_add_information15  => p_loc_information16
                 ,p_postal_code        => p_postal_code);
  IF g_debug THEN
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  END IF;
/*
 EXCEPTION
   WHEN OTHERS THEN
     l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
     pay_in_utils.trace(l_message,l_procedure);
     RAISE;*/
 END check_loc_address_ins;


 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_PER_ADDRESS_UPD                               --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the address of a person.                         --
 --                  This procedure is the hook procedure for the        --
 --                  address when address is updated.                    --
 -- Parameters     :                                                     --
 --             IN :       p_address_id          IN NUMBER               --
 --                        p_add_information14   IN VARCHAR2             --
 --                        p_add_information15   IN VARCHAR2             --
 --                        p_postal_code         IN VARCHAR2             --
 --                                                                      --
 --------------------------------------------------------------------------
 PROCEDURE check_per_address_upd
                          (p_address_id          IN NUMBER
  			  ,p_add_information14   IN VARCHAR2
                          ,p_add_information15   IN VARCHAR2
                          ,p_postal_code         IN VARCHAR2)
 IS
   l_style     per_addresses.style%TYPE;
   l_get_migrator_status VARCHAR2(1);
   l_proc      VARCHAR2(50) ;
   g_debug BOOLEAN;
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(255);

   CURSOR csr_addr_style(p_address_id NUMBER)IS
   SELECT addr.style
     FROM   per_addresses addr
    WHERE  addr.address_id = p_address_id ;

 BEGIN
   g_debug := hr_utility.debug_enabled ;

   IF g_debug THEN
     l_procedure := g_package ||'check_per_address_upd';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_address_id',p_address_id);
     pay_in_utils.trace('p_add_information14',p_add_information14);
     pay_in_utils.trace('p_add_information15',p_add_information15);
     pay_in_utils.trace('p_postal_code',p_postal_code);
     pay_in_utils.trace('**************************************************','********************');
   END IF;

   OPEN csr_addr_style(p_address_id);
   FETCH csr_addr_style INTO l_style;
   CLOSE csr_addr_style;

   IF g_debug THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
   END IF;

   check_address (p_style              => l_style
                 ,p_add_information15  => p_add_information15
                 ,p_postal_code        => p_postal_code);

   IF g_debug THEN
     pay_in_utils.set_location(g_debug,l_procedure,30);
   END IF;

   IF l_style='IN' THEN
     l_get_migrator_status:=hr_general.g_data_migrator_mode;

     hr_general.g_data_migrator_mode:='Y';
     IF UPPER(p_add_information14) IN ('DELHI','NEW DELHI','KOLKATA','CHENNAI','MUMBAI') THEN
       UPDATE per_addresses
       SET add_information16='Y'
       WHERE address_id =p_address_id;
     ELSE
       UPDATE per_addresses
       SET add_information16='N'
       WHERE address_id =p_address_id;
     END IF;
     hr_general.g_data_migrator_mode:=l_get_migrator_status;
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);/*
   EXCEPTION
     WHEN OTHERS THEN
       IF csr_addr_style%ISOPEN THEN
          CLOSE csr_addr_style;
       END IF;
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;*/
  END check_per_address_upd;
 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : check_loc_address_upd                               --
  -- Type           : Procedure                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure is the driver procedure for the validation--
  --                  of address of a location.                           --
  --                  This procedure is the hook procedure for the        --
  --                  address when address is updated.                    --
  -- Parameters     :                                                     --
  --             IN :       p_address_id          IN NUMBER               --
  --                        p_loc_information16   IN VARCHAR2             --
  --                        p_postal_code         IN VARCHAR2             --
  --                                                                      --
  --------------------------------------------------------------------------
  PROCEDURE check_loc_address_upd(p_location_id          IN NUMBER
                                 ,p_loc_information16   IN VARCHAR2 -- State
                                 ,p_postal_code         IN VARCHAR2)
  IS
    l_style     per_addresses.style%TYPE;
    l_proc      VARCHAR2(50);
     g_debug BOOLEAN;
    l_procedure VARCHAR2(100);
    l_message   VARCHAR2(255);

    CURSOR csr_addr_style(p_location_id NUMBER)IS
    SELECT hl.style
    FROM   hr_locations_all hl
    WHERE  hl.location_id = p_location_id ;


  BEGIN
    g_debug := hr_utility.debug_enabled ;

    IF g_debug THEN
      l_procedure := g_package ||'check_loc_address_upd';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_location_id',p_location_id);
      pay_in_utils.trace('p_loc_information16',p_loc_information16);
      pay_in_utils.trace('p_postal_code',p_postal_code);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

    OPEN csr_addr_style(p_location_id);
    FETCH csr_addr_style INTO l_style;
    CLOSE csr_addr_style;

    IF g_debug THEN
      pay_in_utils.set_location(g_debug,l_procedure,20);
    END IF;

    check_address (p_style              => l_style
                  ,p_add_information15  => p_loc_information16
                  ,p_postal_code        => p_postal_code);
    IF g_debug THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
    END IF;/*
  EXCEPTION
    WHEN OTHERS THEN
      IF csr_addr_style%ISOPEN THEN
         CLOSE csr_addr_style;
      END IF;
     l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
     pay_in_utils.trace(l_message,l_procedure);
     RAISE;*/
  END  check_loc_address_upd;

  BEGIN

    g_debug := hr_utility.debug_enabled ;

    IF g_debug THEN
      pay_in_utils.set_location(g_debug,'Entering: '||g_package,10);
    END IF;
    p_cnt:=1;

    --
    -- Populate PL/SQL table with state_code and valid pin codes
    --

    OPEN csr_pin_codes;
    LOOP
    FETCH csr_pin_codes into tab_pin_code(p_cnt).state_code,tab_pin_code(p_cnt).pin_code;
    EXIT WHEN csr_pin_codes%NOTFOUND;
    p_cnt := p_cnt+1;
    END LOOP;
    CLOSE csr_pin_codes;

    IF g_debug THEN
      pay_in_utils.set_location(g_debug,g_package,20);
    END IF;

    pay_in_utils.set_location(g_debug,'Leaving: '||g_package,30);
  EXCEPTION
    WHEN OTHERS THEN
    --
    IF csr_pin_codes%ISOPEN THEN
      IF g_debug THEN
        pay_in_utils.set_location(g_debug,g_package,40);
      END IF;
      CLOSE csr_pin_codes;
    END IF;
    --
   l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'PACKAGE:'||g_package, 'SQLERRMC:'||sqlerrm);
   pay_in_utils.set_location(g_debug,'Leaving : '||g_package, 50);
   pay_in_utils.trace(l_message,g_package);
   RAISE;
  END per_in_add_leg_hook;

/
