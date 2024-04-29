--------------------------------------------------------
--  DDL for Package Body PER_CN_ORG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_ORG_INFO_LEG_HOOK" AS
/* $Header: pecnlhoi.pkb 120.4.12010000.7 2010/02/25 07:00:46 dduvvuri ship $ */

   g_package      VARCHAR2(25);
   g_debug        BOOLEAN;
   g_token_name   hr_cn_api.char_tab_type;
   g_token_value  hr_cn_api.char_tab_type;
   g_message_name VARCHAR2(30);

 --------------------------------------------------------------------------
-- Name           : CHECK_RECORD_EXISTS                                 --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Organizaition Information data for the       --
--                  context IN_CONTRACTOR_INFO.                         --
-- Parameters     :                                                     --
--             IN :       p_org_information_id   IN NUMBER              --
--                        p_org_info_type_code   IN VARCHAR2            --
--                        p_org_information1     IN VARCHAR2            --
--			  p_org_information2     IN VARCHAR2            --
--			  p_org_information3     IN VARCHAR2            --
--			  p_org_information4     IN VARCHAR2            --
--			  p_org_information5     IN VARCHAR2            --
--------------------------------------------------------------------------

PROCEDURE check_record_exists(p_org_information_id   IN NUMBER
                             ,p_organization_id      IN NUMBER
                             ,p_org_info_type_code   IN VARCHAR2
                             ,p_org_information1     IN VARCHAR2
       			     ,p_org_information2     IN VARCHAR2
			     ,p_org_information3     IN VARCHAR2
	  		     ,p_org_information4     IN VARCHAR2
			     ,p_effective_start_date IN DATE
			     ,p_effective_end_date   IN DATE
			     )
AS

    l_rec_count NUMBER;
    l_fut_date  DATE;

    CURSOR csr_check_cont_base_setup
    IS
      SELECT count(org_information_id)
      FROM hr_organization_information
      WHERE org_information_context= 'PER_CONT_AREA_CONT_BASE_CN'
        AND org_information1 = p_org_information1
        AND org_information2 = p_org_information2
        AND nvl(org_information3,'X') = nvl(p_org_information3,'X')
        AND p_effective_start_date BETWEEN fnd_date.canonical_to_date(org_information15)
	                               AND fnd_date.canonical_to_date(NVL(org_information16,'4712/12/31 00:00:00'))
       AND organization_id = p_organization_id
       AND (org_information_id  <> p_org_information_id
            OR p_org_information_id IS NULL);


    CURSOR csr_check_phf_si_rates_setup
    IS
      SELECT count(org_information_id)
      FROM hr_organization_information
      WHERE org_information_context='PER_CONT_AREA_PHF_SI_RATES_CN'
        AND org_information1          = p_org_information1
        AND nvl(org_information2,'X') = nvl(p_org_information2,'X')
        AND org_information3          = p_org_information3
        AND nvl(org_information9,'X') = nvl(p_org_information4,'X')
        AND p_effective_start_date BETWEEN fnd_date.canonical_to_date(org_information10)
	                               AND fnd_date.canonical_to_date(NVL(org_information11,'4712/12/31 00:00:00'))
       AND organization_id = p_organization_id
       AND (org_information_id  <> p_org_information_id
            OR p_org_information_id IS NULL) ;

    CURSOR csr_future_rec_cont_base
    IS
      SELECT min(fnd_date.canonical_to_date(org_information15))
      FROM   hr_organization_information
      WHERE org_information1 = p_org_information1
        AND org_information2 = p_org_information2
        AND nvl(org_information3,'X') = nvl(p_org_information3,'X')
        AND org_information_context='PER_CONT_AREA_CONT_BASE_CN'
        AND NVL(org_information_id,-1) <> NVL(p_org_information_id,-1)
        AND fnd_date.canonical_to_date(org_information15) > p_effective_start_date
        AND organization_id = p_organization_id
        AND (org_information_id  <> p_org_information_id
             OR p_org_information_id IS NULL);

    CURSOR csr_future_rec_phfsi_base
    IS
      SELECT min(fnd_date.canonical_to_date(org_information10))
      FROM   hr_organization_information
      WHERE org_information1 = p_org_information1
        AND NVL(org_information2,'X') = NVL(p_org_information2,'X')
        AND nvl(org_information3,'X') = nvl(p_org_information3,'X')
        AND org_information_context='PER_CONT_AREA_PHF_SI_RATES_CN'
        AND nvl(org_information9,'X') = nvl(p_org_information4,'X')  --Added for bug 9358335
        AND NVL(org_information_id,-1) <> NVL(p_org_information_id,-1)
        AND fnd_date.canonical_to_date(org_information10) > p_effective_start_date
        AND organization_id = p_organization_id
        AND (org_information_id  <> p_org_information_id
             OR p_org_information_id IS NULL);


    l_procedure  VARCHAR2(100);

BEGIN

   l_procedure := g_package || 'check_record_exists';
   g_debug := hr_utility.debug_enabled;
   g_debug := TRUE;

   hr_cn_api.set_location(g_debug,'Entering ' || l_procedure,10);

   IF p_org_info_type_code = 'PER_CONT_AREA_CONT_BASE_CN' THEN

      IF g_debug THEN
         hr_utility.trace('Checking contribution base setup');
      END IF;

      OPEN  csr_check_cont_base_setup;
      FETCH csr_check_cont_base_setup INTO l_rec_count;
      CLOSE csr_check_cont_base_setup;

      OPEN  csr_future_rec_cont_base;
      FETCH csr_future_rec_cont_base INTO l_fut_date;
      CLOSE csr_future_rec_cont_base;

      IF g_debug THEN
         hr_utility.trace('Ended Checking contribution base setup');
      END IF;

   ELSIF  p_org_info_type_code ='PER_CONT_AREA_PHF_SI_RATES_CN' THEN

      IF g_debug THEN
         hr_utility.trace('Checking PHF/SI rates setup');
      END IF;

      OPEN  csr_check_phf_si_rates_setup;
      FETCH csr_check_phf_si_rates_setup INTO l_rec_count;
      CLOSE csr_check_phf_si_rates_setup;

      OPEN  csr_future_rec_phfsi_base;
      FETCH csr_future_rec_phfsi_base INTO l_fut_date;
      CLOSE csr_future_rec_phfsi_base;

      IF g_debug THEN
         hr_utility.trace('Ended Checking PHF/SI Rates setup');
      END IF;

   END IF;

   IF l_rec_count > 0 THEN

      IF g_debug THEN
         hr_utility.trace('Duplicate Record Exists');
      END IF;

      hr_utility.set_message(800,'PER_7901_SYS_DUPLICATE_RECORDS');
      hr_utility.raise_error;

   ELSIF l_fut_date IS NOT NULL THEN

      IF p_effective_end_date >= l_fut_date OR p_effective_end_date IS NULL THEN

	 IF g_debug THEN
	    hr_utility.trace('Duplicate Record Exists');
	 END IF;

         hr_utility.set_message(800,'PER_7901_SYS_DUPLICATE_RECORDS');
         hr_utility.raise_error;  -- bug 9358335 - Moved this line from outer block to this error block
      END IF;

   END IF;

   hr_cn_api.set_location(g_debug,'Leaving ' || l_procedure,30);

END  check_record_exists;
--------------------------------------------------------------------------
-- Name           : check_term_stat_info                                --
-- Type           : Procedure                                           --
-- Access         : Internal                                              --
-- Description    : Check for validity of data in the Termination Statutory Information   --
-- Parameters     :                                                     --
--             IN :       p_effective_start_date   IN DATE              --
--                        p_effective_end_date     IN DATE              --
--                        p_organization_id        IN NUMBER            --
--                        p_org_info_type_code     IN VARCHAR2          --
--		          p_org_information_id     IN NUMBER            --
--------------------------------------------------------------------------
PROCEDURE check_term_stat_info (p_org_information_id  IN NUMBER
                               ,p_organization_id     IN NUMBER
                               ,p_org_info_type_code  IN VARCHAR2
                               ,p_effective_start_date IN DATE
                               ,p_effective_end_date  IN DATE)

IS

   CURSOR c_term_info_setup
   IS
      SELECT COUNT (org_information_id)
      FROM hr_organization_information hoi
      WHERE hoi.organization_id = p_organization_id
      AND hoi.org_information_context = p_org_info_type_code
      AND p_effective_start_date BETWEEN
      fnd_date.canonical_to_date(NVL(hoi.org_information3,'1900/01/01 00:00:00'))
      AND fnd_date.canonical_to_date(NVL(hoi.org_information4,'4712/12/31 00:00:00'))
      AND (org_information_id <>p_org_information_id OR p_org_information_id IS NULL);


    CURSOR c_fut_term_info_setup
    IS
      SELECT min(fnd_date.canonical_to_date(org_information3))
      FROM   hr_organization_information
      WHERE org_information_context= p_org_info_type_code
        AND NVL(org_information_id,-1) <> NVL(p_org_information_id,-1)
        AND fnd_date.canonical_to_date(NVL(org_information3,'1900/01/01 00:00:00')) > p_effective_start_date
        AND organization_id = p_organization_id
        AND (org_information_id  <> p_org_information_id
             OR p_org_information_id IS NULL);

  l_rec_count NUMBER;
  l_procedure  VARCHAR2(100);
  l_fut_date DATE;

BEGIN

   l_procedure := g_package || 'check_term_stat_info';
   g_debug := hr_utility.debug_enabled;
   g_debug := TRUE;


                OPEN  c_term_info_setup;
                FETCH c_term_info_setup INTO l_rec_count;
                CLOSE c_term_info_setup;

                OPEN c_fut_term_info_setup;
                FETCH c_fut_term_info_setup INTO l_fut_date;
                CLOSE c_fut_term_info_setup;

                hr_cn_api.set_location(g_debug,' l_rec_count : '|| l_rec_count, 20);

   IF l_rec_count > 0 THEN
                hr_utility.set_message(800,'PER_7901_SYS_DUPLICATE_RECORDS');
                hr_utility.raise_error;
   ELSIF l_fut_date IS NOT NULL THEN
      IF p_effective_end_date >= l_fut_date OR p_effective_end_date IS NULL THEN
              hr_utility.set_message(800,'PER_7901_SYS_DUPLICATE_RECORDS');
              hr_utility.raise_error;
      END IF;

   END IF;

   hr_cn_api.set_location(g_debug,'Leaving ' || l_procedure,30);

END check_term_stat_info;

-------------------------------------------------------------------------
--                                                                     --
-- Name           : check_single_record                                --
-- Type           : Procedure                                          --
-- Access         : Public                                             --
-- Description    : This procedure checks if any duplicate record of a --
--                  particular Tax area exists for the context         --
--                  PER_PHF_STAT_INFO_CN                               --
-- Parameters     :                                                    --
--             IN :      p_org_information_id  IN NUMBER               --
--                       p_organization_id     IN NUMBER               --
--                       p_org_info_type_code  IN VARCHAR2             --
--                       p_org_information1    IN VARCHAR2             --
-------------------------------------------------------------------------
PROCEDURE check_single_record (
 p_org_information_id  IN NUMBER
,p_organization_id     IN NUMBER
,p_org_info_type_code  IN VARCHAR2
,p_org_information1    IN VARCHAR2)
IS

CURSOR c_phf_high_limit_exempt_setup
IS
	SELECT COUNT (org_information_id)       -- Y/N
	FROM hr_organization_information hoi
	WHERE hoi.organization_id = p_organization_id
	AND hoi.org_information_context = 'PER_PHF_STAT_INFO_CN'
	AND hoi.org_information1 = p_org_information1
	AND (org_information_id <>p_org_information_id OR p_org_information_id IS NULL);

  l_rec_count NUMBER;
  l_procedure  VARCHAR2(100);

BEGIN
   l_procedure := g_package || 'check_single_record';
   g_debug := hr_utility.debug_enabled;
   g_debug := TRUE;

   hr_cn_api.set_location(g_debug,'Entering ' || l_procedure,10);

   IF p_org_info_type_code = 'PER_PHF_STAT_INFO_CN' THEN
	IF g_debug THEN
		hr_utility.trace(' =======================================================');
		hr_utility.trace(' .       p_org_information_id       : '||p_org_information_id);
		hr_utility.trace(' .       p_organization_id       : '||p_organization_id );
		hr_utility.trace(' .       p_org_info_type_code        : '||p_org_info_type_code);
		hr_utility.trace(' .       p_org_information1        : '||p_org_information1);
		hr_utility.trace(' =======================================================');
	END IF;

	OPEN  c_phf_high_limit_exempt_setup;
	FETCH c_phf_high_limit_exempt_setup INTO l_rec_count;
	CLOSE c_phf_high_limit_exempt_setup;
	hr_cn_api.set_location(g_debug,' l_rec_count : '|| l_rec_count, 20);
   END IF;

   IF l_rec_count > 0 THEN
	IF g_debug THEN
		hr_utility.trace('=========================================================');
		hr_utility.trace('message_name'||'PER_7901_SYS_DUPLICATE_RECORDS');
		hr_utility.trace('=========================================================');
	END IF;
	hr_utility.set_message(800,'PER_7901_SYS_DUPLICATE_RECORDS');
	hr_utility.raise_error;
   END IF;

   hr_cn_api.set_location(g_debug,'Leaving ' || l_procedure,30);

END check_single_record;



-------------------------------------------------------------------------
--                                                                     --
-- Name           : validate_date                                      --
-- Type           : Procedure                                          --
-- Access         : Public                                             --
-- Description    : This procedure checks if the effective end date is --
--                  greater than or equal to effective start date .    --
-- Parameters     :                                                    --
--             IN :     p_effective_start_date   IN DATE               --
--                      p_effective_end_date     IN DATE               --
-------------------------------------------------------------------------
PROCEDURE validate_date(p_effective_start_date IN DATE,
                         p_effective_end_date   IN DATE)
IS
   l_procedure VARCHAR2(50);
   E_INVALID_FORMAT_ERR   EXCEPTION;
BEGIN

   l_procedure := g_package || 'validate_date';
   g_debug := hr_utility.debug_enabled;

   hr_cn_api.set_location(g_debug,'Entering ' || l_procedure,10);

   IF p_effective_end_date IS NOT NULL THEN
     hr_cn_api.set_location(g_debug,l_procedure,20);

     IF p_effective_end_date < p_effective_start_date THEN
        RAISE E_INVALID_FORMAT_ERR;
     END IF;

     hr_cn_api.set_location(g_debug,'Leaving ' || l_procedure,30);

   END IF;

EXCEPTION
   WHEN E_INVALID_FORMAT_ERR THEN
    hr_utility.set_message(800,'PER_CN_INCORRECT_DATES');
    hr_cn_api.set_location(g_debug,l_procedure,40);
    hr_utility.raise_error;

END validate_date;


--------------------------------------------------------------------------
-- Name           : check_cn_org_info_internal                          --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc  to be called from the Org Info Hook  --
-- Parameters     :                                                     --
--             IN :       p_effective_date         IN DATE              --
--                        p_organization_id        IN NUMBER            --
--                        p_org_info_type_code     IN VARCHAR2          --
--		          p_org_information1..20   IN VARCHAR2          --
--------------------------------------------------------------------------
PROCEDURE check_cn_org_internal
        (p_org_info_type_code IN VARCHAR2 --Organization Information type
        ,p_org_information_id IN NUMBER   --Organization Information ID
        ,p_organization_id    IN NUMBER   --Organization ID
        ,p_org_information1   IN VARCHAR2
        ,p_org_information2   IN VARCHAR2
        ,p_org_information3   IN VARCHAR2
        ,p_org_information4   IN VARCHAR2
        ,p_org_information5   IN VARCHAR2
        ,p_org_information6   IN VARCHAR2
        ,p_org_information7   IN VARCHAR2
        ,p_org_information8   IN VARCHAR2
        ,p_org_information9   IN VARCHAR2
        ,p_org_information10  IN VARCHAR2
        ,p_org_information11  IN VARCHAR2
        ,p_org_information12  IN VARCHAR2
        ,p_org_information13  IN VARCHAR2
        ,p_org_information14  IN VARCHAR2
        ,p_org_information15  IN VARCHAR2
        ,p_org_information16  IN VARCHAR2
        ,p_org_information17  IN VARCHAR2
        ,p_org_information18  IN VARCHAR2
        ,p_org_information19  IN VARCHAR2
        ,p_org_information20  IN VARCHAR2
        ,p_message_name       OUT NOCOPY VARCHAR2
        ,p_token_name         OUT NOCOPY hr_cn_api.char_tab_type
        ,p_token_value        OUT NOCOPY hr_cn_api.char_tab_type
        )
IS

   l_procedure   VARCHAR2(100);
   l_start_date  DATE;
   l_end_date    DATE;

BEGIN

  l_procedure := g_package || 'check_cn_org_internal';
  g_debug := hr_utility.debug_enabled;

  hr_cn_api.set_location(g_debug,'Entering ' || l_procedure,10);


-- commented the code for bug 6828199
/*  IF p_org_info_type_code = 'PER_PHF_STAT_INFO_CN' THEN
		check_single_record(p_org_information_id   => p_org_information_id
				   ,p_organization_id      => p_organization_id
				   ,p_org_info_type_code   => p_org_info_type_code
				   ,p_org_information1     => p_org_information1
				   );
   END IF;
*/

/* Changes for Bug 6943573 start */
IF p_org_info_type_code = 'PER_TERM_STAT_INFO_CN' THEN

   l_start_date := fnd_date.canonical_to_date(NVL(p_org_information3,'1900/01/01 00:00:00'));
   l_end_date  :=  fnd_date.canonical_to_date(NVL(p_org_information4,'4712/12/31 00:00:00'));
   validate_date(l_start_date,l_end_date);

   --call a new procedure to check if any records are overlapping or if any duplicate records are
   --existing

    check_term_stat_info(p_org_information_id   => p_org_information_id
                                              ,p_organization_id      => p_organization_id
                                                ,p_org_info_type_code   => 'PER_TERM_STAT_INFO_CN'
                                                ,p_effective_start_date => l_start_date
                                              ,p_effective_end_date   => l_end_date
                                          );

ELSIF p_org_info_type_code = 'PER_TERM_GRE_INFO_CN' THEN

   l_start_date := fnd_date.canonical_to_date(NVL(p_org_information3,'1900/01/01 00:00:00'));
   l_end_date  :=  fnd_date.canonical_to_date(NVL(p_org_information4,'4712/12/31 00:00:00'));
   validate_date(l_start_date,l_end_date);

   --call a new procedure to check if any records are overlapping or if any duplicate records are
   --existing


    check_term_stat_info(p_org_information_id   => p_org_information_id
                                              ,p_organization_id      => p_organization_id
                                                ,p_org_info_type_code   => 'PER_TERM_GRE_INFO_CN'
                                                ,p_effective_start_date => l_start_date
                                              ,p_effective_end_date   => l_end_date
                                          );

/* Changes for bug 6943573 end */
/* Changes for bug 8799060 start */
ELSIF p_org_info_type_code = 'PER_SEVERANCE_PAY_TAX_RULE_CN' THEN

   l_start_date := fnd_date.canonical_to_date(NVL(p_org_information3,'1900/01/01 00:00:00'));
   l_end_date  :=  fnd_date.canonical_to_date(NVL(p_org_information4,'4712/12/31 00:00:00'));
   validate_date(l_start_date,l_end_date);

   --call a new procedure to check if any records are overlapping or if any duplicate records are
   --existing

    check_term_stat_info(p_org_information_id   => p_org_information_id
                                              ,p_organization_id      => p_organization_id
                                                ,p_org_info_type_code   => 'PER_SEVERANCE_PAY_TAX_RULE_CN'
                                                ,p_effective_start_date => l_start_date
                                              ,p_effective_end_date   => l_end_date
                                          );
/* Changes for bug 8799060 end */
 ELSIF p_org_info_type_code = 'PER_CONT_AREA_CONT_BASE_CN' THEN

       IF g_debug THEN
          hr_utility.trace('Validating Effective Start Date and Effective End Date');
       END IF;

       l_start_date := fnd_date.canonical_to_date(p_org_information15);
       l_end_date := fnd_date.canonical_to_date(NVL(p_org_information16,'4712/12/31 00:00:00'));
       validate_date(l_start_date
                    ,l_end_date);

       IF g_debug THEN
          hr_utility.trace('Checking for Duplicate Record');
       END IF;

       check_record_exists(p_org_information_id   => p_org_information_id
                          ,p_organization_id      => p_organization_id
                          ,p_org_info_type_code   => p_org_info_type_code
                          ,p_org_information1     => p_org_information1
       			  ,p_org_information2     => p_org_information2
			  ,p_org_information3     => p_org_information3
	  		  ,p_org_information4     => NULL
			  ,p_effective_start_date => l_start_date
			  ,p_effective_end_date   => l_end_date
			  );

       IF g_debug THEN
          hr_utility.trace('Calling pay_cn_deductions.check_cont_base_setup');
       END IF;

       pay_cn_deductions.check_cont_base_setup
              (p_organization_id         => p_organization_id
              ,p_contribution_area       => p_org_information1
              ,p_phf_si_type             => p_org_information2
              ,p_hukou_type              => p_org_information3
              ,p_ee_cont_base_method     => p_org_information4
              ,p_er_cont_base_method     => p_org_information5
              ,p_low_limit_method        => p_org_information6
              ,p_low_limit_amount        => fnd_number.canonical_to_number(p_org_information7)
              ,p_high_limit_method       => p_org_information8
              ,p_high_limit_amount       => fnd_number.canonical_to_number(p_org_information9)
              ,p_switch_periodicity      => p_org_information10
              ,p_switch_month            => p_org_information11
              ,p_rounding_method         => p_org_information12
              ,p_lowest_avg_salary       => fnd_number.canonical_to_number(p_org_information13)
              ,p_average_salary          => fnd_number.canonical_to_number(p_org_information14)
	      ,p_ee_fixed_amount         => fnd_number.canonical_to_number(p_org_information17)
	      ,p_er_fixed_amount         => fnd_number.canonical_to_number(p_org_information18)
              ,p_effective_start_date    => l_start_date
              ,p_effective_end_date      => l_end_date
              ,p_message_name            => g_message_name
              ,p_token_name              => g_token_name
              ,p_token_value             => g_token_value
              );

  ELSIF p_org_info_type_code = 'PER_CONT_AREA_PHF_SI_RATES_CN' THEN

       IF g_debug THEN
          hr_utility.trace('Validating Effective Start Date and Effective End Date');
       END IF;

       l_start_date := fnd_date.canonical_to_date(p_org_information10);
       l_end_date := fnd_date.canonical_to_date(p_org_information11);
       validate_date(l_start_date
                    ,l_end_date);

       IF g_debug THEN
          hr_utility.trace('Checking for Duplicate Record');
       END IF;

       check_record_exists(p_org_information_id   => p_org_information_id
                          ,p_organization_id      => p_organization_id
                          ,p_org_info_type_code   => p_org_info_type_code
                          ,p_org_information1     => p_org_information1
       			  ,p_org_information2     => p_org_information2
			  ,p_org_information3     => p_org_information3
	  		  ,p_org_information4     => p_org_information9
			  ,p_effective_start_date => l_start_date
			  ,p_effective_end_date   => l_end_date
			  );

       IF g_debug THEN
          hr_utility.trace('Calling pay_cn_deductions.check_phf_si_rates_setup');
       END IF;

       pay_cn_deductions.check_phf_si_rates_setup
              (p_organization_id         => p_organization_id
              ,p_contribution_area       => p_org_information1
              ,p_organization            => p_org_information2
              ,p_phf_si_type             => p_org_information3
              ,p_hukou_type              => p_org_information9
              ,p_effective_start_date    => l_start_date
              ,p_effective_end_date      => l_end_date
              ,p_message_name            => g_message_name
              ,p_token_name              => g_token_name
              ,p_token_value             => g_token_value
              );

  END IF;
  hr_cn_api.set_location(g_debug,'Leaving ' || l_procedure,10);

END check_cn_org_internal;

--------------------------------------------------------------------------
-- Name           : check_cn_org_info_type_create                       --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Info Hook  --
-- Parameters     :                                                     --
--             IN :       p_effective_date         IN DATE              --
--                        p_organization_id        IN NUMBER            --
--                        p_org_info_type_code     IN VARCHAR2          --
--		          p_org_information1..20   IN VARCHAR2          --
--------------------------------------------------------------------------
PROCEDURE check_cn_org_info_type_create
        (p_org_info_type_code IN VARCHAR2 --Organization Information type
        ,p_organization_id    IN NUMBER   --Organization ID
        ,p_org_information1   IN VARCHAR2
        ,p_org_information2   IN VARCHAR2
        ,p_org_information3   IN VARCHAR2
        ,p_org_information4   IN VARCHAR2
        ,p_org_information5   IN VARCHAR2
        ,p_org_information6   IN VARCHAR2
        ,p_org_information7   IN VARCHAR2
        ,p_org_information8   IN VARCHAR2
        ,p_org_information9   IN VARCHAR2
        ,p_org_information10  IN VARCHAR2
        ,p_org_information11  IN VARCHAR2
        ,p_org_information12  IN VARCHAR2
        ,p_org_information13  IN VARCHAR2
        ,p_org_information14  IN VARCHAR2
        ,p_org_information15  IN VARCHAR2
        ,p_org_information16  IN VARCHAR2
        ,p_org_information17  IN VARCHAR2
        ,p_org_information18  IN VARCHAR2
        ,p_org_information19  IN VARCHAR2
        ,p_org_information20  IN VARCHAR2
        )
IS

      l_procedure         VARCHAR2(100);

BEGIN
        l_procedure := g_package || 'check_cn_org_info_type_create';
        g_debug := hr_utility.debug_enabled;

        hr_cn_api.set_location(g_debug,'Entering ' || l_procedure,10);

	-- Call check_cn_org_internal
        check_cn_org_internal
        (p_org_info_type_code => p_org_info_type_code
        ,p_org_information_id => NULL
        ,p_organization_id    => p_organization_id
        ,p_org_information1   => p_org_information1
        ,p_org_information2   => p_org_information2
        ,p_org_information3   => p_org_information3
        ,p_org_information4   => p_org_information4
        ,p_org_information5   => p_org_information5
        ,p_org_information6   => p_org_information6
        ,p_org_information7   => p_org_information7
        ,p_org_information8   => p_org_information8
        ,p_org_information9   => p_org_information9
        ,p_org_information10  => p_org_information10
        ,p_org_information11  => p_org_information11
        ,p_org_information12  => p_org_information12
        ,p_org_information13  => p_org_information13
        ,p_org_information14  => p_org_information14
        ,p_org_information15  => p_org_information15
        ,p_org_information16  => p_org_information16
        ,p_org_information17  => p_org_information17
        ,p_org_information18  => p_org_information18
        ,p_org_information19  => p_org_information19
        ,p_org_information20  => p_org_information20
        ,p_message_name       => g_message_name
        ,p_token_name         => g_token_name
        ,p_token_value        => g_token_value
        );

        hr_cn_api.set_location(g_debug,l_procedure,20);

	IF g_debug THEN
	   hr_utility.trace('Message => ' || g_message_name);
	END IF;

        hr_cn_api.raise_message(800
                               ,g_message_name
                               ,g_token_name
                               ,g_token_value);

        hr_cn_api.set_location(g_debug,'Leaving ' || l_procedure,10);

END CHECK_CN_ORG_INFO_TYPE_CREATE;

--------------------------------------------------------------------------
-- Name           : check_cn_org_info_type_update                       --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Info Hook  --
-- Parameters     :                                                     --
--             IN :       p_effective_date         IN DATE              --
--                        p_organization_id        IN NUMBER            --
--                        p_org_info_type_code     IN VARCHAR2          --
--		          p_org_information1..20   IN VARCHAR2          --
--------------------------------------------------------------------------
PROCEDURE CHECK_CN_ORG_INFO_TYPE_UPDATE
        (p_org_info_type_code IN VARCHAR2 --Organization Information type
        ,p_org_information_id IN NUMBER   --Organization Information ID
        ,p_org_information1   IN VARCHAR2
        ,p_org_information2   IN VARCHAR2
        ,p_org_information3   IN VARCHAR2
        ,p_org_information4   IN VARCHAR2
        ,p_org_information5   IN VARCHAR2
        ,p_org_information6   IN VARCHAR2
        ,p_org_information7   IN VARCHAR2
        ,p_org_information8   IN VARCHAR2
        ,p_org_information9   IN VARCHAR2
        ,p_org_information10  IN VARCHAR2
        ,p_org_information11  IN VARCHAR2
        ,p_org_information12  IN VARCHAR2
        ,p_org_information13  IN VARCHAR2
        ,p_org_information14  IN VARCHAR2
        ,p_org_information15  IN VARCHAR2
        ,p_org_information16  IN VARCHAR2
        ,p_org_information17  IN VARCHAR2
        ,p_org_information18  IN VARCHAR2
        ,p_org_information19  IN VARCHAR2
        ,p_org_information20  IN VARCHAR2
        )
IS
      l_organization_id   NUMBER;
      l_procedure         VARCHAR2(100);
      l_org_information1  VARCHAR2(150);
      l_org_information2  VARCHAR2(150);
      l_org_information3  VARCHAR2(150);
      l_org_information4  VARCHAR2(150);
      l_org_information5  VARCHAR2(150);
      l_org_information6  VARCHAR2(150);
      l_org_information7  VARCHAR2(150);
      l_org_information8  VARCHAR2(150);
      l_org_information9  VARCHAR2(150);
      l_org_information10 VARCHAR2(150);
      l_org_information11 VARCHAR2(150);
      l_org_information12 VARCHAR2(150);
      l_org_information13 VARCHAR2(150);
      l_org_information14 VARCHAR2(150);
      l_org_information15 VARCHAR2(150);
      l_org_information16 VARCHAR2(150);
      l_org_information17 VARCHAR2(150);
      l_org_information18 VARCHAR2(150);
      l_org_information19 VARCHAR2(150);
      l_org_information20 VARCHAR2(150);

      CURSOR csr_org_info
      IS
        SELECT organization_id
	      ,org_information1
	      ,org_information2
	      ,org_information3
	      ,org_information4
	      ,org_information5
	      ,org_information6
	      ,org_information7
	      ,org_information8
	      ,org_information9
	      ,org_information10
	      ,org_information11
	      ,org_information12
	      ,org_information13
	      ,org_information14
	      ,org_information15
	      ,org_information16
	      ,org_information17
	      ,org_information18
	      ,org_information19
	      ,org_information20
	FROM  hr_organization_information
	WHERE org_information_id = p_org_information_id;

BEGIN

       l_procedure := g_package || 'check_cn_org_info_type_update';
       g_debug := hr_utility.debug_enabled;

       hr_cn_api.set_location(g_debug,'Entering ' || l_procedure,10);

       OPEN csr_org_info;
       FETCH csr_org_info
       INTO l_organization_id
           ,l_org_information1
           ,l_org_information2
           ,l_org_information3
           ,l_org_information4
           ,l_org_information5
           ,l_org_information6
           ,l_org_information7
           ,l_org_information8
           ,l_org_information9
           ,l_org_information10
           ,l_org_information11
           ,l_org_information12
           ,l_org_information13
           ,l_org_information14
           ,l_org_information15
           ,l_org_information16
           ,l_org_information17
           ,l_org_information18
           ,l_org_information19
           ,l_org_information20 ;
       CLOSE csr_org_info;

       IF NVL(p_org_information1,'X') <> hr_api.g_varchar2 THEN
          l_org_information1 := p_org_information1;
       END IF;
       IF NVL(p_org_information2,'X') <> hr_api.g_varchar2 THEN
          l_org_information2 := p_org_information2;
       END IF;
       IF NVL(p_org_information3,'X') <> hr_api.g_varchar2 THEN
          l_org_information3 := p_org_information3;
       END IF;
       IF NVL(p_org_information4,'X') <> hr_api.g_varchar2 THEN
          l_org_information4 := p_org_information4;
       END IF;
       IF NVL(p_org_information5,'X') <> hr_api.g_varchar2 THEN
          l_org_information5 := p_org_information5;
       END IF;
       IF NVL(p_org_information6,'X') <> hr_api.g_varchar2 THEN
          l_org_information6 := p_org_information6;
       END IF;
       IF NVL(p_org_information7,'X') <> hr_api.g_varchar2 THEN
          l_org_information7 := p_org_information7;
       END IF;
       IF NVL(p_org_information8,'X') <> hr_api.g_varchar2 THEN
          l_org_information8 := p_org_information8;
       END IF;
       IF NVL(p_org_information9,'X') <> hr_api.g_varchar2 THEN
          l_org_information9 := p_org_information9;
       END IF;
       IF NVL(p_org_information10,'X') <> hr_api.g_varchar2 THEN
          l_org_information10 := p_org_information10;
       END IF;
       IF NVL(p_org_information11,'X') <> hr_api.g_varchar2 THEN
          l_org_information11 := p_org_information11;
       END IF;
       IF NVL(p_org_information12,'X') <> hr_api.g_varchar2 THEN
          l_org_information12 := p_org_information12;
       END IF;
       IF NVL(p_org_information13,'X') <> hr_api.g_varchar2 THEN
          l_org_information13 := p_org_information13;
       END IF;
       IF NVL(p_org_information14,'X') <> hr_api.g_varchar2 THEN
          l_org_information14 := p_org_information14;
       END IF;
       IF NVL(p_org_information15,'X') <> hr_api.g_varchar2 THEN
          l_org_information15 := p_org_information15;
       END IF;
       IF NVL(p_org_information16,'X') <> hr_api.g_varchar2 THEN
          l_org_information16 := p_org_information16;
       END IF;
       IF NVL(p_org_information17,'X') <> hr_api.g_varchar2 THEN
          l_org_information17 := p_org_information17;
       END IF;
       IF NVL(p_org_information18,'X') <> hr_api.g_varchar2 THEN
          l_org_information18 := p_org_information18;
       END IF;
       IF NVL(p_org_information19,'X') <> hr_api.g_varchar2 THEN
          l_org_information19 := p_org_information19;
       END IF;
       IF NVL(p_org_information20,'X') <> hr_api.g_varchar2 THEN
          l_org_information20 := p_org_information20;
       END IF;

       -- Call check_cn_org_internal
       check_cn_org_internal
        (p_org_info_type_code => p_org_info_type_code
        ,p_org_information_id => p_org_information_id
        ,p_organization_id    => l_organization_id
        ,p_org_information1   => l_org_information1
        ,p_org_information2   => l_org_information2
        ,p_org_information3   => l_org_information3
        ,p_org_information4   => l_org_information4
        ,p_org_information5   => l_org_information5
        ,p_org_information6   => l_org_information6
        ,p_org_information7   => l_org_information7
        ,p_org_information8   => l_org_information8
        ,p_org_information9   => l_org_information9
        ,p_org_information10  => l_org_information10
        ,p_org_information11  => l_org_information11
        ,p_org_information12  => l_org_information12
        ,p_org_information13  => l_org_information13
        ,p_org_information14  => l_org_information14
        ,p_org_information15  => l_org_information15
        ,p_org_information16  => l_org_information16
        ,p_org_information17  => l_org_information17
        ,p_org_information18  => l_org_information18
        ,p_org_information19  => l_org_information19
        ,p_org_information20  => l_org_information20
        ,p_message_name       => g_message_name
        ,p_token_name         => g_token_name
        ,p_token_value        => g_token_value
        );

	hr_cn_api.set_location(g_debug,l_procedure,20);

        hr_cn_api.raise_message(800
                               ,g_message_name
                               ,g_token_name
                               ,g_token_value);

       hr_cn_api.set_location(g_debug,'Leaving ' || l_procedure,30);

END CHECK_CN_ORG_INFO_TYPE_UPDATE;

BEGIN

    g_package := 'per_cn_org_info_leg_hook.';

END per_cn_org_info_leg_hook;

/
