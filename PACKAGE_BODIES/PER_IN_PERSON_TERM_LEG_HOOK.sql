--------------------------------------------------------
--  DDL for Package Body PER_IN_PERSON_TERM_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_PERSON_TERM_LEG_HOOK" AS
/* $Header: peinlhte.pkb 120.4.12000000.5 2007/10/04 12:14:13 lnagaraj ship $ */
--
--
-- Globals
--
g_package         constant VARCHAR2(100) := 'per_in_person_term_leg_hook.' ;
g_debug           BOOLEAN ;
g_message_name    VARCHAR2(30);
g_token_name      pay_in_utils.char_tab_type;
g_token_value     pay_in_utils.char_tab_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : ACTUAL_TERMINATION_EMP_INT                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Internal Procedure for IN localization              --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id          NUMBER              --
--                  p_business_group_id             NUMBER              --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   30-Sep-04  sshankar 3801926  Created this procedure            --
-- 1.1   26-Oct-04  statkar  3847355  Removed call to pay_in_gratuity_pkg-
--------------------------------------------------------------------------
PROCEDURE actual_termination_emp_int
                      (p_effective_date          IN DATE
		      ,p_period_of_service_id    IN NUMBER
		      ,p_actual_termination_date IN DATE
		      ,p_business_group_id       IN NUMBER
		      ,p_calling_procedure       IN VARCHAR2
           	      ,p_message_name            OUT NOCOPY VARCHAR2
                      ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
                      ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type)
IS

--
l_procedure    VARCHAR2(100);
l_message      VARCHAR2(255);

--
BEGIN
--
  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'actual_termination_emp_int' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_effective_date          : ',p_effective_date);
  pay_in_utils.trace('p_period_of_service_id    : ',p_period_of_service_id);
  pay_in_utils.trace('p_actual_termination_date : ',p_actual_termination_date);
  pay_in_utils.trace('p_business_group_id       : ',p_business_group_id);
  pay_in_utils.trace('p_calling_procedure       : ',p_calling_procedure);
  pay_in_utils.trace('******************************','********************');
end if;

  pay_in_utils.null_message(g_token_name, g_token_value);
  g_message_name := 'SUCCESS';

  pay_in_termination_pkg.create_termination_elements
             (p_period_of_service_id    => p_period_of_service_id
             ,p_business_group_id       => p_business_group_id
             ,p_actual_termination_date => p_actual_termination_date
	     ,p_calling_procedure       => p_calling_procedure
	     ,p_message_name            => p_message_name
             ,p_token_name              => p_token_name
             ,p_token_value             => p_token_value);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_message_name            : ',p_message_name);
  pay_in_utils.trace('******************************','********************');
end if;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

--
END actual_termination_emp_int ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : REVERSE_TERMINATION_EMP                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id          NUMBER              --
--                  p_business_group_id             NUMBER              --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   30-Sep-04  sshankar 3801926  Created this procedure            --
-- 1.1   26-Oct-04  statkar  3847355  Removed call to pay_in_gratuity_pkg-
--------------------------------------------------------------------------
PROCEDURE reverse_termination_emp_int
                      (p_effective_date          IN DATE
		      ,p_period_of_service_id    IN NUMBER
		      ,p_actual_termination_date IN DATE
		      ,p_business_group_id       IN NUMBER
		      ,p_calling_procedure       IN VARCHAR2
           	      ,p_message_name            OUT NOCOPY VARCHAR2
                      ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
                      ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
		      )
IS
  l_procedure    VARCHAR2(100);
  l_message      VARCHAR2(255);
--
BEGIN
--
  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'reverse_termination_emp_int' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_effective_date          : ',p_effective_date);
  pay_in_utils.trace('p_period_of_service_id    : ',p_period_of_service_id);
  pay_in_utils.trace('p_actual_termination_date : ',p_actual_termination_date);
  pay_in_utils.trace('p_business_group_id       : ',p_business_group_id);
  pay_in_utils.trace('p_calling_procedure       : ',p_calling_procedure);
  pay_in_utils.trace('******************************','********************');
end if;

  pay_in_utils.null_message(g_token_name, g_token_value);
  g_message_name := 'SUCCESS';

  pay_in_termination_pkg.delete_termination_elements
             (p_period_of_service_id    => p_period_of_service_id
             ,p_business_group_id       => p_business_group_id
             ,p_actual_termination_date => p_actual_termination_date
	     ,p_calling_procedure       => p_calling_procedure
	     ,p_message_name            => p_message_name
             ,p_token_name              => p_token_name
             ,p_token_value             => p_token_value);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_message_name            : ',p_message_name);
  pay_in_utils.trace('******************************','********************');
end if;

  --
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

--
END reverse_termination_emp_int ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : ACTUAL_TERMINATION_EMP                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id          NUMBER              --
--                  p_business_group_id             NUMBER              --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   30-Sep-04  sshankar 3801926  Created this procedure            --
-- 1.1   11-Jul-06  rpalli   5242205  Restored orig proc with content   --
--                                    as NULL. This proc would not be   --
--                                    used further                      --
-- 1.2   27-Sep-06  aaagarwa 5559210                                    --
-- 1.3   11-Jul-07  rsaharay 6199974  Removed the select from           --
--                                    fnd_sessions                      --
--------------------------------------------------------------------------
PROCEDURE actual_termination_emp
                      (p_effective_date          IN DATE
                      ,p_period_of_service_id    IN NUMBER
                      ,p_actual_termination_date IN DATE
                      ,p_business_group_id    IN NUMBER
                      )
IS
CURSOR c_pds_details
IS
   SELECT final_process_date
         ,actual_termination_date
     FROM per_periods_of_service
    WHERE period_of_service_id = p_period_of_service_id;

  l_final_process_date         DATE;
  l_actual_termination_date    DATE;
  l_effective_date             DATE;
  l_procedure                  VARCHAR2(100);
  l_message                    VARCHAR2(255);
--
BEGIN
--

  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'actual_termination_emp';
  pay_in_utils.set_location(g_debug,'Entering: '|| l_procedure,10);

  IF g_debug
  THEN
    pay_in_utils.trace('******************************','********************');
    pay_in_utils.trace('p_effective_date          : ',p_effective_date);
    pay_in_utils.trace('p_period_of_service_id    : ',p_period_of_service_id);
    pay_in_utils.trace('p_actual_termination_date : ',p_actual_termination_date);
    pay_in_utils.trace('p_business_group_id       : ',p_business_group_id);
    pay_in_utils.trace('******************************','********************');
  END IF;

  OPEN  c_pds_details;
  FETCH c_pds_details INTO l_final_process_date,l_actual_termination_date;
  CLOSE c_pds_details;

  pay_in_utils.trace('l_final_process_date          : ',l_final_process_date);
  pay_in_utils.trace('l_actual_termination_date     : ',l_actual_termination_date);

  g_message_name := 'SUCCESS';
  pay_in_utils.null_message (g_token_name, g_token_value);
  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN
    IF (l_final_process_date IS NULL)
    THEN
        actual_termination_emp_int
                       (p_effective_date          => l_effective_date
                       ,p_period_of_service_id    => p_period_of_service_id
                       ,p_actual_termination_date => l_actual_termination_date
                       ,p_business_group_id       => p_business_group_id
                       ,p_calling_procedure       => l_procedure
                       ,p_message_name            => g_message_name
                       ,p_token_name              => g_token_name
                       ,p_token_value             => g_token_value
                      ) ;
    END IF;
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '|| l_procedure,30);
  RETURN;
END actual_termination_emp ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : FINAL_PROCESS_EMP                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id          NUMBER              --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   11-Jul-06  rpalli   5242205  Created this procedure            --
-- 1.2   11-Jul-07  rsaharay 6199974  Removed the select from           --
--                                    fnd_sessions                      --
--------------------------------------------------------------------------
PROCEDURE final_process_emp
                      (p_period_of_service_id    IN NUMBER)
IS

--
 CURSOR c_pos_dtls IS
     SELECT pos.business_group_id
           ,pos.actual_termination_date
     FROM   per_periods_of_service pos
     WHERE  pos.period_of_service_id = p_period_of_service_id;

l_business_group_id        NUMBER;
l_actual_termination_date  DATE;
l_effective_date           DATE;
--
--
l_procedure    VARCHAR2(100);
l_message      VARCHAR2(255);

--
BEGIN
--
  g_debug := hr_utility.debug_enabled ;

  l_procedure := g_package || 'final_process_emp' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_period_of_service_id    : ',p_period_of_service_id);
  pay_in_utils.trace('******************************','********************');
end if;

  g_message_name := 'SUCCESS';
  pay_in_utils.null_message (g_token_name, g_token_value);
  --
  -- Check if PAY is installed for India Localization
  --
  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN

     pay_in_utils.set_location(g_debug,l_procedure,20);

    OPEN c_pos_dtls;
    FETCH c_pos_dtls
     INTO  l_business_group_id, l_actual_termination_date;
    CLOSE c_pos_dtls;


    if g_debug then
      pay_in_utils.trace('l_effective_date          : ',l_effective_date);
      pay_in_utils.trace('l_actual_termination_date : ',l_actual_termination_date);
      pay_in_utils.trace('l_business_group_id       : ',l_business_group_id);
    end if;

     pay_in_utils.set_location(g_debug,l_procedure,25);

     actual_termination_emp_int
                       (p_effective_date          => l_effective_date
		       ,p_period_of_service_id    => p_period_of_service_id
		       ,p_actual_termination_date => l_actual_termination_date
		       ,p_business_group_id       => l_business_group_id
		       ,p_calling_procedure       => l_procedure
		       ,p_message_name            => g_message_name
		       ,p_token_name              => g_token_name
		       ,p_token_value             => g_token_value
		      ) ;
  --
  END IF ;

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('g_message_name            : ',g_message_name);
  pay_in_utils.trace('******************************','********************');
end if;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
  pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);
--
END final_process_emp ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : REVERSE_TERMINATION_EMP                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id          NUMBER              --
--                  p_business_group_id             NUMBER              --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   30-Sep-04  sshankar 3801926  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE reverse_termination_emp
                      (p_effective_date          IN DATE
		      ,p_period_of_service_id    IN NUMBER
		      ,p_actual_termination_date IN DATE
		      ,p_business_group_id    IN NUMBER
		      )
IS
  l_procedure    VARCHAR2(100);
  l_message      VARCHAR2(255);

--
BEGIN
--
  g_debug := hr_utility.debug_enabled ;

  l_procedure := g_package || 'reverse_termination_emp' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_effective_date          : ',p_effective_date);
  pay_in_utils.trace('p_period_of_service_id    : ',p_period_of_service_id);
  pay_in_utils.trace('p_actual_termination_date : ',p_actual_termination_date);
  pay_in_utils.trace('p_business_group_id       : ',p_business_group_id);
  pay_in_utils.trace('******************************','********************');
end if;

  g_message_name := 'SUCCESS';
  pay_in_utils.null_message (g_token_name, g_token_value);
  --
  -- Check if PAY is installed for India Localization
  --
  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN

     pay_in_utils.set_location(g_debug,l_procedure,20);

     reverse_termination_emp_int
                       (p_effective_date          => p_effective_date
		       ,p_period_of_service_id    => p_period_of_service_id
		       ,p_actual_termination_date => p_actual_termination_date
		       ,p_business_group_id       => p_business_group_id
		       ,p_calling_procedure       => l_procedure
		       ,p_message_name            => g_message_name
		       ,p_token_name              => g_token_name
		       ,p_token_value             => g_token_value
		      ) ;
  --
  END IF ;

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('g_message_name            : ',g_message_name);
  pay_in_utils.trace('******************************','********************');
end if;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
  pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);

--
END reverse_termination_emp ;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : UPDATE_PDS_DETAILS                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id      NUMBER                  --
--                  p_effective_date            DATE                    --
--                  p_leaving_reason            VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   19-Nov-04  aaagarwa 3977410  Created this procedure            --
-- 1.1   25-Sep-07  rsaharay 6401091  Modified cursor c_pos_dtls        --
--------------------------------------------------------------------------
PROCEDURE update_pds_details
                (p_period_of_service_id       IN NUMBER
                ,p_effective_date             IN DATE
                ,p_leaving_reason             IN VARCHAR2
                 )
IS
  CURSOR c_pos_dtls IS
     SELECT pos.actual_termination_date
           ,ppf.business_group_id
     FROM   per_periods_of_service pos
	   ,per_assignments_f paf
	   ,per_people_f ppf
     WHERE  pos.period_of_service_id = p_period_of_service_id
     AND    pos.period_of_service_id = paf.period_of_service_id
     AND    paf.person_id            = ppf.person_id
     AND    p_effective_date  BETWEEN ppf.effective_start_date
                              AND     ppf.effective_end_date
     AND    p_effective_date  BETWEEN paf.effective_start_date
                              AND     paf.effective_end_date;

  l_procedure                  VARCHAR2(100);
  l_message                    VARCHAR2(255);
  l_actual_termination_date    DATE;
  l_business_group_id          NUMBER;
--
BEGIN
--
  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'update_pds_details' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_period_of_service_id    : ',p_period_of_service_id);
  pay_in_utils.trace('p_effective_date          : ',p_effective_date);
  pay_in_utils.trace('p_leaving_reason          : ',p_leaving_reason);
  pay_in_utils.trace('******************************','********************');
end if;

  g_message_name := 'SUCCESS';

  pay_in_termination_pkg.g_leaving_reason := p_leaving_reason;

  pay_in_utils.null_message (g_token_name, g_token_value);
  --
  -- Check if PAY is installed for India Localization
  --

  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN

     pay_in_utils.set_location(g_debug,l_procedure,20);
     OPEN c_pos_dtls;
     FETCH c_pos_dtls
     INTO l_actual_termination_date, l_business_group_id;
     CLOSE c_pos_dtls;

if g_debug then
     pay_in_utils.trace('l_business_group_id         : ',l_business_group_id);
     pay_in_utils.trace('l_actual_termination_date   : ',l_actual_termination_date);
end if;

     pay_in_utils.set_location(g_debug,l_procedure,30);
     pay_in_termination_pkg.delete_gratuity_entry
              (p_period_of_service_id    => p_period_of_service_id
              ,p_business_group_id       => l_business_group_id
              ,p_actual_termination_date => l_actual_termination_date
              ,p_calling_procedure       => l_procedure
              ,p_message_name            => g_message_name
              ,p_token_name              => g_token_name
              ,p_token_value             => g_token_value
              );

if g_debug then
  pay_in_utils.trace('******************************','********************');
     pay_in_utils.trace('g_message_name            : ',g_message_name);
  pay_in_utils.trace('******************************','********************');
end if;

     pay_in_utils.set_location(g_debug,l_procedure,40);
     pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);
     g_message_name := 'SUCCESS';
     pay_in_utils.null_message (g_token_name, g_token_value);



     pay_in_termination_pkg.create_gratuity_entry
              (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => l_business_group_id
	      ,p_actual_termination_date => l_actual_termination_date
	      ,p_calling_procedure       => l_procedure
              ,p_message_name            => g_message_name
              ,p_token_name              => g_token_name
              ,p_token_value             => g_token_value
              );

if g_debug then
  pay_in_utils.trace('******************************','********************');
     pay_in_utils.trace('g_message_name            : ',g_message_name);
  pay_in_utils.trace('******************************','********************');
end if;

     pay_in_utils.set_location(g_debug,l_procedure,50);
     pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);

  END IF ;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

END update_pds_details;

END   per_in_person_term_leg_hook;

/
