--------------------------------------------------------
--  DDL for Package Body PQP_GB_OMP_EARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_OMP_EARNINGS" AS
/* $Header: pqpgboae.pkb 115.1 2002/12/03 11:31:20 cchappid noship $ */

  g_proc_name         VARCHAR2(80) := 'pqp_gb_omp_earnings.';
  l_person_id         per_assignments_f.person_id%TYPE;

/*========================================================================
 *                    CALCULATE_SMP_AVERAGE_EARNINGS
 * This Function Returns the Average Earnings (SMP Earnings)Value of
 * a person effective of given date. First checks if there is a User
 * entered value. If it is Y then returns the user entered value
 * if N then calls SMP function.
 *=======================================================================*/
FUNCTION calculate_smp_average_earnings
           (p_assignment_id     IN NUMBER
           ,p_effective_date    IN DATE
           ,p_average_earnings  OUT NOCOPY NUMBER
           ,p_error_message     OUT NOCOPY VARCHAR2
           )
   RETURN NUMBER IS
--

CURSOR csr_avg_ern ( p_person_id      IN NUMBER,
                     p_effective_date IN DATE ) IS
SELECT user_entered, average_earnings_amount
  FROM ssp_earnings_calculations
 WHERE person_id      = p_person_id
   AND effective_date = p_effective_date ;

CURSOR csr_person_id ( p_assignment_id IN NUMBER ) IS
SELECT person_id
  FROM per_assignments_f
 WHERE assignment_id = p_assignment_id ;

 l_smp_average_earnings     NUMBER := 0;
 l_user_entered             VARCHAR2(1) := 'N' ;

BEGIN

  -- Find the person id for the given assignment.

     OPEN csr_person_id ( p_assignment_id => p_assignment_id )  ;
     FETCH csr_person_id INTO l_person_id ;
      IF csr_person_id%NOTFOUND THEN
        CLOSE csr_person_id ;
        p_error_message := 'Error in pqp_gb_omp_earnings:Person Id not'||
                     ' found for Assignment:'||p_assignment_id;
        RETURN -1;
      END IF ;
    CLOSE csr_person_id ;

-- Cursor to get user entered indicator and the earnings value.
    OPEN csr_avg_ern ( p_person_id      => l_person_id
                      ,p_effective_date => p_effective_date ) ;
    FETCH csr_avg_ern  INTO l_user_entered,l_smp_average_earnings ;
    CLOSE csr_avg_ern ;

IF l_user_entered = 'N' THEN
  -- Call the SMP function to derive the Average Earnings calculation
  -- as of the efective date.
  ssp_ern_bus.calculate_average_earnings (
         p_person_id                => l_person_id
        ,p_effective_date           => p_effective_date
        ,p_average_earnings_amount  => l_smp_average_earnings
        ,p_user_entered             => 'N'
        ,p_absence_category         => 'M');

    IF l_smp_average_earnings >= 0 THEN
       p_average_earnings := l_smp_average_earnings;
       RETURN 0;
    ELSE
       p_error_message := 'Error in pqp_gb_omp_earnings:Average Earnings'||
                          ' calculated was less than zero';
       RETURN -1;
    END IF;

 ELSIF l_user_entered ='Y' THEN

     p_average_earnings := l_smp_average_earnings;
     RETURN 0;

 END IF;

END calculate_smp_average_earnings;

END pqp_gb_omp_earnings;


/
