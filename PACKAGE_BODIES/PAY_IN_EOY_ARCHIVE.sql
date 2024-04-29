--------------------------------------------------------
--  DDL for Package Body PAY_IN_EOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_EOY_ARCHIVE" AS
/* $Header: pyinpeoy.pkb 120.30.12010000.3 2008/08/06 07:28:41 ubhat ship $ */

   g_asg_tab             t_asg_tab;
   g_pay_gre_tab         t_gre_tab;
   g_count               NUMBER;
   g_global_count        NUMBER ;
   g_debug               BOOLEAN;

  g_archive_pact         NUMBER;
  g_employee_type        VARCHAR2(20);
  g_gre_id               VARCHAR2(20);
  g_start_date           DATE;
  g_end_date             DATE;
  g_term_date            DATE;
  g_system_date          VARCHAR2(30);
  g_year                 VARCHAR2(20);
  g_bg_id                NUMBER;
  g_package              CONSTANT VARCHAR2(100) := 'pay_in_eoy_archive.';
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : RANGE_CODE                                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns a sql string to select a     --
  --                  range of assignments eligible for archival.         --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : p_sql                  VARCHAR2                     --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE range_code(
                        p_payroll_action_id   IN  NUMBER
                       ,p_sql                 OUT NOCOPY VARCHAR2
                      )
  IS
  --
    l_procedure  VARCHAR2(100);
    l_message   VARCHAR2(255);
  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure  := g_package || 'range_code';
    -- Call core package to return SQL string to SELECT a range
    -- of assignments eligible for archival
    --
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
    pay_core_payslip_utils.range_cursor(p_payroll_action_id
                                       ,p_sql);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  --
  END range_code;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_PARAMETERS                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure determines the globals applicable    --
  --                  through out the tenure of the process               --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------

PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT  NOCOPY VARCHAR2) IS

CURSOR csr_parameter_info(p_pact_id NUMBER,
                          p_token   CHAR) IS
SELECT SUBSTR(legislative_parameters,
               INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                INSTR(legislative_parameters,' ',
                       INSTR(legislative_parameters,p_token))
                 - (INSTR(legislative_parameters,p_token)+LENGTH(p_token)))
       ,business_group_id
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_token_value                     VARCHAR2(50);
l_bg_id                           NUMBER;
l_message   VARCHAR2(255);
l_procedure VARCHAR2(100);


BEGIN


 l_procedure := g_package ||'get_parameters';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
       pay_in_utils.trace('Payroll Action id  ',p_payroll_action_id);
       pay_in_utils.trace('Token Name         ',p_token_name);
  END IF;


  OPEN csr_parameter_info(p_payroll_action_id,
                          p_token_name);

  FETCH csr_parameter_info INTO l_token_value,l_bg_id;

  CLOSE csr_parameter_info;

  p_token_value := TRIM(l_token_value);

  IF (p_token_name = 'BG_ID') THEN
      p_token_value := l_bg_id;
  END IF;

  IF (p_token_value IS NULL) THEN
       p_token_value := '%';
  END IF;

    IF g_debug THEN
       pay_in_utils.trace('Token Value         ',p_token_value);
  END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);


END get_parameters;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : INITIALIZATION_CODE                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to set global contexts.      --
  --                  The globals used are PL/SQL tables                  --
  --                  This will be used to define balance and other context-
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE initialization_code (
                                  p_payroll_action_id  IN NUMBER
                                )
  IS
  --
    l_procedure  VARCHAR2(100) ;
    l_message   VARCHAR2(255);
  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || 'initialization_code';

    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    g_archive_pact := p_payroll_action_id;

   IF g_debug THEN
       pay_in_utils.trace('Payroll Action id  ',p_payroll_action_id);
   END IF;

    get_parameters(p_payroll_action_id,'YEAR',g_year);
    get_parameters(p_payroll_action_id,'GRE',g_gre_id);
    get_parameters(p_payroll_action_id,'EMPLOYEE_TYPE',g_employee_type);


    SELECT TRUNC(effective_date)
    INTO   g_system_date
    FROM   fnd_sessions
    WHERE  session_id = USERENV('sessionid');

   pay_in_utils.set_location(g_debug,l_procedure, 20);

    g_start_date := fnd_date.string_to_date(('01/04/'|| SUBSTR(g_year,1,4)),'DD/MM/YYYY');
    g_end_date   := fnd_date.string_to_date(('31/03/'|| SUBSTR(g_year,6)),'DD/MM/YYYY');

    g_start_date := ADD_MONTHS(g_start_date,-12);
    g_end_date   := ADD_MONTHS(g_end_date,-12);

    SELECT FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
    INTO   g_bg_id
    FROM   dual;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  END initialization_code;


 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : PROCESS_EMPLOYEE_TYPE                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : Procedure to check the archival eligibility of an   --
  --                  assignment                                          --
  -- Parameters     :                                                     --
  --             IN : p_employee_type         VARCHAR2                    --
  --                  p_assignment_id         NUMBER                      --
  --                  p_gre_id                VARCHAR2                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 10-JUN-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  FUNCTION process_employee_type(p_employee_type   VARCHAR2
                                ,p_assignment_id   NUMBER
                                ,p_gre_id          VARCHAR2
                                 )
  RETURN BOOLEAN
  IS
  --This cursor determines termination date of an assignment.
      CURSOR c_termination_check
      IS
        SELECT NVL(pos.actual_termination_date,(fnd_date.string_to_date('31-12-4712','DD-MM-YYYY')))
        FROM   per_all_assignments_f  asg
              ,per_periods_of_service pos
        WHERE asg.person_id         = pos.person_id
        AND   asg.assignment_id     = p_assignment_id
        AND   asg.business_group_id = pos.business_group_id
        AND   asg.business_group_id = g_bg_id
        AND   NVL(pos.actual_termination_date,(to_date('31-12-4712','DD-MM-YYYY')))
        BETWEEN asg.effective_start_date AND asg.effective_end_date
        ORDER BY 1 desc;
  --This cursor determines the GRE/Legal Entity as on the end of financial year.
      CURSOR c_gre_id
      IS
        SELECT 1
        FROM   per_all_assignments_f  asg
              ,hr_soft_coding_keyflex scl
        WHERE asg.assignment_id = p_assignment_id
        AND   asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
        AND   scl.segment1 = TO_CHAR(g_gre_id)
        AND   g_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date;
  --This cursor determines if an assignment had a change in GRE/Legal Entity. If
  --this cursor retruns 0 or 1 then this means that there was no change in asg's
  --GRE/Legal entity. This cursor returns 0 if the assignment was created on a
  --Date prior or equal to g_start_date and scl.segment1 didnot go any change for
  --the complete period starting from g_start_date and ending on g_end_date.
      CURSOR c_gre_count
      IS
        SELECT COUNT(DISTINCT scl.segment1)
        FROM   per_all_assignments_f  asg
              ,hr_soft_coding_keyflex scl
        WHERE asg.assignment_id = p_assignment_id
        AND   asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
        AND (  asg.effective_start_date BETWEEN g_start_date AND g_end_date
             OR
               g_start_date BETWEEN  asg.effective_start_date AND g_end_date
             );
  --This cursor determines the presence of an assignment in a given GRE/Legal Entity
  --in a given financial year. Here the purpose is to ascertain the presence of an
  --employee in a GRE in a given financial year.
      CURSOR c_gre_employee
      IS
        SELECT 1
        FROM   per_all_assignments_f  asg
              ,hr_soft_coding_keyflex scl
        WHERE asg.assignment_id = p_assignment_id
        AND   asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
        AND   scl.segment1 = TO_CHAR(g_gre_id)
        AND   (asg.effective_start_date BETWEEN g_start_date AND g_end_date
               OR
               g_start_date BETWEEN asg.effective_start_date AND g_end_date
               )
        AND   ROWNUM = 1;
--
  l_flag                           NUMBER;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);

--
  BEGIN

 l_procedure := g_package ||'process_employee_type';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    -- Determine the presence of an asg in a GRE, if GRE was specified.
    IF (g_gre_id <> '%')
    THEN
            pay_in_utils.set_location(g_debug,l_procedure, 20);
         OPEN  c_gre_employee;
         FETCH c_gre_employee INTO l_flag;
         CLOSE c_gre_employee;
     -- Added NVL for bug 4964645
         IF (NVL(l_flag,-1) <> 1) THEN
               pay_in_utils.set_location(g_debug,l_procedure, 30);
            RETURN FALSE;
         END IF;

    END IF;

     -- Finding the termination date.
     OPEN  c_termination_check;
     FETCH c_termination_check INTO g_term_date;
     CLOSE c_termination_check;
--
     l_flag := NULL;
--
   pay_in_utils.set_location(g_debug,l_procedure, 20);
     IF (g_employee_type NOT IN('ALL','CURRENT'))
     THEN
        pay_in_utils.set_location(g_debug,l_procedure, 30);
          --Checking for terminated and transferred cases.
          IF (g_term_date BETWEEN g_start_date AND g_end_date-1)
          THEN
                RETURN TRUE;
          END IF;
         --Start checking for transferred case.
         l_flag := NULL;
         OPEN  c_gre_count;
         FETCH c_gre_count INTO l_flag;
         CLOSE c_gre_count;
        pay_in_utils.set_location(g_debug,l_procedure, 40);
         IF (l_flag < 2)
         THEN
             pay_in_utils.set_location(g_debug,l_procedure, 50);
             RETURN FALSE;     /* This assignment did not go any change in GRE/Legal entity and hence
                                  returning false                */
         ELSIF(g_gre_id = '%') THEN
             pay_in_utils.set_location(g_debug,l_procedure, 60);
             RETURN TRUE;     /*  Returning true as this asg had changes in GRE/Legal Entity.     */
         ELSE
             pay_in_utils.set_location(g_debug,l_procedure, 70);
             l_flag := NULL;                          -- This assignment was attached to the specified GRE.
             OPEN  c_gre_id;                          -- Now check for transfer. For this check the GRE as on the
             FETCH c_gre_id INTO l_flag;              -- last day of financial year. If its same, then there was
             CLOSE c_gre_id;                          -- no transfer and return false, else return true.
             IF (l_flag = 1)
             THEN
                  RETURN FALSE;
             ELSE
                  RETURN TRUE;
             END IF;
         END IF;
     ELSE
     --Start Checking for Regular Employee, i.e the employees who are attached to the specified GRE
     --as on the last day of the financial year.
        pay_in_utils.set_location(g_debug,l_procedure, 80);
        IF (g_term_date >= g_end_date)
        THEN -- Employee is a regular one.
        pay_in_utils.set_location(g_debug,l_procedure, 90);
             IF(g_gre_id = '%')
             THEN
                  RETURN TRUE;
             ELSE
                  OPEN  c_gre_id;
                  FETCH c_gre_id INTO l_flag;
                  CLOSE c_gre_id;
                  IF ((l_flag = 1)OR (g_employee_type ='ALL'))
                  THEN
                     RETURN TRUE;
                  ELSE
                     RETURN FALSE;
                  END IF;
             END IF;
        ELSE
        pay_in_utils.set_location(g_debug,l_procedure, 100);
             IF (g_employee_type ='ALL')
             THEN
                 RETURN TRUE;
             ELSE
                 RETURN FALSE;
             END IF;
        END IF;
     END IF;
  END process_employee_type;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_ACTION_CODE                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure further restricts the assignment_id's--
  --                  returned by range_code.                             --
  --                  It filters the assignments selected by range_code   --
  --                  procedure.                                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --                  p_start_person         NUMBER                       --
  --                  p_end_person           NUMBER                       --
  --                  p_chunk                NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  -- 115.1 14-Feb-2006    lnagaraj   Introduced c_process_assignments     --
  --------------------------------------------------------------------------
  --
  PROCEDURE assignment_action_code(p_payroll_action_id   IN NUMBER
                                  ,p_start_person        IN NUMBER
                                  ,p_end_person          IN NUMBER
                                  ,p_chunk               IN NUMBER
                                  )
  IS
  /*Changed for Bug 4768371*/
  CURSOR c_process_assignments
    IS
      SELECT  paf.assignment_id assignment_id
        FROM per_assignments_f paf
            ,pay_payroll_actions ppa
            ,pay_assignment_actions paa
       WHERE paf.business_group_id = g_bg_id
         AND paf.person_id BETWEEN p_start_person AND p_end_person
         AND p_payroll_action_id IS NOT NULL
         AND paa.tax_unit_id LIKE  g_gre_id
         AND paa.assignment_id =paf.assignment_id
         AND ppa.action_type IN('P','U','I')
         AND paa.payroll_action_id = ppa.payroll_action_id
         AND ppa.action_status = 'C'
         AND ppa.effective_date BETWEEN  g_start_date and g_end_date
         AND paf.effective_start_date <= g_end_date
         AND paf.effective_end_date >= g_start_date
         AND ppa.business_group_id =g_bg_id
         GROUP BY paf.assignment_id;



    l_procedure                 VARCHAR2(100);
    l_message                   VARCHAR2(255);
    l_action_id                 NUMBER;
    l_bg_id                     NUMBER;
    l_flag                      BOOLEAN;
  --
  BEGIN
  --
    l_procedure  :=  g_package || 'assignment_action_code';
    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    get_parameters(p_payroll_action_id,'BG_ID',l_bg_id);
    get_parameters(p_payroll_action_id,'YEAR',g_year);
    get_parameters(p_payroll_action_id,'GRE',g_gre_id);
    get_parameters(p_payroll_action_id,'EMPLOYEE_TYPE',g_employee_type);

    pay_in_utils.set_location(g_debug,l_procedure, 20);
    SELECT TRUNC(effective_date)
    INTO   g_system_date
    FROM   fnd_sessions
    WHERE  session_id = USERENV('sessionid');

    SELECT FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
    INTO   g_bg_id
    FROM   dual;

    g_start_date := fnd_date.string_to_date(('01/04/'|| SUBSTR(g_year,1,4)),'DD/MM/YYYY');
    g_end_date   := fnd_date.string_to_date(('31/03/'|| SUBSTR(g_year,6)),'DD/MM/YYYY');

    g_start_date := ADD_MONTHS(g_start_date,-12);
    g_end_date   := ADD_MONTHS(g_end_date,-12);

   pay_in_utils.set_location(g_debug,l_procedure, 30);


    FOR csr_rec IN c_process_assignments
    LOOP
       pay_in_utils.set_location(g_debug,l_procedure, 40);
        l_flag := FALSE;

       IF g_debug THEN
         pay_in_utils.trace('Assignment id  ',csr_rec.assignment_id);
       END IF;


        l_flag := process_employee_type(p_employee_type => g_employee_type
                                       ,p_assignment_id => csr_rec.assignment_id
                                       ,p_gre_id        => g_gre_id);
        IF (l_flag = TRUE) THEN
                 pay_in_utils.set_location(g_debug,l_procedure, 50);
                 SELECT pay_assignment_actions_s.NEXTVAL
                 INTO   l_action_id
                 FROM   dual;

                  hr_nonrun_asact.insact(lockingactid => l_action_id
                                        ,assignid     => csr_rec.assignment_id
                                        ,pactid       => p_payroll_action_id
                                        ,chunk        => p_chunk
                                        );
        END IF;

     END LOOP;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 60);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 70);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  END assignment_action_code;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PERSON_DATA                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the person data             --
  -- Parameters     :                                                     --
  --             IN : p_run_asg_action_id    NUMBER                       --
  --                  p_arc_asg_action_id    NUMBER                       --
  --                  p_payroll_run_date     DATE                         --
  --                  p_prepayment_date      DATE                         --
  --                  p_assignment_id        NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  -- 115.1 03-OCT-2005    snekkala   Added code to handle termination     --
  -- 115.2 25-SEP-2007    rsaharay   Modified c_pos                       --
  --------------------------------------------------------------------------
  --
   PROCEDURE archive_person_data(p_run_asg_action_id     IN NUMBER
                                ,p_arc_asg_action_id     IN NUMBER
                                ,p_arc_payroll_act_id    IN NUMBER
                                ,p_prepayment_date       IN DATE
                                ,p_assignment_id         IN NUMBER
                                ,p_gre_id                IN NUMBER
                                ,p_payroll_run_date      IN VARCHAR2
                                ,p_effective_start_date  IN DATE
                                ,p_effective_end_date    IN DATE
                                )
   IS

   CURSOR c_emp_no
   IS
   SELECT pep.employee_number             emp_no
         ,asg.person_id         person_id
         ,DECODE(scl.segment9,'N',DECODE(scl.segment10,'N','N','Y'),'Y')interest
         ,DECODE(pep.per_information4,NULL,pep.per_information5,pep.per_information4) pan
         ,DECODE(pep.title,NULL,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title)
         ,SUBSTR(hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title)
         ,INSTR(hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title),' ',1)+1)) name
         ,pep.title                                        title
         ,fnd_date.date_to_canonical(pep.date_of_birth)    dob
         ,pep.sex                                          gender
         ,pep.per_information7      residential_status
   FROM   per_all_assignments_f  asg
         ,hr_soft_coding_keyflex scl
         ,per_all_people_f       pep
   WHERE  asg.assignment_id = p_assignment_id
   AND    pep.person_id  = asg.person_id
   AND    pep.business_group_id = g_bg_id
   AND    asg.business_group_id = g_bg_id
   AND    asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = TO_CHAR(p_gre_id)
   AND    p_effective_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date
   AND    p_effective_end_date BETWEEN pep.effective_start_date AND pep.effective_end_date ;

  CURSOR c_pos
  IS
  SELECT nvl(pos.name,job.name) name
  FROM   per_all_positions pos
        ,per_assignments_f asg
        ,per_jobs          job
  WHERE  asg.position_id=pos.position_id(+)
  AND    asg.job_id=job.job_id(+)
  AND    asg.assignment_id = p_assignment_id
  AND    asg.business_group_id = g_bg_id
  AND    p_effective_end_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_end_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date;



  CURSOR c_father_name(p_person_id          NUMBER)
  IS
  SELECT DECODE(pea.title,NULL,hr_in_utility.per_in_full_name(pea.first_name,pea.middle_names,pea.last_name,pea.title)
        ,SUBSTR(hr_in_utility.per_in_full_name(pea.first_name,pea.middle_names,pea.last_name,pea.title)
        ,INSTR(hr_in_utility.per_in_full_name(pea.first_name,pea.middle_names,pea.last_name,pea.title),' ',1)+1))father
        ,pea.title       title
  FROM   per_all_people_f pep
        ,per_all_people_f pea
        ,per_contact_relationships con
  WHERE  pep.person_id = p_person_id
  AND    pea.person_id =con.contact_person_id
  AND    pep.business_group_id = g_bg_id
  AND    pea.business_group_id = g_bg_id
  AND    con.person_id=pep.person_id
  AND    con.contact_type='JP_FT'
  AND    p_effective_end_date BETWEEN pep.effective_start_date AND pep.effective_end_date
  AND    p_effective_end_date BETWEEN pea.effective_start_date AND pea.effective_end_date;

  CURSOR c_employee_address(p_person_id     NUMBER)
  IS
  SELECT address_id
        ,address_type
  FROM   per_addresses
  WHERE  person_id = p_person_id
  AND    address_type = DECODE(address_type,'IN_P','IN_P','IN_C')
  AND    p_effective_end_date BETWEEN date_from AND nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'))
  ORDER BY address_type DESC;

  CURSOR c_phone(p_person_id         NUMBER)
  IS
  SELECT phone_number rep_phone_no
        ,phone_type
  FROM   per_phones
  WHERE  parent_id = p_person_id
  AND    phone_type =  DECODE(phone_type,'H1','H1','M')
  AND    p_effective_end_date BETWEEN date_from AND NVL(date_to,TO_DATE('31-12-4712','DD-MM-YYYY'))
  ORDER BY phone_type ASC;

     l_emp_no                   per_all_assignments_f.assignment_number%TYPE;
     l_person_id                per_all_people_f.person_id%TYPE;
     l_dob                      VARCHAR2(30);
     l_pan                      per_all_people_f.per_information4%TYPE;
     l_residential_status       per_all_people_f.per_information7%TYPE;
     l_name                     per_all_people_f.full_name%TYPE;
     l_emp_title                per_all_people_f.title%TYPE;
     l_emp_fath_title           per_all_people_f.title%TYPE;
     l_father_name              per_all_people_f.full_name%TYPE;
     l_gender                   per_all_people_f.sex%TYPE;
     l_pos                      per_all_positions.name%TYPE;
     l_employee_address         per_addresses.address_id%TYPE;
     l_employee_address_type    per_addresses.address_type%TYPE;
     l_phone_no                 per_phones.phone_number%TYPE;
     l_phone_type               per_phones.phone_type%TYPE;
     l_interest                 VARCHAR2(2);
     l_action_info_id           NUMBER;
     l_ovn                      NUMBER;
     flag                       BOOLEAN;
     -- Added the variable as part of bug 4621622
     l_effective_end_date       DATE;
     l_message                  VARCHAR2(255);
     l_procedure                VARCHAR2(100);


   BEGIN

     l_procedure := g_package ||'archive_person_data';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     IF g_debug THEN
       pay_in_utils.trace('Run Assignment Action id    ',p_run_asg_action_id);
       pay_in_utils.trace('Archive Assignment Action id    ',p_arc_asg_action_id);
       pay_in_utils.trace('Archive payroll Action id      ',p_arc_payroll_act_id);
       pay_in_utils.trace('Prepayment Date         ',p_prepayment_date);
       pay_in_utils.trace('Assignment id          ',p_assignment_id);
       pay_in_utils.trace('GRE id                 ',p_gre_id);
       pay_in_utils.trace('Payroll Run Date        ',p_payroll_run_date);
       pay_in_utils.trace('Effective Start Date         ',p_effective_start_date);
       pay_in_utils.trace('Effective End Date           ',p_effective_end_date);
     END IF;

      OPEN  c_emp_no;
      FETCH c_emp_no INTO l_emp_no,l_person_id,l_interest,l_pan,l_name,l_emp_title,l_dob,l_gender,l_residential_status;
      CLOSE c_emp_no;


/*
      OPEN  c_person_details(l_person_id);
      FETCH c_person_details INTO l_pan,l_name,l_emp_title,l_dob,l_gender,l_residential_status;
      CLOSE c_person_details;
*/
      OPEN  c_pos;
      FETCH c_pos INTO l_pos;
      CLOSE c_pos;

      pay_in_utils.set_location(g_debug,l_procedure, 20);

      OPEN  c_father_name(l_person_id);
      FETCH c_father_name INTO l_father_name,l_emp_fath_title;
      CLOSE c_father_name;

      OPEN  c_employee_address(l_person_id);
      FETCH c_employee_address INTO l_employee_address,l_employee_address_type;
      CLOSE c_employee_address;

      OPEN  c_phone(l_person_id);
      FETCH c_phone INTO l_phone_no,l_phone_type;
      CLOSE c_phone;
      pay_in_utils.set_location(g_debug,l_procedure, 30);
      --
      -- Bug 4621622 : Added this code to handle termination case
      --
      IF p_effective_start_date > p_effective_end_date THEN
         l_effective_end_date := fnd_date.string_to_date('31-MAR-' || TO_CHAR(add_months(p_effective_start_date,12),'YYYY'),'DD-MM-YYYY');
      ELSE
         l_effective_end_date := p_effective_end_date;
      END IF;
      --
      -- Bug 4621622 changes end
      --
   pay_in_utils.set_location(g_debug,l_procedure, 40);

      pay_action_information_api.create_action_information
                (p_action_context_id              =>     p_arc_asg_action_id
                ,p_action_context_type            =>     'AAP'
                ,p_action_information_category    =>     'IN_EOY_PERSON'
                ,p_source_id                      =>     p_run_asg_action_id
                ,p_effective_date                 =>     p_prepayment_date
                ,p_assignment_id                  =>     p_assignment_id
                ,p_action_information1            =>     l_emp_no
                ,p_action_information2            =>     g_year
                ,p_action_information3            =>     p_gre_id
                ,p_action_information4            =>     l_pan
                ,p_action_information5            =>     l_name
                ,p_action_information6            =>     l_emp_title
                ,p_action_information7            =>     l_father_name
                ,p_action_information8            =>     l_emp_fath_title
                ,p_action_information9            =>     l_pos
                ,p_action_information10           =>     l_dob
                ,p_action_information11           =>     l_gender
                ,p_action_information12           =>     l_interest
                ,p_action_information13           =>     l_person_id
                ,p_action_information14           =>     l_employee_address
                ,p_action_information15           =>     l_residential_status
                ,p_action_information16           =>     l_phone_no
                ,p_action_information17           =>     p_effective_start_date
                -- Bug 4621622 : Changed p_effective_end_date to l_effective_end_date
                ,p_action_information18           =>     l_effective_end_date
                ,p_action_information19           =>     p_arc_payroll_act_id
                ,p_action_information20           =>     p_payroll_run_date
                ,p_action_information_id          =>     l_action_info_id
                ,p_object_version_number          =>     l_ovn
                );

          IF g_debug THEN
            pay_in_utils.trace('Employee Name           ',l_name);
            pay_in_utils.trace('Employee Number         ',l_emp_no);
            pay_in_utils.trace('Start Date              ',p_effective_start_date);
            pay_in_utils.trace('End Date                ',l_effective_end_date);
           END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);

   END archive_person_data;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : BALANCE_DIFFERENCE                                  --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure determines the balance difference.   --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 09-SEP-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE balance_difference(g_result_table1            IN pay_balance_pkg.t_detailed_bal_out_tab
                              ,g_result_table2            IN pay_balance_pkg.t_detailed_bal_out_tab
                              ,g_result_table  IN OUT NOCOPY pay_balance_pkg.t_detailed_bal_out_tab
                              )
  IS
     l_message   VARCHAR2(255);
     l_procedure VARCHAR2(100);

  BEGIN

   l_procedure := g_package ||'balance_difference';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     FOR i IN 1..GREATEST(g_result_table1.COUNT,g_result_table2.COUNT)
     LOOP
        g_result_table(i).balance_value :=
                        NVL(g_result_table1(i).balance_value,0)
                      - NVL(g_result_table2(i).balance_value,0);
     END LOOP;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

  END;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_BALANCES                                    --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This generic procedure archives the balances based  --
  --                  on the Source Text 2                                --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
   PROCEDURE archive_balances(p_run_asg_action_id     IN  NUMBER
                             ,pre_gre_asg_act_id      IN  NUMBER DEFAULT NULL
                             ,p_arc_asg_action_id     IN  NUMBER
                             ,p_gre_id                IN  NUMBER
                             ,p_action_inf_category   IN  VARCHAR2
                             ,p_balance_name          IN  VARCHAR2
                             ,p_balance_name1         IN  VARCHAR2 DEFAULT NULL
                             ,p_balance_name2         IN  VARCHAR2 DEFAULT NULL
                             ,p_balance_name3         IN  VARCHAR2 DEFAULT NULL
                             ,p_balance_dimension     IN  VARCHAR2
                             ,p_balance_dimension1    IN  VARCHAR2 DEFAULT NULL
                             ,p_balance_dimension2    IN  VARCHAR2 DEFAULT NULL
                             ,p_balance_dimension3    IN  VARCHAR2 DEFAULT NULL
                             ,g_context_table      IN OUT NOCOPY pay_balance_pkg.t_context_tab
                             ,g_result_table       IN OUT NOCOPY pay_balance_pkg.t_detailed_bal_out_tab
                             ,g_result_table1      IN OUT NOCOPY pay_balance_pkg.t_detailed_bal_out_tab
                             ,g_result_table2      IN OUT NOCOPY pay_balance_pkg.t_detailed_bal_out_tab
                             ,g_result_table3      IN OUT NOCOPY pay_balance_pkg.t_detailed_bal_out_tab
                             ,g_balance_value_tab  IN OUT NOCOPY pay_balance_pkg.t_balance_value_tab
                             )
  IS

   l_action_info_id      NUMBER;
   l_ovn                 NUMBER;
   l_result_table1       pay_balance_pkg.t_detailed_bal_out_tab;
   l_result_table2       pay_balance_pkg.t_detailed_bal_out_tab;
   l_message             VARCHAR2(255);
   l_procedure           VARCHAR2(100);
   l_result_table4       pay_balance_pkg.t_detailed_bal_out_tab;


  BEGIN

  l_procedure := g_package ||'archive_balances';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
       pay_in_utils.trace('Run Asg Action id              ',p_run_asg_action_id);
       pay_in_utils.trace('Prev GRE Asg action id         ',pre_gre_asg_act_id);
       pay_in_utils.trace('Archive Asg Action id          ',p_arc_asg_action_id);
       pay_in_utils.trace('GRE id                         ',p_gre_id);
       pay_in_utils.trace('Action Info Category           ',p_action_inf_category);
       pay_in_utils.trace('Balance name                   ',p_balance_name);
       pay_in_utils.trace('Balance name1                  ',p_balance_name1);
       pay_in_utils.trace('Balance name2                  ',p_balance_name2);
       pay_in_utils.trace('Balance name31                ',p_balance_name3);
       pay_in_utils.trace('Dimension Name                 ',p_balance_dimension);
       pay_in_utils.trace('Dimension Name1                ',p_balance_dimension1);
       pay_in_utils.trace('Dimension Name2                ',p_balance_dimension2);
       pay_in_utils.trace('Dimension Name3                ',p_balance_dimension3);

   END IF;

  /* Allowance Advance functionality Start */
    IF (p_action_inf_category ='IN_EOY_ALLOW') THEN
      pay_in_utils.set_location(g_debug,l_procedure, 21);

      g_balance_value_tab(1).defined_balance_id :=
                              pay_in_tax_utils.get_defined_balance('Adjusted Advance for Allowances','_ASG_COMP_YTD');

      pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                               ,p_defined_balance_lst   =>         g_balance_value_tab
                               ,p_context_lst           =>         g_context_table
                               ,p_output_table          =>         l_result_table1
                              );
      pay_in_utils.set_location(g_debug,l_procedure, 22);

      IF pre_gre_asg_act_id IS NOT NULL
      THEN
        pay_in_utils.set_location(g_debug,l_procedure, 30);
        pay_balance_pkg.get_value(p_assignment_action_id  =>         pre_gre_asg_act_id
                                 ,p_defined_balance_lst   =>         g_balance_value_tab
                                 ,p_context_lst           =>         g_context_table
                                 ,p_output_table          =>         l_result_table2
                                 );
        balance_difference(l_result_table1,l_result_table2,l_result_table4);
      ELSE
             l_result_table4 := l_result_table1;
      END IF;
      pay_in_utils.set_location(g_debug,l_procedure, 23);

      l_result_table1.DELETE;
      l_result_table2.DELETE;


    END IF;
    pay_in_utils.set_location(g_debug,l_procedure, 25);
   /* Allowance Advance functionality End*/

  g_balance_value_tab(1).defined_balance_id :=
                          pay_in_tax_utils.get_defined_balance(p_balance_name,p_balance_dimension);

  pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                           ,p_defined_balance_lst   =>         g_balance_value_tab
                           ,p_context_lst           =>         g_context_table
                           ,p_output_table          =>         l_result_table1--g_result_table
                           );

   pay_in_utils.set_location(g_debug,l_procedure, 20);

  IF pre_gre_asg_act_id IS NOT NULL
  THEN
          pay_in_utils.set_location(g_debug,l_procedure, 30);
          pay_balance_pkg.get_value(p_assignment_action_id  =>         pre_gre_asg_act_id
                                   ,p_defined_balance_lst   =>         g_balance_value_tab
                                   ,p_context_lst           =>         g_context_table
                                   ,p_output_table          =>         l_result_table2
                                    );
         balance_difference(l_result_table1,l_result_table2,g_result_table);
  ELSE
         g_result_table := l_result_table1;
  END IF;

   pay_in_utils.set_location(g_debug,l_procedure, 40);

  IF (p_balance_name1 IS NOT NULL)
  THEN
    pay_in_utils.set_location(g_debug,l_procedure, 50);
    g_balance_value_tab(1).defined_balance_id :=
                         pay_in_tax_utils.get_defined_balance(p_balance_name1,p_balance_dimension1);

    pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                              ,p_defined_balance_lst   =>         g_balance_value_tab
                              ,p_context_lst           =>         g_context_table
                              ,p_output_table          =>         l_result_table1--g_result_table1
                              );
    IF pre_gre_asg_act_id IS NOT NULL AND p_action_inf_category = 'IN_EOY_PERQ'
    THEN
       pay_in_utils.set_location(g_debug,l_procedure, 60);
            pay_balance_pkg.get_value(p_assignment_action_id  =>         pre_gre_asg_act_id
                                     ,p_defined_balance_lst   =>         g_balance_value_tab
                                     ,p_context_lst           =>         g_context_table
                                     ,p_output_table          =>         l_result_table2
                                      );
           balance_difference(l_result_table1,l_result_table2,g_result_table1);
    ELSE
       pay_in_utils.set_location(g_debug,l_procedure, 70);
           g_result_table1 := l_result_table1;
    END IF;
  END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 80);

  IF (p_balance_name2 IS NOT NULL)
  THEN
   pay_in_utils.set_location(g_debug,l_procedure, 90);
    g_balance_value_tab(1).defined_balance_id :=
                        pay_in_tax_utils.get_defined_balance(p_balance_name2,p_balance_dimension2);

    pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                              ,p_defined_balance_lst   =>         g_balance_value_tab
                              ,p_context_lst           =>         g_context_table
                              ,p_output_table          =>         l_result_table1--g_result_table2
                              );
    IF pre_gre_asg_act_id IS NOT NULL
    THEN
       pay_in_utils.set_location(g_debug,l_procedure, 100);
            pay_balance_pkg.get_value(p_assignment_action_id  =>         pre_gre_asg_act_id
                                     ,p_defined_balance_lst   =>         g_balance_value_tab
                                     ,p_context_lst           =>         g_context_table
                                     ,p_output_table          =>         l_result_table2
                                      );
           balance_difference(l_result_table1,l_result_table2,g_result_table2);
    ELSE
           g_result_table2 := l_result_table1;
    END IF;
  END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 110);

  IF (p_balance_name3 IS NOT NULL)
  THEN
   pay_in_utils.set_location(g_debug,l_procedure, 120);
    g_balance_value_tab(1).defined_balance_id :=
                        pay_in_tax_utils.get_defined_balance(p_balance_name3,p_balance_dimension3);

     pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                              ,p_defined_balance_lst   =>         g_balance_value_tab
                              ,p_context_lst           =>         g_context_table
                              ,p_output_table          =>         g_result_table3
                              );
  END IF;

   pay_in_utils.set_location(g_debug,l_procedure, 130);
   pay_in_utils.trace('**************************************************','********************');
  IF (p_action_inf_category = 'IN_EOY_ALLOW')
  THEN
     pay_in_utils.set_location(g_debug,l_procedure, 140);
          FOR i IN 1..g_context_table.COUNT
          LOOP
              IF ((g_result_table(i).balance_value <> 0)
               OR(NVL(g_result_table1(i).balance_value,0) <> 0)
               OR(NVL(g_result_table2(i).balance_value,0) <> 0)
               OR(NVL(g_result_table3(i).balance_value,0) <> 0)
               OR(NVL(l_result_table4(i).balance_value,0) <> 0)
               )
              THEN
                pay_action_information_api.create_action_information
                     (p_action_context_id              =>     p_arc_asg_action_id
                     ,p_action_context_type            =>     'AAP'
                     ,p_action_information_category    =>     p_action_inf_category
                     ,p_source_id                      =>     p_run_asg_action_id
                     ,p_action_information1            =>     g_context_table(i).source_text2
                     ,p_action_information2            =>     (NVL(g_result_table(i).balance_value,0) + NVL(l_result_table4(i).balance_value,0) )
                     ,p_action_information3            =>     NVL(g_result_table1(i).balance_value,0)
                     ,p_action_information4            =>     NVL(g_result_table2(i).balance_value,0)
                     ,p_action_information5            =>     NVL(g_result_table3(i).balance_value,0)
                     ,p_action_information_id          =>     l_action_info_id
                     ,p_object_version_number          =>     l_ovn
                     );
                IF g_debug THEN
                     pay_in_utils.trace('ALLOWANCE Name                  ',g_context_table(i).source_text2);
                     pay_in_utils.trace('ALLOWANCE Amt                   ',NVL(g_result_table(i).balance_value,0));
                     pay_in_utils.trace('ALLOWANCE Taxable Amt           ',NVL(g_result_table1(i).balance_value,0));
                     pay_in_utils.trace('ALLOWANCE Std  Amt              ',NVL(g_result_table2(i).balance_value,0));
                     pay_in_utils.trace('ALLOWANCE Std Taxable Amt       ',NVL(g_result_table3(i).balance_value,0));
                 END IF;

              END IF;
          END LOOP;
  ELSIF (p_action_inf_category = 'IN_EOY_PERQ')
  THEN
     pay_in_utils.set_location(g_debug,l_procedure, 150);
          FOR i IN 1..g_context_table.COUNT
          LOOP
              IF ((g_result_table(i).balance_value <> 0)
               OR(NVL(g_result_table1(i).balance_value,0) <> 0)
                 )
              THEN
                pay_action_information_api.create_action_information
                     (p_action_context_id              =>     p_arc_asg_action_id
                     ,p_action_context_type            =>     'AAP'
                     ,p_action_information_category    =>     p_action_inf_category
                     ,p_source_id                      =>     p_run_asg_action_id
                     ,p_action_information1            =>     g_context_table(i).source_text2
                     ,p_action_information2            =>     NVL(g_result_table(i).balance_value,0)
                     ,p_action_information3            =>     NVL(g_result_table1(i).balance_value,0)
                     ,p_action_information_id          =>     l_action_info_id
                     ,p_object_version_number          =>     l_ovn
                     );

                IF g_debug THEN
                     pay_in_utils.trace('PERQ Name        ',g_context_table(i).source_text2);
                     pay_in_utils.trace('PERQ Taxable Amt            ',NVL(g_result_table(i).balance_value,0));
                     pay_in_utils.trace('PERQ Employee Contribution  ',NVL(g_result_table1(i).balance_value,0));
                 END IF;

              END IF;
          END LOOP;
  ELSE
     pay_in_utils.set_location(g_debug,l_procedure, 160);
          FOR i IN 1..g_context_table.COUNT
          LOOP
              IF (g_result_table(i).balance_value <> 0)
              THEN
                pay_action_information_api.create_action_information
                     (p_action_context_id              =>     p_arc_asg_action_id
                     ,p_action_context_type            =>     'AAP'
                     ,p_action_information_category    =>     p_action_inf_category
                     ,p_source_id                      =>     p_run_asg_action_id
                     ,p_action_information1            =>     g_context_table(i).source_text2
                     ,p_action_information2            =>     g_result_table(i).balance_value
                     ,p_action_information_id          =>     l_action_info_id
                     ,p_object_version_number          =>     l_ovn
                     );

                IF g_debug THEN
                     pay_in_utils.trace('Oth Balance name        ',g_context_table(i).source_text2);
                     pay_in_utils.trace('Oth Balance Value       ',g_result_table(i).balance_value);
                 END IF;


              END IF;
          END LOOP;
  END IF;
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 170);

  END archive_balances;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_VIA_DETAILS                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the Chapter VI A related    --
  --                  balance details                                     --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
   PROCEDURE archive_via_details(p_run_asg_action_id     IN  NUMBER
                                ,p_arc_asg_action_id     IN  NUMBER
                                ,p_gre_id                IN  NUMBER
                                ,p_assignment_id         IN  NUMBER
                                ,p_payroll_date          IN  DATE
                                )
   IS

   CURSOR c_defined_balance_id--80D,80DD,80DDB,80G,80GGA
   IS
   SELECT pdb.defined_balance_id balance_id
         ,pbt.balance_name       balance_name
   FROM   pay_balance_types pbt
         ,pay_balance_dimensions pbd
         ,pay_defined_balances pdb
   WHERE  pbt.balance_name IN(
                               'F16 Deductions Sec 80D'
                              ,'F16 Deductions Sec 80DD'
                              ,'F16 Deductions Sec 80DDB'
                              ,'F16 Deductions Sec 80G'
                              ,'F16 Deductions Sec 80GGA'
                              )
   AND pbd.dimension_name='_ASG_LE_PTD'
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.balance_dimension_id  = pdb.balance_dimension_id
   ORDER BY pbt.balance_name;

   CURSOR c_def_balance_id--80E,80GG and 80U
   IS
   SELECT pdb.defined_balance_id balance_id
         ,pbt.balance_name       balance_name
   FROM   pay_balance_types pbt
         ,pay_balance_dimensions pbd
         ,pay_defined_balances pdb
   WHERE  pbt.balance_name IN(
                              'F16 Deductions Sec 80CCE'
                             ,'F16 Deductions Sec 80E'
                             ,'F16 Deductions Sec 80GG'
                             ,'F16 Deductions Sec 80U'
                             ,'F16 Employee PF Contribution'
                             ,'F16 Total Chapter VI A Deductions'
                             )
   AND pbd.dimension_name='_ASG_LE_PTD'
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.balance_dimension_id  = pdb.balance_dimension_id
   ORDER BY pbt.balance_name;

   g_bal_name_tab        t_bal_name_tab;
   g_balance_value_tab   pay_balance_pkg.t_balance_value_tab;
   g_balance_value_tab1  pay_balance_pkg.t_balance_value_tab;
   g_context_table       pay_balance_pkg.t_context_tab;
   g_result_table        pay_balance_pkg.t_detailed_bal_out_tab;
   g_result_table1       pay_balance_pkg.t_detailed_bal_out_tab;
   g_result_table2       pay_balance_pkg.t_detailed_bal_out_tab;
   g_result_table3       pay_balance_pkg.t_detailed_bal_out_tab;

   i                     NUMBER;
   l_defined_balance_id  NUMBER;
   l_action_info_id      NUMBER;
   l_ovn                 NUMBER;
   l_pf_contr            NUMBER;
   l_da_gross            NUMBER;
   l_da_qa_amt           NUMBER;
   l_scss_qa_amt         NUMBER;
   l_scss_gross         NUMBER;
   l_li_gross            NUMBER;
   l_li_qa_amt           NUMBER;
   l_pension_qa_amt      NUMBER;
   l_pension_gross       NUMBER;
   l_balance_defined_id  NUMBER;
   l_ytd_val             NUMBER;
   l_ptd_val             NUMBER;
   l_classification      hr_organization_information.org_information3%TYPE;
   l_message             VARCHAR2(255);
   l_procedure           VARCHAR2(100);
   l_80ccd_gross         NUMBER ;
   l_80ccd_qa_amt        NUMBER ;
BEGIN
--Qualifying Amount determination and archival for 80E,80GG and 80U

 l_procedure := g_package ||'archive_via_details';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  i := 1;
  g_bal_name_tab.DELETE;


  FOR c_rec IN c_def_balance_id
  LOOP
      g_balance_value_tab(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab(i).balance_name            := c_rec.balance_name;
      i := i + 1;
  END LOOP;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

 g_context_table(1).tax_unit_id := p_gre_id;

  pay_balance_pkg.get_value(p_assignment_action_id  =>     p_run_asg_action_id
                          ,p_defined_balance_lst   =>     g_balance_value_tab
                          ,p_context_lst           =>     g_context_table
                          ,p_output_table          =>     g_result_table
                          );

   pay_in_utils.set_location(g_debug,l_procedure, 30);
   pay_in_utils.trace('**************************************************','********************');
  FOR i IN 1..g_balance_value_tab.COUNT
  LOOP
      IF (g_result_table(i).balance_value <> 0)
      THEN
         pay_in_utils.set_location(g_debug,l_procedure, 40);
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_VIA'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     g_bal_name_tab(i).balance_name
             ,p_action_information2            =>     g_result_table(i).balance_value
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
                IF g_debug THEN
                     pay_in_utils.trace('VIA Balance name        ',g_bal_name_tab(i).balance_name);
                     pay_in_utils.trace('VIA Balance Value       ',g_result_table(i).balance_value);
                 END IF;

     END IF;
  END LOOP;

--Qualifying Amount determination for 80D,80DD,80DDB,80G,80GGA
  i := 1;
  g_bal_name_tab.DELETE;
  g_balance_value_tab.DELETE;
  g_result_table.DELETE;

   pay_in_utils.set_location(g_debug,l_procedure, 50);

  FOR c_rec IN c_defined_balance_id
  LOOP
      g_balance_value_tab(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab(i).balance_name            := c_rec.balance_name;
      i := i + 1;
  END LOOP;



  pay_balance_pkg.get_value(p_assignment_action_id  =>     p_run_asg_action_id
                          ,p_defined_balance_lst   =>     g_balance_value_tab
                          ,p_context_lst           =>     g_context_table
                          ,p_output_table          =>     g_result_table
                          );
   pay_in_utils.set_location(g_debug,l_procedure, 60);

--Gross Amount determination for 80D,80DD,80DDB,80G,80GGA

  g_result_table1.DELETE;
  g_balance_value_tab1.DELETE;
  g_context_table.DELETE;

  g_context_table(1).source_text2  := 'Medical Insurance';   -- 80D
  g_context_table(2).source_text2  := 'Disabled Dependents'; -- 80DD
  g_context_table(3).source_text2  := 'Disease Treatment';   -- 80DDB
  g_context_table(4).source_text2  := 'Donations';           -- 80G
  g_context_table(5).source_text2  := 'Research Donation';   -- 80GGA

   FOR i IN 1..5
   LOOP
     g_context_table(i).tax_unit_id := p_gre_id;
   END LOOP;

  g_balance_value_tab1(1).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('Gross Chapter VIA Deductions','_ASG_LE_COMP_PTD');

  pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                           ,p_defined_balance_lst   =>         g_balance_value_tab1
                           ,p_context_lst           =>         g_context_table
                           ,p_output_table          =>         g_result_table1
                           );

   pay_in_utils.set_location(g_debug,l_procedure, 70);

--Archiving the QA and Gross Amount in the same record for 80D,80DD,80DDB,80G,80GGA
  FOR i IN 1..g_balance_value_tab.COUNT
  LOOP
      IF ((g_result_table(i).balance_value <> 0)OR(g_result_table1(i).balance_value <> 0))
      THEN
         pay_in_utils.set_location(g_debug,l_procedure, 80);
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_VIA'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     g_bal_name_tab(i).balance_name
             ,p_action_information2            =>     g_result_table(i).balance_value
             ,p_action_information3            =>     g_result_table1(i).balance_value
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );

                IF g_debug THEN
                     pay_in_utils.trace('VIA Balance name        ',g_bal_name_tab(i).balance_name);
                     pay_in_utils.trace('VIA Qualifying Amt     ',g_result_table(i).balance_value);
                     pay_in_utils.trace('VIA Gross Amt           ',g_result_table1(i).balance_value);
                 END IF;


     END IF;
  END LOOP;

--Archival for 80CCE elements start here
  g_balance_value_tab.DELETE;
  g_context_table.DELETE;
  g_result_table1.DELETE;
  g_result_table.DELETE;

  g_context_table(1).source_text2  := 'House Loan Repayment';
  g_context_table(2).source_text2  := 'Public Provident Fund';
  g_context_table(3).source_text2  := 'Interest on NSC';
  g_context_table(4).source_text2  := 'Mutual Fund or UTI';
  g_context_table(5).source_text2  := 'National Housing Bank';
  g_context_table(6).source_text2  := 'ULIP';
  g_context_table(7).source_text2  := 'Notified Annuity Plan';
  g_context_table(8).source_text2  := 'Notified Pension Fund';
  g_context_table(9).source_text2  := 'Public Sector Scheme';
  g_context_table(10).source_text2 := 'Superannuation Fund';
  g_context_table(11).source_text2 := 'Infrastructure Bonds';
  g_context_table(12).source_text2 := 'NSC';
  g_context_table(13).source_text2 := 'Deposits in Govt. Security';
  g_context_table(14).source_text2 := 'Notified Deposit Scheme';
  g_context_table(15).source_text2 := 'Approved Shares or Debentures';
  g_context_table(16).source_text2 := 'Approved Mutual Fund';
  g_context_table(17).source_text2 := 'Tuition fee';
  g_context_table(18).source_text2 := 'Fixed Deposits';
  g_context_table(19).source_text2 := 'Five Year Post Office Time Deposit Account';
  g_context_table(20).source_text2 := 'NABARD Bank Deposits';


   FOR i IN 1..20
   LOOP
     g_context_table(i).tax_unit_id := p_gre_id;
   END LOOP;


  archive_balances(p_run_asg_action_id   => p_run_asg_action_id
                  ,p_arc_asg_action_id   => p_arc_asg_action_id
                  ,p_gre_id              => p_gre_id
                  ,p_action_inf_category => 'IN_EOY_VIA'
                  ,p_balance_name        => 'Deductions under Section 80CCE'
                  ,p_balance_dimension   => '_ASG_LE_COMP_PTD'
                  ,g_context_table       => g_context_table
                  ,g_result_table        => g_result_table
                  ,g_result_table1       => g_result_table1
                  ,g_result_table2       => g_result_table2
                  ,g_result_table3       => g_result_table3
                  ,g_balance_value_tab   => g_balance_value_tab
                  );

   pay_in_utils.set_location(g_debug,l_procedure, 90);

--Archive record for Deferred Anuity and Life Insurance Premium
  g_context_table.DELETE;
  g_result_table1.DELETE;
  g_result_table2.DELETE;
  g_result_table3.DELETE;
  g_result_table.DELETE;
  g_balance_value_tab.DELETE;
  g_balance_value_tab1.DELETE;

  g_context_table(1).source_text2  := 'Life Insurance Premium';
  g_context_table(2).source_text2  := 'Deferred Annuity';
  g_context_table(3).source_text2  := 'Pension Fund 80CCC';
  g_context_table(4).source_text2  := 'Senior Citizens Savings Scheme';

    FOR i IN 1..4
    LOOP
     g_context_table(i).tax_unit_id := p_gre_id;
    END LOOP;


  g_balance_value_tab(1).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('Deductions under Section 80CCE','_ASG_LE_COMP_PTD');

-- Qualifying Amounts for Life Insurance and  Deferred Annuity obtained
  pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                           ,p_defined_balance_lst   =>         g_balance_value_tab
                           ,p_context_lst           =>         g_context_table
                           ,p_output_table          =>         g_result_table
                           );

   l_li_qa_amt       := NVL(g_result_table(1).balance_value,0);
   l_da_qa_amt       := NVL(g_result_table(2).balance_value,0);
   l_pension_qa_amt  := NVL(g_result_table(3).balance_value,0);
   l_scss_qa_amt     := NVL(g_result_table(4).balance_value,0);

--Gross Amount for Life Insurance
 g_context_table.DELETE;

   pay_in_utils.set_location(g_debug,l_procedure, 100);
 g_context_table(1).source_text2  := 'Life Insurance Premium';
 g_context_table(1).tax_unit_id := p_gre_id;
 g_balance_value_tab1(1).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('Gross Chapter VIA Deductions','_ASG_LE_COMP_PTD');

  pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                           ,p_defined_balance_lst   =>         g_balance_value_tab1
                           ,p_context_lst           =>         g_context_table
                           ,p_output_table          =>         g_result_table1
                           );

   l_li_gross  := NVL(g_result_table1(1).balance_value,0);

  g_balance_value_tab1.DELETE;
  g_result_table1.DELETE;

   pay_in_utils.set_location(g_debug,l_procedure, 120);
--Gross Amount for Deferred Annuity
  g_context_table.DELETE;
  g_context_table(1).tax_unit_id := p_gre_id;

  g_balance_value_tab1(1).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('Deferred Annuity','_ASG_LE_PTD');

--Gross Amount for Pension Fund 80CCC

  g_balance_value_tab1(2).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('Pension Fund','_ASG_LE_PTD');

  --Gross Amount for Senior Citizens

  g_balance_value_tab1(3).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('Senior Citizens Savings Scheme','_ASG_LE_PTD');


  pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                           ,p_defined_balance_lst   =>         g_balance_value_tab1
                           ,p_context_lst           =>         g_context_table
                           ,p_output_table          =>         g_result_table1
                           );



   l_da_gross := NVL(g_result_table1(1).balance_value,0);

   l_pension_gross := NVL(g_result_table1(2).balance_value,0);

   l_scss_gross := NVL(g_result_table1(3).balance_value,0);


   pay_in_utils.set_location(g_debug,l_procedure, 140);

     g_balance_value_tab1.DELETE;
     g_result_table1.DELETE;
     g_context_table.DELETE;

--Gross Amount and Qualifying Amount for 80CCD
  g_context_table(1).tax_unit_id := p_gre_id;
  g_balance_value_tab1(1).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('F16 ER Pension Contribution','_ASG_LE_PTD');
  g_balance_value_tab1(2).defined_balance_id :=
  pay_in_tax_utils.get_defined_balance('F16 Section 80CCD','_ASG_LE_PTD');

  pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                           ,p_defined_balance_lst   =>         g_balance_value_tab1
                           ,p_context_lst           =>         g_context_table
                           ,p_output_table          =>         g_result_table1
                           );

  l_80ccd_gross        := NVL(g_result_table1(1).balance_value,0);
  l_80ccd_qa_amt       := NVL(g_result_table1(2).balance_value,0);

     g_balance_value_tab1.DELETE;
     g_result_table1.DELETE;
     g_context_table.DELETE;

--Archival of Deferred Annuity, Pension Fund 80CCC and Life Insurance starts
      IF (l_li_qa_amt <> 0 OR l_li_gross <> 0)
      THEN
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_VIA'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     'Life Insurance Premium'
             ,p_action_information2            =>     l_li_qa_amt
             ,p_action_information3            =>     l_li_gross
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
                IF g_debug THEN
                     pay_in_utils.trace('VIA LIC Qualifying Amt      ',l_li_qa_amt);
                     pay_in_utils.trace('VIA LIC Gross Amt           ',l_li_gross);
                 END IF;
     END IF;

     IF (l_da_gross <> 0 OR l_da_qa_amt <> 0)
      THEN
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_VIA'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     'Deferred Annuity'
             ,p_action_information2            =>     l_da_qa_amt
             ,p_action_information3            =>     l_da_gross
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
                IF g_debug THEN
                      pay_in_utils.trace('VIA Deferred Annuity Qualifying Amt      ',l_da_qa_amt);
                      pay_in_utils.trace('VIA Deferred Annuity Gross Amt           ',l_da_gross);
                END IF;

     END IF;

     IF (l_pension_gross <> 0 OR l_pension_qa_amt <> 0)
      THEN
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_VIA'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     'Pension Fund 80CCC'
             ,p_action_information2            =>     l_pension_qa_amt
             ,p_action_information3            =>     l_pension_gross
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );

                IF g_debug THEN
                     pay_in_utils.trace('VIA 80CCC Qualifying Amt      ',l_li_qa_amt);
                     pay_in_utils.trace('VIA 80CCC Gross Amt           ',l_li_gross);
                 END IF;

     END IF;

     IF (l_scss_gross <> 0 OR l_scss_qa_amt <> 0)
      THEN
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_VIA'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     'Senior Citizens Savings Scheme'
             ,p_action_information2            =>     l_scss_qa_amt
             ,p_action_information3            =>     l_scss_gross
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );

                IF g_debug THEN
                     pay_in_utils.trace('Senior Citizens Savings Scheme Qualifying Amt      ',l_scss_qa_amt);
                     pay_in_utils.trace('Senior Citizens Savings Scheme Gross Amt           ',l_scss_gross);
                 END IF;

     END IF;

     --Archival of 80CCD starts
      IF (l_80ccd_qa_amt <> 0 OR l_80ccd_gross <> 0)
      THEN
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_VIA'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     'Govt Pension Scheme 80CCD'
             ,p_action_information2            =>     l_80ccd_qa_amt
             ,p_action_information3            =>     l_80ccd_gross
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
                IF g_debug THEN
                     pay_in_utils.trace('VIA Deduction under Section 80CCD Qualifying Amt      ',l_80ccd_qa_amt);
                     pay_in_utils.trace('VIA Deduction under Section 80CCD Gross Amt           ',l_80ccd_gross);
                 END IF;
     END IF;
     pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,l_procedure, 150);

  END archive_via_details;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ALLOWANCES                                  --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the allowance related values--
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
   PROCEDURE archive_allowances(p_run_asg_action_id     IN  NUMBER
                               ,p_arc_asg_action_id     IN  NUMBER
                               ,p_gre_id                IN  NUMBER
                               ,pre_gre_asg_act_id      IN  NUMBER DEFAULT NULL
                               ,p_flag                  IN  BOOLEAN DEFAULT FALSE
                               )
   IS
     CURSOR c_hra
     IS
     SELECT action_information_id
           ,object_version_number
     FROM   pay_action_information
     WHERE  action_information_category = 'IN_EOY_ALLOW'
     AND    source_id = p_run_asg_action_id
     AND    action_context_id = p_arc_asg_action_id
     AND    action_information1 = 'House Rent Allowance'
     ORDER BY action_information_id DESC;

     CURSOR c_comp_name
     IS
     SELECT pur.row_low_range_or_name name
     FROM   pay_user_rows_f pur,
            pay_user_tables put
     WHERE  pur.user_table_id    = put.user_table_id
     AND    put.user_table_name  = 'IN_ALLOWANCES'
     AND    put.legislation_code = 'IN'
     AND   (pur.legislation_code = 'IN' OR pur.business_group_id = g_bg_id)
     AND    g_start_date BETWEEN pur.effective_start_date AND pur.effective_end_date
     ORDER by name ASC;

     g_balance_value_tab   pay_balance_pkg.t_balance_value_tab;
     g_context_table       pay_balance_pkg.t_context_tab;
     g_result_table        pay_balance_pkg.t_detailed_bal_out_tab;
     l_action_info_id      NUMBER;
     l_ovn                 NUMBER;
     l_defined_balance_id  NUMBER;
     g_result_table1       pay_balance_pkg.t_detailed_bal_out_tab;
     g_result_table2       pay_balance_pkg.t_detailed_bal_out_tab;
     g_result_table3       pay_balance_pkg.t_detailed_bal_out_tab;
     l_value               NUMBER;
     i                     NUMBER := 0;
     l_message             VARCHAR2(255);
     l_procedure           VARCHAR2(100);

   BEGIN

     l_procedure := g_package ||'archive_allowances';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


     FOR c_rec IN c_comp_name
     LOOP
        i := i + 1;
        g_context_table(i).source_text2  := c_rec.name;
     END LOOP;

  IF g_debug THEN
       pay_in_utils.trace('Assignment Action id          ',p_run_asg_action_id);
       pay_in_utils.trace('Archive Asg Action id         ',p_arc_asg_action_id);
       pay_in_utils.trace('GRE id                        ',p_gre_id);
       pay_in_utils.trace('Previous GRE Asg Action id    ',pre_gre_asg_act_id);
   END IF;


     archive_balances(p_run_asg_action_id   => p_run_asg_action_id
                     ,pre_gre_asg_act_id    => pre_gre_asg_act_id
                     ,p_arc_asg_action_id   => p_arc_asg_action_id
                     ,p_gre_id              => p_gre_id
                     ,p_action_inf_category => 'IN_EOY_ALLOW'
                     ,p_balance_name        => 'Allowance Amount'
                     ,p_balance_name1       => 'Allowances Standard Value'
                     ,p_balance_name2       => 'Taxable Allowances'
                     ,p_balance_name3       => 'Taxable Allowances for Projection'
                     ,p_balance_dimension   => '_ASG_COMP_YTD'
                     ,p_balance_dimension1  => '_ASG_COMP_PTD'
                     ,p_balance_dimension2  => '_ASG_COMP_YTD'
                     ,p_balance_dimension3  => '_ASG_COMP_PTD'
                     ,g_context_table       => g_context_table
                     ,g_result_table        => g_result_table
                     ,g_result_table1       => g_result_table1
                     ,g_result_table2       => g_result_table2
                     ,g_result_table3       => g_result_table3
                     ,g_balance_value_tab   => g_balance_value_tab
                     );
   pay_in_utils.set_location(g_debug,l_procedure, 20);

    OPEN  c_hra;
    FETCH c_hra INTO l_action_info_id,l_ovn;
    CLOSE c_hra;

    IF l_action_info_id IS NOT NULL
    THEN
       pay_in_utils.set_location(g_debug,l_procedure, 30);
        IF (pre_gre_asg_act_id IS NOT NULL)--Not the first record
        THEN
                IF p_flag -- Neither the first nor the last record. Hence diff of THRA _ASG_YTD at 2 diff act ids.
                THEN
                    l_defined_balance_id := pay_in_tax_utils.get_defined_balance('Taxable House Rent Allowance','_ASG_YTD');
                    l_value := pay_balance_pkg.get_value(p_defined_balance_id   =>         l_defined_balance_id
                                                        ,p_assignment_action_id =>         p_run_asg_action_id
                                                        );
                    l_value := l_value - pay_balance_pkg.get_value(p_defined_balance_id   => l_defined_balance_id
                                                                  ,p_assignment_action_id => pre_gre_asg_act_id
                                                                  );
                ELSE   -- Last Record. Hence diff of Projected and YTD value.
                    l_defined_balance_id :=
                    pay_in_tax_utils.get_defined_balance('Taxable House Rent Allowance for Projection','_ASG_LE_PTD');

                    l_value := pay_balance_pkg.get_value(p_defined_balance_id   =>         l_defined_balance_id
                                                        ,p_assignment_action_id =>         p_run_asg_action_id
                                                        );
                    l_defined_balance_id := pay_in_tax_utils.get_defined_balance('Taxable House Rent Allowance','_ASG_YTD');
                    l_value := l_value - pay_balance_pkg.get_value(p_defined_balance_id   => l_defined_balance_id
                                                                  ,p_assignment_action_id => pre_gre_asg_act_id
                                                                  );
               END IF;
      ELSIF p_flag  -- First Record in a multi tan scenario, hence take the THRA_ASG_YTD
      THEN
               pay_in_utils.set_location(g_debug,l_procedure, 40);
               l_defined_balance_id := pay_in_tax_utils.get_defined_balance('Taxable House Rent Allowance','_ASG_YTD');
               l_value := pay_balance_pkg.get_value(p_defined_balance_id   =>         l_defined_balance_id
                                                   ,p_assignment_action_id =>         p_run_asg_action_id
                                                   );
      ELSE          -- Only a single record exists, hence take the Projetced value
               pay_in_utils.set_location(g_debug,l_procedure, 50);
               l_defined_balance_id := pay_in_tax_utils.get_defined_balance('Taxable House Rent Allowance for Projection','_ASG_PTD');
               l_value := pay_balance_pkg.get_value(p_defined_balance_id   =>         l_defined_balance_id
                                                   ,p_assignment_action_id =>         p_run_asg_action_id
                                                   );
      END IF;

 IF g_debug THEN
       pay_in_utils.trace('Balance value         ',l_value);
   END IF;

        pay_action_information_api.update_action_information
        (
          p_action_information_id     =>  l_action_info_id
         ,p_object_version_number     =>  l_ovn
         ,p_action_information5       =>  l_value
         );
       pay_in_utils.set_location(g_debug,l_procedure, 60);
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 70);


   END archive_allowances;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PERQUISISTES                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the perquisite details      --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
   PROCEDURE archive_perquisites(p_run_asg_action_id      IN  NUMBER
                                 ,p_arc_asg_action_id     IN  NUMBER
                                 ,p_gre_id                IN  NUMBER
                                 ,pre_gre_asg_act_id      IN  NUMBER DEFAULT NULL
                                 )
   IS
     g_balance_value_tab   pay_balance_pkg.t_balance_value_tab;
     g_context_table       pay_balance_pkg.t_context_tab;
     g_result_table        pay_balance_pkg.t_detailed_bal_out_tab;
     l_action_info_id      NUMBER;
     l_ovn                 NUMBER;
     g_result_table1       pay_balance_pkg.t_detailed_bal_out_tab;
     g_result_table2       pay_balance_pkg.t_detailed_bal_out_tab;
     g_result_table3       pay_balance_pkg.t_detailed_bal_out_tab;
     l_message             VARCHAR2(255);
     l_procedure           VARCHAR2(100);

   BEGIN
    l_procedure := g_package ||'archive_perquisites';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace('Assignment Action id          ',p_run_asg_action_id);
       pay_in_utils.trace('Archive Asg Action id         ',p_arc_asg_action_id);
       pay_in_utils.trace('GRE id                        ',p_gre_id);
       pay_in_utils.trace('Previous GRE Asg Action id    ',pre_gre_asg_act_id);
    END IF;

     g_context_table.DELETE;
     g_result_table.DELETE;
     g_result_table1.DELETE;
     g_result_table2.DELETE;
     g_result_table3.DELETE;
     g_balance_value_tab.DELETE;


     g_context_table(1).source_text2  := 'Company Accommodation';
     g_context_table(2).source_text2  := 'Company Movable Assets';
     g_context_table(3).source_text2  := 'Domestic Servant';
     g_context_table(4).source_text2  := 'Free Education';
     g_context_table(5).source_text2  := 'Gas / Water / Electricity';
     g_context_table(6).source_text2  := 'Leave Travel Concession';
     g_context_table(7).source_text2  := 'Loan at Concessional Rate';
     g_context_table(8).source_text2  := 'Medical';
     g_context_table(9).source_text2  := 'Shares';
     g_context_table(10).source_text2 := 'Transfer of Company Assets';
     g_context_table(11).source_text2 := 'Employer Paid Tax';
     g_context_table(12).source_text2 := 'Gift Voucher';
     g_context_table(13).source_text2 := 'Travel / Tour / Accommodation';
     g_context_table(14).source_text2 := 'Free Transport';
     g_context_table(15).source_text2 := 'Credit Cards';
     g_context_table(16).source_text2 := 'Club Expenditure';
     g_context_table(17).source_text2 := 'Motor Car Perquisite';
     g_context_table(18).source_text2 := 'Lunch Perquisite';

   pay_in_utils.set_location(g_debug,l_procedure, 20);

     archive_balances(p_run_asg_action_id   => p_run_asg_action_id
                     ,pre_gre_asg_act_id    => pre_gre_asg_act_id
                     ,p_arc_asg_action_id   => p_arc_asg_action_id
                     ,p_gre_id              => p_gre_id
                     ,p_action_inf_category => 'IN_EOY_PERQ'
                     ,p_balance_name        => 'Taxable Perquisites'
                     ,p_balance_name1       => 'Perquisite Employee Contribution'
                     ,p_balance_dimension   => '_ASG_COMP_YTD'
                     ,p_balance_dimension1  => '_ASG_COMP_YTD'
                     ,g_context_table       => g_context_table
                     ,g_result_table        => g_result_table
                     ,g_result_table1       => g_result_table1
                     ,g_result_table2       => g_result_table2
                     ,g_result_table3       => g_result_table3
                     ,g_balance_value_tab   => g_balance_value_tab
                     );
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

   END archive_perquisites;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_EOY_SALARY                                  --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the various salary components-
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
   PROCEDURE archive_eoy_salary(p_run_asg_action_id     IN  NUMBER
                               ,p_arc_asg_action_id     IN  NUMBER
                               ,p_gre_id                IN  NUMBER)
   IS
   CURSOR c_defined_balance_id
   IS
   SELECT pdb.defined_balance_id balance_id
         ,pbt.balance_name       balance_name
   FROM   pay_balance_types pbt
         ,pay_balance_dimensions pbd
         ,pay_defined_balances pdb
   WHERE  pbt.balance_name IN('Long Term Capital Gains'
                             ,'Short Term Capital Gains'
                             ,'Capital Gains'
                             ,'Loss From House Property'
                             ,'Business and Profession Gains'
                             ,'Other Sources of Income'
                             )
   AND pbd.dimension_name='_ASG_PTD'
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

   CURSOR c_f16_sal_balances
   IS
   SELECT pdb.defined_balance_id balance_id
         ,pbt.balance_name       balance_name
   FROM   pay_balance_types pbt
         ,pay_balance_dimensions pbd
         ,pay_defined_balances pdb
   WHERE((pbt.balance_name IN('F16 Education Cess till Date'
			     ,'F16 Sec and HE Cess till Date'
                             ,'F16 Surcharge till Date'
                             ,'F16 Income Tax till Date'
                             ,'F16 Education Cess'
                             ,'F16 Sec and HE Cess'
                             ,'F16 Employment Tax'
                             ,'F16 Entertainment Allowance'
                             ,'F16 Marginal Relief'
                             ,'F16 Profit in lieu of Salary'
                             ,'F16 Relief under Sec 89'
                             ,'F16 Salary Under Section 17'
                             ,'F16 Surcharge'
                             ,'F16 Tax on Total Income'
                             ,'F16 Value of Perquisites'
                             ,'F16 Gross Salary'
                             ,'F16 Gross Salary less Allowances'
                             ,'F16 Income Chargeable Under head Salaries'
                             ,'F16 Gross Total Income'
                             ,'F16 Total Income'
                             ,'F16 Total Tax payable'
                             ,'F16 Balance Tax'
                             ,'F16 Tax Refundable'
                             ,'F16 Allowances Exempt'
                             ,'F16 Other Income'
                             ,'F16 Deductions under Sec 16'
                             )
   AND pbd.dimension_name   = '_ASG_LE_PTD')
       OR (pbt.balance_name  = 'ER Paid Tax on Non Monetary Perquisite'
       AND pbd.dimension_name = '_ASG_LE_YTD'))
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

   CURSOR c_defined_bal_id
   IS
   SELECT pdb.defined_balance_id balance_id
         ,pbt.balance_name       balance_name
   FROM   pay_balance_types pbt
         ,pay_balance_dimensions pbd
         ,pay_defined_balances pdb
   WHERE  pbt.balance_name IN(
                             'Excess Interest Amount'
                            ,'Excess PF Amount'
                            ,'TDS on Previous Employment'
                            ,'CESS on Previous Employment'
                            ,'Sec and HE Cess on Previous Employment'
                            ,'SC on Previous Employment'
                            ,'Previous Employment Earnings'
                             )
   AND pbd.dimension_name='_ASG_YTD'
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

   g_balance_value_tab  pay_balance_pkg.t_balance_value_tab;
   g_balance_value_tab1 pay_balance_pkg.t_balance_value_tab;
   g_result_table       pay_balance_pkg.t_detailed_bal_out_tab;

   i NUMBER;
   j NUMBER;
   g_bal_name_tab        t_bal_name_tab;
   g_bal_name_tab1       t_bal_name_tab;
   g_context_table              pay_balance_pkg.t_context_tab;
   l_action_info_id      NUMBER;
   l_ovn                 NUMBER;
   l_in_tax_ded          NUMBER;
   l_message   VARCHAR2(255);
   l_procedure VARCHAR2(100);
   l_total_cess NUMBER ;
   l_total_cess_till_date NUMBER ;
   l_cess_action_info_id                NUMBER;
   l_cess_ov_id                         NUMBER;
   l_cess_td_action_info_id             NUMBER;
   l_cess_td_ov_id                      NUMBER;

BEGIN
  l_procedure := g_package ||'archive_eoy_salary';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('Assignment Action id          ',p_run_asg_action_id);
       pay_in_utils.trace('Archive Asg Action id         ',p_arc_asg_action_id);
       pay_in_utils.trace('GRE id                        ',p_gre_id);
   END IF;

  i := 1;
  g_bal_name_tab.DELETE;
  l_in_tax_ded := 0;
  l_total_cess:=0;
  l_total_cess_till_date:=0;

  FOR c_rec IN c_defined_balance_id
  LOOP
      g_balance_value_tab(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab(i).balance_name            := c_rec.balance_name;
      i := i + 1;
  END LOOP;

  pay_balance_pkg.get_value(p_run_asg_action_id,g_balance_value_tab);

   pay_in_utils.set_location(g_debug,l_procedure, 20);



 pay_in_utils.trace('**************************************************','********************');
  FOR i IN 1..g_balance_value_tab.COUNT
  LOOP
      IF (g_balance_value_tab(i).balance_value <> 0)
      THEN
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_ASG_SAL'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     g_bal_name_tab(i).balance_name
             ,p_action_information2            =>     g_balance_value_tab(i).balance_value
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );

        IF g_debug THEN
           pay_in_utils.trace('SALARY Balance Name         ',g_bal_name_tab(i).balance_name);
           pay_in_utils.trace('SALARY Balance Value        ',g_balance_value_tab(i).balance_value);
        END IF;

     END IF;
  END LOOP;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

--Archiving balances having YTD Dimensions
  i := 1;
  FOR c_rec IN c_defined_bal_id
  LOOP
      g_balance_value_tab1(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab1(i).balance_name            := c_rec.balance_name;
       i := i + 1;
  END LOOP;

  pay_balance_pkg.get_value(p_run_asg_action_id,g_balance_value_tab1);

   pay_in_utils.set_location(g_debug,l_procedure, 30);

  FOR i IN 1..g_balance_value_tab1.COUNT
  LOOP



      IF (g_balance_value_tab1(i).balance_value <> 0)
      THEN
        pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_EOY_ASG_SAL'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     g_bal_name_tab1(i).balance_name
             ,p_action_information2            =>     g_balance_value_tab1(i).balance_value
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
        IF g_debug THEN
           pay_in_utils.trace('SALARY Balance Name         ',g_bal_name_tab1(i).balance_name);
           pay_in_utils.trace('SALARY Balance Value         ',g_balance_value_tab1(i).balance_value);
        END IF;

      END IF;
  END LOOP;


   pay_in_utils.set_location(g_debug,l_procedure, 40);
  --Archiving balances having LE_PTD Dimensions
      i := 1;
       g_bal_name_tab1.DELETE;
       g_balance_value_tab1.DELETE;
       g_context_table(1).tax_unit_id := p_gre_id;



       FOR c_rec IN c_f16_sal_balances
       LOOP
           g_balance_value_tab1(i).defined_balance_id := c_rec.balance_id;
           g_bal_name_tab1(i).balance_name            := c_rec.balance_name;
           i := i + 1;

       END LOOP;

       pay_in_utils.set_location(g_debug,l_procedure, 50);

              pay_balance_pkg.get_value(p_assignment_action_id  =>     p_run_asg_action_id
                                       ,p_defined_balance_lst   =>     g_balance_value_tab1
                                       ,p_context_lst           =>     g_context_table
                                       ,p_output_table          =>     g_result_table
                                       );


             FOR i IN 1..g_bal_name_tab1.COUNT
              LOOP
                 IF (g_bal_name_tab1(i).balance_name = 'F16 Education Cess till Date'		OR
                     g_bal_name_tab1(i).balance_name = 'F16 Sec and HE Cess till Date'		OR
                     g_bal_name_tab1(i).balance_name = 'F16 Surcharge till Date'		OR
                     g_bal_name_tab1(i).balance_name = 'F16 Income Tax till Date' )		THEN
                        l_in_tax_ded := l_in_tax_ded + g_result_table(i).balance_value;
                 END IF;
		 IF (g_bal_name_tab1(i).balance_name = 'F16 Education Cess till Date'		OR
                     g_bal_name_tab1(i).balance_name = 'F16 Sec and HE Cess till Date' )        THEN
		        l_total_cess_till_date:=l_total_cess_till_date + g_result_table(i).balance_value;
                 END IF ;
		 IF (g_bal_name_tab1(i).balance_name = 'F16 Education Cess'		OR
                     g_bal_name_tab1(i).balance_name = 'F16 Sec and HE Cess' )        THEN
		      l_total_cess := l_total_cess + g_result_table(i).balance_value;
                 END IF ;

              END LOOP;
             pay_in_utils.set_location(g_debug,l_procedure, 60);

             g_bal_name_tab1(g_result_table.COUNT + 1).balance_name := 'Income Tax Deduction';
             g_result_table(g_result_table.COUNT + 1).balance_value := l_in_tax_ded;

               FOR i IN 1..g_bal_name_tab1.COUNT
               LOOP

                  IF g_result_table(i).balance_value <> 0
                  THEN
                    pay_action_information_api.create_action_information
                         (p_action_context_id              =>     p_arc_asg_action_id
                         ,p_action_context_type            =>     'AAP'
                         ,p_action_information_category    =>     'IN_EOY_ASG_SAL'
                         ,p_source_id                      =>     p_run_asg_action_id
                         ,p_action_information1            =>     g_bal_name_tab1(i).balance_name
                         ,p_action_information2            =>     g_result_table(i).balance_value
                         ,p_action_information_id          =>     l_action_info_id
                         ,p_object_version_number          =>     l_ovn
                         );
                   IF g_bal_name_tab1(i).balance_name='F16 Education Cess' THEN
                      l_cess_action_info_id:=l_action_info_id;
                      l_cess_ov_id:=l_ovn;
                   END IF ;
                   IF g_bal_name_tab1(i).balance_name='F16 Education Cess till Date' THEN
                      l_cess_td_action_info_id:=l_action_info_id;
                      l_cess_td_ov_id:=l_ovn;
                   END IF ;

                        IF g_debug THEN
                           pay_in_utils.trace('SALARY Balance Name         ',g_bal_name_tab1(i).balance_name);
                           pay_in_utils.trace('SALARY Balance Value        ',g_result_table(i).balance_value);
                        END IF;

                  END IF;
               END LOOP;
                      IF l_total_cess <> 0 THEN
                         pay_action_information_api.update_action_information
                         (p_action_information_id          =>     l_cess_action_info_id
                         ,p_object_version_number          =>     l_cess_ov_id
                         ,p_action_information1            =>     'F16 Education Cess'
                         ,p_action_information2            =>     l_total_cess
                         );
                      END IF ;
                      IF l_total_cess_till_date <> 0 THEN
                         pay_action_information_api.update_action_information
                         (p_action_information_id          =>     l_cess_td_action_info_id
                         ,p_object_version_number          =>     l_cess_td_ov_id
                         ,p_action_information1            =>     'F16 Education Cess till Date'
                         ,p_action_information2            =>     l_total_cess_till_date
                         );
                      END IF ;
                         l_cess_action_info_id:=0;
                         l_cess_ov_id:=0;
                         l_cess_td_action_info_id:=0;
                         l_cess_td_ov_id:=0;
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 70);


END archive_eoy_salary;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_OTHER_BALANCES                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This is called to archive the fields that were not  --
  --                  covered under IN_EOY_ALLOW and IN_EOY_PERQ          --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
   PROCEDURE archive_other_balances(p_run_asg_action_id     IN  NUMBER
                                   ,p_arc_asg_action_id     IN  NUMBER
                                   ,pre_gre_asg_act_id      IN  NUMBER DEFAULT NULL
                                   ,p_gre_id                IN  NUMBER
                                   ,p_start_date            IN  DATE
                                   ,p_end_date              IN  DATE
                                   )
   IS

   CURSOR c_defined_bal_id
   IS
   SELECT pdb.defined_balance_id balance_id
         ,pbt.balance_name       balance_name
   FROM   pay_balance_types pbt
         ,pay_balance_dimensions pbd
         ,pay_defined_balances pdb
   WHERE  pbt.balance_name IN('Taxable Allowances'
                             ,'Taxable Perquisites'
                             ,'Monthly Furniture Cost'
                             ,'Furniture Perquisite'
                             ,'Cost and Rent of Furniture'
                             ,'Perquisite Employee Contribution'
                             ,'ER Paid Tax on Monetary Perquisite'
                             )
   AND pbd.dimension_name='_ASG_YTD'
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.balance_dimension_id  = pdb.balance_dimension_id;




   g_balance_value_tab          pay_balance_pkg.t_balance_value_tab;
   l_balance_value_tab1         pay_balance_pkg.t_balance_value_tab;
   l_balance_value_tab2         pay_balance_pkg.t_balance_value_tab;
   g_context_table              pay_balance_pkg.t_context_tab;
   g_result_table               pay_balance_pkg.t_detailed_bal_out_tab;
   g_bal_name_tab               t_bal_name_tab;
   i                            NUMBER;
   l_context                    VARCHAR2(50);
   l_defined_balance_id         NUMBER;
   l_value                      NUMBER;
   l_action_info_id             NUMBER;
   l_ovn                        NUMBER;
   l_tax_on_direct_pymt         NUMBER :=0;
   l_message                    VARCHAR2(255);
   l_procedure                  VARCHAR2(100);

   BEGIN

     l_procedure := g_package ||'archive_other_balances';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Assignment Action id          ',p_run_asg_action_id);
       pay_in_utils.trace('Archive Asg Action id         ',p_arc_asg_action_id);
       pay_in_utils.trace('GRE id                        ',p_gre_id);
       pay_in_utils.trace('Previous GRE Asg Action id    ',pre_gre_asg_act_id);
       pay_in_utils.trace('Start Date                    ',p_start_date);
       pay_in_utils.trace('End Date                      ',p_end_date);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

--Archiving the various Perquisite and Allowance records

       i := 1;
       g_context_table.DELETE;
       g_bal_name_tab.DELETE;
       g_balance_value_tab.DELETE;

       FOR c_rec IN c_defined_bal_id
       LOOP
           g_balance_value_tab(i).defined_balance_id := c_rec.balance_id;
           g_bal_name_tab(i).balance_name            := c_rec.balance_name;
           i := i + 1;
       END LOOP;

       pay_in_utils.set_location(g_debug,l_procedure, 20);

       l_balance_value_tab1 := g_balance_value_tab;
       l_balance_value_tab2 := g_balance_value_tab;

       pay_balance_pkg.get_value(p_run_asg_action_id,l_balance_value_tab1);

       IF pre_gre_asg_act_id IS NOT NULL
       THEN
               pay_balance_pkg.get_value(pre_gre_asg_act_id,l_balance_value_tab2);
       END IF;

       pay_in_utils.set_location(g_debug,l_procedure, 30);
       FOR i IN 1..g_balance_value_tab.COUNT
       LOOP

           IF (g_bal_name_tab(i).balance_name <> 'Monthly Furniture Cost')
           THEN
              g_balance_value_tab(i).balance_value := NVL(l_balance_value_tab1(i).balance_value,0)
                                                    - NVL(l_balance_value_tab2(i).balance_value,0);
           ELSE
              g_balance_value_tab(i).balance_value := NVL(l_balance_value_tab1(i).balance_value,0);
           END IF;

           IF (g_balance_value_tab(i).balance_value <> 0)
           THEN
               IF (g_bal_name_tab(i).balance_name = 'Taxable Allowances')
               THEN
                  l_context := 'IN_EOY_ALLOW';
               ELSE
                  l_context := 'IN_EOY_PERQ';
               END IF;
               pay_in_utils.set_location(g_debug,l_procedure, 40);

             pay_action_information_api.create_action_information
                  (p_action_context_id              =>     p_arc_asg_action_id
                  ,p_action_context_type            =>     'AAP'
                  ,p_action_information_category    =>     l_context
                  ,p_source_id                      =>     p_run_asg_action_id
                  ,p_action_information1            =>     g_bal_name_tab(i).balance_name
                  ,p_action_information2            =>     g_balance_value_tab(i).balance_value
                  ,p_action_information_id          =>     l_action_info_id
                  ,p_object_version_number          =>     l_ovn
                  );

                IF g_debug THEN
                   pay_in_utils.trace('**************************************************','********************');
                   pay_in_utils.trace('OTHER Balance Name        ', g_bal_name_tab(i).balance_name);
                   pay_in_utils.trace('OTHER Balance Value        ',g_balance_value_tab(i).balance_value);
                   pay_in_utils.trace('**************************************************','********************');
                END IF;

          END IF;
       END LOOP;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);


  END archive_other_balances;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ORG_DATA                                    --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to archive the Organizational details at  --
  --                  Payroll level                                       --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_end_date   DATE                         --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  -- 115.1 25-SEP-2007    rsaharay   Modified c_pos,c_rep_address         --
  --------------------------------------------------------------------------
   PROCEDURE archive_org_data(p_arc_pay_action_id     IN  NUMBER
                             ,p_gre_id                IN  NUMBER
                             ,p_effective_end_date    IN  DATE
                             )
   IS

   CURSOR c_org_inc_tax_df_details
   IS
   SELECT  hoi.org_information1        tan
          ,hoi.org_information2        ward
          ,hoi.org_information4        reg_org_id
          ,hoi.org_information5        tan_ack_no
          ,hou.name                    org_name
          ,hou.location_id             location_id
   FROM    hr_organization_information hoi
          ,hr_organization_units       hou
   WHERE hoi.organization_id = p_gre_id
   AND hoi.org_information_context = 'PER_IN_INCOME_TAX_DF'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND p_effective_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

   CURSOR c_reg_org_details(p_reg_org_id        NUMBER)
   IS
   SELECT hoi.org_information3        pan
         ,hoi.org_information4        legal_name
   FROM  hr_organization_information  hoi
        ,hr_organization_units        hou
   WHERE hoi.organization_id = p_reg_org_id
   AND   hoi.org_information_context = 'PER_IN_COMPANY_DF'
   AND   hou.organization_id = hoi.organization_id
   AND   hou.business_group_id = g_bg_id
   AND   p_effective_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR c_pos(p_person_id                  NUMBER)
  IS
  SELECT nvl(pos.name,job.name) name
  FROM   per_all_positions pos
        ,per_assignments_f asg
        ,per_jobs          job
  WHERE  asg.position_id=pos.position_id(+)
  AND    asg.job_id=job.job_id(+)
  AND    asg.person_id = p_person_id
  AND    asg.primary_flag = 'Y'
  AND    asg.business_group_id = g_bg_id
  AND    p_effective_end_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_end_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


  CURSOR c_father_name(p_person_id          NUMBER)
  IS
  SELECT DECODE(pea.title,NULL,hr_in_utility.per_in_full_name(pea.first_name,pea.middle_names,pea.last_name,pea.title)
        ,SUBSTR(hr_in_utility.per_in_full_name(pea.first_name,pea.middle_names,pea.last_name,pea.title)
        ,INSTR(hr_in_utility.per_in_full_name(pea.first_name,pea.middle_names,pea.last_name,pea.title),' ',1)+1)) father
        ,pea.title       title
  FROM   per_all_people_f pep
        ,per_all_people_f pea
        ,per_contact_relationships con
  WHERE  pep.person_id = p_person_id
  AND    pea.person_id =con.contact_person_id
  AND    pep.business_group_id = g_bg_id
  AND    pea.business_group_id = g_bg_id
  AND    con.person_id=pep.person_id
  AND    con.contact_type='JP_FT'
  AND    p_effective_end_date BETWEEN pep.effective_start_date AND pep.effective_end_date
  AND    p_effective_end_date BETWEEN pea.effective_start_date AND pea.effective_end_date;

  CURSOR c_representative_id
  IS
  SELECT hoi.org_information1                               person_id
        ,DECODE(pep.title,NULL,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title)
        ,SUBSTR(hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title)
        ,INSTR(hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title),' ',1)+1)) rep_name
        ,pep.title                                          title
  FROM   hr_organization_information   hoi
        ,hr_organization_units         hou
        ,per_all_people_f              pep
  WHERE  hoi.org_information_context = 'PER_IN_INCOME_TAX_REP_DF'
  AND    hoi.organization_id = p_gre_id
  AND    hou.organization_id = hoi.organization_id
  AND    hou.business_group_id = g_bg_id
  AND    pep.person_id = hoi.org_information1
  AND    pep.business_group_id = hou.business_group_id
  AND    p_effective_end_date BETWEEN pep.effective_start_date AND pep.effective_end_date
  AND    p_effective_end_date BETWEEN fnd_date.canonical_to_date(hoi.org_information2)
  AND    NVL(fnd_date.canonical_to_date(hoi.org_information3),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR c_rep_address(p_person_id         NUMBER)
  IS
  SELECT hou.location_id rep_location
  FROM   per_all_assignments_f   asg
        ,hr_organization_units hou
  WHERE asg.person_id = p_person_id
  AND   asg.primary_flag = 'Y'
  AND   asg.business_group_id = g_bg_id
  AND   hou.organization_id = asg.organization_id
  AND   hou.business_group_id = asg.business_group_id
  AND   p_effective_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date
  AND   p_effective_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR c_rep_phone(p_person_id         NUMBER)
  IS
  SELECT phone_number rep_phone_no
        ,phone_type
  FROM   per_phones
  WHERE  parent_id = p_person_id
  AND    phone_type =  DECODE(phone_type,'H1','H1','M')
  AND    p_effective_end_date BETWEEN date_from AND NVL(date_to,TO_DATE('31-12-4712','DD-MM-YYYY'))
  ORDER BY phone_type ASC;

  CURSOR c_rep_work_fax(p_person_id         NUMBER)
  IS
  SELECT phone_number work_fax
  FROM   per_phones
  WHERE  parent_id = p_person_id
  AND    phone_type =  'WF'
  AND    p_effective_end_date BETWEEN date_from AND NVL(date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  l_tan                 hr_organization_information.org_information1%TYPE;
  l_ward                hr_organization_information.org_information2%TYPE;
  l_reg_org_id          hr_organization_information.org_information4%TYPE;
  l_tan_ack_no          hr_organization_information.org_information5%TYPE;
  l_org_name            hr_organization_units.name%TYPE;
  l_location_id         hr_organization_units.location_id%TYPE;
  l_pan                 hr_organization_information.org_information3%TYPE;
  l_legal_name          hr_organization_information.org_information4%TYPE;
  l_rep_person_id       per_all_people_f.person_id%TYPE;
  l_rep_name            per_all_people_f.full_name%TYPE;
  l_position            per_all_positions.name%TYPE;
  l_rep_father          per_all_people_f.full_name%TYPE;
  l_rep_location        hr_organization_units.location_id%TYPE;
  l_rep_phone_no        per_phones.phone_number%TYPE;
  l_phone_type          per_phones.phone_type%TYPE;
  l_rep_father_title    per_all_people_f.title%TYPE;
  l_rep_title           per_all_people_f.title%TYPE;
  l_rep_work_fax        per_phones.phone_number%TYPE;
  l_action_info_id      NUMBER;
  l_ovn                 NUMBER;
  l_message             VARCHAR2(255);
  l_procedure           VARCHAR2(100);



  BEGIN
    l_procedure := g_package ||'archive_org_data';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('Payroll Action id  ',p_arc_pay_action_id);
       pay_in_utils.trace('GRE id             ',p_gre_id);
       pay_in_utils.trace('End Date           ',p_effective_end_date);
   END IF;


   OPEN  c_org_inc_tax_df_details;
   FETCH c_org_inc_tax_df_details INTO l_tan,l_ward,l_reg_org_id,l_tan_ack_no,l_org_name,l_location_id;
   CLOSE c_org_inc_tax_df_details;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

   OPEN  c_reg_org_details(l_reg_org_id);
   FETCH c_reg_org_details INTO l_pan,l_legal_name;
   CLOSE c_reg_org_details;

   pay_in_utils.set_location(g_debug,l_procedure, 30);
   OPEN  c_representative_id;
   FETCH c_representative_id INTO l_rep_person_id,l_rep_name,l_rep_title;
   CLOSE c_representative_id;

   pay_in_utils.set_location(g_debug,l_procedure, 40);
   OPEN  c_pos(l_rep_person_id);
   FETCH c_pos INTO l_position;
   CLOSE c_pos;

   pay_in_utils.set_location(g_debug,l_procedure, 50);
   OPEN  c_father_name(l_rep_person_id);
   FETCH c_father_name INTO l_rep_father,l_rep_father_title;
   CLOSE c_father_name;

   pay_in_utils.set_location(g_debug,l_procedure, 60);
   OPEN  c_rep_address(l_rep_person_id);
   FETCH c_rep_address INTO l_rep_location;
   CLOSE c_rep_address;

   pay_in_utils.set_location(g_debug,l_procedure, 70);
   OPEN  c_rep_phone(l_rep_person_id);
   FETCH c_rep_phone INTO l_rep_phone_no,l_phone_type;
   CLOSE c_rep_phone;

   pay_in_utils.set_location(g_debug,l_procedure, 80);
   OPEN  c_rep_work_fax(l_rep_person_id);
   FETCH c_rep_work_fax INTO l_rep_work_fax;
   CLOSE c_rep_work_fax;

   pay_in_utils.set_location(g_debug,l_procedure, 90);
   pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_pay_action_id
             ,p_action_context_type            =>     'PA'
             ,p_action_information_category    =>     'IN_EOY_ORG'
             ,p_action_information1            =>     p_gre_id
             ,p_action_information2            =>     l_pan
             ,p_action_information3            =>     g_year
             ,p_action_information4            =>     l_tan
             ,p_action_information5            =>     l_tan_ack_no
             ,p_action_information6            =>     l_org_name
             ,p_action_information7            =>     l_location_id
             ,p_action_information8            =>     l_legal_name
             ,p_action_information9            =>     l_ward
             ,p_action_information10           =>     l_rep_person_id
             ,p_action_information11           =>     l_rep_name
             ,p_action_information12           =>     l_rep_title
             ,p_action_information13           =>     l_position
             ,p_action_information14           =>     l_rep_father
             ,p_action_information15           =>     l_rep_father_title
             ,p_action_information16           =>     l_rep_location
             ,p_action_information17           =>     l_rep_phone_no
             ,p_action_information18           =>     l_rep_work_fax
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 100);


  END archive_org_data;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CODE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to call the internal procedures to        --
  --                  actually archive the data.                          --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id       NUMBER                 --
  --                  p_effective_date             DATE                   --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 23-MAY-2005    aaagarwa   Initial Version                      --
  -- 115.1 05-APR-2006    rpalli     Bug#5135223:Modified a parameter     --
  --                                 l_run_date_earned passed through     --
  --                                 archive_person_data and              --
  --                                 archive_via_details                  --
  --
   PROCEDURE archive_code (
                           p_assignment_action_id  IN NUMBER
                          ,p_effective_date        IN DATE
                         )
  IS
--This cursor determines the GRE/Legal Entity record

   CURSOR get_assignment_pact_id
   IS
   SELECT paa.assignment_id
         ,paa.payroll_action_id
     FROM pay_assignment_actions  paa
         ,per_all_assignments_f paf
    WHERE paa.assignment_action_id = p_assignment_action_id
      AND paa.assignment_id = paf.assignment_id
      AND ROWNUM =1;

   CURSOR c_gre_records
   IS
   SELECT  GREATEST(asg.effective_start_date,g_start_date) start_date
          ,LEAST(asg.effective_end_date,g_end_date)        end_date
          ,scl.segment1
   FROM   per_all_assignments_f  asg
         ,hr_soft_coding_keyflex scl
         ,pay_assignment_actions paa
   WHERE  asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    paa.assignment_action_id = p_assignment_action_id
   AND    asg.assignment_id = paa.assignment_id
   AND    scl.segment1 LIKE TO_CHAR(g_gre_id)
   AND  ( asg.effective_start_date BETWEEN g_start_date  AND g_end_date
      OR  g_start_date BETWEEN asg.effective_start_date  AND g_end_date
        )
   AND    GREATEST(asg.effective_start_date,g_start_date) <= LEAST(asg.effective_end_date,g_end_date)
   ORDER BY 1 asc;

   CURSOR get_eoy_archival_details(p_start_date        DATE
                                   ,p_end_date         DATE
                                   ,p_tax_unit_id      NUMBER
                                   ,p_assignment_id    NUMBER
                                   )
    IS
    SELECT TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) run_asg_action_id
      FROM pay_assignment_actions paa
          ,pay_payroll_actions ppa
          ,per_assignments_f paf
     WHERE paf.assignment_id = paa.assignment_id
       AND paf.assignment_id = p_assignment_id
       AND paa.tax_unit_id  = p_tax_unit_id
       AND paa.payroll_action_id = ppa.payroll_action_id
       AND ppa.action_type IN('R','Q','I','B')
       AND ppa.action_status ='C'
       AND ppa.effective_date between p_start_date and p_end_date
       AND paa.source_action_id IS NULL
       AND ppa.payroll_id    = paf.payroll_id
       AND (1 = DECODE(ppa.action_type,'I',1,0)
            OR EXISTS (SELECT ''
                     FROM pay_action_interlocks intk,
                          pay_assignment_actions paa1,
                          pay_payroll_actions ppa1
                    WHERE intk.locked_action_id = paa.assignment_Action_id
                      AND intk.locking_action_id =  paa1.assignment_action_id
                      AND paa1.payroll_action_id =ppa1.payroll_action_id
                      AND paa1.assignment_id = p_assignment_id
                      AND ppa1.action_type in('P','U')
                      AND ppa.action_type in('R','Q','B')
                      AND ppa1.action_status ='C'
                      AND ppa1.effective_date BETWEEN p_start_date and p_end_date
                      AND ROWNUM =1 ));

    CURSOR c_get_date_earned(l_run_assact NUMBER)
    IS
    SELECT ppa.date_earned run_date
      FROM pay_payroll_actions ppa,
           pay_assignment_actions paa
     WHERE paa.payroll_action_id = ppa.payroll_action_id
       AND paa.assignment_action_id = l_run_assact;

  CURSOR get_prepayment_date(l_run_assact NUMBER)
  IS
  SELECT ppa.effective_date
    FROM pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_action_interlocks intk
   WHERE intk.locked_action_id = l_run_assact
     AND intk.locking_action_id =paa.assignment_action_id
     AND ppa.payroll_action_id = paa.payroll_action_id
     AND ppa.action_type IN('P','U');

   CURSOR c_pay_action_level_check(p_payroll_action_id    NUMBER
                                  ,p_gre_id               NUMBER)
   IS
        SELECT 1
        FROM   pay_action_information
        WHERE  action_information_category = 'IN_EOY_ORG'
        AND    action_context_type         = 'PA'
        AND    action_context_id           = p_payroll_action_id
        AND    action_information1         = p_gre_id;

  --This cursor determines termination date of an assignment.
      CURSOR c_termination_check(p_assignment_id NUMBER)
      IS
        SELECT NVL(pos.actual_termination_date,(fnd_date.string_to_date('31-12-4712','DD-MM-YYYY')))
        FROM   per_all_assignments_f  asg
              ,per_periods_of_service pos
        WHERE asg.person_id         = pos.person_id
        AND   asg.assignment_id     = p_assignment_id
        AND   asg.business_group_id = pos.business_group_id
        AND   asg.business_group_id = g_bg_id
        AND   NVL(pos.actual_termination_date,(to_date('31-12-4712','DD-MM-YYYY')))
        BETWEEN asg.effective_start_date AND asg.effective_end_date
        ORDER BY 1 desc;

    l_procedure                       VARCHAR2(100);

    l_assignment_id                   NUMBER;
    l_run_asg_action_id               NUMBER;
    l_run_date_earned                 DATE;
    l_pre_effective_date              DATE;
    l_arc_pay_action_id               NUMBER;
    l_check                           NUMBER;
    l_end_date                        DATE;
    l_previous_gre_asg_action_id      NUMBER;
    l_end                             NUMBER;
    l_start                           NUMBER;
    l_flag                            BOOLEAN;
    l_record_count                    NUMBER;
    l_message                         VARCHAR2(255);

  BEGIN
  --

    g_debug := hr_utility.debug_enabled;
    l_procedure := g_package || 'archive_code';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
--
       g_count := 1;
       g_asg_tab.DELETE;



    OPEN  get_assignment_pact_id;
    FETCH get_assignment_pact_id INTO l_assignment_id ,l_arc_pay_action_id;
    CLOSE get_assignment_pact_id;
   pay_in_utils.set_location(g_debug,l_procedure, 20);
--
    FOR c_rec IN c_gre_records
    LOOP

           g_asg_tab(g_count).gre_id       := c_rec.segment1;
           g_asg_tab(g_count).start_date   := c_rec.start_date;
           g_asg_tab(g_count).end_date     := c_rec.end_date;

           IF(
              (g_count <>1)
                AND
              (g_asg_tab(g_count-1).gre_id = g_asg_tab(g_count).gre_id)
                 AND
              (g_asg_tab(g_count-1).end_date + 1 = c_rec.start_date)  -- Added for 4964645
             )
           THEN
                g_asg_tab(g_count-1).end_date   := g_asg_tab(g_count).end_date;
                g_asg_tab(g_count).gre_id       := NULL;
                g_asg_tab(g_count).start_date   := NULL;
                g_asg_tab(g_count).end_date     := NULL;

                g_count := g_count -1;
           END IF;

           IF g_debug THEN
               pay_in_utils.trace('GRE Count No ',g_count);
               pay_in_utils.trace('GRE id       ',g_asg_tab(g_count).gre_id);
               pay_in_utils.trace('Start Date   ',g_asg_tab(g_count).start_date);
               pay_in_utils.trace('End Date     ',g_asg_tab(g_count).end_date );
          END IF;

           g_count := g_count + 1;
    END LOOP;
    l_record_count := g_count-1;

   pay_in_utils.set_location(g_debug,l_procedure, 30);

    IF (g_employee_type = 'ALL')
    THEN
       l_end   := g_count-1;
       l_start := 1;
    ELSIF (g_employee_type = 'CURRENT')
    THEN
       IF (g_asg_tab(g_count-1).end_date = g_end_date)
       THEN
           l_end   := g_count-1;
           l_start := g_count-1;
       ELSE
           l_end   := 0;
           l_start := 1;
       END IF;
    ELSE
       IF (g_asg_tab(g_count-1).end_date = g_end_date)
       THEN
           IF (g_count - 1)>1
           THEN
                l_end   := g_count-2;
                l_start := 1;
           ELSE
                l_end   := 1;
                l_start := 1;
           END IF;
       ELSE
               l_end   := g_count-1;
               l_start := 1;
       END IF;
    END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 50);

   IF g_debug THEN
       pay_in_utils.trace('Start record    ',l_start);
       pay_in_utils.trace('End Record      ',l_end);
   END IF;

    FOR i IN l_start..l_end
    LOOP

         OPEN  get_eoy_archival_details(g_asg_tab(i).start_date
                                       ,g_asg_tab(i).end_date
                                       ,g_asg_tab(i).gre_id
                                       ,l_assignment_id
                                       );
         FETCH get_eoy_archival_details INTO l_run_asg_action_id;
         CLOSE get_eoy_archival_details;

   pay_in_utils.set_location(g_debug,l_procedure, 60);

         IF l_run_asg_action_id IS NOT NULL THEN
            pay_in_utils.set_location(g_debug,l_procedure, 70);
           OPEN c_get_date_earned(l_run_asg_action_id);
           FETCH c_get_date_earned INTO l_run_date_earned;
           CLOSE c_get_date_earned;

          OPEN get_prepayment_date(l_run_asg_action_id);
          FETCH get_prepayment_date INTO l_pre_effective_date;
          CLOSE get_prepayment_date;



   pay_in_utils.set_location(g_debug,l_procedure, 80);

     l_previous_gre_asg_action_id := NULL;
     IF (i > 1 AND i <> l_record_count)-- Neither the first nor the last record. Hence determine the diff
     THEN                               -- Taxable House Rent Allowance_ASG_YTD as on previous and current GRE.
        FOR c_rec IN get_eoy_archival_details(g_asg_tab(i-1).start_date,g_asg_tab(i-1).end_date,g_asg_tab(i-1).gre_id,l_assignment_id)
        LOOP
          l_previous_gre_asg_action_id := c_rec.run_asg_action_id;
          EXIT;
         END LOOP;

        l_flag := TRUE;
     ELSIF (i = 1 AND l_record_count > 1)-- This is the first record in a multi tan scenario, hence
     THEN                                 -- take the Taxable House Rent Allowance_ASG_YTD only.
        l_flag := TRUE;
     ELSIF (i = l_record_count AND l_record_count > 1)-- This is the latest record in multi TAN case.
     THEN                                               --  Hence take the diff of projected and ytd value.
       FOR c_rec IN get_eoy_archival_details(g_asg_tab(i-1).start_date,g_asg_tab(i-1).end_date,g_asg_tab(i-1).gre_id,l_assignment_id)
       LOOP
           l_previous_gre_asg_action_id := c_rec.run_asg_action_id;
           EXIT;
       END LOOP;
        l_flag := FALSE;
     ELSIF (i = 1 AND l_record_count = 1)-- There exists only one record, hence take the Projected value
     THEN
        l_flag := FALSE;
     END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 90);

     OPEN  c_termination_check(l_assignment_id);
     FETCH c_termination_check INTO l_end_date;
     CLOSE c_termination_check;
   pay_in_utils.set_location(g_debug,l_procedure, 100);

      archive_person_data(p_run_asg_action_id      => l_run_asg_action_id
                          ,p_arc_asg_action_id    => p_assignment_action_id
                          ,p_arc_payroll_act_id   => l_arc_pay_action_id
                          ,p_prepayment_date      => l_pre_effective_date
                          ,p_assignment_id        => l_assignment_id
                          ,p_gre_id               => g_asg_tab(i).gre_id
                          ,p_payroll_run_date     => fnd_date.date_to_canonical(l_run_date_earned)
                          ,p_effective_start_date => g_asg_tab(i).start_date
                          ,p_effective_end_date   => LEAST(g_asg_tab(i).end_date,l_end_date)
                          );
   pay_in_utils.set_location(g_debug,l_procedure, 110);

      archive_via_details(p_run_asg_action_id     => l_run_asg_action_id
                          ,p_arc_asg_action_id     => p_assignment_action_id
                          ,p_gre_id                => g_asg_tab(i).gre_id
                          ,p_assignment_id         => l_assignment_id
                          ,p_payroll_date          => l_run_date_earned
                          );
   pay_in_utils.set_location(g_debug,l_procedure, 120);

       archive_allowances(p_run_asg_action_id     => l_run_asg_action_id
                         ,p_arc_asg_action_id     => p_assignment_action_id
                         ,p_gre_id                => g_asg_tab(i).gre_id
                         ,pre_gre_asg_act_id      => l_previous_gre_asg_action_id
                         ,p_flag                  => l_flag
                         );
   pay_in_utils.set_location(g_debug,l_procedure, 130);

       archive_perquisites(p_run_asg_action_id     => l_run_asg_action_id
                          ,p_arc_asg_action_id     => p_assignment_action_id
                          ,p_gre_id                => g_asg_tab(i).gre_id
                          ,pre_gre_asg_act_id      => l_previous_gre_asg_action_id
                          );
   pay_in_utils.set_location(g_debug,l_procedure, 140);

       archive_eoy_salary(p_run_asg_action_id     => l_run_asg_action_id
                         ,p_arc_asg_action_id     => p_assignment_action_id
                         ,p_gre_id                => g_asg_tab(i).gre_id
                         );
   pay_in_utils.set_location(g_debug,l_procedure, 150);

       archive_other_balances(p_run_asg_action_id     => l_run_asg_action_id
                             ,p_arc_asg_action_id     => p_assignment_action_id
                             ,pre_gre_asg_act_id      => l_previous_gre_asg_action_id
                             ,p_gre_id                => g_asg_tab(i).gre_id
                             ,p_start_date            => g_asg_tab(i).start_date
                             ,p_end_date              => g_asg_tab(i).end_date
                             );
   pay_in_utils.set_location(g_debug,l_procedure, 160);

    OPEN  c_pay_action_level_check(l_arc_pay_action_id,g_asg_tab(i).gre_id);
    FETCH c_pay_action_level_check INTO l_check;
    CLOSE c_pay_action_level_check;
   pay_in_utils.set_location(g_debug,l_procedure, 170);

    IF l_check IS NULL
    THEN
         pay_in_utils.set_location(g_debug,l_procedure, 180);
                archive_org_data(p_arc_pay_action_id      => l_arc_pay_action_id
                                ,p_gre_id                 => g_asg_tab(i).gre_id
                                ,p_effective_end_date     => g_system_date
                                );
    END IF;
    END IF;

    END LOOP;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
 --
  EXCEPTION
    WHEN OTHERS THEN
      IF  get_eoy_archival_details%ISOPEN THEN
         CLOSE get_eoy_archival_details;
      END IF;
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  END archive_code;

END PAY_IN_EOY_ARCHIVE;

/
