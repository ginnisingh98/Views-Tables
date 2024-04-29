--------------------------------------------------------
--  DDL for Package Body PAY_JP_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_BALANCE_PKG" AS
/* $Header: pyjpblnc.pkb 120.1.12000000.3 2007/05/21 08:28:49 keyazawa noship $ */
--
-- Cache the action parameter
--
cached       boolean  := FALSE;
g_low_volume pay_action_parameters.parameter_value%type := 'N';
--
--===============================================================================
  FUNCTION get_business_group_id(p_assignment_action_id IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
--===============================================================================
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;

    CURSOR get_business_group_id IS
      select /*+ ORDERED
                 USE_NL(PAA, PPA)
                 INDEX(PAY_ASSIGNMENT_ACTIONS_PK PAA)
                 INDEX(PAY_PAYROLL_ACTIONS_PK PPA) */
            ppa.business_group_id
      from  pay_assignment_actions  paa,
            pay_payroll_actions ppa
      where paa.assignment_action_id = p_assignment_action_id
      and ppa.payroll_action_id = paa.payroll_action_id;
  BEGIN
    OPEN get_business_group_id;
    FETCH get_business_group_id INTO l_business_group_id;
    if get_business_group_id%NOTFOUND then
      l_business_group_id := NULL;
    end if;
    CLOSE get_business_group_id;

    return l_business_group_id;
  END get_business_group_id;
--
--===============================================================================
  FUNCTION get_business_group_id(
      p_assignment_id   IN PER_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE,
      p_effective_date  IN DATE)
--===============================================================================
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;

    CURSOR get_business_group_id IS
      select  /*+ INDEX(PER_ASSIGNMENTS_F_PK PA) */
              pa.business_group_id
      from  per_assignments_f pa
      where pa.assignment_id = p_assignment_id
      and p_effective_date
        between pa.effective_start_date and pa.effective_end_date;
  BEGIN
    OPEN get_business_group_id;
    FETCH get_business_group_id INTO l_business_group_id;
    if get_business_group_id%NOTFOUND then
      l_business_group_id := NULL;
    end if;
    CLOSE get_business_group_id;

    return l_business_group_id;
  END get_business_group_id;
--
--===============================================================================
  FUNCTION get_legislation_code(p_business_group_id IN PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE)
--===============================================================================
  RETURN VARCHAR2
  IS
    l_legislation_code  PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;

    CURSOR get_legislation_code IS
      select  pbg.legislation_code
      from  per_business_groups pbg
      where pbg.business_group_id = p_business_group_id;
  BEGIN
    OPEN get_legislation_code;
    FETCH get_legislation_code INTO l_legislation_code;
    if get_legislation_code%NOTFOUND then
      l_legislation_code := NULL;
    end if;
    CLOSE get_legislation_code;

    return l_legislation_code;
  END get_legislation_code;
--
--===============================================================================
  PROCEDURE get_element_input_id(
    p_element_name    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    p_input_value_name  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    p_business_group_id IN PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE,
    p_element_type_id IN OUT NOCOPY NUMBER,
    p_input_value_id  IN OUT NOCOPY NUMBER)
--===============================================================================
  IS
    l_legislation_code  PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;
  BEGIN
    l_legislation_code:=get_legislation_code(p_business_group_id);
    if l_legislation_code is NULL then
      p_element_type_id:=NULL;
      p_input_value_id:=NULL;
      raise NO_DATA_FOUND;
    end if;

    p_element_type_id:=get_element_type_id(p_element_name,p_business_group_id,l_legislation_code);
    if p_element_type_id is NULL then
      p_input_value_id:=NULL;
      raise NO_DATA_FOUND;
    end if;

    p_input_value_id:=get_input_value_id(p_element_type_id,p_input_value_name);
    if p_input_value_id is NULL then
      p_element_type_id:=NULL;
      p_input_value_id:=NULL;
      raise NO_DATA_FOUND;
    end if;
  EXCEPTION
    when NO_DATA_FOUND then
      NULL;
  END get_element_input_id;
--
--===============================================================================
  FUNCTION get_defined_balance_id(p_balance_name    IN PAY_BALANCE_TYPES.BALANCE_NAME%TYPE,
          p_dimension_name  IN PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE,
          p_business_group_id IN PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE)
--===============================================================================
  RETURN NUMBER
  IS
    l_defined_balance_id  NUMBER;
    l_legislation_code  PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;

    CURSOR get_defined_balance_id IS
      select  /*+ ORDERED
                 USE_NL(PBT, PDB, PBD)
                 INDEX(PAY_BALANCE_TYPES_UK2 PBT)
                 INDEX(PAY_DEFINED_BALANCES_UK2 PDB)
                 INDEX(PAY_BALANCE_DIMENSIONS_PK PBD) */
            pdb.defined_balance_id
      from  pay_balance_types pbt,
            pay_defined_balances  pdb,
            pay_balance_dimensions  pbd
      where pbt.balance_name = p_balance_name
      and nvl(pbt.business_group_id,p_business_group_id) = p_business_group_id
      and nvl(pbt.legislation_code,l_legislation_code) = l_legislation_code
      and pbd.dimension_name = p_dimension_name
      and nvl(pbd.business_group_id,p_business_group_id) = p_business_group_id
      and nvl(pbd.legislation_code,l_legislation_code) = l_legislation_code
      and pdb.balance_type_id = pbt.balance_type_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id;

  BEGIN
    l_legislation_code := get_legislation_code(p_business_group_id);
    if l_legislation_code is NULL then
      return NULL;
    end if;

    OPEN get_defined_balance_id;
    FETCH get_defined_balance_id INTO l_defined_balance_id;
    if get_defined_balance_id%NOTFOUND then
      l_defined_balance_id := NULL;
    end if;
    CLOSE get_defined_balance_id;

    return l_defined_balance_id;
  END get_defined_balance_id;

--===============================================================================
  FUNCTION GET_BALANCE_TYPE_ID(
    p_balance_name    IN PAY_BALANCE_TYPES.BALANCE_NAME%TYPE,
    p_business_group_id IN PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE,
    p_legislation_code  IN PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE)
--===============================================================================
  RETURN NUMBER
  IS
    l_balance_type_id NUMBER;

    CURSOR cur_balance_type_id IS
      select  /*+ INDEX(PAY_BALANCE_TYPES_UK2 PBT) */
            pbt.balance_type_id
      from  pay_balance_types pbt
      where pbt.balance_name = p_balance_name
      and nvl(pbt.business_group_id,p_business_group_id) = p_business_group_id
      and nvl(pbt.legislation_code,p_legislation_code) = p_legislation_code;
  BEGIN
    OPEN cur_balance_type_id;
    FETCH cur_balance_type_id INTO l_balance_type_id;
    if cur_balance_type_id%NOTFOUND then
      l_balance_type_id := NULL;
    end if;
    CLOSE cur_balance_type_id;

    return l_balance_type_id;
  END GET_BALANCE_TYPE_ID;

--------------------------------------------------------------
--               GET_BALANCE_VALUE (action mode)            --
--------------------------------------------------------------
  FUNCTION GET_BALANCE_VALUE(
    P_BALANCE_NAME    IN PAY_BALANCE_TYPES.BALANCE_NAME%TYPE,
    P_DIMENSION_NAME  IN PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE,
    P_ASSIGNMENT_ACTION_ID  IN NUMBER)
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_defined_balance_id  PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
    l_result_value    NUMBER;
  BEGIN
    l_result_value := 0;

    l_business_group_id := get_business_group_id(p_assignment_action_id);
    if l_business_group_id is NULL then
      return l_result_value;
    end if;

    l_defined_balance_Id := get_defined_balance_id(p_balance_name,p_dimension_name,l_business_group_id);
    if l_defined_balance_id is NULL then
      return l_result_value;
    end if;

    l_result_value := get_balance_value(
          l_defined_balance_id,
          p_assignment_action_id);

    return l_result_value;
  END GET_BALANCE_VALUE;

--------------------------------------------------------------
--               GET_BALANCE_VALUE (action mode)            --
--------------------------------------------------------------
  FUNCTION GET_BALANCE_VALUE(
    P_DEFINED_BALANCE_ID  IN NUMBER,
    P_ASSIGNMENT_ACTION_ID  IN NUMBER)
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_defined_balance_id  PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
    l_result_value    NUMBER;
  BEGIN
    l_result_value := 0;

    l_result_value := pay_balance_pkg.get_value(
            p_defined_balance_id,
            p_assignment_action_id);

    return l_result_value;
  END GET_BALANCE_VALUE;

-------------------------------------------------------------
--               GET_BALANCE_VALUE (date mode)             --
-------------------------------------------------------------
  FUNCTION GET_BALANCE_VALUE(
    P_BALANCE_NAME    IN PAY_BALANCE_TYPES.BALANCE_NAME%TYPE,
    P_DIMENSION_NAME  IN PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE,
    P_ASSIGNMENT_ID   IN NUMBER,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_defined_balance_id  PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
    l_result_value    NUMBER;
  BEGIN
    l_result_value := 0;

    l_business_group_id := get_business_group_id(p_assignment_id,p_effective_date);
    if l_business_group_id is NULL then
      return l_result_value;
    end if;

    l_defined_balance_Id := get_defined_balance_id(p_balance_name,p_dimension_name,l_business_group_id);
    if l_defined_balance_id is NULL then
      return l_result_value;
    end if;

    l_result_value := get_balance_value(
          l_defined_balance_id,
          p_assignment_id,
          p_effective_date);

    return l_result_value;
  END GET_BALANCE_VALUE;

-------------------------------------------------------------
--               GET_BALANCE_VALUE (date mode)             --
-------------------------------------------------------------
  FUNCTION GET_BALANCE_VALUE(
    P_DEFINED_BALANCE_ID  IN NUMBER,
    P_ASSIGNMENT_ID   IN NUMBER,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN NUMBER
  IS
    l_result_value    NUMBER;
  BEGIN
    l_result_value := 0;

    -- If the specified assignment is not linked to payroll,
    -- pay_balance_pkg causes no_data_found at line 1262.
    BEGIN
      l_result_value := pay_balance_pkg.get_value(
              p_defined_balance_id,
              p_assignment_id,
              p_effective_date);
    EXCEPTION
      WHEN no_data_found THEN
        l_result_value := 0;
    END;

    return l_result_value;
  END GET_BALANCE_VALUE;

-------------------------------------------------------------
-- GET_BALANCE_VALUE_ASG_RUN (for _ASG_RUN dimension only) --
-------------------------------------------------------------
  FUNCTION GET_BALANCE_VALUE_ASG_RUN(
    P_BALANCE_TYPE_ID IN NUMBER,
    P_ASSIGNMENT_ACTION_ID  IN NUMBER)
  RETURN NUMBER
  IS
    l_result_value  NUMBER;
    l_defined_balance_id PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
    CURSOR cur_balance_value_asg_run IS
      SELECT /*+ ORDERED
                 USE_NL(ASSACT, PACT, FEED, RR, TARGET)
                 INDEX(PAY_ASSIGNMENT_ACTIONS_PK ASSACT)
                 INDEX(PAY_PAYROLL_ACTIONS_PK PACT)
                 INDEX(PAY_BALANCE_FEEDS_F_FK1 FEED)
                 INDEX(PAY_RUN_RESULTS_N50 RR)
                 INDEX(PAY_RUN_RESULT_VALUES_PK TARGET) */
             nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0)
      FROM  pay_assignment_actions  ASSACT,
            pay_payroll_actions PACT,
            pay_balance_feeds_f FEED,
            pay_run_results   RR,
            pay_run_result_values TARGET
      where ASSACT.assignment_action_id = p_assignment_action_id
      and PACT.payroll_action_id = ASSACT.payroll_action_id
      and RR.assignment_action_id = ASSACT.assignment_action_id
      and RR.status in ('P','PA')
      and TARGET.run_result_id = RR.run_result_id
      and FEED.input_value_id = TARGET.input_value_id
      and FEED.balance_type_id = p_balance_type_id
      and PACT.effective_date between
        FEED.effective_start_date and FEED.effective_end_date;

    CURSOR cur_balance_value_asg_run_rule IS
-- =============================================================================
-- Fix bug#3331016: Removed RULE hint from statement.
-- -----------------------------------------------------------------------------
     SELECT /*+ ORDERED
                USE_NL(ASSACT, PACT, FEED, RR, TARGET)
                INDEX(PAY_ASSIGNMENT_ACTIONS_PK ASSACT)
                INDEX(PAY_PAYROLL_ACTIONS_PK PACT)
                INDEX(PAY_BALANCE_FEEDS_F_FK1 FEED)
                INDEX(PAY_RUN_RESULTS_N50 RR)
                INDEX(PAY_RUN_RESULT_VALUES_PK TARGET) */
            nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0)
      FROM
        pay_assignment_actions  ASSACT,
        pay_payroll_actions PACT,
        pay_balance_feeds_f FEED,
        pay_run_results   RR,
        pay_run_result_values TARGET
      where ASSACT.assignment_action_id = p_assignment_action_id
      and PACT.payroll_action_id = ASSACT.payroll_action_id
      and RR.assignment_action_id = ASSACT.assignment_action_id
      and RR.status in ('P','PA')
      and TARGET.run_result_id = RR.run_result_id
      and FEED.input_value_id = TARGET.input_value_id
      and FEED.balance_type_id = p_balance_type_id
      and PACT.effective_date between
        FEED.effective_start_date and FEED.effective_end_date;
  BEGIN
    --
    -- Use Rule hint on balances if LOW_VOLUME pay_action_paremeter set
    --
    l_defined_balance_id := pay_jp_balance_pkg.get_defined_balance_id (p_balance_type_id,p_assignment_action_id);
    if (cached = FALSE) then
      cached := TRUE;
      begin
        select parameter_value
        into g_low_volume
        from pay_action_parameters
        where parameter_name = 'LOW_VOLUME';
        exception
        when others then
        g_low_volume := 'N';
      end;
    end if;
    IF l_defined_balance_id is not null THEN
     l_result_value := pay_balance_pkg.get_value(l_defined_balance_id, p_assignment_action_id);
    ELSE
     if (g_low_volume = 'Y') then
       OPEN cur_balance_value_asg_run_rule;
       FETCH cur_balance_value_asg_run_rule INTO l_result_value;
       if cur_balance_value_asg_run_rule%NOTFOUND then
         l_result_value := 0;
       end if;
        CLOSE cur_balance_value_asg_run_rule;
     else
       OPEN cur_balance_value_asg_run;
       FETCH cur_balance_value_asg_run INTO l_result_value;
       if cur_balance_value_asg_run%NOTFOUND then
         l_result_value := 0;
       end if;
       CLOSE cur_balance_value_asg_run;
     end if;
    END IF;
    return l_result_value;
  END GET_BALANCE_VALUE_ASG_RUN;

-----------------------------------------------------------
--               GET_RESULT_VALUE_PAY_VALUE              --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_PAY_VALUE(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_ASSIGNMENT_ACTION_ID  IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_element_type_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    l_input_value_id  PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
    l_result_value    NUMBER;
  BEGIN
    l_result_value := NULL;

    l_business_group_id := get_business_group_id(p_assignment_action_id);
    if l_business_group_id is NULL then
      return l_result_value;
    end if;

    get_element_input_id(
        p_element_name    => p_element_name,
--bug#2002696
--                              p_input_value_name  => hr_general.decode_lookup('NAME_TRANSLATIONS','PAY VALUE'),
--bug#2002696
                                p_input_value_name      => 'Pay Value',
        p_business_group_id => l_business_group_id,
        p_element_type_id => l_element_type_id,
        p_input_value_id  => l_input_value_id);
    if l_element_type_id is NULL or l_input_value_id is NULL then
      return l_result_value;
    end if;

    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_result_value:=get_result_value_number(l_element_type_id,l_input_value_id,p_assignment_action_id);

    return l_result_value;
  END GET_RESULT_VALUE_PAY_VALUE;

-----------------------------------------------------------
--               GET_RESULT_VALUE_PAY_VALUE              --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_PAY_VALUE(
    P_ELEMENT_TYPE_ID IN NUMBER,
    P_INPUT_VALUE_ID  IN NUMBER,
    P_ASSIGNMENT_ACTION_ID  IN NUMBER)
  RETURN NUMBER
  IS
    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_result_value  number;
  --
    -- This cursor doesn't check action_type.
    -- This cursor restrict optimizer not to use
    -- PAY_RUN_RESULTS_N1 index in PAY_RUN_RESULTS.
    CURSOR get_result_value_pay_value IS
      select  /*+ ORDERED
                  USE_NL(PAA, PPA, PRR, PRRV)
                  INDEX(PAY_ASSIGNMENT_ACTIONS_PK PAA)
                  INDEX(PAY_PAYROLL_ACTIONS_PK PPA)
                  INDEX(PAY_RUN_RESULTS_N50 PRR)
                  INDEX(PAY_RUN_RESULT_VALUES_PK PRRV) */
             sum(fnd_number.canonical_to_number(prrv.result_value))
      from  pay_assignment_actions  paa,
        pay_payroll_actions ppa,
        pay_run_results   prr,
        pay_run_result_values prrv
      where paa.assignment_action_id = p_assignment_action_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and prr.assignment_action_id = paa.assignment_action_id
      and prr.element_type_id + 0 = p_element_type_id
      and prr.status in ('P','PA')
      and prrv.run_result_id = prr.run_result_id
      and prrv.input_value_id = p_input_value_id;
  BEGIN
    l_result_value := NULL;

    OPEN get_result_value_pay_value;
    FETCH get_result_value_pay_value INTO l_result_value;
    if get_result_value_pay_value%NOTFOUND then
      l_result_value := NULL;
    end if;
    CLOSE get_result_value_pay_value;

    return l_result_value;
  END GET_RESULT_VALUE_PAY_VALUE;

-----------------------------------------------------------
--               GET_RESULT_VALUE_CHAR                   --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_CHAR(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    P_ASSIGNMENT_ACTION_ID  IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
  RETURN VARCHAR2
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_element_type_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    l_input_value_id  PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
    l_result_value    PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE;
  BEGIN
    l_result_value := NULL;

    l_business_group_id := get_business_group_id(p_assignment_action_id);
    if l_business_group_id is NULL then
      return l_result_value;
    end if;

    get_element_input_id(
        p_element_name    => p_element_name,
        p_input_value_name  => p_input_value_name,
        p_business_group_id => l_business_group_id,
        p_element_type_id => l_element_type_id,
        p_input_value_id  => l_input_value_id);
    if l_element_type_id is NULL or l_input_value_id is NULL then
      return l_result_value;
    end if;

    l_result_value:=get_result_value_char(l_element_type_id,l_input_value_id,p_assignment_action_id);

    return l_result_value;
  END get_result_value_char;

-----------------------------------------------------------
--               GET_RESULT_VALUE_CHAR                   --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_CHAR(
    P_ELEMENT_TYPE_ID IN NUMBER,
    P_INPUT_VALUE_ID  IN NUMBER,
    P_ASSIGNMENT_ACTION_ID  IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
  RETURN VARCHAR2
  IS
    l_result_value  PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE;
    -- This cursor doesn't check action_type.
    -- This cursor restrict optimizer not to use
    -- PAY_RUN_RESULTS_N1 index in PAY_RUN_RESULTS.
    CURSOR get_result_value IS
      select  /*+ ORDERED
                  USE_NL(PAA, PPA, PRR, PRRV)
                  INDEX(PAY_ASSIGNMENT_ACTIONS_PK PAA)
                  INDEX(PAY_PAYROLL_ACTIONS_PK PPA)
                  INDEX(PAY_RUN_RESULTS_N50 PRR)
                  INDEX(PAY_RUN_RESULT_VALUES_PK PRRV) */
            min(prrv.result_value)
      from  pay_assignment_actions  paa,
            pay_payroll_actions ppa,
            pay_run_results   prr,
            pay_run_result_values prrv
      where paa.assignment_action_id = p_assignment_action_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and prr.assignment_action_id = paa.assignment_action_id
      and prr.element_type_id + 0 = p_element_type_id
      and prr.status in ('P','PA')
      and prrv.run_result_id = prr.run_result_id
      and prrv.input_value_id = p_input_value_id;
  BEGIN
    l_result_value := NULL;

    OPEN get_result_value;
    FETCH get_result_value INTO l_result_value;
    if get_result_value%NOTFOUND then
      l_result_value := NULL;
    end if;
    CLOSE get_result_value;

    return l_result_value;
  END GET_RESULT_VALUE_CHAR;

-----------------------------------------------------------
--               GET_RESULT_VALUE_NUMBER                 --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_NUMBER(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    P_ASSIGNMENT_ACTION_ID  IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_element_type_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    l_input_value_id  PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
    l_result_value    NUMBER;
  BEGIN
    l_result_value := NULL;

    l_business_group_id := get_business_group_id(p_assignment_action_id);
    if l_business_group_id is NULL then
      return l_result_value;
    end if;

    get_element_input_id(
        p_element_name    => p_element_name,
        p_input_value_name  => p_input_value_name,
        p_business_group_id => l_business_group_id,
        p_element_type_id => l_element_type_id,
        p_input_value_id  => l_input_value_id);
    if l_element_type_id is NULL or l_input_value_id is NULL then
      return l_result_value;
    end if;

    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_result_value:=get_result_value_number(l_element_type_id,l_input_value_id,p_assignment_action_id);

    return l_result_value;
  END get_result_value_number;

-----------------------------------------------------------
--               GET_RESULT_VALUE_NUMBER                 --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_NUMBER(
    P_ELEMENT_TYPE_ID IN NUMBER,
    P_INPUT_VALUE_ID  IN NUMBER,
    P_ASSIGNMENT_ACTION_ID  IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
  RETURN NUMBER
  IS
    l_result_value  NUMBER;
    -- This cursor doesn't check action_type.
    -- This cursor restrict optimizer not to use
    -- PAY_RUN_RESULTS_N1 index in PAY_RUN_RESULTS.
    CURSOR get_result_value IS
      select  /*+ ORDERED
                  USE_NL(PAA, PPA, PRR, PRRV)
                  INDEX(PAY_ASSIGNMENT_ACTIONS_PK PAA)
                  INDEX(PAY_PAYROLL_ACTIONS_PK PPA)
                  INDEX(PAY_RUN_RESULTS_N50 PRR)
                  INDEX(PAY_RUN_RESULT_VALUES_PK PRRV) */
            min(fnd_number.canonical_to_number(prrv.result_value))
      from  pay_assignment_actions  paa,
            pay_payroll_actions ppa,
            pay_run_results   prr,
            pay_run_result_values prrv
      where paa.assignment_action_id = p_assignment_action_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and prr.assignment_action_id = paa.assignment_action_id
      and prr.element_type_id + 0 = p_element_type_id
      and prr.status in ('P','PA')
      and prrv.run_result_id = prr.run_result_id
      and prrv.input_value_id = p_input_value_id;
  BEGIN
    l_result_value := NULL;

    OPEN get_result_value;
    FETCH get_result_value INTO l_result_value;
    if get_result_value%NOTFOUND then
      l_result_value := NULL;
    end if;
    CLOSE get_result_value;

    return l_result_value;
  END GET_RESULT_VALUE_NUMBER;

-----------------------------------------------------------
--               GET_RESULT_VALUE_DATE                   --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_DATE(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    P_ASSIGNMENT_ACTION_ID  IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
  RETURN DATE
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_element_type_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    l_input_value_id  PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
    l_result_value    DATE;
  BEGIN
    l_result_value := NULL;

    l_business_group_id := get_business_group_id(p_assignment_action_id);
    if l_business_group_id is NULL then
      return l_result_value;
    end if;

    get_element_input_id(
        p_element_name    => p_element_name,
        p_input_value_name  => p_input_value_name,
        p_business_group_id => l_business_group_id,
        p_element_type_id => l_element_type_id,
        p_input_value_id  => l_input_value_id);
    if l_element_type_id is NULL or l_input_value_id is NULL then
      return l_result_value;
    end if;

    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_result_value:=get_result_value_date(l_element_type_id,l_input_value_id,p_assignment_action_id);

    return l_result_value;
  END get_result_value_date;

-----------------------------------------------------------
--               GET_RESULT_VALUE_DATE                   --
-----------------------------------------------------------
  FUNCTION GET_RESULT_VALUE_DATE(
    P_ELEMENT_TYPE_ID IN NUMBER,
    P_INPUT_VALUE_ID  IN NUMBER,
    P_ASSIGNMENT_ACTION_ID  IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE)
  RETURN DATE
  IS
    l_result_value  DATE;
    -- This cursor doesn't check action_type.
    -- This cursor restrict optimizer not to use
    -- PAY_RUN_RESULTS_N1 index in PAY_RUN_RESULTS.
    CURSOR get_result_value IS
      -- Support for canonical date format
      -- select min(to_date(prrv.result_value,'DD-MON-YYYY'))
      select  /*+ ORDERED
                  USE_NL(PAA, PPA, PRR, PRRV)
                  INDEX(PAY_ASSIGNMENT_ACTIONS_PK PAA)
                  INDEX(PAY_PAYROLL_ACTIONS_PK PPA)
                  INDEX(PAY_RUN_RESULTS_N50 PRR)
                  INDEX(PAY_RUN_RESULT_VALUES_PK PRRV) */
            min(fnd_date.canonical_to_date(prrv.result_value))
      from  pay_assignment_actions  paa,
            pay_payroll_actions ppa,
            pay_run_results   prr,
            pay_run_result_values prrv
      where paa.assignment_action_id = p_assignment_action_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and prr.assignment_action_id = paa.assignment_action_id
      and prr.element_type_id + 0 = p_element_type_id
      and prr.status in ('P','PA')
      and prrv.run_result_id = prr.run_result_id
      and prrv.input_value_id = p_input_value_id;
  BEGIN
    l_result_value := NULL;

    OPEN get_result_value;
    FETCH get_result_value INTO l_result_value;
    if get_result_value%NOTFOUND then
      l_result_value := NULL;
    end if;
    CLOSE get_result_value;

    return l_result_value;
  END GET_RESULT_VALUE_DATE;

-----------------------------------------------------
--               GET_ENTRY_VALUE_CHAR              --
-----------------------------------------------------
  FUNCTION GET_ENTRY_VALUE_CHAR(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    P_ASSIGNMENT_ID   IN PER_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN VARCHAR2
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_element_type_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    l_input_value_id  PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
    l_entry_value   PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE%TYPE;
  BEGIN
    l_entry_value := NULL;

    l_business_group_id := get_business_group_id(p_assignment_id,p_effective_date);
    if l_business_group_id is NULL then
      return l_entry_value;
    end if;

    get_element_input_id(
        p_element_name    => p_element_name,
        p_input_value_name  => p_input_value_name,
        p_business_group_id => l_business_group_id,
        p_element_type_id => l_element_type_id,
        p_input_value_id  => l_input_value_id);
    if l_element_type_id is NULL or l_input_value_id is NULL then
      return l_entry_value;
    end if;

    l_entry_value:=get_entry_value_char(l_input_value_id,p_assignment_id,p_effective_date);

    return l_entry_value;
  END GET_ENTRY_VALUE_CHAR;

-----------------------------------------------------
--               GET_ENTRY_VALUE_CHAR              --
-----------------------------------------------------
  FUNCTION GET_ENTRY_VALUE_CHAR(
    P_INPUT_VALUE_ID  IN NUMBER,
    P_ASSIGNMENT_ID   IN NUMBER,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN VARCHAR2
  IS
    l_entry_value   PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE%TYPE;

    CURSOR get_entry_value IS
      select  /*+ ORDERED
                  USE_NL(PIV, PLIV, PEE, PEEV)
                  INDEX(PAY_INPUT_VALUES_F_PK PIV)
                  INDEX(PAY_LINK_INPUT_VALUES_F_N2 PLIV)
                  INDEX(PAY_ELEMENT_ENTRIES_F_N51 PEE)
                  INDEX(PAY_ELEMENT_ENTRY_VALUES_F_N50 PEEV) */
              min(  decode(piv.hot_default_flag,  'Y',nvl(peev.screen_entry_value,nvl(pliv.default_value,piv.default_value)),
                  'N',peev.screen_entry_value))
      from  pay_input_values_f    piv,
            pay_link_input_values_f   pliv,
            pay_element_entries_f   pee,
            pay_element_entry_values_f  peev
      WHERE piv.input_value_id = p_input_value_id
      and p_effective_date
        between piv.effective_start_date and piv.effective_end_date
      and pliv.input_value_id = piv.input_value_id
      and p_effective_date
        between pliv.effective_start_date and pliv.effective_end_date
      and pee.element_link_id = pliv.element_link_id
      and pee.assignment_id = p_assignment_id
      and nvl(pee.entry_type,'E') = 'E'
      and p_effective_date
        between pee.effective_start_date and pee.effective_end_date
      and peev.element_entry_id = pee.element_entry_id
      and peev.effective_start_date = pee.effective_start_date
      and peev.effective_end_date = pee.effective_end_date
      and peev.input_value_id = piv.input_value_id;
  BEGIN
    l_entry_value := NULL;

    OPEN get_entry_value;
    FETCH get_entry_value INTO l_entry_value;
    if get_entry_value%NOTFOUND then
      l_entry_value := NULL;
    end if;
    CLOSE get_entry_value;

    return l_entry_value;
  END GET_ENTRY_VALUE_CHAR;

-------------------------------------------------------
--               GET_ENTRY_VALUE_NUMBER              --
-------------------------------------------------------
  FUNCTION GET_ENTRY_VALUE_NUMBER(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    P_ASSIGNMENT_ID   IN PER_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN NUMBER
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_element_type_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    l_input_value_id  PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_entry_value   number;
  BEGIN
    l_entry_value := NULL;

    l_business_group_id := get_business_group_id(p_assignment_id,p_effective_date);
    if l_business_group_id is NULL then
      return l_entry_value;
    end if;

    get_element_input_id(
        p_element_name    => p_element_name,
        p_input_value_name  => p_input_value_name,
        p_business_group_id => l_business_group_id,
        p_element_type_id => l_element_type_id,
        p_input_value_id  => l_input_value_id);
    if l_element_type_id is NULL or l_input_value_id is NULL then
      return l_entry_value;
    end if;

    l_entry_value:=get_entry_value_number(l_input_value_id,p_assignment_id,p_effective_date);

    return l_entry_value;
  END GET_ENTRY_VALUE_NUMBER;

-----------------------------------------------------
--               GET_ENTRY_VALUE_NUMBER            --
-----------------------------------------------------
  FUNCTION GET_ENTRY_VALUE_NUMBER(
    P_INPUT_VALUE_ID  IN NUMBER,
    P_ASSIGNMENT_ID   IN NUMBER,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN NUMBER
  IS
    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_entry_value   number;

    CURSOR get_entry_value IS
      select  /*+ ORDERED
                  USE_NL(PIV, PLIV, PEE, PEEV)
                  INDEX(PAY_INPUT_VALUES_F_PK PIV)
                  INDEX(PAY_LINK_INPUT_VALUES_F_N2 PLIV)
                  INDEX(PAY_ELEMENT_ENTRIES_F_N51 PEE)
                  INDEX(PAY_ELEMENT_ENTRY_VALUES_F_N50 PEEV) */
          min(fnd_number.canonical_to_number(decode(decode(substr(piv.uom,1,1),'M','N','N','N','I','N','H','N',null),'N',
          decode(piv.hot_default_flag,  'Y',nvl(peev.screen_entry_value,nvl(pliv.default_value,piv.default_value)),
                  'N',peev.screen_entry_value),null)))
      from  pay_input_values_f    piv,
            pay_link_input_values_f   pliv,
            pay_element_entries_f   pee,
            pay_element_entry_values_f  peev
      WHERE piv.input_value_id = p_input_value_id
      and p_effective_date
        between piv.effective_start_date and piv.effective_end_date
      and pliv.input_value_id = piv.input_value_id
      and p_effective_date
        between pliv.effective_start_date and pliv.effective_end_date
      and pee.element_link_id = pliv.element_link_id
      and pee.assignment_id = p_assignment_id
      and nvl(pee.entry_type,'E') = 'E'
      and p_effective_date
        between pee.effective_start_date and pee.effective_end_date
      and peev.element_entry_id = pee.element_entry_id
      and peev.effective_start_date = pee.effective_start_date
      and peev.effective_end_date = pee.effective_end_date
      and peev.input_value_id = piv.input_value_id;
  BEGIN
    l_entry_value := NULL;

    OPEN get_entry_value;
    FETCH get_entry_value INTO l_entry_value;
    if get_entry_value%NOTFOUND then
      l_entry_value := NULL;
    end if;
    CLOSE get_entry_value;

    return l_entry_value;
  END GET_ENTRY_VALUE_NUMBER;

-----------------------------------------------------
--               GET_ENTRY_VALUE_DATE              --
-----------------------------------------------------
  FUNCTION GET_ENTRY_VALUE_DATE(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    P_ASSIGNMENT_ID   IN PER_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN DATE
  IS
    l_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_element_type_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    l_input_value_id  PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_entry_value   date;
  BEGIN
    l_entry_value := NULL;

    l_business_group_id := get_business_group_id(p_assignment_id,p_effective_date);
    if l_business_group_id is NULL then
      return l_entry_value;
    end if;

    get_element_input_id(
        p_element_name    => p_element_name,
        p_input_value_name  => p_input_value_name,
        p_business_group_id => l_business_group_id,
        p_element_type_id => l_element_type_id,
        p_input_value_id  => l_input_value_id);
    if l_element_type_id is NULL or l_input_value_id is NULL then
      return l_entry_value;
    end if;

    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_entry_value:=get_entry_value_date(l_input_value_id,p_assignment_id,p_effective_date);

    return l_entry_value;
  END GET_ENTRY_VALUE_DATE;

-----------------------------------------------------
--               GET_ENTRY_VALUE_DATE              --
-----------------------------------------------------
  FUNCTION GET_ENTRY_VALUE_DATE(
    P_INPUT_VALUE_ID  IN NUMBER,
    P_ASSIGNMENT_ID   IN NUMBER,
    P_EFFECTIVE_DATE  IN DATE)
  RETURN DATE
  IS
    -- Modified by keyazawa at 2003/09/03 for bug#3088039
    l_entry_value   date;

    CURSOR get_entry_value IS
      --select  min (to_date(decode(substr(piv.uom,1,1),'D',
      --    decode(piv.hot_default_flag,  'Y',nvl(peev.screen_entry_value,nvl(pliv.default_value,piv.default_value)),
      --            'N',peev.screen_entry_value),null),'DD-MON-YYYY'))
      select  /*+ ORDERED
                  USE_NL(PIV, PLIV, PEE, PEEV)
                  INDEX(PAY_INPUT_VALUES_F_PK PIV)
                  INDEX(PAY_LINK_INPUT_VALUES_F_N2 PLIV)
                  INDEX(PAY_ELEMENT_ENTRIES_F_N51 PEE)
                  INDEX(PAY_ELEMENT_ENTRY_VALUES_F_N50 PEEV) */
          min (fnd_date.canonical_to_date(decode(substr(piv.uom,1,1),'D',
          decode(piv.hot_default_flag,  'Y',nvl(peev.screen_entry_value,nvl(pliv.default_value,piv.default_value)),
                  'N',peev.screen_entry_value),null)))
      from  pay_input_values_f    piv,
            pay_link_input_values_f   pliv,
            pay_element_entries_f   pee,
            pay_element_entry_values_f  peev
      WHERE piv.input_value_id = p_input_value_id
      and p_effective_date
        between piv.effective_start_date and piv.effective_end_date
      and pliv.input_value_id = piv.input_value_id
      and p_effective_date
        between pliv.effective_start_date and pliv.effective_end_date
      and pee.element_link_id = pliv.element_link_id
      and pee.assignment_id = p_assignment_id
      and nvl(pee.entry_type,'E') = 'E'
      and p_effective_date
        between pee.effective_start_date and pee.effective_end_date
      and peev.element_entry_id = pee.element_entry_id
      and peev.effective_start_date = pee.effective_start_date
      and peev.effective_end_date = pee.effective_end_date
      and peev.input_value_id = piv.input_value_id;
  BEGIN
    l_entry_value := NULL;

    OPEN get_entry_value;
    FETCH get_entry_value INTO l_entry_value;
    if get_entry_value%NOTFOUND then
      l_entry_value := NULL;
    end if;
    CLOSE get_entry_value;

    return l_entry_value;
  END GET_ENTRY_VALUE_DATE;

-----------------------------------------------------
--           GET_ELEMENT_TYPE_ID                   --
-----------------------------------------------------
  FUNCTION GET_ELEMENT_TYPE_ID(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_BUSINESS_GROUP_ID IN NUMBER,
    P_LEGISLATION_CODE  IN PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE)
  RETURN NUMBER
  IS
    l_element_type_id NUMBER;

    CURSOR get_element_type_id IS
      select  /*+ INDEX(PAY_ELEMENT_TYPES_F_UK2 PET) */
              min(pet.element_type_id)
      from  pay_element_types_f pet
      where pet.element_name = p_element_name
      and nvl(pet.business_group_id,p_business_group_id) = p_business_group_id
      and nvl(pet.legislation_code,p_legislation_code) = p_legislation_code;
  BEGIN
    OPEN get_element_type_id;
    FETCH get_element_type_id INTO l_element_type_id;
    if get_element_type_id%NOTFOUND then
      l_element_type_id := NULL;
    end if;
    CLOSE get_element_type_id;

    return l_element_type_id;
  END GET_ELEMENT_TYPE_ID;

-----------------------------------------------------
--           GET_INPUT_VALUE_ID                    --
-----------------------------------------------------
  FUNCTION GET_INPUT_VALUE_ID(
    P_ELEMENT_TYPE_ID IN NUMBER,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE)
  RETURN NUMBER
  IS
    l_input_value_id  NUMBER;

    CURSOR get_input_value_id IS
      select  /*+ INDEX(PAY_INPUT_VALUES_F_UK2 PIV) */
              min(piv.input_value_id)
      from  pay_input_values_f  piv
      where piv.element_type_id = p_element_type_id
      and piv.name=p_input_value_name;
  BEGIN
    OPEN get_input_value_id;
    FETCH get_input_value_id INTO l_input_value_id;
    if get_input_value_id%NOTFOUND then
      l_input_value_id := NULL;
    end if;
    CLOSE get_input_value_id;

    return l_input_value_id;
  END GET_INPUT_VALUE_ID;

-----------------------------------------------------
--           GET_INPUT_VALUE_ID                    --
-----------------------------------------------------
  FUNCTION GET_INPUT_VALUE_ID(
    P_ELEMENT_NAME    IN PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
    P_INPUT_VALUE_NAME  IN PAY_INPUT_VALUES_F.NAME%TYPE,
    P_BUSINESS_GROUP_ID IN NUMBER,
    P_LEGISLATION_CODE  IN PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE)
  RETURN NUMBER
  IS
    l_element_type_id NUMBER;
    l_input_value_id  NUMBER;
  BEGIN
    l_input_value_id:=NULL;

    l_element_type_id:=get_element_type_id(p_element_name,p_business_group_id,p_legislation_code);
    if l_element_type_id is NULL then
      return l_input_value_id;
    end if;

    l_input_value_id:=get_input_value_id(l_element_type_id,p_input_value_name);
    if l_input_value_id is NULL then
      l_input_value_id:=NULL;
    end if;

    return l_input_value_id;
  END GET_INPUT_VALUE_ID;
--
-----------------------------------------------------
--        GET_LOC_UNI_SEQ_INPUT_VALUE_ID           --
-----------------------------------------------------
/* --------------------------------------------------
-- Note: This function is only used for the element
-- of unique display_sequence as JP localization
-- seed data. When the other argument is specified,
-- null value would be returned.
-------------------------------------------------- */
FUNCTION get_loc_uni_seq_input_value_id(
  p_element_name          in pay_element_types_f.element_name%type,
  p_input_value_disp_seq  in pay_input_values_f.display_sequence%type,
  p_business_group_id     in number,
  p_legislation_code      in per_business_groups.legislation_code%type)
return number
IS
--
  l_element_type_id number;
  l_input_value_id  number;
--
  cursor  csr_input_value
  is
  select  piv.input_value_id
  from    pay_input_values_f  piv
  where   piv.element_type_id = l_element_type_id
  and     piv.display_sequence = p_input_value_disp_seq
  /* Validate if input value is owned as JP legislation code */
  and     piv.legislation_code = decode(p_legislation_code,'JP',p_legislation_code,null)
  /* Validate if there are another input value of same display sequence */
  and     not exists(
              select  null
              from    pay_input_values_f  piv2
              where   piv2.element_type_id = piv.element_type_id
              and     piv2.display_sequence = piv.display_sequence
              and     piv2.input_value_id <> piv.input_value_id);
--
BEGIN
--
  l_input_value_id := null;
--
  l_element_type_id:=get_element_type_id(p_element_name,p_business_group_id,p_legislation_code);
  if l_element_type_id is null then
    return l_input_value_id;
  end if;
--
-- /* Excluded the case that
--    input value is not JP seed data
--    or multiple same sequence input value exist. */
  open csr_input_value;
  fetch csr_input_value into l_input_value_id;
  if csr_input_value%notfound then
    l_input_value_id := null;
  end if;
  close csr_input_value;
--
  return l_input_value_id;
--
END get_loc_uni_seq_input_value_id;
--
--===============================================================================
  FUNCTION GET_SAVE_RUN_BALANCE(
    P_BALANCE_TYPE_ID      IN PAY_BALANCE_TYPES.BALANCE_TYPE_ID%TYPE,
    P_BUSINESS_GROUP_ID    IN PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE,
    P_LEGISLATION_CODE     IN PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE
)
 RETURN VARCHAR2 IS
--===============================================================================
l_save_run_balance	PAY_DEFINED_BALANCES.SAVE_RUN_BALANCE%TYPE;

BEGIN

SELECT	SAVE_RUN_BALANCE
INTO	l_save_run_balance
FROM	PAY_DEFINED_BALANCES
WHERE	BALANCE_TYPE_ID = P_BALANCE_TYPE_ID
AND	nvl(BUSINESS_GROUP_ID,p_business_group_id) = p_business_group_id
AND	nvl(LEGISLATION_CODE,p_legislation_code) = p_legislation_code;

return l_save_run_balance;
EXCEPTION
	WHEN OTHERS THEN
	RETURN NULL;
END GET_SAVE_RUN_BALANCE;
--===============================================================================
  FUNCTION GET_DEFINED_BALANCE_ID(
    P_BALANCE_TYPE_ID		IN PAY_BALANCE_TYPES.BALANCE_TYPE_ID%TYPE,
    P_ASSIGNMENT_ID 		IN PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE,
    P_EFFECTIVE_DATE		IN DATE
  )
  RETURN NUMBER IS
--===============================================================================
CURSOR	get_balance_name(
		p_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE,
		p_legislation_code  PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE
	) IS
SELECT	BALANCE_NAME
FROM	PAY_BALANCE_TYPES
WHERE	nvl(BUSINESS_GROUP_ID,p_business_group_id) = p_business_group_id
AND	nvl(LEGISLATION_CODE,p_legislation_code) = p_legislation_code
AND	BALANCE_TYPE_ID = p_balance_type_id;

l_defined_balance_id 	PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_business_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_legislation_code	PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;
l_balance_name		PAY_BALANCE_TYPES.BALANCE_NAME%TYPE;
l_dimension_name	PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE;
l_save_run_balance	PAY_DEFINED_BALANCES.SAVE_RUN_BALANCE%TYPE;

BEGIN
l_business_group_id := get_business_group_id(P_ASSIGNMENT_ID,P_EFFECTIVE_DATE);
l_legislation_code := get_legislation_code(l_business_group_id);

l_save_run_balance := GET_SAVE_RUN_BALANCE(P_BALANCE_TYPE_ID,l_business_group_id,l_legislation_code);

IF l_save_run_balance <> 'Y' THEN
	RETURN NULL;
END IF;

OPEN get_balance_name(l_business_group_id,l_legislation_code);
 FETCH get_balance_name INTO l_balance_name;
 if get_balance_name%NOTFOUND then
  l_balance_name := NULL;
 end if;
CLOSE get_balance_name;

l_dimension_name := '_ASG_RUN';
l_defined_balance_id := GET_DEFINED_BALANCE_ID(l_balance_name,l_dimension_name,l_business_group_id);

return l_defined_balance_id;
EXCEPTION
	WHEN OTHERS THEN
	RETURN NULL;
END GET_DEFINED_BALANCE_ID;
--
--===============================================================================
  FUNCTION GET_DEFINED_BALANCE_ID(
    P_BALANCE_TYPE_ID      IN PAY_BALANCE_TYPES.BALANCE_TYPE_ID%TYPE,
    P_ASSIGNMENT_ACTION_ID IN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE
  )
  RETURN NUMBER IS
--===============================================================================
CURSOR	csr_assignment_action_id IS
SELECT	/*+ ORDERED
           USE_NL(PAA, PPA)
           INDEX(PAY_ASSIGNMENT_ACTIONS_PK PAA)
           INDEX(PAY_PAYROLL_ACTIONS_PK PPA) */
    	PAA.ASSIGNMENT_ID,
      PPA.EFFECTIVE_DATE
FROM	PAY_ASSIGNMENT_ACTIONS	PAA,
	PAY_PAYROLL_ACTIONS	PPA
WHERE	PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
AND	PAA.ASSIGNMENT_ACTION_ID = p_assignment_action_id;

l_defined_balance_id 	PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_assignment_id		PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ID%TYPE;
l_effective_date	PAY_PAYROLL_ACTIONS.EFFECTIVE_DATE%TYPE;

BEGIN
OPEN csr_assignment_action_id;
 FETCH csr_assignment_action_id INTO l_assignment_id,l_effective_date;
 if csr_assignment_action_id%NOTFOUND then
  l_assignment_id := NULL;
  l_effective_date := NULL;
 end if;
CLOSE csr_assignment_action_id;

l_defined_balance_id := GET_DEFINED_BALANCE_ID(p_balance_type_id, l_assignment_id, l_effective_date);
return l_defined_balance_id;
EXCEPTION
	WHEN OTHERS THEN
	RETURN NULL;
END GET_DEFINED_BALANCE_ID;
--
END PAY_JP_BALANCE_PKG;

/
