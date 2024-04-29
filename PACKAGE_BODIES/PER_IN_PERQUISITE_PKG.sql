--------------------------------------------------------
--  DDL for Package Body PER_IN_PERQUISITE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_PERQUISITE_PKG" as
/* $Header: peinperq.pkb 120.7.12010000.7 2010/01/12 06:50:32 mdubasi ship $ */

--
-- Globals
--
g_package   constant VARCHAR2(100) := 'per_in_perquisite_pkg.' ;
g_debug     BOOLEAN ;



PROCEDURE check_element_entry(p_effective_date     IN DATE
                             ,p_element_entry_id     IN NUMBER
		             ,p_effective_start_date IN DATE
		             ,p_effective_end_date   IN DATE
			     ,p_calling_procedure    IN VARCHAR2
			     ,p_message_name         OUT NOCOPY VARCHAR2
                             ,p_token_name           OUT NOCOPY pay_in_utils.char_tab_type
                             ,p_token_value          OUT NOCOPY pay_in_utils.char_tab_type
                              ) IS
/* Cursor to find the element name of the current element entry */

    CURSOR c_perquisite_name IS
    SELECT pet.element_information1
          ,pet.element_type_id
	  ,pee.assignment_id
      FROM pay_element_types_f pet
          ,pay_element_entries_f pee
     WHERE pet.element_type_id =pee.element_type_id
       AND pee.element_entry_id =p_element_entry_id
       AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
       AND p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;


 /* Cursor to find the Screen entry value and entry value id for the current entry on effective date and given an input value */
    CURSOR c_curr_entry_value  (p_element_entry_id NUMBER
                               ,p_input_name       VARCHAR2
			       ,p_element_type_id  NUMBER)
        IS
    SELECT  peev.screen_entry_value,
            peev.element_entry_value_id
      FROM  pay_element_entry_values_f peev
           ,pay_input_values_f piv
     WHERE  peev.element_entry_id = p_element_entry_id
       AND  piv.name = p_input_name
       AND  peev.input_value_id = piv.input_value_id
       AND  piv.element_Type_id = p_element_type_id
       AND  p_effective_date BETWEEN peev.effective_start_date
                                 AND peev.effective_end_date
       AND  p_effective_Date BETWEEN piv.effective_start_date
                                 AND piv.effective_end_date;


   /* Cursor to find the the global value as on effective date */
    CURSOR c_global_value(l_global_name VARCHAR2) IS
    SELECT global_value
      from ff_globals_f ffg
     WHERE ffg.global_name = l_global_name
       AND p_effective_date BETWEEN ffg.effective_start_date AND ffg.effective_end_date;

  /* Cursor to find input value id given the element and input value name*/
   CURSOR c_input_value_id(p_element_type_id NUMBER
                          ,p_input_name VARCHAR2)
       IS
   SELECT piv.input_value_id
     FROM pay_input_values_f piv
    WHERE piv.element_type_id = p_element_type_id
      AND piv.NAME = p_input_name
      AND p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date;


  /* Cursor to find the number of entries with entry value as 'Motor Car' and that overlap
     in 'Motor Car' Perquisite */
  CURSOR c_element_entries( p_element_type_id NUMBER
                           ,p_assignment_id NUMBER
			   ,p_input_value_id NUMBER -- type of automotive
			   ,p_input_value_id_start NUMBER -- benefit start
			   ,p_input_value_id_end NUMBER -- benefit end
			   ,l_benefit_start_date DATE
			   ,l_benefit_end_date DATE)
      IS
  SELECT pee.element_entry_id
        ,pee.effective_start_date
    FROM pay_element_entries_f pee
        ,pay_element_entry_values_f peev1
	,pay_element_entry_values_f peev2
	,pay_element_entry_values_f peev3
    WHERE pee.assignment_id = p_assignment_id
      AND pee.element_type_id =	p_element_type_id
      and pee.element_entry_id =peev1.element_entry_id
      AND peev1.input_value_id = p_input_value_id
      and peev1.screen_entry_value ='CAR'
      and pee.element_entry_id =peev2.element_entry_id
      AND peev2.input_value_id = p_input_value_id_start
      and pee.element_entry_id =peev3.element_entry_id
      AND peev3.input_value_id = p_input_value_id_end
      AND fnd_date.canonical_to_date(peev2.screen_entry_value) <= nvl(l_benefit_end_date,to_date('31-12-4712','DD-MM-YYYY'))
      AND nvl(fnd_date.canonical_to_date(peev3.screen_entry_value),to_date('31-12-4712','DD-MM-YYYY'))   >= l_benefit_start_date
      AND pee.element_entry_id <> p_element_entry_id   -- Bugfix 4049484
      AND p_effective_date BETWEEN pee.effective_start_date   and pee.effective_end_date
      AND p_effective_date BETWEEN peev1.effective_start_date and peev1.effective_end_date
      AND p_effective_date BETWEEN peev2.effective_start_date and peev2.effective_end_date
      AND p_effective_date BETWEEN peev3.effective_start_date and peev3.effective_end_date;


  /* Cursor to find the Screen entry value  for the given entry on given date and given an input value id */
   CURSOR c_element_entry_values(p_el_entry_id NUMBER
                                ,p_inp_value_id NUMBER
                                ,p_eff_start_date DATE) IS
   SELECT peev.screen_entry_value
     FROM pay_element_entry_values_f peev
    WHERE peev.element_entry_id = p_el_entry_id
      AND peev.input_value_id = p_inp_value_id
      AND p_eff_start_date BETWEEN peev.effective_start_date AND peev.effective_end_date;

   CURSOR c_element_entry_details(p_element_entry_id    NUMBER)
   IS
      SELECT pee.effective_start_date
            ,pet.element_type_id
            ,pee.assignment_id
        FROM pay_element_entries_f pee
            ,pay_element_types_f   pet
            ,pay_element_links_f   links
       WHERE pee.element_entry_id  = p_element_entry_id
         AND pet.element_type_id   = links.element_type_id
         AND links.element_link_id = pee.element_link_id
         AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
         AND p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

    l_get_migrator_status VARCHAR2(1);
    l_procedure VARCHAR2(100);

    l_dep_value1 pay_element_entry_values_f.screen_entry_value%TYPE;
    l_dep_value2  pay_element_entry_values_f.screen_entry_value%TYPE;

    TYPE tab_input_value_id IS TABLE OF pay_input_values_f.input_value_id%TYPE INDEX BY BINARY_INTEGER;
    l_input_value_id  tab_input_value_id;

    TYPE tab_element_entry_value IS TABLE OF pay_element_entry_values_f.screen_entry_value%TYPE INDEX BY BINARY_INTEGER;
    l_element_entry_value  tab_element_entry_value;

    TYPE tab_element_entry_id IS TABLE OF pay_element_entries_f.element_entry_id%TYPE INDEX BY BINARY_INTEGER;
    l_element_entry_id  tab_element_entry_id;

     TYPE tab_element_type_id IS TABLE OF pay_element_types_f.element_type_id%TYPE INDEX BY BINARY_INTEGER;
    l_element_type_id_tab  tab_element_type_id;

    l_entry_value_id  NUMBER;
    i NUMBER ;
    l_exempted NUMBER;
    l_element_name pay_element_types_f.element_name %TYPE;
    l_element_type_id NUMBER;
    l_assignment_id NUMBER;


    p_input_value_id NUMBER;
    l_gbl_value NUMBER;
    l_entry_id  NUMBER;

    l_element_start_date DATE;
    l_inputvalue_id      NUMBER;
--
-- Start of private procedures
--
---------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_BENEFIT_DATES                                 --
 -- Type           : Procedure                                           --
 -- Access         : Private                                             --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of Benefit Dates of a Perquisite.                   --
 --                  This procedure is the hook procedure for the        --
 --                  when an element entry is created                    --
 -- Parameters     :                                                     --
 --             IN :       l_element_entry_id        IN   number         --

---------------------------------------------------------------------------

PROCEDURE check_benefit_dates(l_element_entry_id number)
IS
  l_benefit_start_date pay_element_entry_values_f.screen_entry_value%TYPE;
  l_benefit_end_date   pay_element_entry_values_f.screen_entry_value%TYPE;
  l_procedure VARCHAR2(100);
BEGIN

  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'check_benefit_dates' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('l_element_entry_id            : ',l_element_entry_id);
  pay_in_utils.trace('******************************','********************');
end if;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  l_get_migrator_status:=hr_general.g_data_migrator_mode;
  hr_general.g_data_migrator_mode:='Y';
  pay_in_utils.set_location(g_debug,l_procedure,20);

  /* Default the benefit Start date to element Entry Start Date */
  OPEN c_curr_entry_value(p_element_entry_id,'Benefit Start Date',l_element_type_id);
  FETCH c_curr_entry_value into l_benefit_start_date,l_entry_value_id;
if g_debug then
  pay_in_utils.trace('l_benefit_start_date            : ',l_benefit_start_date);
  pay_in_utils.trace('l_entry_value_id                : ',l_entry_value_id);
end if;
    IF l_benefit_start_date IS NULL THEN
        pay_in_utils.set_location(g_debug,l_procedure,30);
        UPDATE pay_element_entry_values_f
	   SET screen_entry_value = to_char(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
         WHERE element_entry_value_id =l_entry_value_id
	   AND effective_start_date =p_effective_start_date;
    END IF;
    pay_in_utils.set_location(g_debug,l_procedure,40);
    hr_general.g_data_migrator_mode:=l_get_migrator_status;
  CLOSE c_curr_entry_value;

  pay_in_utils.set_location(g_debug,l_procedure,50);

  OPEN c_curr_entry_value(p_element_entry_id,'Benefit End Date',l_element_type_id);
  FETCH c_curr_entry_value INTO l_benefit_end_date,l_entry_value_id;
  CLOSE c_curr_entry_value;

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('l_benefit_end_date              : ',l_benefit_end_date);
  pay_in_utils.trace('l_entry_value_id                : ',l_entry_value_id);
  pay_in_utils.trace('******************************','********************');
end if;

  pay_in_utils.set_location(g_debug,l_procedure,60);

  /* Check that Benefit End is not earlier than Benefit Start */
  IF (nvl(TRUNC(to_date(l_benefit_start_date,'YYYY/MM/DD HH24:MI:SS')),p_effective_start_date)> TRUNC(to_date(l_benefit_end_date,'YYYY/MM/DD HH24:MI:SS'))) THEN
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,70);
    p_message_name := 'PER_IN_INCORRECT_DATES';
    RETURN;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_curr_entry_value%ISOPEN THEN CLOSE c_curr_entry_value ; END IF;
      pay_in_utils.set_location(g_debug,'Leaving FROM Exception Block : '||l_procedure,80);
      p_message_name := 'PER_IN_ORACLE_GENERIC_ERROR';
      p_token_name(1) := 'FUNCTION';
      p_token_value(1) := l_procedure;
      p_token_name(1) := 'SQLERRMC';
      p_token_value(1) := sqlerrm;
END ;

---------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_LOAN_ENTRY                                    --
 -- Type           : Procedure                                           --
 -- Access         : Private                                             --
 -- Description    : Procedure is the driver procedure for the Updating  --
 --                  Taxable Flag of Loan Perquisite.                    --
 -- Parameters     :                                                     --
 --             IN :       l_element_name        IN   VARCHAR2           --
 --                        l_element_type_id     IN   NUMBER             --
 --                        l_assignment_id     IN   NUMBER               --
---------------------------------------------------------------------------
PROCEDURE check_loan_entry(l_element_name    VARCHAR2,
                               l_element_Type_id NUMBER,
                               l_assignment_id   NUMBER) IS

      CURSOR c_entries_start_tax_yr(p_tax_year_start DATE, p_assignment_id NUMBER, p_element_name varchar2) IS
        SELECT pee.element_entry_id,pet.element_type_id
          FROM pay_element_entries_f pee,pay_element_types_f pet
         WHERE pee.assignment_id = p_assignment_id
          AND pee.element_type_id = pet.element_type_id
          AND pet.element_information1 = p_element_name
         GROUP BY pee.element_entry_id,pet.element_type_id
        HAVING MIN(pee.effective_start_date) >= p_tax_year_start;

      l_tax_year_start          DATE;
      p_cnt                     number;
      l_principal_amt_in_tax_yr NUMBER;
      l_curr_principal_amt      NUMBER;
      l_loan_input_value_id     tab_input_value_id;
      l_tax_input_value_id      tab_input_value_id;
      l_procedure               VARCHAR2(100);
      l_loan_type               pay_element_entry_values_f.screen_entry_value%TYPE;
      l_loan_interest_type      pay_element_entry_values_f.screen_entry_value%TYPE;

    BEGIN

      g_debug     := hr_utility.debug_enabled;
      l_procedure := g_package || 'check_loan_entry';
      pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

      if g_debug then
        pay_in_utils.trace('******************************',
                           '********************');
        pay_in_utils.trace('l_element_name                  : ',
                           l_element_name);
        pay_in_utils.trace('l_element_Type_id               : ',
                           l_element_Type_id);
        pay_in_utils.trace('l_assignment_id                 : ',
                           l_assignment_id);
        pay_in_utils.trace('******************************',
                           '********************');
      end if;

      p_message_name := 'SUCCESS';
      pay_in_utils.null_message(p_token_name, p_token_value);

      pay_in_utils.set_location(g_debug,
                                'Effective Date: ' || p_effective_date,
                                20);

      /*Check for Additional Information Begins*/

      OPEN c_input_value_id(l_element_type_id, 'Additional Information');
      FETCH c_input_value_id
        INTO p_input_value_id;
      CLOSE c_input_value_id;

      if g_debug then
        pay_in_utils.trace('p_input_value_id                 : ',
                           p_input_value_id);
      end if;

      pay_in_utils.set_location(g_debug, l_procedure, 12);
      IF p_input_value_id IS NOT NULL THEN
        /*Check made so that previous created elements without input value 'Additional Information' works.*/
        OPEN c_element_entry_values(p_element_entry_id,
                                    p_input_value_id,
                                    p_effective_date);
        FETCH c_element_entry_values
          INTO l_loan_interest_type;
        CLOSE c_element_entry_values;

        if g_debug then
          pay_in_utils.trace('l_loan_interest_type                 : ',
                             l_loan_interest_type);
        end if;

        OPEN c_input_value_id(l_element_type_id, 'Loan Type');
        FETCH c_input_value_id
          INTO p_input_value_id;
        CLOSE c_input_value_id;

        if g_debug then
          pay_in_utils.trace('p_input_value_id                 : ',
                             p_input_value_id);
        end if;

        pay_in_utils.set_location(g_debug, l_procedure, 12);

        OPEN c_element_entry_values(p_element_entry_id,
                                    p_input_value_id,
                                    p_effective_date);
        FETCH c_element_entry_values
          INTO l_loan_type;
        CLOSE c_element_entry_values;

        IF g_debug THEN
          pay_in_utils.trace('l_loan_type                 : ', l_loan_type);
        END IF;

        IF l_loan_type = 'HOUSING' THEN
          IF l_loan_interest_type IS NULL THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
            p_token_name(1) := 'TOKEN1';
            p_token_value(1) := 'Additional Information';
            p_token_name(2) := 'TOKEN2';
            p_token_value(2) := 'Loan Type';
            p_token_name(3) := 'TOKEN3';
            p_token_value(3) := 'Housing Loan';
            RETURN;
          ELSIF l_loan_interest_type NOT IN
                ('HL_FIXED_RURAL', 'HL_FIXED_URBAN', 'HL_FLOATING_RURAL',
                 'HL_FLOATING_URBAN') THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
            p_token_name(1) := 'TOKEN';
            p_token_value(1) := 'Loan Type and Additional Information';
            RETURN;
          END IF;
        ELSIF l_loan_type = 'CAR' THEN
          IF l_loan_interest_type IS NULL THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
            p_token_name(1) := 'TOKEN1';
            p_token_value(1) := 'Additional Information';
            p_token_name(2) := 'TOKEN2';
            p_token_value(2) := 'Loan Type';
            p_token_name(3) := 'TOKEN3';
            p_token_value(3) := 'Car Loan';
            RETURN;
          ELSIF l_loan_interest_type NOT IN ('CAR_NEW', 'CAR_USED') THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
            p_token_name(1) := 'TOKEN';
            p_token_value(1) := 'Loan Type and Additional Information';
            RETURN;
          END IF;
        ELSIF l_loan_type = 'TWOWHEELER' THEN
          IF l_loan_interest_type IS NULL THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
            p_token_name(1) := 'TOKEN1';
            p_token_value(1) := 'Additional Information';
            p_token_name(2) := 'TOKEN2';
            p_token_value(2) := 'Loan Type';
            p_token_name(3) := 'TOKEN3';
            p_token_value(3) := 'Two Wheeler Loan';
            RETURN;
          ELSIF l_loan_interest_type NOT IN ('TWL_FIXED', 'TWL_FLOATING') THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
            p_token_name(1) := 'TOKEN';
            p_token_value(1) := 'Loan Type and Additional Information';
            RETURN;
          END IF;
	ELSIF l_loan_type = 'EDUCATION' THEN
          IF p_effective_start_date >= TO_DATE('01-04-2009','DD-MM-YYYY') THEN
          IF l_loan_interest_type NOT IN ('EL_BOYS','EL_GIRLS') THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
            p_token_name(1) := 'TOKEN';
            p_token_value(1) := 'Loan Type and Additional Information';
            RETURN;
          END IF;
          END IF;
        ELSIF l_loan_type = 'MORTGAGE' THEN
	  IF p_effective_start_date >= TO_DATE('01-04-2008','DD-MM-YYYY') THEN
          IF l_loan_interest_type IS NULL THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
            p_token_name(1) := 'TOKEN1';
            p_token_value(1) := 'Additional Information';
            p_token_name(2) := 'TOKEN2';
            p_token_value(2) := 'Loan Type';
            p_token_name(3) := 'TOKEN3';
            p_token_value(3) := 'Mortgage Loan';
            RETURN;
        ELSIF l_loan_interest_type NOT IN ('MRTAGE_IMMOVABLE', 'MRTAGE_GOLD') THEN
            pay_in_utils.set_location(g_debug,
                                      'Leaving: ' || l_procedure,
                                      100);
            p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
            p_token_name(1) := 'TOKEN';
            p_token_value(1) := 'Loan Type and Additional Information';
            RETURN;
          END IF;
	  END IF;
        END IF;
      END IF;
      /*Check for Additional Information Ends*/

      /* Start - Get entries of loan availed in current tax year */
      l_tax_year_start := pay_in_tax_utils.get_financial_year_start(p_effective_date);
      pay_in_utils.set_location(g_debug,
                                'Tax Year Start: ' || l_tax_year_start,
                                30);

      p_cnt := 0;
      FOR i IN c_entries_start_tax_yr(l_tax_year_start,
                                      l_assignment_id,
                                      l_element_name) LOOP
        l_element_entry_id(p_cnt) := i.element_entry_id;
        l_element_type_id_tab (p_cnt) := i.element_type_id;
       /*Added for the bugfix 6469684*/
       OPEN  c_input_value_id(l_element_type_id_tab (p_cnt), 'Loan Principal Amount');
       FETCH c_input_value_id
        INTO l_loan_input_value_id(p_cnt);
       CLOSE c_input_value_id;

      OPEN  c_input_value_id(l_element_type_id_tab(p_cnt), 'Taxable Flag');
      FETCH c_input_value_id
       INTO l_tax_input_value_id(p_cnt);
      CLOSE c_input_value_id;
        p_cnt := p_cnt + 1;
      END LOOP;
      /* End - Get entries of loan avialed in current tax year */

      pay_in_utils.set_location(g_debug, 'Entry Count: ' || p_cnt, 40);
      l_principal_amt_in_tax_yr := 0;

      /* Start - Find the sum of Loan Principal Amount*/
      FOR j IN 0 .. p_cnt - 1 LOOP
        pay_in_utils.set_location(g_debug,
                                  'Entry id  and Input value id : ' ||
                                  l_element_entry_id(j) || l_loan_input_value_id(j),
                                  50);

        OPEN c_element_entry_values(l_element_entry_id(j),
                                    l_loan_input_value_id(j),
                                    p_effective_date);
        FETCH c_element_entry_values
          INTO l_curr_principal_amt;

        l_principal_amt_in_tax_yr := l_principal_amt_in_tax_yr +
                                     nvl(l_curr_principal_amt, 0);

        CLOSE c_element_entry_values;
      END LOOP;
      /* End - Find the sum of Loan Principal Amount*/

      OPEN c_global_value('IN_MAX_LOAN_AMT_EXEMPTION');
      FETCH c_global_value
        INTO l_gbl_value;
      CLOSE c_global_value;

      pay_in_utils.set_location(g_debug,
                                'Total Principal Amount: ' ||
                                l_principal_amt_in_tax_yr,
                                60);
      --
      --  start - Check if exemption limit is exceeded
      --


      l_get_migrator_status           := hr_general.g_data_migrator_mode;
      hr_general.g_data_migrator_mode := 'Y';

      IF l_principal_amt_in_tax_yr > l_gbl_value then
        /* Update the Taxable Flag to 'Y' when limit is exceeded */
        FOR j IN 0 .. P_CNT - 1 LOOP

          pay_in_utils.set_location(g_debug,
                                    'Changing the following entries : ' ||
                                    l_element_entry_id(j),
                                    70);
          UPDATE pay_element_entry_values_f peev
             SET peev.screen_entry_value = 'Y'
           WHERE peev.element_entry_id = l_element_entry_id(j)
             AND peev.input_value_id = l_tax_input_value_id(j)
             AND p_effective_date BETWEEN peev.effective_start_date and
                 peev.effective_end_date
             AND nvl(peev.screen_entry_value, 'N') = 'N';
        END LOOP;
      ELSE
        FOR j IN 0 .. P_CNT - 1 LOOP
          /* Update the Taxable Flag to 'N' when the user accidentally enters incorrect values previously */
          pay_in_utils.set_location(g_debug,
                                    'Changing the following entries : ' ||
                                    l_element_entry_id(j),
                                    80);
          UPDATE pay_element_entry_values_f peev
             SET peev.screen_entry_value = 'N'
           WHERE peev.element_entry_id = l_element_entry_id(j)
             AND peev.input_value_id = l_tax_input_value_id(j)
             AND p_effective_date BETWEEN peev.effective_start_date and
                 peev.effective_end_date
             AND nvl(peev.screen_entry_value, 'Y') = 'Y';
        END LOOP;

      END IF;

      hr_general.g_data_migrator_mode := l_get_migrator_status;
      --
      --  End - Check if exemption limit is exceeded
      --
      /* delete the PL/SQL table */
      l_element_entry_id.delete;
      pay_in_utils.set_location(g_debug, 'Leaving: ' || l_procedure, 90);
    EXCEPTION
      WHEN OTHERS THEN
        IF c_entries_start_tax_yr%ISOPEN THEN
          CLOSE c_entries_start_tax_yr;
        END IF;
        IF c_input_value_id%ISOPEN THEN
          CLOSE c_input_value_id;
        END IF;
        IF c_element_entry_values%ISOPEN THEN
          CLOSE c_element_entry_values;
        END IF;
        IF c_global_value%ISOPEN THEN
          CLOSE c_global_value;
        END IF;

        pay_in_utils.set_location(g_debug,
                                  'Leaving FROM Exception Block : ' ||
                                  l_procedure,
                                  100);
        p_message_name := 'PER_IN_ORACLE_GENERIC_ERROR';
        p_token_name(1) := 'FUNCTION';
        p_token_value(1) := l_procedure;
        p_token_name(2) := 'SQLERRMC';
        p_token_value(2) := sqlerrm;
    END check_loan_entry;


---------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_MOTORCAR_ENTRY                                --
 -- Type           : Procedure                                           --
 -- Access         : Private                                             --
 -- Description    : Procedure is the driver procedure to validate       --
 --                  Motor car entries.                                  --
 -- Parameters     :                                                     --
 --             IN :       l_element_name        IN   VARCHAR2           --
 --                :       l_element_Type_id     IN   NUMBER             --
 --                :       l_assignment_id       IN   NUMBER             --

---------------------------------------------------------------------------

PROCEDURE check_motorcar_entry(l_element_name VARCHAR2
                              ,l_element_Type_id NUMBER
			      ,l_assignment_id NUMBER)
   IS
    l_first_count NUMBER;
    TYPE tab_input_value_name IS TABLE OF pay_input_values_f.name%TYPE INDEX BY BINARY_INTEGER;
    l_input_value_name  tab_input_value_name;

    TYPE tab_effective_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    l_eff_start_date  tab_effective_date;
    p_cnt NUMBER;
    l_procedure VARCHAR2(100);
    p_input_value_id_start number;
    p_input_value_id_end number;

    l_benefit_start pay_element_entry_values_f.screen_entry_value%TYPE;
    l_benefit_end pay_element_entry_values_f.screen_entry_value%TYPE;
    l_benefit_start_date date;
    l_benefit_end_date date;
    l_type_automotive pay_element_entry_values_f.screen_entry_value%TYPE;

BEGIN

  l_procedure := g_package ||'check_motorcar_entry';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('l_element_name                  : ',l_element_name);
  pay_in_utils.trace('l_element_Type_id               : ',l_element_Type_id);
  pay_in_utils.trace('l_assignment_id                 : ',l_assignment_id);
  pay_in_utils.trace('******************************','********************');
end if;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

 pay_in_utils.set_location(g_debug,l_procedure,11);

  OPEN c_input_value_id(l_element_type_id
                       ,'Type of Automotive');
  FETCH c_input_value_id INTO p_input_value_id;
  CLOSE c_input_value_id;

  if g_debug then
    pay_in_utils.trace('p_input_value_id                 : ',p_input_value_id);
  end if;

  pay_in_utils.set_location(g_debug,l_procedure,12);

  OPEN c_element_entry_values(p_element_entry_id
                            , p_input_value_id
	                    , p_effective_date);
  FETCH c_element_entry_values INTO l_type_automotive;
  CLOSE c_element_entry_values;

  if g_debug then
    pay_in_utils.trace('l_type_automotive                 : ',l_type_automotive);
  end if;


 IF l_type_automotive = 'CAR' THEN   -- Bugfix 4049484

  OPEN c_input_value_id(l_element_type_id
                       ,'Benefit Start Date');
  FETCH c_input_value_id INTO p_input_value_id_start;
  CLOSE c_input_value_id;

  if g_debug then
    pay_in_utils.trace('p_input_value_id_start                 : ',p_input_value_id_start);
  end if;

  OPEN c_input_value_id(l_element_type_id
                       ,'Benefit End Date');
  FETCH c_input_value_id INTO p_input_value_id_end;
  CLOSE c_input_value_id;

  if g_debug then
    pay_in_utils.trace('p_input_value_id_end                 : ',p_input_value_id_end);
  end if;

  OPEN c_element_entry_values(p_element_entry_id
                            , p_input_value_id_start
	                    , p_effective_date);
  FETCH c_element_entry_values INTO l_benefit_start;
  CLOSE c_element_entry_values;

  if g_debug then
    pay_in_utils.trace('l_benefit_start                 : ',l_benefit_start);
  end if;

  OPEN c_element_entry_values(p_element_entry_id
                            , p_input_value_id_end
			    , p_effective_date);
  FETCH c_element_entry_values INTO l_benefit_end;
  CLOSE c_element_entry_values;

  if g_debug then
    pay_in_utils.trace('l_benefit_end                 : ',l_benefit_end);
  end if;

l_benefit_start_date :=fnd_Date.canonical_to_date(l_benefit_start);
l_benefit_end_date :=fnd_Date.canonical_to_date(l_benefit_end);

  if g_debug then
    pay_in_utils.trace('l_benefit_start_date                 : ',l_benefit_start_date);
    pay_in_utils.trace('l_benefit_end_date                   : ',l_benefit_end_date);
  end if;

  -- Bugfix 4049484
   i:=1;
   l_element_entry_id(0) := p_element_entry_id;
   l_eff_start_date(0) := l_benefit_start_date;

  /* Get the  entries of Motor Car that overlap with the current entry */
  OPEN  c_element_entries(l_element_Type_id,l_assignment_id,p_input_value_id,p_input_value_id_start,p_input_value_id_end,l_benefit_start_date,l_benefit_end_date);
   LOOP
     FETCH c_element_entries INTO l_element_entry_id(i),l_eff_start_date(i);
     EXIT WHEN c_element_entries%NOTFOUND;
       i :=i+1;
    END LOOP;
  CLOSE c_element_entries;


   p_cnt := l_element_entry_id.COUNT;
/* Start - Perform the following checks when there are more than one entry for Motor Car */

  IF p_cnt > 1 THEN  -- Bugfix 4049484
    pay_in_utils.set_location(g_debug,' Entry count  is : '||p_cnt,40);


  /* Get the input value id */
  l_input_value_name(0) := 'Type of Automotive';
  l_input_value_name(1) := 'Category of Car';
  l_input_value_name(2) := 'Operational Expenses by';
  l_input_value_name(3) := 'Usage of Car';

   FOR  i in 0..3 LOOP
     OPEN c_input_value_id(l_element_type_id
                          ,l_input_value_name(i)) ;
     FETCH c_input_value_id
      INTO l_input_value_id(i);
     CLOSE c_input_value_id;
   END LOOP;

  pay_in_utils.set_location(g_debug,l_procedure,50);

  l_first_count :=0;

    /* LOOP Start */
    FOR i in 0..p_cnt-1 LOOP
      pay_in_utils.set_location(g_debug,l_procedure,60);

      IF l_element_entry_value.COUNT>0 THEN
        l_element_entry_value.delete;
      END IF;

      pay_in_utils.set_location(g_debug,l_procedure,70);

      FOR j IN 0..3 LOOP
        OPEN c_element_entry_values(l_element_entry_id(i)
                                  , l_input_value_id(j)
	                        , l_eff_start_date(i));
        FETCH c_element_entry_values INTO l_element_entry_value(j);
        CLOSE c_element_entry_values;
      END LOOP;

      pay_in_utils.set_location(g_debug,l_procedure,80);

      IF (l_element_entry_value(0) = 'CAR' AND l_element_entry_value(1) = 'OWN_EMPLOYER' AND l_element_entry_value(2) = 'EMPLOYEE' AND l_element_entry_value(3) = 'PARTIAL' )THEN
         pay_in_utils.set_location(g_debug,l_procedure,90);
         --
	 -- Check that no more than one entry with the above values exist
	 --
	 IF l_first_count <> 0 THEN
	   pay_in_utils.set_location(g_debug,'Invalid entry Motor Car More than one entry : '||l_procedure,100);
           p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
	   p_token_name(1) := 'TOKEN';
           p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','MOTOR_CAR');
           RETURN;
         END IF;
	 l_first_count := l_first_count +1;
      ELSIF (l_element_entry_value(0) = 'CAR' and l_element_entry_value(1) = 'OWN_EMPLOYER' AND l_element_entry_value(2) =  'EMPLOYER'	  AND l_element_entry_value(3) ='PRIVATE') THEN
	  NULL;
      ELSE
        /* Raise an error for all other combination of values */
      	pay_in_utils.set_location(g_debug,'Invalid entry motor car : '||l_procedure,110);
        p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
	p_token_name(1) := 'TOKEN';
        p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','MOTOR_CAR');
        RETURN;
       END IF;

    END LOOP;
    /* Loop End */
    /*  Check that exactly one entry satisfies the conditon*/
    IF l_first_count <>1 THEN
      pay_in_utils.set_location(g_debug,'Invalid entry in car entry : '||l_procedure,120);
      p_message_name := 'PER_IN_INVALID_ELEMENT_ENTRY';
      p_token_name(1) := 'TOKEN';
      p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','MOTOR_CAR');
      RETURN;
    END IF;


  END IF;
  /* End - Perform the following checks when there are more than one entry for Motor Car */
  IF  l_element_entry_id.COUNT > 0 THEN l_element_entry_id.delete; END IF;
  IF  l_input_value_id.COUNT > 0 THEN l_input_value_id.delete; END IF;
  IF l_eff_start_date.COUNT > 0 THEN  l_eff_start_date.delete; END IF;
  IF l_element_entry_value.COUNT > 0 THEN l_element_entry_value.delete;  END IF;
 END IF; /* End - Type of Automotive is Motor Car */

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,130);
EXCEPTION
  WHEN OTHERS THEN
      IF c_input_value_id%ISOPEN THEN CLOSE c_input_value_id ; END IF;
      IF c_global_value%ISOPEN THEN CLOSE c_global_value ; END IF;
      pay_in_utils.set_location(g_debug,'Leaving FROM Exception Block : '||l_procedure,140);
      p_message_name := 'PER_IN_ORACLE_GENERIC_ERROR';
      p_token_name(1) := 'FUNCTION';
      p_token_value(1) := l_procedure;
      p_token_name(2) := 'SQLERRMC';
      p_token_value(2) := sqlerrm;
END check_motorcar_entry;

---------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_LTC_ENTRY                                     --
 -- Type           : Procedure                                           --
 -- Access         : Private                                             --
 -- Description    : Procedure is the driver procedure to validate       --
 --                  Motor car entries.                                  --
 -- Parameters     :                                                     --
 --             IN :       l_element_name        IN   VARCHAR2           --
 --                :       l_element_Type_id     IN   NUMBER             --
 --                :       l_assignment_id       IN   NUMBER             --

---------------------------------------------------------------------------
PROCEDURE check_ltc_entry(l_element_name VARCHAR2
                         ,l_element_Type_id NUMBER
			 ,l_assignment_id NUMBER)
IS
 /* Cursor to find the LTC Block at the given effective Date */
  CURSOR c_ltc_block(p_date DATE)
      IS
  SELECT hrl.lookup_code
        ,hrl.meaning
    FROM hr_lookups hrl
   WHERE hrl.lookup_type ='IN_LTC_BLOCK'
     AND to_number(to_char(p_date,'YYYY')) BETWEEN
        to_number(SUBSTR(HRL.LOOKUP_CODE,1,4)) AND  to_number(SUBSTR(HRL.LOOKUP_CODE,8,4)) ;

  /* Cursor to find the LTC Availed in Previous employment given the  LTC Block Start and End Dates */
  CURSOR c_prev_employer_ltc_availed(p_start_date date
                                    ,p_end_date date
			            ,p_assignment_id NUMBER)
      IS
  SELECT sum(nvl(ppm.pem_information8,0))
    FROM per_previous_employers ppm,
         per_all_assignments_f paa
   WHERE paa.assignment_id = p_assignment_id
     AND p_effective_start_date BETWEEN paa.effective_start_date AND paa.effective_end_date
     AND paa.person_id =ppm.person_id
     AND ppm.end_date BETWEEN p_start_date and p_end_date;

 /* Cursor to Find the  LTC Availed in Current Employment given the LTC Block Start and End Dates*/
  CURSOR c_prev_blk_entry_value(p_element_Type_id NUMBER
                               ,p_start_date DATE
                               ,p_end_date   DATE
	      		       ,p_assignment_id NUMBER
			       ,p_value_input number
			       ,p_blk_input number
			       ,p_prev_block VARCHAR2)
      IS
   SELECT count(*)
     FROM pay_element_entries_f pee
         ,pay_element_entry_values_f peev1
         ,pay_element_entry_values_f peev2
    WHERE pee.assignment_id = p_assignment_id
      AND pee.element_type_id = p_element_Type_id
      AND peev1.input_value_id = p_value_input
      AND peev1.element_entry_id =peev2.element_entry_id
      AND peev2.input_value_id = p_blk_input
      AND peev2.screen_entry_value = p_prev_block
      AND nvl(peev1.screen_entry_value,'N')='N'
      AND peev1.element_entry_id =pee.element_entry_id
      AND pee.effective_start_date BETWEEN p_start_date AND p_end_date
      AND peev1.effective_start_date BETWEEN p_start_date AND p_end_date
      AND peev2.effective_start_date BETWEEN p_start_date AND p_end_date;

  /* Cursor to find if LTC Exemption is already carried Over from previous Block*/
  CURSOR c_exemption_availed(p_element_Type_id NUMBER
                            ,p_start_date DATE
			    ,p_end_date   DATE
			    ,p_assignment_id NUMBER
			    ,p_value_input NUMBER
			    ,p_blk_input NUMBER
			    ,p_curr_block VARCHAR2)
      IS
  SELECT count(*)
    FROM pay_element_entries_f pee
        ,pay_element_entry_values_f peev1
        ,pay_element_entry_values_f peev2
   WHERE pee.assignment_id = p_assignment_id
     AND pee.element_type_id = p_element_Type_id
     AND peev1.input_value_id = p_value_input
     AND peev1.element_entry_id =peev2.element_entry_id
     AND peev2.input_value_id = p_blk_input
     AND peev2.screen_entry_value = p_curr_block
     AND peev1.screen_entry_value='Y'
     AND peev1.element_entry_id =pee.element_entry_id
     AND pee.effective_start_date BETWEEN p_start_date AND p_end_date
     AND peev1.effective_start_date BETWEEN p_start_date AND p_end_date
     AND peev2.effective_start_date BETWEEN p_start_date AND p_end_date;

  l_entry_value  pay_element_entry_values_f.screen_entry_value%TYPE;


  l_curr_block HR_LOOKUPS.LOOKUP_CODE%TYPE;
  l_curr_period HR_LOOKUPS.meaning%TYPE;
  l_current_year NUMBER;
  l_current_blk_start NUMBER;

  l_prev_blk_date DATE;
  l_prev_block HR_LOOKUPS.LOOKUP_CODE%TYPE;
  l_prev_period HR_LOOKUPS.meaning%TYPE;

  l_carry_over_id NUMBER;
  l_journey_block_id NUMBER;

  l_cur_emplr_prev_blk NUMBER;
  l_prev_emplr_curr_blk NUMBER;
  l_prev_emplr_prev_blk NUMBER;
  l_exemption NUMBER;
  l_procedure VARCHAR2(100);


  l_prev_start_date DATE;
  l_prev_end_date DATE;
  l_curr_start_date DATE;
  l_curr_end_date DATE;
  l_max_with_carry_over NUMBER;
  l_max_ltc NUMBER;


BEGIN
  l_procedure := g_package ||'check_ltc_entry';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('l_element_name                  : ',l_element_name);
  pay_in_utils.trace('l_element_Type_id               : ',l_element_Type_id);
  pay_in_utils.trace('l_assignment_id                 : ',l_assignment_id);
  pay_in_utils.trace('******************************','********************');
end if;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  OPEN c_curr_entry_value(p_element_entry_id,'Carryover from Prev Block',l_element_type_id);
  FETCH c_curr_entry_value INTO l_entry_value,l_entry_value_id;
  CLOSE c_curr_entry_value;

  if g_debug then
    pay_in_utils.trace('l_entry_value                 : ',l_entry_value);
    pay_in_utils.trace('l_entry_value_id              : ',l_entry_value_id);
  end if;
  pay_in_utils.set_location(g_debug,l_procedure,15);

  --
  -- Find value held in globals before any further Processing
  -- Fix 3956926
  --

  OPEN c_global_value('IN_MAX_JOURNEY_BLOCK_LTC');
  FETCH c_global_value INTO l_max_ltc;
  CLOSE c_global_value;

  if g_debug then
    pay_in_utils.trace('l_max_ltc                 : ',l_max_ltc);
  end if;

  OPEN c_global_value('IN_JOURNEY_CARRY_OVER');
  FETCH c_global_value INTO l_max_with_carry_over;
  CLOSE c_global_value;

  if g_debug then
    pay_in_utils.trace('l_max_with_carry_over                 : ',l_max_with_carry_over);
  end if;
  --
  --Start of Check the value in Carryover from Prev Block
  --
  IF nvl(l_entry_value,'N') ='Y' THEN

    -- Check that the current year is the first year in LTC Block.Otherwise,raise an error
    OPEN c_ltc_block(p_effective_date);
    FETCH c_ltc_block INTO l_curr_block,l_curr_period;
    CLOSE c_ltc_block;

    if g_debug then
      pay_in_utils.trace('l_curr_block                  : ',l_curr_block);
      pay_in_utils.trace('l_curr_period                 : ',l_curr_period);
      pay_in_utils.trace('p_effective_date              : ',p_effective_date);
    end if;
    pay_in_utils.set_location(g_debug,l_procedure,20);

    l_current_year := to_number(to_char(p_effective_date,'YYYY'));
    l_current_blk_start := to_number(substr(l_curr_block,1,4));
    IF l_current_year <> l_current_blk_start THEN
      pay_in_utils.set_location(g_debug,'Leaving.. '||l_procedure,30);
      p_message_name := 'PER_IN_LTC_CARRY_OVER';  -- Fix 3956926
      RETURN;
    END IF;

    l_curr_start_date := to_date(substr(l_curr_period,1,11),'DD-MM-YYYY');
    l_curr_end_date   := to_date(substr(l_curr_period,15,11),'DD-MM-YYYY');

    if g_debug then
      pay_in_utils.trace('p_effective_start_date              : ',p_effective_start_date);
    end if;
    -- Get the Previous Block start and End Dates
    l_prev_blk_date := ADD_MONTHS(p_effective_start_date,-48);
    OPEN c_ltc_block(l_prev_blk_date);
    FETCH c_ltc_block INTO l_prev_block,l_prev_period;
    close c_ltc_block;

    if g_debug then
      pay_in_utils.trace('l_prev_block              : ',l_prev_block);
      pay_in_utils.trace('l_prev_period             : ',l_prev_period);
    end if;
    pay_in_utils.set_location(g_debug,l_procedure,40);

    l_prev_start_date := to_date(substr(l_prev_period,1,11),'DD-MM-YYYY');
    l_prev_end_date   := to_date(substr(l_prev_period,15,11),'DD-MM-YYYY');


    -- Get LTC Availed in Current employment in previous LTC Block
    OPEN c_input_value_id(l_element_Type_id
                         ,'Carryover from Prev Block');
    FETCH c_input_value_id INTO l_carry_over_id;
    CLOSE c_input_value_id;

    if g_debug then
      pay_in_utils.trace('l_carry_over_id             : ',l_carry_over_id);
    end if;

    OPEN c_input_value_id(l_element_Type_id
                         ,'LTC Journey Block');
    FETCH c_input_value_id INTO l_journey_block_id;
    CLOSE c_input_value_id;

    if g_debug then
      pay_in_utils.trace('l_journey_block_id             : ',l_journey_block_id);
    end if;

    pay_in_utils.set_location(g_debug,l_procedure,50);

    OPEN c_prev_blk_entry_value(l_element_type_id
                               ,l_prev_start_date
                               ,l_prev_end_date
	    		       ,l_assignment_id
  			       ,l_carry_over_id
			       ,l_journey_block_id
			       ,l_prev_block);
    FETCH c_prev_blk_entry_value INTO l_cur_emplr_prev_blk;
    CLOSE c_prev_blk_entry_value;

    if g_debug then
      pay_in_utils.trace('l_cur_emplr_prev_blk             : ',l_cur_emplr_prev_blk);
    end if;

    OPEN c_prev_employer_ltc_availed(l_prev_start_date
                                    ,l_prev_end_date
				    ,l_assignment_id );
    FETCH c_prev_employer_ltc_availed INTO
          l_prev_emplr_prev_blk;
    CLOSE c_prev_employer_ltc_availed;

    if g_debug then
      pay_in_utils.trace('l_prev_emplr_prev_blk             : ',l_prev_emplr_prev_blk);
    end if;

    pay_in_utils.set_location(g_debug,l_procedure,60);


    /* Check if carry over is valid */
    IF ( nvl(l_cur_emplr_prev_blk,0) + nvl(l_prev_emplr_prev_blk,0)  >=l_max_ltc) THEN
      pay_in_utils.set_location(g_debug,'Leaving...'||l_procedure,70);
      p_message_name := 'PER_IN_LTC_EXEMPTION_AVAILED';
      RETURN;
    END IF;


    OPEN c_exemption_availed(l_element_type_id
                            ,l_curr_start_date
			    ,l_curr_end_date
			    ,l_assignment_id
			    ,l_carry_over_id
			    ,l_journey_block_id
			    ,l_curr_block);
    FETCH c_exemption_availed INTO l_exemption;
    CLOSE c_exemption_availed;

    if g_debug then
      pay_in_utils.trace('l_exemption             : ',l_exemption);
    end if;

    pay_in_utils.set_location(g_debug,l_procedure,80);

    /* Check if Carry Over has already been availed */
    IF (nvl(l_exemption,0) > (l_max_with_carry_over - l_max_ltc) ) THEN
      pay_in_utils.set_location(g_debug,'Leaving... '||l_procedure,90);
      p_message_name := 'PER_IN_LTC_EXEMPTION_AVAILED';
      RETURN;
    END IF;
    pay_in_utils.set_location(g_debug,l_procedure,100);

  END IF;

 pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,110);
EXCEPTION
  WHEN OTHERS THEN
     IF c_curr_entry_value%ISOPEN THEN CLOSE c_curr_entry_value ; END IF;
     IF c_ltc_block%ISOPEN THEN CLOSE c_ltc_block ; END IF;
     IF c_prev_blk_entry_value%ISOPEN THEN CLOSE c_prev_blk_entry_value ; END IF;
     IF c_exemption_availed%ISOPEN THEN CLOSE c_exemption_availed ; END IF;
     IF c_input_value_id%ISOPEN THEN CLOSE c_input_value_id ; END IF;
     IF c_prev_employer_ltc_availed%ISOPEN THEN CLOSE c_prev_employer_ltc_availed ; END IF;
     IF c_global_value%ISOPEN THEN CLOSE c_global_value ; END IF;

     pay_in_utils.set_location(g_debug,'Leaving FROM Exception Block : '||l_procedure,120);
     p_message_name := 'PER_IN_ORACLE_GENERIC_ERROR';
     p_token_name(1) := 'FUNCTION';
     p_token_value(1) := l_procedure;
     p_token_name(1) := 'SQLERRMC';
     p_token_value(1) := sqlerrm;
END check_ltc_entry;
--
-- End of Private Procedures
--

BEGIN

    l_procedure := g_package ||'check_entry_value';
    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    p_message_name := 'SUCCESS';
    pay_in_utils.null_message(p_token_name, p_token_value);

    l_get_migrator_status:=hr_general.g_data_migrator_mode;
    -- Get the Element Name

    OPEN c_perquisite_name;
    FETCH c_perquisite_name INTO l_element_name,l_element_Type_id,l_assignment_id;
    CLOSE c_perquisite_name;

    IF (l_element_name IS NULL)
    THEN
        /*
         Check introduced for Leave Travel Conession
        */
        OPEN  c_element_entry_details(p_element_entry_id);
        FETCH c_element_entry_details INTO l_element_start_date,l_element_type_id,l_assignment_id;
        CLOSE c_element_entry_details;

        l_inputvalue_id  :=  pay_in_utils.get_input_value_id(l_element_start_date
                                                            ,l_element_type_id
                                                            ,'Component Name'
                                                            );

        OPEN  c_element_entry_values(p_element_entry_id,l_inputvalue_id,l_element_start_date);
        FETCH c_element_entry_values INTO l_element_name;
        CLOSE c_element_entry_values;

        IF (l_element_name IS NULL)
        THEN
                RETURN;
        END IF;

    END IF;
    pay_in_utils.set_location(g_debug,'Element name is: '||l_element_name,20);
    pay_in_utils.set_location(g_debug,'Element_Type_id: '||l_element_Type_id,20);
    pay_in_utils.set_location(g_debug,'Assignment_id  : '||l_assignment_id,20);


    IF l_element_name = 'Loan at Concessional Rate' THEN
      check_loan_entry(l_element_name,l_element_Type_id,l_assignment_id);

    ELSIF l_element_name = 'Motor Car Perquisite' THEN
      check_benefit_dates(l_element_Type_id);
        if g_debug then
          pay_in_utils.trace('p_message_name             : ',p_message_name);
        end if;
      IF p_message_name <>'SUCCESS' THEN  RETURN;  END IF;
      check_motorcar_entry(l_element_name,l_element_Type_id,l_assignment_id);
       --Bugfix 3982447 Start
        if g_debug then
          pay_in_utils.trace('p_message_name             : ',p_message_name);
        end if;
      IF p_message_name <>'SUCCESS' THEN  RETURN;  END IF;

      if g_debug then
        pay_in_utils.trace('p_element_entry_id         : ',p_element_entry_id);
      end if;

      OPEN c_curr_entry_value  (p_element_entry_id
                              ,'Category of Car'
			      ,l_element_type_id );
      FETCH c_curr_entry_value INTO  l_dep_value1,l_entry_value_id;
      CLOSE c_curr_entry_value;

      if g_debug then
        pay_in_utils.trace('l_dep_value1             : ',l_dep_value1);
        pay_in_utils.trace('l_entry_value_id         : ',l_entry_value_id);
      end if;

      IF l_dep_value1 ='OWN_EMPLOYEE' THEN
        OPEN c_curr_entry_value  (p_element_entry_id
                                ,'Operational Expenses by'
		   	        ,l_element_type_id );
        FETCH c_curr_entry_value INTO  l_dep_value2,l_entry_value_id;
        CLOSE c_curr_entry_value;

      if g_debug then
        pay_in_utils.trace('l_dep_value2             : ',l_dep_value2);
        pay_in_utils.trace('l_entry_value_id         : ',l_entry_value_id);
      end if;


	IF l_dep_value2 = 'EMPLOYEE'  THEN
          pay_in_utils.null_message(p_token_name, p_token_value);
          p_message_name := 'PER_IN_INVALID_PERQUISITE';
          pay_in_utils.set_location(g_debug,'Invalid perquisite ...'||l_procedure,25);
          RETURN;
        END IF;
      END IF;
      --Bugfix 3982447 End

    ELSIF l_element_name  =  'Company Accommodation' THEN
      --


      -- Start of 'Company Accommodation'
      --
      check_benefit_dates(l_element_Type_id);

      if g_debug then
        pay_in_utils.trace('p_message_name             : ',p_message_name);
      end if;

      IF p_message_name <>'SUCCESS' THEN  RETURN;  END IF;

      OPEN c_curr_entry_value  (p_element_entry_id
                              ,'Property'
			      ,l_element_type_id );
      FETCH c_curr_entry_value INTO  l_dep_value1,l_entry_value_id;
      CLOSE c_curr_entry_value;

      if g_debug then
        pay_in_utils.trace('l_dep_value1             : ',l_dep_value1);
        pay_in_utils.trace('l_entry_value_id         : ',l_entry_value_id);
      end if;
      --
      -- Check value interdependency Start
      --
      IF l_dep_value1 ='RENT' THEN
        OPEN c_curr_entry_value  (p_element_entry_id
                                ,'Rent Paid by Employer'
		   	        ,l_element_type_id );
        FETCH c_curr_entry_value INTO  l_dep_value2,l_entry_value_id;
        CLOSE c_curr_entry_value;

      if g_debug then
        pay_in_utils.trace('l_dep_value2             : ',l_dep_value2);
        pay_in_utils.trace('l_entry_value_id         : ',l_entry_value_id);
      end if;

	IF l_dep_value2 IS NULL or l_dep_value2 = 0 THEN
          pay_in_utils.null_message(p_token_name, p_token_value);
          p_message_name := 'PER_IN_ENTRY_VALUE_ZERO';
          p_token_name(1) := 'TOKEN1';
          p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','RENT_EMPLOLYER');
	  p_token_name(2) := 'TOKEN2';
          p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PROPERTY');
	  p_token_name(3) := 'TOKEN3';
          p_token_value(3) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','LEASED');

          pay_in_utils.set_location(g_debug,'Company Accommodation '||l_procedure,25);
          RETURN;
        END IF;
	-- Bugfix 3991117 Start
      ELSIF l_dep_value1 = 'OWN' THEN
        OPEN c_curr_entry_value  (p_element_entry_id
                                ,'Rent Paid by Employer'
		   	        ,l_element_type_id );
        FETCH c_curr_entry_value INTO  l_dep_value2,l_entry_value_id;
        CLOSE c_curr_entry_value;

        if g_debug then
          pay_in_utils.trace('l_dep_value2             : ',l_dep_value2);
          pay_in_utils.trace('l_entry_value_id         : ',l_entry_value_id);
        end if;

	IF  l_dep_value2 IS NOT NULL AND l_dep_value2 <> 0 THEN
          pay_in_utils.null_message(p_token_name, p_token_value);
	  p_message_name  := 'PER_IN_INVALID_ELEMENT_ENTRY';
          p_token_name(1) := 'TOKEN';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','COMP_ACC');
          pay_in_utils.set_location(g_debug,'Company Accommodation '||l_procedure,28);
          RETURN;
        END IF;


      -- Bugfix 3991117 End
      END IF;
      --
      -- Check value interdependency End
      --
      --
      -- End of Company Accommodaiton
      --
   ELSIF l_element_name ='Company Movable Assets' THEN
      check_benefit_dates(l_element_Type_id);
/* Bug Fix 4533671
      IF p_message_name <>'SUCCESS' THEN  RETURN;  END IF;
      --
      --  Start of Company Movable Assets
      --
      OPEN c_curr_entry_value  (p_element_entry_id
                               ,'Usage'
			       ,l_element_type_id );
      FETCH c_curr_entry_value INTO  l_dep_value1,l_entry_value_id;
      CLOSE c_curr_entry_value;

      --
      -- Check value interdependency Start
      --
      IF l_dep_value1 ='SOLD' THEN
        OPEN c_curr_entry_value  (p_element_entry_id
                                ,'Date of Purchase'
			       ,l_element_type_id );
        FETCH c_curr_entry_value INTO  l_dep_value2,l_entry_value_id;
        CLOSE c_curr_entry_value;

        IF l_dep_value2 IS NULL THEN
          pay_in_utils.set_location(g_debug,'ltc '||l_procedure,25);
          pay_in_utils.null_message(p_token_name, p_token_value);
	  p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
          p_token_name(1) := 'TOKEN1';
          p_token_value(1) := 'Date of Purchase';
          p_token_name(2) := 'TOKEN2';
          p_token_value(2) := 'Usage';
	  p_token_name(3) := 'TOKEN3';
          p_token_value(3) := 'Sold to Employee';
          RETURN;
        END IF;
	--
        -- Check value interdependency End
        --
      END IF;*/
      --
      --  End of  Company Movable Assets
      --


    ELSIF l_element_name = 'Leave Travel Concession' THEN
      check_ltc_entry(l_element_name,l_element_Type_id,l_assignment_id);
    ELSIF l_element_name = 'Free Education' THEN
        check_benefit_dates(l_element_Type_id);
    END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
  EXCEPTION
    WHEN OTHERS THEN
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
      p_message_name := 'PER_IN_ORACLE_GENERIC_ERROR';
      p_token_name(1) := 'FUNCTION';
      p_token_value(1) := l_procedure;
      p_token_name(2) := 'SQLERRMC';
      p_token_value(2) := sqlerrm;
   END check_element_entry;

  END per_in_perquisite_pkg;

/
