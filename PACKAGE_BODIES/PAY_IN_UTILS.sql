--------------------------------------------------------
--  DDL for Package Body PAY_IN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_UTILS" AS
/* $Header: pyinutil.pkb 120.22.12010000.2 2009/07/27 12:20:48 mdubasi ship $ */
  g_debug    BOOLEAN;
  g_package  VARCHAR2(20);

----------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_MAX_ACT_SEQUENCE                                --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : This function returns the maximum action sequence   --
--                  for a given assignment id and process type          --
-- Parameters     :                                                     --
--             IN : p_assignment_id  NUMBER                             --
--                  p_process_type   VARCHAR2                           --
--                  p_effective_date DATE                               --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION get_max_act_sequence(p_assignment_id  IN NUMBER
                             ,p_process_type   IN VARCHAR2
                             ,p_effective_date IN DATE
                              )
RETURN NUMBER
IS
  CURSOR c_max_act_seq
  IS
      SELECT MAX(paa.action_sequence)
        FROM pay_assignment_actions paa
            ,pay_payroll_actions    ppa
       WHERE paa.payroll_action_id          = ppa.payroll_action_id
         AND ppa.action_type                = p_process_type
         AND paa.assignment_id              = p_assignment_id
         AND TRUNC(ppa.effective_date,'MM') = TRUNC(p_effective_date,'MM');

   l_max_act_seq    NUMBER := NULL;
   l_procedure      VARCHAR2(50);
   l_message        VARCHAR2(300);
   --
BEGIN
    g_debug      := hr_utility.debug_enabled;
    l_procedure  := g_package||'get_max_act_sequence';
--
    set_location(g_debug, 'Entered '|| l_procedure,10);
    trace('Assignment ID ',p_assignment_id );
    trace('Process Type  ',p_process_type  );
    trace('Effective Date',p_effective_date);

    OPEN  c_max_act_seq;
    FETCH c_max_act_seq INTO l_max_act_seq;
    CLOSE c_max_act_seq;

    trace('Maximum Action Sequence',l_max_act_seq);

    set_location(g_debug, 'Leaving '|| l_procedure,30);
    RETURN l_max_act_seq;

EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       set_location(g_debug,' Leaving : '||l_procedure, 40);
       trace(l_message,null);
       RAISE;
END get_max_act_sequence;

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
        hr_utility.set_location(SUBSTR('INLOG: '||p_message,1,72), p_step);
     END IF;

END set_location;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : TRACE                                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to set the trace                          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     varchar2                              --
--                  p_value       varchar2                              --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE trace (p_message   IN   VARCHAR2
                ,p_value     IN   VARCHAR2)
IS
BEGIN
    hr_utility.trace(RPAD(SUBSTR('INTRC: '||p_message,1,60),60,' ')||': '||p_value);
END trace;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : TRACE                                               --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to set the trace in Fast formulas          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     varchar2                              --
--                  p_value       varchar2                              --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION trace (p_message IN VARCHAR2
               ,p_value   IN VARCHAR2) RETURN NUMBER
IS
BEGIN
    trace(p_message,p_value);
    RETURN 0;
END trace;

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
-- 1.0   28-Aug-2004 statkar  Created                                   --
---------------------------------------------------------------------------
FUNCTION get_pay_message
            (p_message_name      IN VARCHAR2
            ,p_token1            IN VARCHAR2 DEFAULT NULL
            ,p_token2            IN VARCHAR2 DEFAULT NULL
            ,p_token3            IN VARCHAR2 DEFAULT NULL
            ,p_token4            IN VARCHAR2 DEFAULT NULL
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
    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'get_pay_message';
--
    set_location(g_debug, 'Entered '||l_proc,5);
    set_location(g_debug, '.  Message Name: '||p_message_name,40);

    hr_utility.set_message(800,p_message_name);

   IF p_token1 IS NOT NULL THEN
      /* Obtain token 1 name and value */
      l_colon_position := INSTR(p_token1,':');
      l_token_name  := SUBSTR(p_token1,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token1,l_colon_position+1,LENGTH(p_token1)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location(g_debug,'.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
   END IF;

   IF p_token2 IS NOT NULL  THEN
      /* Obtain token 2 name and value */
      l_colon_position := INSTR(p_token2,':');
      l_token_name  := SUBSTR(p_token2,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token2,l_colon_position+1,LENGTH(p_token2)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location(g_debug,'.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
   END IF;

   IF p_token3 IS NOT NULL THEN
      /* Obtain token 3 name and value */
      l_colon_position := INSTR(p_token3,':');
      l_token_name  := SUBSTR(p_token3,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token3,l_colon_position+1,LENGTH(p_token3)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location(g_debug,'.  Token3: '||l_token_name||'. Value: '||l_token_value,70);
   END IF;

   IF p_token4 IS NOT NULL THEN
      /* Obtain token 4 name and value */
      l_colon_position := INSTR(p_token4,':');
      l_token_name  := SUBSTR(p_token4,1,l_colon_position-1);
      l_token_value := SUBSTR(SUBSTR(p_token4,l_colon_position+1,LENGTH(p_token4)) ,1,77);
      hr_utility.set_message_token(l_token_name,l_token_value);
      set_location(g_debug,'.  Token4: '||l_token_name||'. Value: '||l_token_value,80);
   END IF;

   l_message := SUBSTRB(hr_utility.get_message,1,250);

   set_location(g_debug,'leaving '||l_proc,100);
   RETURN l_message;

END get_pay_message;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NULL_MESSAGES                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to null the messages                       --
-- Parameters     :                                                     --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   28-AUG-04  statkar   Created this function                     --
--------------------------------------------------------------------------
  PROCEDURE null_message
           (p_token_name   IN OUT NOCOPY pay_in_utils.char_tab_type
           ,p_token_value  IN OUT NOCOPY pay_in_utils.char_tab_type)
  IS

  BEGIN
      p_token_name.delete;
      p_token_value.delete;
      RETURN;
  END null_message;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : RAISE_MESSAGE                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to set and raise the messages              --
-- Parameters     :                                                     --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   28-AUG-04  statkar   Created this function                     --
--------------------------------------------------------------------------
  PROCEDURE raise_message
           (p_application_id IN NUMBER
           ,p_message_name IN VARCHAR2
           ,p_token_name   IN OUT NOCOPY pay_in_utils.char_tab_type
           ,p_token_value  IN OUT NOCOPY pay_in_utils.char_tab_type)
  IS
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
-- 1.1   24-Sep-04  statkar   3902024 - Changed p_row_name to p_row_value-
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
     l_proc       VARCHAR2(100);
BEGIN
    l_proc  := g_package||'get_user_table_value';
    g_debug := hr_utility.debug_enabled;

    set_location(g_debug, 'Entering : '||l_proc,10);

    l_value  :=  hruserdt.get_table_value
                  ( p_bus_group_id      => p_business_group_id
                   ,p_table_name        => p_table_name
                   ,p_col_name          => p_column_name
                   ,p_row_value         => p_row_value
                   ,p_effective_date    => p_effective_date
                   );

    p_message := 'SUCCESS';

    set_location(g_debug, 'Leaving : '||l_proc,20);

    RETURN l_value;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        p_message := get_pay_message('PER_IN_USER_TABLE_INCOMPLETE','TABLE:'||p_table_name,'COLUMN:'||p_column_name,'VALUE:'||p_row_value);
        trace (p_message,null);
        RETURN -1;

END get_user_table_value;


--------------------------------------------------------------------------
-- Name           : GET_RUN_TYPE_NAME                                   --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function checks the Run Type used for the Payroll   --
--                  Run                                                 --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_payroll_action_id       IN NUMBER                 --
--                                                                      --
-- Version    Date     Author   Bug      Description                    --
-- =====================================================================--
-- 115.0     20-Sep-04   ABHJAIN  3683543  Initial Version              --
--                                                                      --
--------------------------------------------------------------------------


FUNCTION get_run_type_name (p_payroll_action_id     IN NUMBER
                           ,p_assignment_action_id  IN NUMBER)
         RETURN VARCHAR2 IS
l_run_type_name VARCHAR2(80);
BEGIN

SELECT prt.run_type_name into l_run_type_name
  FROM pay_run_types_f      prt,
       pay_payroll_actions  ppa,
       pay_assignment_actions paa
 WHERE ppa.payroll_action_id = p_payroll_action_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND prt.run_type_id = paa.run_type_id
   AND paa.assignment_action_id = p_assignment_action_id
   AND ppa.effective_date between prt.effective_start_date
                              and prt.effective_end_date;

  RETURN (l_run_type_name);

EXCEPTION

  WHEN OTHERS THEN
    RETURN NVL(l_run_type_name,'-1');

END get_run_type_name ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EFFECTIVE_DATE                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the calculates the effective date  --
--                  based on the following conditions:                  --
--                  1) If effective date is passed returns the same     --
--                  2) Else use the System date.                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date DATE                               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   24/09/04   puchil   Created this function                      --
--------------------------------------------------------------------------
FUNCTION get_effective_date(p_effective_date IN DATE)
RETURN DATE
IS
   --
   l_proc VARCHAR2(120);
   l_effective_date DATE;
   --
BEGIN
   --
   l_proc := g_package||'.get_effective_date';
   set_location(g_debug, l_proc, 10);
   --
   -- If the effective date is passed as null then
   -- use the system date for calculation.
   --
   IF p_effective_date is null THEN
     --
     l_effective_date := to_date(to_char(sysdate, 'DD-MM-YYYY'), 'DD-MM-YYYY');
     set_location(g_debug, l_proc, 20);
     --
   ELSE
     --
     l_effective_date := p_effective_date;
     set_location(g_debug, l_proc, 30);
     --
   END IF;
   --
   set_location(g_debug, l_proc, 40);
   RETURN l_effective_date;
   --
END get_effective_date;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PERSON_ID                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the person_id of the assignment    --
--                  as of effective date. IF effective date is null     --
--                  then details are retrieved as of sysdate.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id  NUMBER                             --
--                  p_effective_date DATE                               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   30/12/02   puchil   Created this function                      --
--------------------------------------------------------------------------
FUNCTION get_person_id
    (p_assignment_id  IN per_assignments_f.assignment_id%TYPE
    ,p_effective_date IN DATE default null)
RETURN per_assignments_f.person_id%TYPE
IS
   --
   CURSOR csr_person_details(c_effective_date IN DATE)
   IS
   SELECT person_id
     FROM per_assignments_f
    WHERE assignment_id = p_assignment_id
      AND c_effective_date BETWEEN effective_start_date
                               AND effective_end_date;
   --
   l_proc VARCHAR2(100);
   l_effective_date DATE;
   l_person_id  per_assignments_f.person_id%TYPE;
   --
BEGIN
   --
   l_proc := g_package||'get_person_id';
   g_debug := hr_utility.debug_enabled;
   set_location(g_debug, 'Entering: ' || l_proc, 10);
   --
   IF g_debug THEN
      --
      trace('Assignment ID : ', p_assignment_id);
      trace('Effective Date: ', p_effective_date);
      --
   END IF;
   --
   IF p_assignment_id IS NULL THEN
      --
      set_location(g_debug, 'Leaving: '||l_proc, 20);
      RETURN NULL;
      --
   END IF;
   --
   l_effective_date := get_effective_date(p_effective_date);
   --
   OPEN csr_person_details(l_effective_date);
   FETCH csr_person_details INTO l_person_id;
   CLOSE csr_person_details;
   --
   set_location(g_debug, 'Leaving: '||l_proc, 50);
   --
   RETURN l_person_id;
   --
EXCEPTION
   WHEN OTHERS THEN
        RETURN null;

END get_person_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ASSIGNMENT_ID                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the assignment_if of the person    --
--                  as of effective date. IF effective date is null     --
--                  then details are retrieved as of sysdate.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id      NUMBER                             --
--                  p_effective_date DATE                               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   30/12/02   puchil   Created this function                      --
--------------------------------------------------------------------------
FUNCTION get_assignment_id
    (p_person_id      IN per_people_f.person_id%TYPE
    ,p_effective_date IN DATE default null)
RETURN per_assignments_f.assignment_id%TYPE
IS
   --
   CURSOR csr_assignment_details(c_effective_date IN DATE)
   IS
   SELECT assignment_id
     FROM per_assignments_f
    WHERE person_id = p_person_id
      AND c_effective_date BETWEEN effective_start_date
                               AND effective_end_date;
   --
   l_proc VARCHAR2(100);
   l_effective_date DATE;
   l_assignment_id per_assignments_f.assignment_id%TYPE;
   --
BEGIN
   --
   l_proc := g_package||'.get_assignment_id';
   g_debug := hr_utility.debug_enabled;
   set_location(g_debug, 'Entering: ' || l_proc, 10);
   --
   IF g_debug THEN
      --
      trace('Assignment ID : ' , p_person_id);
      trace('Effective Date: ' , p_effective_date);
      --
   END IF;
   --
   IF p_person_id IS NULL THEN
      --
      set_location(g_debug, 'Leaving: '||l_proc, 20);
      RETURN NULL;
      --
   END IF;
   --
   l_effective_date := get_effective_date(p_effective_date);
   --
   OPEN csr_assignment_details(l_effective_date);
   FETCH csr_assignment_details INTO l_assignment_id;
   CLOSE csr_assignment_details;
   --
   set_location(g_debug, 'Leaving: '||l_proc, 30);
   --
   RETURN l_assignment_id;
   --
EXCEPTION
   WHEN OTHERS THEN
        RETURN null;

END get_assignment_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_TAX_YEAR                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the beginning of the next finan-   --
--                  cial year calculated based of the p_date input.     --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date DATE                                         --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   23/09/04   puchil   Created this function                      --
--------------------------------------------------------------------------
FUNCTION next_tax_year(p_date IN  DATE)
RETURN DATE
IS
  l_year  number(4);
  l_start DATE;
  l_start_dd_mm VARCHAR2(6);
BEGIN
  l_year := TO_NUMBER(TO_CHAR(p_date,'yyyy'));
  l_start_dd_mm := '01-04-';

  IF p_date >= TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'dd-mm-yyyy') THEN
    l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year+1),'dd-mm-yyyy');
  ELSE
    l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'dd-mm-yyyy');
  END IF;
  RETURN l_start;
END next_tax_year;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : validate_dates                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks if the effective end date is   --
--                  greater than or equal to effective start date .     --
-- Parameters     :                                                     --
--             IN :     p_effective_start_date   IN DATE                --
--                      p_effective_end_date     IN DATE                --
--         RETURN :   BOOLEAN                                           --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27/09/04   statkar   Created this function                     --
--------------------------------------------------------------------------
FUNCTION validate_dates(p_start_date IN DATE,
                        p_end_date   IN DATE)
RETURN BOOLEAN
IS
   l_end_date DATE;
BEGIN
   l_end_date  := NVL(p_end_date,to_date('31-12-4712','DD-MM-YYYY'));

   IF l_end_date < p_start_date THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END validate_dates;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_org_class                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks if the organization passed has --
--                  the classification enabled                          --
-- Parameters     :                                                     --
--             IN :     p_effective_start_date   IN DATE                --
--                      p_effective_end_date     IN DATE                --
--         RETURN :   BOOLEAN                                           --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27/09/04   statkar   Created this function                     --
--------------------------------------------------------------------------
FUNCTION chk_org_class(p_organization_id IN NUMBER,
                       p_org_class       IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR csr_exists IS
     SELECT '1'
     FROM   hr_organization_information
     WHERE  organization_id = p_organization_id
     AND    org_information_context = 'CLASS'
     AND    org_information1 = p_org_class
     AND    org_information2 = 'Y';

  l_dummy    VARCHAR2(1);

BEGIN

  OPEN csr_exists;
  FETCH csr_exists
  INTO  l_dummy;

  IF csr_exists%NOTFOUND OR l_dummy IS NULL THEN
     RETURN FALSE;
  ELSE
     RETURN TRUE;
  END IF;
  CLOSE csr_exists;

END chk_org_class;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : number_to_words                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the passed number after       --
--                  converting it into words                            --
-- Parameters     :                                                     --
--             IN :   p_value   IN NUMBER                               --
--         RETURN :   VARCHAR2                                          --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   02/11/04   abhjain   Created this function                     --
-- 1.1   04/07/05   abhjain   Corrected the function                    --
--------------------------------------------------------------------------
FUNCTION number_to_words(p_value IN NUMBER)
RETURN VARCHAR2
is
     num1        NUMBER(12,2);
     numy        NUMBER(12,2);
     l_num_temp  NUMBER;
     l_num_temp1 NUMBER(2);
     l_num_temp2 NUMBER(12,2);
     l_num_temp3 NUMBER;
     money       NUMBER;
     num2        VARCHAR2(20);
     money_str   VARCHAR2(200);
     t_str       VARCHAR2(200);
     l_char1     VARCHAR2(20);
     l_char2     VARCHAR2(20);
BEGIN
        num1 := p_value;
        money := num1;
        num1 := floor(num1/1000000000);
        IF num1  > 0 THEN
           num2:=     to_char(to_date(num1,'j'),'jsp');
           money_str := num2||' hundred';
        END IF;
        num1 := mod(money,1000000000);
        money := num1;
        l_num_temp3 := floor(num1/10000000);
        IF l_num_temp3 > 0 THEN
          t_str := to_char(to_date( l_num_temp3 ,'j'),'jsp');
          money_str := money_str||' '|| t_str||' crore';
          num1 := mod(num1,10000000);
        END IF;
        l_num_temp3 := floor(num1/100000);
        IF l_num_temp3 > 0 THEN
          t_str := to_char(to_date( l_num_temp3 ,'j'),'jsp');
          money_str := money_str||' '||t_str||' lac';
          num1 := mod(num1,100000);
        END IF;
        l_num_temp3 := floor(num1/1000);
        IF l_num_temp3 > 0 THEN
          t_str := to_char(to_date( l_num_temp3 ,'j'),'jsp');
          money_str := money_str||' '||t_str||' thousand';
          num1 := mod(num1,1000);
        END IF;
        l_num_temp3 := floor(num1/100);
        IF l_num_temp3 > 0 THEN
          t_str := to_char(to_date( l_num_temp3 ,'j'),'jsp');
          money_str := money_str||' '||t_str||' hundred';
          num1 := mod(num1,100);
        END IF;
        num1 := floor(num1);
        IF num1 > 0 THEN
          t_str := to_char(to_date(num1,'j'),'jsp');
          money_str := money_str ||' '|| t_str;
        END IF;
        l_num_temp2 := mod(p_value,1)*100;
        IF l_num_temp2 > 0 THEN
            l_char2 := to_char(to_Date(l_num_temp2,'j'),'jsp');
           RETURN (replace('Rupees'||nvl(money_str, ' Zero')||' and '||l_char2||' paise only', '-', ' '));
        ELSE
           RETURN(replace('Rupees'||nvl(money_str, ' Zero')||' and zero paise only', '-', ' '));
        END IF;


END number_to_words ;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : encode_html_string                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This procedure encodes the HTML literals .          --
--                                                                      --
-- Parameters     :                                                     --
--             IN :   p_value   IN NUMBER                               --
--         RETURN :   VARCHAR2                                          --
--------------------------------------------------------------------------
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid   Bug      Description                       --
--------------------------------------------------------------------------
-- 1.0   22/12/04   aaagarwa 4070869  Created this function             --
--------------------------------------------------------------------------

FUNCTION encode_html_string(p_value IN VARCHAR2)
RETURN VARCHAR2
IS
  TYPE html_rec IS RECORD
          (html_char VARCHAR2(2)
          ,encoded   VARCHAR2(10)
          );

  TYPE html_char_tab IS TABLE OF  html_rec INDEX BY binary_integer;

  char_list html_char_tab;
  i  NUMBER;
  l_value VARCHAR2(1000);
begin
 IF p_value IS NULL then
    RETURN null;
 END IF;

  char_list(0).html_char:='&';
  char_list(0).encoded:='&amp;';

  char_list(1).html_char:='>';
  char_list(1).encoded:='&gt;';

  char_list(2).html_char:='<';
  char_list(2).encoded:='&lt;';

  i:=0;
  l_value := p_value;
  while(i<char_list.count())
  LOOP
      l_value:=replace(l_value,char_list(i).html_char,char_list(i).encoded);
      i:=i+1;
  END LOOP;

 RETURN l_value;

END encode_html_string;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_SCL_SEGMENT_ON_DATE                             --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Returns                                             --
-- Parameters     :                                                     --
--             IN : p_assigment_id        VARCHAR2                      --
--                : p_business_group_id   NUMBER                        --
--                : p_date                DATE                          --
--                : p_column              VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------

FUNCTION get_scl_segment_on_date(p_assignment_id     IN NUMBER
                               ,p_business_group_id IN NUMBER
                               ,p_date              IN DATE
                               ,p_column            IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR cur_scl_value (p_assignment_id      NUMBER
                       ,p_business_group_id  NUMBER
                       ,p_date               DATE)
       IS
   SELECT hsc.segment1
         ,hsc.segment2
         ,hsc.segment3
         ,hsc.segment4
         ,hsc.segment5
         ,hsc.segment6
         ,hsc.segment7
         ,hsc.segment8
         ,hsc.segment9
         ,hsc.segment10
         ,hsc.segment11
         ,hsc.segment12
     FROM per_assignments_f      paf
         ,hr_soft_coding_keyflex hsc
    WHERE paf.assignment_id = p_assignment_id
      AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
      AND paf.business_group_id = p_business_group_id
      AND p_date BETWEEN paf.effective_start_date
                     AND paf.effective_end_date;

  l_segment1 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment2 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment3 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment4 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment5 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment6 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment7 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment8 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment9 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment10 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment11 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment12 hr_soft_coding_keyflex.segment1%TYPE;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);

BEGIN

  l_procedure := g_package||'get_org_id';
  g_debug          := hr_utility.debug_enabled;

  set_location(g_debug,'Entering : '||l_procedure, 10);

  OPEN cur_scl_value (p_assignment_id
               ,p_business_group_id
               ,p_date);
  FETCH cur_scl_value into l_segment1
                    ,l_segment2
                    ,l_segment3
                    ,l_segment4
                    ,l_segment5
                    ,l_segment6
                    ,l_segment7
                    ,l_segment8
                    ,l_segment9
                    ,l_segment10
                    ,l_segment11
                    ,l_segment12;

  set_location (g_debug,'l_segment1 = '||l_segment1,10);
  set_location (g_debug,'l_segment2 = '||l_segment2,20);
  set_location (g_debug,'l_segment3 = '||l_segment3,30);
  set_location (g_debug,'l_segment4 = '||l_segment4,40);
  set_location (g_debug,'l_segment5 = '||l_segment5,50);
  set_location (g_debug,'l_segment6 = '||l_segment6,60);
  set_location (g_debug,'l_segment7 = '||l_segment7,70);
  set_location (g_debug,'l_segment8 = '||l_segment8,80);
  set_location (g_debug,'l_segment9 = '||l_segment9,90);
  set_location (g_debug,'l_segment10 = '||l_segment10,100);
  set_location (g_debug,'l_segment11 = '||l_segment11,110);
  set_location (g_debug,'l_segment12 = '||l_segment12,120);
  CLOSE cur_scl_value;

  IF p_column = 'segment1' THEN
     RETURN  l_segment1;
  ELSIF p_column = 'segment2' THEN
     RETURN  l_segment2;
  ELSIF p_column = 'segment3' THEN
     RETURN  l_segment3;
  ELSIF p_column = 'segment4' THEN
     RETURN  l_segment4;
  ELSIF p_column = 'segment5' THEN
     RETURN  l_segment5;
  ELSIF p_column = 'segment6' THEN
     RETURN  l_segment6;
  ELSIF p_column = 'segment7' THEN
     RETURN  l_segment7;
  ELSIF p_column = 'segment8' THEN
     RETURN  l_segment8;
  ELSIF p_column = 'segment9' THEN
     RETURN  l_segment9;
  ELSIF p_column = 'segment10' THEN
     RETURN  l_segment10;
  ELSIF p_column = 'segment11' THEN
     RETURN  l_segment11;
  ELSIF p_column = 'segment12' THEN
     RETURN  NVL(l_segment12,'0');
 END IF;

  set_location(g_debug,'Leaving : '||l_procedure, 30);

EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       set_location(g_debug,' Leaving : '||l_procedure, 30);
       trace(l_message,null);
       RETURN NULL;


END get_scl_segment_on_date;
-------------------------------------------------------------------------
--                                                                      --
-- Name           : get_element_link_id                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns element link id for an        --
--                  assignment for an element as on a given date        --
-- Parameters     :                                                     --
--             IN :     p_assignment_id   NUMBER                        --
--                      p_effective_date  DATE                          --
--                      p_element_type_id NUMBER                        --
--         RETURN :     NUMBER                                          --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   06/12/05  aaagarwa   Created this function                     --
--------------------------------------------------------------------------
FUNCTION get_element_link_id(p_assignment_id   IN NUMBER
                            ,p_effective_date  IN DATE
                            ,p_element_type_id IN NUMBER
                            )
RETURN NUMBER
IS

CURSOR c_bg
IS
   SELECT business_group_id
   FROM   per_assignments_f
   where  assignment_id = p_assignment_id
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;


CURSOR c_element_link_details(p_element_type_id NUMBER
                             ,p_effective_date  DATE
                             ,p_bg_id           NUMBER
			     ,p_payroll_id      NUMBER
                             ,p_organization_id NUMBER
                             ,p_position_id     NUMBER
                             ,p_job_id          NUMBER
                             ,p_grade_id        NUMBER
                             ,p_location_id     NUMBER
                             ,p_pay_basis_id    NUMBER
                             ,p_employment_category VARCHAR2
                             )
IS
SELECT  element_link_id,
        payroll_id,
        link_to_all_payrolls_flag,
        organization_id,
        position_id,
        job_id,
        grade_id,
        location_id,
        pay_basis_id,
        employment_category,
        people_group_id
  FROM  pay_element_links_f
 WHERE  element_type_id = p_element_type_id
   AND  business_group_id = p_bg_id
   AND (payroll_id = p_payroll_id OR payroll_id is null)
   AND (organization_id = p_organization_id OR organization_id is null)
   AND (position_id = p_position_id OR position_id is null)
   AND (job_id = p_job_id OR job_id is null)
   AND (grade_id = p_grade_id OR grade_id is null)
   AND (location_id = p_location_id OR location_id is null)
   AND (pay_basis_id = p_pay_basis_id OR pay_basis_id is null)
   AND (employment_category = p_employment_category OR employment_category is null)
   AND link_to_all_payrolls_flag in ('N','Y')
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

CURSOR c_assignment_details(p_assignment_id  NUMBER
                           ,p_effective_date DATE
                           )
IS
SELECT  payroll_id,
        organization_id,
        position_id,
        job_id,
        grade_id,
        location_id,
        pay_basis_id,
        employment_category
  FROM  per_assignments_f
 WHERE  assignment_id = p_assignment_id
   AND  p_effective_date BETWEEN effective_start_date AND effective_end_date;


CURSOR c_link_usage(p_assignment_id   NUMBER
                   ,p_element_link_id NUMBER
                   ,p_effective_date  DATE
                   )
IS
SELECT 1
  FROM pay_assignment_link_usages_f
 WHERE assignment_id   = p_assignment_id
   AND element_link_id = p_element_link_id
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;


l_element_link_id            pay_element_links_f.element_link_id%TYPE;
l_link_payroll_id            pay_element_links_f.payroll_id%TYPE;
l_link_to_all_payrolls_flag  pay_element_links_f.link_to_all_payrolls_flag%TYPE;
l_link_org_id                pay_element_links_f.organization_id%TYPE;
l_link_pos_id                pay_element_links_f.position_id%TYPE;
l_link_job_id                pay_element_links_f.job_id%TYPE;
l_link_grd_id                pay_element_links_f.grade_id%TYPE;
l_link_loc_id                pay_element_links_f.location_id%TYPE;
l_link_pay_basis_id          pay_element_links_f.pay_basis_id%TYPE;
l_link_emp_catg_id           pay_element_links_f.employment_category%TYPE;
l_link_pep_grp_id            pay_element_links_f.people_group_id%TYPE;

l_asg_payroll_id             per_all_assignments_f.payroll_id%TYPE;
l_asg_org_id                 per_all_assignments_f.organization_id%TYPE;
l_asg_pos_id                 per_all_assignments_f.position_id%TYPE;
l_asg_job_id                 per_all_assignments_f.job_id%TYPE;
l_asg_grd_id                 per_all_assignments_f.grade_id%TYPE;
l_asg_loc_id                 per_all_assignments_f.location_id%TYPE;
l_asg_pay_basis_id           per_all_assignments_f.pay_basis_id%TYPE;
l_asg_emp_catg_id            per_all_assignments_f.employment_category%TYPE;
l_bus_grp_id                 NUMBER;


l_flag                       NUMBER;

BEGIN
  OPEN  c_bg;
  FETCH c_bg INTO l_bus_grp_id;
  CLOSE c_bg;


  OPEN  c_assignment_details(p_assignment_id,p_effective_date);
  FETCH c_assignment_details INTO l_asg_payroll_id,
                                  l_asg_org_id,
                                  l_asg_pos_id,
                                  l_asg_job_id,
                                  l_asg_grd_id,
                                  l_asg_loc_id,
                                  l_asg_pay_basis_id,
                                  l_asg_emp_catg_id;
  CLOSE c_assignment_details;

  OPEN  c_element_link_details(p_element_type_id,p_effective_date,l_bus_grp_id,
                               l_asg_payroll_id,l_asg_org_id,l_asg_pos_id,l_asg_job_id,
                               l_asg_grd_id,l_asg_loc_id,l_asg_pay_basis_id,l_asg_emp_catg_id) ;
  FETCH c_element_link_details INTO l_element_link_id,
                                    l_link_payroll_id,
                                    l_link_to_all_payrolls_flag,
                                    l_link_org_id,
                                    l_link_pos_id,
                                    l_link_job_id,
                                    l_link_grd_id,
                                    l_link_loc_id,
                                    l_link_pay_basis_id,
                                    l_link_emp_catg_id,
                                    l_link_pep_grp_id;
  CLOSE c_element_link_details;



  OPEN  c_link_usage(p_assignment_id,l_element_link_id,p_effective_date);
  FETCH c_link_usage INTO l_flag;
  CLOSE c_link_usage;

  IF ((l_link_payroll_id IS NOT NULL AND l_link_payroll_id = l_asg_payroll_id)
     OR
     (l_link_to_all_payrolls_flag ='Y' AND l_asg_payroll_id IS NOT NULL)
     OR
     (l_link_payroll_id IS NULL AND l_link_to_all_payrolls_flag ='N')
     )
     AND (l_link_pep_grp_id   IS NULL OR 1 = l_flag)
  THEN
          RETURN l_element_link_id;
  ELSE
          RETURN NULL;
  END IF;
END get_element_link_id;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_element_link                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks if an assignment is eligible   --
--                  for an element as on a given date.                  --
-- Parameters     :                                                     --
--             IN :     p_element_name    VARCHAR2                      --
--                      p_assignment_id   NUMBER                        --
--                      p_effective_date  DATE                          --
--            OUT :     p_element_link_id NUMBER                        --
--         RETURN :   VARCHAR2                                          --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27/12/04  lnagaraj   Created this function                     --
--------------------------------------------------------------------------
FUNCTION chk_element_link(p_element_name IN VARCHAR2
                         ,p_assignment_id  IN NUMBER
                         ,p_effective_date IN DATE
                         ,p_element_link_id OUT NOCOPY NUMBER)
RETURN VARCHAR2
IS
   CURSOR csr_element_type_id
   IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  (legislation_code = 'IN' OR business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'))
   AND    element_name = p_element_name
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

/*
   CURSOR csr_element_link_details
       IS
   SELECT link.element_link_id
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
    WHERE assgn.assignment_id = p_assignment_id
      AND ((link.payroll_id IS NOT NULL AND link.payroll_id = assgn.payroll_id) OR
           (link.link_to_all_payrolls_flag = 'Y' AND assgn.payroll_id IS NOT NULL) OR
           (link.payroll_id IS NULL AND link.link_to_all_payrolls_flag = 'N'))
      AND (link.organization_id = assgn.organization_id OR link.organization_id IS NULL)
      AND (link.position_id = assgn.position_id OR link.position_id IS NULL)
      AND (link.job_id = assgn.job_id OR link.job_id IS NULL)
      AND (link.grade_id = assgn.grade_id OR link.grade_id IS NULL)
      AND (link.location_id = assgn.location_id OR link.location_id IS NULL)
      AND (link.pay_basis_id = assgn.pay_basis_id OR link.pay_basis_id IS NULL)
      AND (link.employment_category = assgn.employment_category OR link.employment_category IS NULL)
      AND (link.people_group_id IS NULL OR
           EXISTS ( SELECT 1 FROM pay_assignment_link_usages_f usage
                     WHERE usage.assignment_id = assgn.assignment_id
                       AND usage.element_link_id = link.element_link_id
                       AND p_effective_date BETWEEN usage.effective_start_date AND usage.effective_end_date
                   ))
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = p_element_name
      AND p_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND p_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND p_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date;
*/
p_message VARCHAR2(30);
l_element_type_id pay_element_types_f.element_type_id%TYPE;

BEGIN
  p_message :='SUCCESS';
/*
  OPEN csr_element_link_details;
  FETCH csr_element_link_details INTO p_element_link_id ;
  CLOSE csr_element_link_details;
*/
  OPEN csr_element_type_id;
  FETCH csr_element_type_id INTO l_element_type_id ;
  CLOSE csr_element_type_id;

  p_element_link_id := get_element_link_id(p_assignment_id
                                          ,p_effective_date
                                          ,l_element_type_id
                                          );

  IF p_element_link_id IS NULL THEN
     --
     p_message := 'PER_IN_MISSING_LINK';
     --
  END IF;

  RETURN  p_message;

END chk_element_link;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EE_VALUE                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the element entry value          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id  NUMBER                          --
--                  p_input_name        VARCHAR2                        --
--                  p_effective_date    DATE                            --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_ee_value
         (p_element_entry_id  IN NUMBER
         ,p_input_name        IN VARCHAR2
         ,p_effective_date    IN DATE
         )
RETURN VARCHAR2
IS
   CURSOR c_entry_value
   IS
   SELECT val.screen_entry_value
   FROM   pay_element_entry_values_f val
         ,pay_input_values_f inputs
   WHERE  val.input_value_id   = inputs.input_value_id
     AND  val.element_entry_id = p_element_entry_id
     AND  inputs.name = p_input_name
     AND  inputs.legislation_code = 'IN'
     AND  p_effective_date between val.effective_start_date AND val.effective_end_date
     AND  p_effective_date between inputs.effective_start_date AND inputs.effective_end_date;
--
   l_screen_entry_value  pay_element_entry_values_f.screen_entry_value%TYPE := NULL;
BEGIN

    OPEN  c_entry_value;
    FETCH c_entry_value INTO l_screen_entry_value;
    CLOSE c_entry_value;

    RETURN l_screen_entry_value;

END get_ee_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EE_VALUE                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the element entry value          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id  NUMBER                          --
--                  p_input_name        VARCHAR2                        --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_ee_value
         (p_element_entry_id  IN NUMBER
         ,p_input_name        IN VARCHAR2
         )
RETURN VARCHAR2
IS
   CURSOR c_entry_value
   IS
   SELECT val.screen_entry_value
   FROM   pay_element_entry_values_f val
         ,pay_input_values_f inputs
   WHERE  val.input_value_id   = inputs.input_value_id
     AND  val.element_entry_id = p_element_entry_id
     AND  inputs.name = p_input_name
     AND  inputs.legislation_code = 'IN';
--
   l_screen_entry_value  pay_element_entry_values_f.screen_entry_value%TYPE := NULL;
BEGIN
    set_location(g_debug, 'Entered '|| g_package||'.get_ee_value',1);
    OPEN  c_entry_value;
    FETCH c_entry_value INTO l_screen_entry_value;
    CLOSE c_entry_value;
    set_location(g_debug, 'Leaving '|| g_package||'.get_ee_value',5);
    RETURN l_screen_entry_value;

END get_ee_value;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ACTION_TYPE                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the action_type of an asact_id   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id  NUMBER                      --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_action_type
         (p_assignment_action_id  IN NUMBER
         )
RETURN VARCHAR2
IS
    CURSOR c_act_type IS
         SELECT 'L'
         FROM   pay_payroll_actions ppa
               ,pay_assignment_actions paa
         WHERE  paa.payroll_action_id = ppa.payroll_action_id
         AND    paa.assignment_action_id = p_assignment_action_id
         AND    EXISTS (SELECT 1
                        FROM pay_payroll_Actions ppa2
                        WHERE ppa2.effective_date >= ppa.effective_date
                        AND   ppa2.action_type IN ('R','Q')
                        AND   ppa2.action_status = 'C') ;

    l_act_type  pay_payroll_actions.action_type%TYPE;
BEGIN

   OPEN c_act_type;
   FETCH c_act_type
   INTO  l_act_type;
   IF c_act_type%NOTFOUND THEN
       l_act_type := 'K';
   END IF;
   CLOSE c_act_type;
   RETURN l_act_type;

END get_action_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAX_UNIT_ID                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tax unit id for an assignment--
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id  NUMBER                             --
--                  p_effective_date DATE                               --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_tax_unit_id
         (p_assignment_id  IN NUMBER
         ,p_effective_date DATE
         )
RETURN VARCHAR2
IS
   CURSOR c_gre_id
   IS
      SELECT scl.segment1
        FROM per_assignments_f asg,
             hr_soft_coding_keyflex scl
       WHERE asg.assignment_id = p_assignment_id
         AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
         AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

   l_tax_unit_id hr_soft_coding_keyflex.segment1%TYPE;
BEGIN
   OPEN  c_gre_id;
   FETCH c_gre_id INTO l_tax_unit_id;
   CLOSE c_gre_id;

   RETURN l_tax_unit_id;
END get_tax_unit_id;

--------------------------------------------------------------------------
-- Name           : GET_FORMULA_ID                                      --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the formula_id                    --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_formula_name        VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_formula_id
         (p_effective_date   IN DATE
         ,p_formula_name     IN VARCHAR2
         )
RETURN NUMBER
IS
   l_formula_id NUMBER ;
   l_procedure  CONSTANT VARCHAR2(100):= g_package||'get_formula_id';
   l_message    VARCHAR2(255);
BEGIN
   g_debug := hr_utility.debug_enabled;
   set_location(g_debug, 'Entering: '||l_procedure,10);

   SELECT formula_id
   INTO   l_formula_id
   FROM   ff_formulas_f
   WHERE  legislation_code = 'IN'
   AND    formula_name = p_formula_name
   AND    p_effective_date  BETWEEN effective_start_Date AND effective_end_date;

   trace('Formula Id',l_formula_id);

   set_location(g_debug, 'Leaving: '||l_procedure,20);
   RETURN l_formula_id;

EXCEPTION
   WHEN OTHERS THEN
      set_location(g_debug, 'Leaving: '||l_procedure,30);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      trace('SQLERRM',l_message);
      RAISE ;

END get_formula_id;

--------------------------------------------------------------------------
-- Name           : GET_ELEMENT_TYPE_ID                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the element_type_id               --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_element_name        VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_element_type_id
         (p_effective_date    IN DATE
         ,p_element_name      IN VARCHAR2
         )
RETURN NUMBER
IS

   l_element_id NUMBER ;
   l_procedure  CONSTANT VARCHAR2(100):= g_package||'get_element_type_id';
   l_message    VARCHAR2(255);
BEGIN
   g_debug := hr_utility.debug_enabled;
   set_location(g_debug, 'Entering: '||l_procedure,10);

   SELECT element_type_id
   INTO   l_element_id
   FROM   pay_element_types_f
   WHERE  element_name = p_element_name
   AND    p_effective_date  BETWEEN effective_start_date AND effective_end_date;

   trace('Element Type Id',l_element_id);

   set_location(g_debug, 'Leaving: '||l_procedure,20);
   RETURN l_element_id;

EXCEPTION
   WHEN OTHERS THEN
      set_location(g_debug, 'Leaving: '||l_procedure,30);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      trace('SQLERRM',l_message);
      RETURN TO_NUMBER(NULL);
      RAISE ;

END get_element_type_id;

--------------------------------------------------------------------------
-- Name           : GET_BALANCE_TYPE_ID                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the balance_type_id               --
-- Parameters     :                                                     --
--             IN : p_balance_name        VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_balance_type_id
         (p_balance_name      IN VARCHAR2
         )
RETURN NUMBER
IS
   l_balance_id NUMBER ;
   l_procedure  CONSTANT VARCHAR2(100):= g_package||'get_balance_type_id';
   l_message    VARCHAR2(255);
BEGIN
   g_debug := hr_utility.debug_enabled;
   set_location(g_debug, 'Entering: '||l_procedure,10);

   SELECT balance_type_id
   INTO   l_balance_id
   FROM   pay_balance_types
   WHERE  legislation_code = 'IN'
   AND    balance_name = p_balance_name;

   trace('Balance Type Id',l_balance_id);

   set_location(g_debug, 'Leaving: '||l_procedure,20);
   RETURN l_balance_id;

EXCEPTION
   WHEN OTHERS THEN
      set_location(g_debug, 'Leaving: '||l_procedure,30);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      trace('SQLERRM',l_message);
      RETURN TO_NUMBER(NULL);
      RAISE ;

END get_balance_type_id;

--------------------------------------------------------------------------
-- Name           : GET_INPUT_VALUE_ID                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the input_value_id                --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_element_id          NUMBER                        --
--                : p_input_value         VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_input_value_id
         (p_effective_date    IN DATE
         ,p_element_id        IN NUMBER
	 ,p_input_value       IN VARCHAR2
         )
RETURN NUMBER
IS
  CURSOR c_input_value_id
  IS
    SELECT input_value_id
      FROM pay_input_values_f
     WHERE element_type_id = p_element_id
       AND p_effective_date  BETWEEN effective_start_date AND effective_end_date
       AND NAME = p_input_value;

   l_input_value_id NUMBER ;
   l_procedure  CONSTANT VARCHAR2(100):= g_package||'get_input_value_id';
   l_message    VARCHAR2(255);
BEGIN
   g_debug := hr_utility.debug_enabled;
   set_location(g_debug, 'Entering: '||l_procedure,10);

   OPEN  c_input_value_id;
   FETCH c_input_value_id INTO l_input_value_id;
   IF (c_input_value_id%NOTFOUND)
   THEN
        set_location(g_debug, 'l_input_value_id: NULL ',15);
   END IF;
   CLOSE c_input_value_id;

   trace('Input Value Id',l_input_value_id);

   set_location(g_debug, 'Leaving: '||l_procedure,20);
   RETURN l_input_value_id;

EXCEPTION
   WHEN OTHERS THEN
      set_location(g_debug, 'Leaving: '||l_procedure,30);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      trace('SQLERRM',l_message);
      RETURN TO_NUMBER(NULL);
      RAISE ;

END get_input_value_id;

--------------------------------------------------------------------------
-- Name           : GET_INPUT_VALUE_ID                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the input_value_id                --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_element_id          NUMBER                        --
--                : p_input_value         VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_input_value_id
         (p_effective_date    IN DATE
         ,p_element_name      IN VARCHAR2
	 ,p_input_value       IN VARCHAR2
         )
RETURN NUMBER
IS

   l_input_value_id NUMBER ;
   l_procedure  CONSTANT VARCHAR2(100):= g_package||'get_input_value_id';
   l_message    VARCHAR2(255);
BEGIN
   g_debug := hr_utility.debug_enabled;
   set_location(g_debug, 'Entering: '||l_procedure,10);

   l_input_value_id := get_input_value_id
                             (p_effective_date
                             ,get_element_type_id(p_effective_date, p_element_name)
			     ,p_input_value);

   trace('Input Value Id',l_input_value_id);

   set_location(g_debug, 'Leaving: '||l_procedure,20);
   RETURN l_input_value_id;

EXCEPTION
   WHEN OTHERS THEN
      set_location(g_debug, 'Leaving: '||l_procedure,30);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      trace('SQLERRM',l_message);
      RETURN TO_NUMBER(NULL);
      RAISE ;

END get_input_value_id;

--------------------------------------------------------------------------
-- Name           : GET_TEMPLATE_ID                                     --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION get_template_id
         (p_template_name     IN    VARCHAR2
         )
RETURN NUMBER
IS
   l_template_id   NUMBER;
   l_procedure     VARCHAR2(100):= g_package||'get_template_id';
   l_message       VARCHAR2(1000);
BEGIN
    set_location(g_debug,'Entering: '||l_procedure,10);

    SELECT template_id
    INTO   l_template_id
    FROM   pay_element_templates
    WHERE  template_name = p_template_name
    AND    legislation_code = 'IN';

    trace('Template Id',l_template_id);

    set_location(g_debug,'Leaving: '||l_procedure,20);

    RETURN l_template_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN TO_NUMBER(NULL);
   WHEN OTHERS THEN
      set_location(g_debug, 'Leaving: '||l_procedure,30);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      trace('SQLERRM',l_message);
      RAISE ;

END get_template_id;

--------------------------------------------------------------------------
-- Name           : INS_FORM_RES_RULE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to update element details in post-process --
-- Parameters     :                                                     --
--             IN : p_business_group_id          NUMBER                 --
--                : p_effective_date             DATE                   --
--                : p_status_processing_rule_id  NUMBER                 --
--                : p_result_name                VARCHAR2               --
--                : p_result_rule_type           VARCHAR2               --
--                : p_element_name               VARCHAR2               --
--                : p_input_value_name           VARCHAR2               --
--                : p_severity_level             VARCHAR2               --
--                : p_element_type_id            NUMBER                 --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE ins_form_res_rule
 (
  p_business_group_id          NUMBER,
  p_effective_date             DATE ,
  p_status_processing_rule_id  NUMBER,
  p_result_name                VARCHAR2,
  p_result_rule_type           VARCHAR2,
  p_element_name               VARCHAR2 DEFAULT NULL,
  p_input_value_name           VARCHAR2 DEFAULT NULL,
  p_severity_level             VARCHAR2 DEFAULT NULL,
  p_element_type_id            NUMBER DEFAULT NULL
 )
 IS

   c_end_of_time       CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');
   v_form_res_rule_id  NUMBER;
   l_input_value_id    pay_formula_result_rules_f.input_value_id%TYPE;
   l_element_type_id   pay_element_types_f.element_type_id%TYPE;
   l_procedure         CONSTANT VARCHAR2(100):= g_package||'ins_form_res_rule';
   l_message           VARCHAR2(1000);

BEGIN
   set_location(g_debug,'Entering : '||l_procedure,10);

   IF p_result_rule_type  IN('D','U') THEN

     set_location(g_debug,l_procedure,20);

     l_input_value_id :=
           get_input_value_id(p_effective_date
	                     ,p_element_type_id
			     ,p_input_value_name);

   ELSIF p_result_rule_type  IN ('I') THEN

     set_location(g_debug,l_procedure,30);
     l_element_type_id :=
           get_element_type_id(p_effective_date
	                      ,p_element_name);

     l_input_value_id :=
           get_input_value_id(p_effective_date
	                     ,l_element_type_id
			     ,p_input_value_name);

   END IF;

   set_location(g_debug,l_procedure,40);
   SELECT pay_formula_result_rules_s.nextval
   INTO   v_form_res_rule_id
   FROM   sys.dual;

   set_location(g_debug,l_procedure,50);
   INSERT INTO pay_formula_result_rules_f
   (formula_result_rule_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    status_processing_rule_id,
    result_name,
    result_rule_type,
    severity_level,
    input_value_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date,
    element_type_id)
    VALUES
   (v_form_res_rule_id,
    p_effective_date,
    c_end_of_time,
    p_business_group_id,
    p_status_processing_rule_id,
    upper(p_result_name),
    p_result_rule_type,
    p_severity_level,
    l_input_value_id,
    trunc(sysdate),
    -1,
    -1,
    -1,
    trunc(sysdate),
    decode(p_result_rule_type,
           'D',p_element_type_id,
	   'S',p_element_type_id,
	   'I',l_element_type_id,
	   'U',p_element_type_id,null));

   set_location(g_debug, 'Leaving: '||l_procedure,60);

EXCEPTION
    WHEN OTHERS THEN
      set_location(g_debug, 'Leaving: '||l_procedure,70);
      l_message := get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      trace('SQLERRM',l_message);
      RAISE ;

END ins_form_res_rule;

--------------------------------------------------------------------------
-- Name           : DEL_FORM_RES_RULE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to delete formula setup for elements      --
-- Parameters     :                                                     --
--             IN : p_element_type_id_id         NUMBER                 --
--                : p_effective_date             DATE                   --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE del_form_res_rule
        (p_element_type_id   IN  NUMBER,
	 p_effective_date    IN  DATE
        )
IS
   CURSOR csr_sr IS
      SELECT rowid
            ,status_processing_rule_id
            ,effective_start_date
      FROM   pay_status_processing_rules_f psr
      WHERE  psr.element_type_id = p_element_type_id
      AND    p_effective_date BETWEEN psr.effective_start_date
                              AND     psr.effective_end_date;

   CURSOR csr_fr (p_status_rule_id IN NUMBER )
   IS
      SELECT ROWID
            ,formula_result_rule_id
            ,effective_start_date
      FROM   pay_formula_result_rules_f
      WHERE  status_processing_rule_id = p_status_rule_id
      AND    p_effective_date BETWEEN effective_start_date
                              AND     effective_end_date;

   l_procedure         CONSTANT VARCHAR2(100):= g_package||'del_form_res_rule';
   l_message           VARCHAR2(1000);

BEGIN

   set_location(g_debug,'Entering : '||l_procedure,10);
   FOR j IN csr_sr
   LOOP
      set_location(g_debug,l_procedure,20);

      IF g_debug THEN
         trace('Status Rule Id  ',j.status_processing_rule_id);
         trace('Effective Date  ',to_char(j.effective_start_date,'DD-Mon-YYYY'));
      END IF ;

      FOR k IN csr_fr(j.status_processing_rule_id)
      LOOP

        set_location(g_debug,l_procedure,30);

        IF g_debug THEN
           trace('Result Rule Id  ',k.formula_result_rule_id);
           trace('Effective Date  ',to_char(k.effective_start_date,'DD-Mon-YYYY'));
        END IF ;

        pay_formula_result_rules_pkg.delete_row(k.rowid);

        set_location(g_debug,l_procedure,40);

      END LOOP ; -- csr_fr ends

      set_location(g_debug,l_procedure,50);

      pay_status_rules_pkg.delete_row
          ( x_rowid                        => j.rowid
          , p_session_date                 => j.effective_start_date
          , p_delete_mode                  => hr_api.g_zap
          , p_status_processing_rule_id    => j.status_processing_rule_id
          );

      set_location(g_debug,l_procedure,60);

   END LOOP; -- csr_sr ends
   set_location(g_debug,'Leaving : '||l_procedure,70);

END del_form_res_rule;

--------------------------------------------------------------------------
-- Name           : DELETE_BALANCE_FEEDS                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE delete_balance_feeds
         (p_balance_name     IN    VARCHAR2
	 ,p_element_name     IN    VARCHAR2
	 ,p_input_value_name IN    VARCHAR2
	 ,p_effective_date   IN    DATE
         )
IS

    CURSOR csr_bf IS
       SELECT balance_feed_id, object_version_number
       FROM   pay_balance_feeds_f
       WHERE  balance_type_id = get_balance_type_id (p_balance_name)
       AND    input_value_id = get_input_value_id (p_effective_date, p_element_name, p_input_value_name)
       AND    p_effective_date BETWEEN effective_start_Date AND effective_end_date;

    l_bf_id   NUMBER ;
    l_ovn     NUMBER ;
    l_start   DATE ;
    l_end     DATE ;
    l_warn    BOOLEAN ;
   l_procedure         CONSTANT VARCHAR2(100):= g_package||'delete_balance_feeds';
   l_message           VARCHAR2(1000);

BEGIN

   set_location(g_debug,'Entering : '||l_procedure,10);

   OPEN csr_bf;
   FETCH csr_bf INTO l_bf_id, l_ovn;
   IF csr_bf%NOTFOUND THEN
      set_location(g_debug,'Leaving : '||l_procedure,15);
      RETURN ;
   END IF ;
   CLOSE csr_bf;
   set_location(g_debug,l_procedure,20);

   pay_balance_feeds_api.delete_balance_feed
    (
       p_effective_date               => p_effective_date
      ,p_datetrack_delete_mode        => hr_api.g_delete
      ,p_balance_feed_id              => l_bf_id
      ,p_object_version_number        => l_ovn
      ,p_effective_start_date         => l_start
      ,p_effective_end_date           => l_end
      ,p_exist_run_result_warning     => l_warn
    );

   set_location(g_debug,'Leaving : '||l_procedure,30);

END delete_balance_feeds;

--------------------------------------------------------------------------
-- Name           : GET_PERSON_NAME                                     --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the person name based on person id--
-- Parameters     :                                                     --
--             IN : p_person_id       IN  NUMBER                        --
--                : p_effective_date  IN  DATE                          --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_person_name
         (p_person_id      IN NUMBER
         ,p_effective_date IN DATE
         )
RETURN VARCHAR2
IS
   CURSOR c_person_name
   IS
      SELECT full_name
        FROM per_people_f
       WHERE person_id = p_person_id
         AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_full_name      per_all_people_f.full_name%TYPE;
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'get_person_name';

BEGIN
    set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  c_person_name;
    FETCH c_person_name INTO l_full_name;
    CLOSE c_person_name;

    set_location(g_debug,l_procedure,20);

    IF g_debug THEN
       trace('Full Name is ',l_full_name);
    END IF ;
    set_location(g_debug,'Leaving : '||l_procedure,30);

    RETURN l_full_name;
END get_person_name;

--------------------------------------------------------------------------
-- Name           : GET_ORGANIZATION_NAME                               --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the organization name             --
-- Parameters     :                                                     --
--             IN : p_organization_id IN  NUMBER                        --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_organization_name
         (p_organization_id      IN NUMBER
         )
RETURN VARCHAR2
IS
   CURSOR c_organization_name
   IS
      SELECT name
        FROM hr_organization_units
       WHERE organization_id = p_organization_id;

   l_org_name           hr_organization_units.name%TYPE;
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'get_organization_name';

BEGIN
    set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  c_organization_name;
    FETCH c_organization_name INTO l_org_name;
    CLOSE c_organization_name;

    set_location(g_debug,l_procedure,20);

    IF g_debug THEN
       trace('Full Name is ',l_org_name);
    END IF ;
    set_location(g_debug,'Leaving : '||l_procedure,30);

    RETURN l_org_name;
END get_organization_name;

--------------------------------------------------------------------------
-- Name           : GET_PAYMENT_NAME                                    --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the payment method name           --
-- Parameters     :                                                     --
--             IN : P_PAYMENT_TYPE_ID IN  NUMBER                        --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_payment_name
         (p_payment_type_id      IN NUMBER
         )
RETURN VARCHAR2
IS
   CURSOR c_payment_method_name
   IS
      SELECT pptl.payment_type_name
        FROM pay_payment_types ppt
            ,pay_payment_types_tl pptl
       WHERE ppt.payment_type_id = pptl.payment_type_id
         AND ppt.territory_code = 'IN'
         AND ppt.category <> 'MT'
         AND pptl.language = USERENV('LANG')
         AND ppt.payment_type_id = p_payment_type_id;

   l_payment_mthd_name  pay_payment_types_tl.payment_type_name%TYPE;
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'get_payment_name';
BEGIN
    set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  c_payment_method_name;
    FETCH c_payment_method_name INTO l_payment_mthd_name;
    CLOSE c_payment_method_name;

    set_location(g_debug,l_procedure,20);

    IF g_debug THEN
       trace('Payment Method Name is ',l_payment_mthd_name);
    END IF ;
    set_location(g_debug,'Leaving : '||l_procedure,30);

    RETURN l_payment_mthd_name;

END get_payment_name;

--------------------------------------------------------------------------
-- Name           : GET_BANK_NAME                                       --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the bank name                     --
-- Parameters     :                                                     --
--             IN : p_org_information_id IN  NUMBER                     --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_bank_name
         (p_org_information_id   IN NUMBER
         )
RETURN VARCHAR2
IS
   CURSOR c_bank_name
   IS
      SELECT hr_general.decode_lookup('IN_BANK',org_information1)
        FROM hr_organization_information
       WHERE org_information_context = 'PER_IN_CHALLAN_BANK'
         AND org_information_id = p_org_information_id;

   l_bank_name          VARCHAR2(300);
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'get_bank_name';
BEGIN
    set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  c_bank_name;
    FETCH c_bank_name INTO l_bank_name;
    CLOSE c_bank_name;

    set_location(g_debug,l_procedure,20);

    IF g_debug THEN
       trace('Bank Name is ',l_bank_name);
    END IF ;
    set_location(g_debug,'Leaving : '||l_procedure,30);

    RETURN l_bank_name;

END get_bank_name;

--------------------------------------------------------------------------
-- Name           : GET_ADDR_DFF_DETAILS                                --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the segments of 'Personal Address --
--                : ' Information' DFF for IN localization.             --
-- Parameters     :                                                     --
--             IN : p_address_id    IN  NUMBER                          --
--                : p_segment_no    IN  VARCHAR2                        --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_addr_dff_details
         (p_address_id   IN NUMBER
         ,p_segment_no   IN VARCHAR2
         )
RETURN VARCHAR2
IS
   CURSOR c_personal_addr_dff_details
   IS
      SELECT DECODE(p_segment_no,'1',add_information13
                                ,'2',add_information14
                                ,'3',hr_general.decode_lookup('IN_STATES',add_information15)
                                ,hr_general.decode_lookup('YES_NO',add_information16)
                   )
         FROM per_addresses
        WHERE address_id = p_address_id
          AND style = 'IN';

   l_seg_value          VARCHAR2(300);
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'get_addr_dff_details';
BEGIN
    set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  c_personal_addr_dff_details;
    FETCH c_personal_addr_dff_details INTO l_seg_value;
    CLOSE c_personal_addr_dff_details;

    set_location(g_debug,l_procedure,20);

    IF g_debug THEN
       trace('Segment Value  is ',l_seg_value);
    END IF ;
    set_location(g_debug,'Leaving : '||l_procedure,30);

    RETURN l_seg_value;

END get_addr_dff_details;

--------------------------------------------------------------------------
-- Name           : GET_ARCHIVE_REF_NUM                                 --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the form 24Q or 24QC ref number.  --
-- Parameters     :                                                     --
--             IN : p_year               IN VARCHAR2                    --
--                : p_quarter            IN VARCHAR2                    --
--                : p_return_type        IN VARCHAR2                    --
--                : p_organization_id    IN NUMBER                      --
--                : p_action_context_id  IN NUMBER                      --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_archive_ref_num
         (p_year               IN VARCHAR2,
          p_quarter            IN VARCHAR2,
          p_return_type        IN VARCHAR2,
          p_organization_id    IN NUMBER,
          p_action_context_id  IN NUMBER
         )
RETURN VARCHAR2
IS
   CURSOR c_archive_ref_number
   IS
      SELECT action_information30
        FROM pay_action_information
       WHERE action_information3 = p_year || p_quarter
         AND action_context_type = 'PA'
         AND action_information_category  = DECODE(p_return_type,'O','IN_24Q_ORG','IN_24QC_ORG')
         AND action_information30 IS NOT NULL
         AND action_information1 = p_organization_id
         AND action_context_id   = p_action_context_id
      ORDER BY action_information30 DESC;

   l_archive_ref_number          VARCHAR2(300);
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'get_archive_ref_num';
BEGIN
    set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  c_archive_ref_number;
    FETCH c_archive_ref_number INTO l_archive_ref_number;
    CLOSE c_archive_ref_number;

    set_location(g_debug,l_procedure,20);

    IF g_debug THEN
       trace('Archive Reference Number is ',l_archive_ref_number);
    END IF ;
    set_location(g_debug,'Leaving : '||l_procedure,30);

    RETURN l_archive_ref_number;

END get_archive_ref_num;

--------------------------------------------------------------------------
-- Name           : get_processing_type                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get processing type                     --
--                  (Non-recurring/Recurring) of an element             --
-- Parameters     :                                                     --
--             IN :   p_element_type_id   NUMBER                        --
--                    p_business_group_id NUMBER                        --
--                    p_earned_date       DATE                          --
--------------------------------------------------------------------------
FUNCTION get_processing_type
    (p_element_type_id          IN NUMBER
    ,p_business_group_id        IN NUMBER
    ,p_earned_date              IN DATE
    )
RETURN VARCHAR IS

   CURSOR c_processing_type IS
     SELECT processing_type
       FROM pay_element_types_f
      WHERE element_type_id = p_element_type_id
        AND business_group_id = p_business_group_id
	AND p_earned_date BETWEEN effective_start_date AND effective_end_date;

    l_processing_type VARCHAR2(5);
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'get_processing_type';

BEGIN

   set_location(g_debug,'Entering : '||l_procedure,10);

   IF (g_debug)THEN
        trace('**************************************************','********************');
        set_location(g_debug,'Input Paramters value is',20);
        trace('p_element_type_id',p_element_type_id);
        trace('p_business_group_id',p_business_group_id);
        trace('p_earned_date',p_earned_date);
        trace('**************************************************','********************');
   END IF;

  OPEN c_processing_type;
  FETCH c_processing_type INTO l_processing_type;
  CLOSE c_processing_type;

   IF (g_debug)THEN
        trace('**************************************************','********************');
        trace('l_processing_type  is ',l_processing_type);
        trace('**************************************************','********************');
   END IF;

   set_location(g_debug,'Leaving : '||l_procedure,30);
   RETURN l_processing_type;

END get_processing_type;

--------------------------------------------------------------------------
-- Name           : chk_business_group                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to check the business group as per the     --
--                : profile value.                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id IN  NUMBER                          --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION chk_business_group
         (p_assignment_id   IN NUMBER
         )
RETURN NUMBER
IS
   CURSOR c_asg_bg_id
   IS
      SELECT 1
        FROM per_assignments_f
       WHERE assignment_id = p_assignment_id
         AND business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
       ORDER BY effective_end_date DESC;

   l_bg_flag            NUMBER := -1;
   l_procedure          CONSTANT VARCHAR2(100):= g_package ||'chk_business_group';
BEGIN
    set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  c_asg_bg_id;
    FETCH c_asg_bg_id INTO l_bg_flag;
    CLOSE c_asg_bg_id;

    set_location(g_debug,l_procedure,20);

    IF g_debug THEN
       trace('l_bg_flag  is ',l_bg_flag);
    END IF ;

    IF (l_bg_flag = -1)
    THEN
       set_location(g_debug,'Leaving : '||l_procedure,35);
       RETURN -1;
    ELSE
       set_location(g_debug,'Leaving : '||l_procedure,40);
       RETURN p_assignment_id;
    END IF;
END chk_business_group;

--------------------------------------------------------------------------
-- Name           : GET_SECONDARY_CLASSIFICATION                        --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the secondary classification      --
-- Parameters     :                                                     --
--             IN : p_element_type_id     NUMBER                        --
--            OUT : p_date_earned         DATE                          --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_secondary_classification
         (p_element_type_id     NUMBER
         ,p_date_earned         DATE
         )
RETURN NUMBER
IS
   CURSOR c_element_sec_classification
   IS
      SELECT DECODE(pec.classification_name
                   ,'Monetary Perquisite',1
                   ,'Non Monetary Perquisite',2
                   ,-1
                   )
      FROM   pay_sub_classification_rules_f pscr
            ,pay_element_classifications pec
      WHERE  pscr.classification_id = pec.classification_id
      AND    pec.parent_classification_id =
                  (SELECT classification_id FROM pay_element_classifications
                    WHERE classification_name = 'Perquisites'
                      AND legislation_code = 'IN'
                  )
      AND   element_type_id = p_element_type_id
      AND   p_date_earned BETWEEN pscr.effective_start_date
      AND   pscr.effective_end_date;

      l_sec_classification      NUMBER;
BEGIN
   OPEN  c_element_sec_classification;
   FETCH c_element_sec_classification INTO l_sec_classification;
   CLOSE c_element_sec_classification;

   RETURN l_sec_classification;
END get_secondary_classification;

--------------------------------------------------------------------------
-- Name           : GET_CONFIGURATION_INFO                              --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the configuartion information    --
-- Parameters     :                                                     --
--             IN : p_element_type_id     NUMBER                        --
--            OUT : p_date_earned         DATE                          --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_configuration_info
         (p_element_type_id     NUMBER
         ,p_date_earned         DATE
         )
RETURN VARCHAR2
IS
   CURSOR c_config_info
   IS
      SELECT pet.configuration_information2
        FROM pay_element_types_f      pee
            ,pay_element_templates    pet
            ,pay_shadow_element_types pset
       WHERE pee.element_type_id   = p_element_type_id
         AND pee.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND pee.element_name      = pset.element_name
         AND pset.template_id      = pet.template_id
         AND p_date_earned BETWEEN pee.effective_start_date AND pee.effective_end_date;

   l_config_info pay_element_templates.configuration_information2%TYPE;

   BEGIN
        OPEN  c_config_info;
        FETCH c_config_info INTO l_config_info;
        CLOSE c_config_info;
        RETURN l_config_info;
   END get_configuration_info;
--------------------------------------------------------------------------
-- Name           : GET_ELEMENT_ENTRY_END_DATE                          --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the element entry date           --
-- Parameters     :                                                     --
--             IN : p_element_entry_id    NUMBER                        --
--         RETURN : DATE                                                --
--------------------------------------------------------------------------
FUNCTION get_element_entry_end_date
         (p_element_entry_id     NUMBER
         )
RETURN DATE
IS
   CURSOR c_get_ee_end_date
   IS
      SELECT effective_end_date
        FROM pay_element_entries_f
       WHERE element_entry_id = p_element_entry_id;

   l_ee_end_date   pay_element_entries_f.effective_end_date%TYPE;
BEGIN
   OPEN  c_get_ee_end_date;
   FETCH c_get_ee_end_date INTO l_ee_end_date;
   CLOSE c_get_ee_end_date;

   RETURN l_ee_end_date;
END get_element_entry_end_date;

--------------------------------------------------------------------------
-- Name           : GET_CONTACT_RELATIONSHIP                            --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the relationship between 2 person              --
-- Parameters     :                                                     --
--             IN : p_asg_id    NUMBER                                  --
--                : p_contact_person_id NUMBER                          --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------
FUNCTION get_contact_relationship
         (p_asg_id     NUMBER
	 ,p_contact_person_id NUMBER
         )
RETURN VARCHAR2
IS
   CURSOR c_relationship
   IS
   SELECT hr_general.decode_lookup('CONTACT',RELATION.CONTACT_TYPE)
     FROM per_contact_relationships relation,
          per_all_people_f ppf,
	  per_all_assignments_f asg
    WHERE relation.contact_person_id = p_contact_person_id
      AND relation.person_id = ppf.person_id
      AND asg.person_id = ppf.person_id
      AND asg.assignment_id = p_asg_id
      AND SYSDATE >= relation.date_start
      AND SYSDATE BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND SYSDATE BETWEEN ppf.effective_start_date AND ppf.effective_end_date;


   l_relation   hr_lookups.meaning%TYPE;
   l_emp_person_id NUMBER;


BEGIN
l_emp_person_id := get_person_id(p_asg_id,SYSDATE);
IF (l_emp_person_id = p_contact_person_id) THEN
  l_relation := 'Self';
ELSE
   OPEN  c_relationship;
   FETCH c_relationship INTO l_relation;
   CLOSE c_relationship;
END IF;
   RETURN l_relation;
END get_contact_relationship;

--------------------------------------------------------------------------
-- Name           : GET_HIRE_DATE                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the hiredate of a  assignment                  --
-- Parameters     :                                                     --
--             IN : p_assignment_id    NUMBER                           --
--         RETURN : DATE                                                --

--------------------------------------------------------------------------
FUNCTION get_hire_date(p_assignment_id NUMBER)
RETURN DATE
IS
CURSOR csr_hire_date
IS
SELECT MAX(pos.date_start)
   FROM per_periods_of_service pos
       ,per_people_f ppf
       ,per_assignments_f paf
  WHERE pos.person_id = ppf.person_id
    AND ppf.person_id = paf.person_id
	AND pos.date_start between paf.effective_start_date and paf.effective_end_date
	AND paf.assignment_id = p_assignment_id;

l_hire_date DATE;

BEGIN
  OPEN  csr_hire_date;
  FETCH csr_hire_date INTO l_hire_date;
  CLOSE csr_hire_date;

   RETURN l_hire_date;
END get_hire_date;

--------------------------------------------------------------------------
-- Name           : GET_POSITION_NAME                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the position of a  assignment                  --
-- Parameters     :                                                     --
--             IN : p_assignment_id    NUMBER                           --
--             IN : p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------
FUNCTION get_position_name
         (p_assignment_id     NUMBER
	 ,p_effective_date DATE
         )
RETURN VARCHAR2
IS
  CURSOR csr_positions
  IS
  SELECT pos.name
    FROM per_positions pos,
         per_assignments_f asg
   WHERE pos.position_id = asg.position_id
     AND asg.assignment_id = p_assignment_id
     AND p_effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date;

l_position per_positions.name%TYPE;

BEGIN
  OPEN csr_positions;
  FETCH csr_positions INTO l_position;
  CLOSE csr_positions;

  RETURN l_position;

END get_position_name;

--------------------------------------------------------------------------
-- Name           : GET_AGE                                             --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the age of a person as on a date               --
-- Parameters     :                                                     --
--             IN : p_person_id        NUMBER                           --
--                : p_effective_date   DATE                             --
--         RETURN : NUMBER                                              --

--------------------------------------------------------------------------

FUNCTION get_age(p_person_id in number
                ,p_effective_date in date)
RETURN NUMBER
IS

Cursor c_dob is
  select ppf.date_of_birth
    from per_people_f ppf
   where ppf.person_id = p_person_id
     and p_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date;

l_dob date;
l_age number;

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_age';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_person_id',p_person_id);
        pay_in_utils.trace('p_effective_date',p_effective_date);
   END IF;


  Open c_dob;
  Fetch c_dob into l_dob;
  Close c_dob;


  l_age := trunc((p_effective_date - l_dob)/365);

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_age',l_age);
   END IF;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  Return l_age;

END get_age;

--------------------------------------------------------------------------
-- Name           : GET_LTC_BLOCK                                       --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the current LTC Block                          --
-- Parameters     :                                                     --
--             IN : p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------

FUNCTION get_ltc_block
         (p_effective_date DATE
         )
RETURN VARCHAR2
IS
  CURSOR csr_ltc_block
  IS
  SELECT lookup_code
  FROM hr_lookups hrl
 WHERE HRL.lookup_type = 'IN_LTC_BLOCK'
   AND p_effective_date BETWEEN TO_DATE(SUBSTR(HRL.MEANING,1,11),'DD-MM-YYYY')
                   AND TO_DATE(SUBSTR(HRL.MEANING,15,11),'DD-MM-YYYY');

l_ltc_block hr_lookups.lookup_code%TYPE;

BEGIN
  OPEN csr_ltc_block;
  FETCH csr_ltc_block INTO l_ltc_block;
  CLOSE csr_ltc_block;
  RETURN l_ltc_block;

END get_ltc_block;

--------------------------------------------------------------------------
-- Name           : GET_PREV_LTC_BLOCK                                  --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the previous LTC Block                         --
-- Parameters     :                                                     --
--             IN : p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------

FUNCTION get_prev_ltc_block
         (p_effective_date DATE
         )
RETURN VARCHAR2
IS
  CURSOR csr_ltc_block(l_effective_date DATE)
  IS
  SELECT lookup_code
  FROM hr_lookups hrl
 WHERE HRL.lookup_type = 'IN_LTC_BLOCK'
   AND l_effective_date BETWEEN TO_DATE(SUBSTR(HRL.MEANING,1,11),'DD-MM-YYYY')
                   AND TO_DATE(SUBSTR(HRL.MEANING,15,11),'DD-MM-YYYY');

l_ltc_block hr_lookups.lookup_code%TYPE;
l_effective_date DATE;

BEGIN
  l_effective_date := add_months(p_effective_date,-48);

  OPEN csr_ltc_block(l_effective_date);
  FETCH csr_ltc_block INTO l_ltc_block;
  CLOSE csr_ltc_block;
  RETURN l_ltc_block;

END get_prev_ltc_block;

BEGIN
  g_package := 'pay_in_utils.';

END pay_in_utils;

/
