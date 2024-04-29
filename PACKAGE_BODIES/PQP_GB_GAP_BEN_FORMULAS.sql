--------------------------------------------------------
--  DDL for Package Body PQP_GB_GAP_BEN_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_GAP_BEN_FORMULAS" AS
--  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
--
--
--
  PROCEDURE debug
    (p_trace_message  IN     VARCHAR2
    ,p_trace_location IN     NUMBER   DEFAULT NULL
    )
  IS
     l_padding VARCHAR2(12);
     l_MAX_MESSAGE_LENGTH NUMBER:= 72;
  BEGIN

      IF p_trace_location IS NOT NULL THEN

        l_padding := SUBSTR
                      (RPAD(' ',LEAST(g_nested_level,5)*2,' ')
                      ,1,l_MAX_MESSAGE_LENGTH
                         - LEAST(LENGTH(p_trace_message)
                                ,l_MAX_MESSAGE_LENGTH)
                      );

       hr_utility.set_location
        (l_padding||
         SUBSTR(p_trace_message
               ,GREATEST(-LENGTH(p_trace_message),-l_MAX_MESSAGE_LENGTH))
        ,p_trace_location);

      ELSE

       hr_utility.trace(SUBSTR(p_trace_message,1,250));

      END IF;

  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_number IN     NUMBER )
  IS
  BEGIN
      debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_date IN     DATE )
  IS
  BEGIN
      debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;
--
--
--
  PROCEDURE debug_enter
    (p_proc_name IN     VARCHAR2 DEFAULT NULL
    ,p_trace_on  IN     VARCHAR2 DEFAULT NULL
    )
  IS
--     l_trace_options    VARCHAR2(200);
  BEGIN

-- --Uncomment this code to run the package with a debug trace
--
--   IF  g_nested_level = 0 -- swtich tracing on/off at the top level only
--   AND NVL(p_trace_on,'N') = 'Y'
--   THEN
--
--      hr_utility.trace_on(NULL,'REQID'); -- Pipe name REQIDnnnnnn
--
--   END IF; -- if nested level = 0
--
-- --Uncomment this code to run the package with a debug trace

    g_nested_level :=  g_nested_level + 1;
    debug('Entered: '||NVL(p_proc_name,g_proc_name),g_nested_level*100);

  END debug_enter;
--
--
--
  PROCEDURE debug_exit
    (p_proc_name               IN     VARCHAR2 DEFAULT NULL
    ,p_trace_off               IN     VARCHAR2 DEFAULT NULL
    ,p_override_trace_location IN     NUMBER   DEFAULT NULL
    )
  IS
  BEGIN

    debug
     ('Leaving: '||NVL(p_proc_name,g_proc_name)
     ,NVL(p_override_trace_location,-g_nested_level*100)
     );

    g_nested_level := g_nested_level - 1;

--  --Uncomment this code to run the package with a debug trace
--
--  IF  g_nested_level = 0
--  AND NVL(p_trace_off,'Y') = 'Y'
--  THEN
--
--    hr_utility.trace_off;
--
--  END IF;
--
--  --Uncomment this code to run the package with a debug trace

  END debug_exit;
--
--
--
  PROCEDURE create_ben_formulas
    (p_business_group_id            IN     NUMBER
    ,p_effective_date               IN     DATE
    ,p_absence_pay_plan_category    IN     VARCHAR2
    ,p_base_name                    IN     VARCHAR2
    ,p_formulas IN OUT NOCOPY pqp_gb_gap_ben_formulas.t_formulas
    ,p_error_code                      OUT NOCOPY NUMBER
    ,p_error_message                   OUT NOCOPY VARCHAR2
    )
  IS

  l_formula_name         ff_formulas.formula_name%TYPE;-- VARCHAR2(80)
  l_formula_type         ff_formula_types.formula_type_name%TYPE;-- VARCHAR2(80)
  l_description          ff_formulas.description%TYPE;-- VARCHAR2(240)
  l_formula_type_id      ff_formula_types.formula_type_id%TYPE;

  -- this date is passed as effective start date for LER formulas only.
  -- In the remaining formulas p_effective_date is passed
  l_effective_start_date DATE:= fnd_date.canonical_to_date('1951/01/01 00:00:00');
                                --p_effective_date;
  l_effective_end_date   DATE:=
    fnd_date.canonical_to_date('4712/12/31 00:00:00');

  l_text                 VARCHAR2(32767);

  l_business_group_name  hr_all_organization_units.name%TYPE;--VARCHAR2(240)
  l_business_group_id    ff_formulas.business_group_id%TYPE :=
  p_business_group_id ;
  l_legislation_code     ff_formulas.legislation_code%TYPE:= NULL;
  l_formula_count        NUMBER:= 1;

  l_base_name            pay_element_templates.base_name%TYPE:=
    TRIM(UPPER(p_base_name));

  l_proc_name  VARCHAR2(61):= g_proc_name||'create_ben_formulas';

  BEGIN
    debug_enter(l_proc_name);
    debug(l_proc_name,10);
    p_error_code:= 0;
    p_error_message := NULL;

  IF g_use_this_functionality THEN

--
-- Start of Person Change Causes Life Event rule for the Absence Delete LER
--
  BEGIN



    debug(l_proc_name,20);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB
      (--         1         2         3         4         5
       --1234567890123456789012345678901234567890123456789012345
        'PQP_GB_BEN_LER_ABSENCE_DELETE_EVENT_PERSON_CHANGES_RULE'
       --||l_uniquestamp
      ,1,80);

    debug(l_formula_name);

    OPEN csr_get_formula_id(p_business_group_id,l_formula_name);
    FETCH csr_get_formula_id INTO l_check_ler_formulas;
    IF csr_get_formula_id%NOTFOUND THEN

    debug(l_proc_name,22);
    l_formula_type:=  -- VARCHAR2(80)
      'Person Change Causes Life Event';
    l_description:= -- VARCHAR2(240)
       'Sample rule to detect a new or changed absence entry.';

    debug(l_proc_name,25);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_LER_ABSENCE_DELETE_EVENT_PERSON_CHANGES_RULE
  Formula Type: Person Change Causes Life Event
  Description : Sample formula to detect that an absence has been deleted.

DISCLAIMER  :
 In future releases of HRMS programs, Oracle Corporation may change or
 upgrade this formula, and all other definitions for the predefined template
 of which this formula is a part.  We do not guarantee that the  formula and the
 predefined template will provide a ready-made solution to be used in your
 environment. If the formula does not reflect your business rules,  you are
 responsible for writing a formula of your own to meet your particular
 requirements. Any use of this  formula and the predefined extract is subject to
 the terms of the Oracle license agreement for the HRMS programs and
 documentation.

**Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/
/*
Set default values.
*/
DEFAULT FOR BEN_ABA_IN_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
/* Other inputs available are
DEFAULT FOR BEN_ABA_IN_PERSON_ID                  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_PERSON_ID                  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABS_ATTENDANCE_REASON_ID   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABS_ATTENDANCE_REASON_ID   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_SICKNESS_START_DATE        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_SICKNESS_START_DATE        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_SICKNESS_END_DATE          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_SICKNESS_END_DATE          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_DAYS               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_DAYS               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_HOURS              IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_HOURS              IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_NOTIFICATION          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_NOTIFICATION          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_PROJECTED_START       IS ''_DEFAULT_''
*/

/*
Declare Input values.

NOTE the naming convention followed
     BEN_ABA_IN_<Column Name> - New Values
     BEN_ABA_IO_<Column Name> - Old Values
*/

INPUTS ARE BEN_ABA_IN_DATE_START(TEXT)
          ,BEN_ABA_IO_DATE_START(TEXT)
          ,BEN_ABA_IN_DATE_END(TEXT)
          ,BEN_ABA_IO_DATE_END(TEXT)
          ,BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
          ,BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
/* Other inputs available are
          ,BEN_ABA_IN_PERSON_ID(TEXT)
          ,BEN_ABA_IO_PERSON_ID(TEXT)
          ,BEN_ABA_IN_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABA_IO_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABA_IN_SICKNESS_START_DATE(TEXT)
          ,BEN_ABA_IO_SICKNESS_START_DATE(TEXT)
          ,BEN_ABA_IN_SICKNESS_END_DATE(TEXT)
          ,BEN_ABA_IO_SICKNESS_END_DATE(TEXT)
          ,BEN_ABA_IN_ABSENCE_DAYS(TEXT)
          ,BEN_ABA_IO_ABSENCE_DAYS(TEXT)
          ,BEN_ABA_IN_ABSENCE_HOURS(TEXT)
          ,BEN_ABA_IO_ABSENCE_HOURS(TEXT)
          ,BEN_ABA_IN_DATE_NOTIFICATION(TEXT)
          ,BEN_ABA_IO_DATE_NOTIFICATION(TEXT)
          ,BEN_ABA_IN_DATE_PROJECTED_END(TEXT)
          ,BEN_ABA_IO_DATE_PROJECTED_END(TEXT)
          ,BEN_ABA_IN_DATE_PROJECTED_START(TEXT)
          ,BEN_ABA_IO_DATE_PROJECTED_START(TEXT)
          ,BEN_ABA_IN_TIME_END(TEXT)
          ,BEN_ABA_IO_TIME_END(TEXT)
          ,BEN_ABA_IN_TIME_PROJECTED_END(TEXT)
          ,BEN_ABA_IO_TIME_PROJECTED_END(TEXT)
          ,BEN_ABA_IN_TIME_PROJECTED_START(TEXT)
          ,BEN_ABA_IO_TIME_PROJECTED_START(TEXT)
*/

/*
Initialise values.
*/

l_default                      = ''_DEFAULT_'' /* TEXT */
l_yn                           = ''N''         /* TEXT */


/* 01. Determine the old and new values for ABSENCE_ATTENDANCE_TYPE_ID

   NOTE Though these values are stored as dates or numbers they are made
   available to the formula as TEXT inputs.

   The dates are available in the default canoncial format of
   "YYYY/MM/DD HH24:MI:SS".
   Where required, use TO_DATE to convert text into a date.

   The numbers are available in the default canonical format.
   Where required, use TO_NUMBER to convert into text into a number.
*/

l_absence_type_id_old_value  = BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID
l_absence_type_id_new_value  = BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID

/* 02a. Check that the new value of absence type id has been defaulted.

       NOTE When an absence is deleted, the absence_type_id new value will be
       defaulted. To record an absence delete a seperate life event reason has
       to be setup. To prevent a absence start change from being logged on a
       delete, an additional check is introduced to ensure that new value is not
       equal to the default.
*/
IF NOT l_absence_type_id_old_value = l_default
  AND
   l_absence_type_id_new_value = l_default
THEN
 (
  /* 02b. Set the return flag to "Y"es to allow this person change to cause an
          "absence delete" life event.

     NOTE the default for the flag is "N"o.
  */
  l_yn = ''Y''
 )

RETURN l_yn
';

    debug(l_proc_name,27);
    SELECT formula_type_id
    INTO   l_formula_type_id
    FROM   ff_formula_types
    WHERE  formula_type_name = l_formula_type;

    debug(l_proc_name,29);
    debug(l_effective_start_date||';'||l_effective_end_date,30);
    debug(l_business_group_id||';'||l_legislation_code,31);
    debug(l_formula_type_id||';'||l_formula_name,31);

    l_formula_count:= l_formula_count + 1;
    INSERT INTO ff_formulas_f
      (formula_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,legislation_code
      ,formula_type_id
      ,formula_name
      ,description
      ,formula_text
      ,sticky_flag)
    VALUES(ff_formulas_s.NEXTVAL
      ,l_effective_start_date
      ,l_effective_end_date
      ,l_business_group_id
      ,l_legislation_code
      ,l_formula_type_id
      ,l_formula_name
      ,l_description
      ,NULL
      ,NULL
       )
--    WHERE NOT EXISTS
--           (SELECT 1
--            FROM   ff_formulas_f
--            WHERE  formula_name = l_formula_name
--              AND  business_group_id = l_business_group_id
--           )
    RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE  formula_id = p_formulas(l_formula_count)
      -- formula_name = l_formula_name
      -- AND  business_group_id = l_business_group_id
    ;


  END IF;
  CLOSE csr_get_formula_id;

  END;
--
-- End of Person Change Causes Life Event rule for the Absence Delete LER
--
--
-- Start of Person Change Causes Life Event rule for the Absence End LER
--
  BEGIN

    debug(l_proc_name,30);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB
      (--         1         2         3         4         5
       --1234567890123456789012345678901234567890123456789012
        'PQP_GB_BEN_LER_ABSENCE_END_EVENT_PERSON_CHANGES_RULE'
       --||l_uniquestamp
      ,1,80);
    debug(l_formula_name);
  OPEN csr_get_formula_id(p_business_group_id,l_formula_name);
  FETCH csr_get_formula_id INTO l_check_ler_formulas;
  IF csr_get_formula_id%NOTFOUND THEN
    debug(l_proc_name,32);
    l_formula_type:=  -- VARCHAR2(80)
      'Person Change Causes Life Event';
    l_description:= -- VARCHAR2(240)
       'Sample rule to detect a new or changed absence entry.';

    debug(l_proc_name,35);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_LER_ABSENCE_END_EVENT_PERSON_CHANGES_RULE
  Formula Type: Person Change Causes Life Event
  Description : Sample formula to detect a new or changed absence end date.

DISCLAIMER  :
 In future releases of HRMS programs, Oracle Corporation may change or
 upgrade this formula, and all other definitions for the predefined template
 of which this formula is a part.  We do not guarantee that the  formula and the
 predefined template will provide a ready-made solution to be used in your
 environment. If the formula does not reflect your business rules,  you are
 responsible for writing a formula of your own to meet your particular
 requirements. Any use of this  formula and the predefined extract is subject to
 the terms of the Oracle license agreement for the HRMS programs and
 documentation.

**Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/
/*
Set default values.
*/
DEFAULT FOR BEN_ABA_IN_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
/* Other inputs available are
DEFAULT FOR BEN_ABA_IN_PERSON_ID                  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_PERSON_ID                  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABS_ATTENDANCE_REASON_ID   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABS_ATTENDANCE_REASON_ID   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_SICKNESS_START_DATE        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_SICKNESS_START_DATE        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_SICKNESS_END_DATE          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_SICKNESS_END_DATE          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_DAYS               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_DAYS               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_HOURS              IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_HOURS              IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_NOTIFICATION          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_NOTIFICATION          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_PROJECTED_START       IS ''_DEFAULT_''
*/

/*
Declare Input values.

NOTE the naming convention followed
     BEN_ABA_IN_<Column Name> - New Values
     BEN_ABA_IO_<Column Name> - Old Values
*/

INPUTS ARE BEN_ABA_IN_DATE_START(TEXT)
          ,BEN_ABA_IO_DATE_START(TEXT)
          ,BEN_ABA_IN_DATE_END(TEXT)
          ,BEN_ABA_IO_DATE_END(TEXT)
          ,BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
          ,BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
/* Other inputs available are
          ,BEN_ABA_IN_PERSON_ID(TEXT)
          ,BEN_ABA_IO_PERSON_ID(TEXT)
          ,BEN_ABA_IN_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABA_IO_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABA_IN_SICKNESS_START_DATE(TEXT)
          ,BEN_ABA_IO_SICKNESS_START_DATE(TEXT)
          ,BEN_ABA_IN_SICKNESS_END_DATE(TEXT)
          ,BEN_ABA_IO_SICKNESS_END_DATE(TEXT)
          ,BEN_ABA_IN_ABSENCE_DAYS(TEXT)
          ,BEN_ABA_IO_ABSENCE_DAYS(TEXT)
          ,BEN_ABA_IN_ABSENCE_HOURS(TEXT)
          ,BEN_ABA_IO_ABSENCE_HOURS(TEXT)
          ,BEN_ABA_IN_DATE_NOTIFICATION(TEXT)
          ,BEN_ABA_IO_DATE_NOTIFICATION(TEXT)
          ,BEN_ABA_IN_DATE_PROJECTED_END(TEXT)
          ,BEN_ABA_IO_DATE_PROJECTED_END(TEXT)
          ,BEN_ABA_IN_DATE_PROJECTED_START(TEXT)
          ,BEN_ABA_IO_DATE_PROJECTED_START(TEXT)
          ,BEN_ABA_IN_TIME_END(TEXT)
          ,BEN_ABA_IO_TIME_END(TEXT)
          ,BEN_ABA_IN_TIME_PROJECTED_END(TEXT)
          ,BEN_ABA_IO_TIME_PROJECTED_END(TEXT)
          ,BEN_ABA_IN_TIME_PROJECTED_START(TEXT)
          ,BEN_ABA_IO_TIME_PROJECTED_START(TEXT)
*/

/*
Initialise values.
*/

l_default                      = ''_DEFAULT_'' /* TEXT */
l_yn                           = ''N''         /* TEXT */


/* 01. Determine the old and new values for DATE_START

   NOTE Though these values are stored as dates or numbers they are made
   available to the formula as TEXT inputs.

   The dates are available in the default canoncial format of
   "YYYY/MM/DD HH24:MI:SS".
   Where required, use TO_DATE to convert text into a date.

   The numbers are available in the default canonical format.
   Where required, use TO_NUMBER to convert into text into a number.
*/

l_date_end_old_value         = BEN_ABA_IO_DATE_END
l_date_end_new_value         = BEN_ABA_IN_DATE_END
l_absence_type_id_new_value  = BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID

/* 02a. Check that there is a difference between the old and new values of
       DATE_END.

       NOTE When an absence is deleted, the absence_type_id new value will be
       defaulted. To record an absence delete a seperate life event reason has
       to be setup. To prevent a absence start change from being logged on a
       delete, an additional check is introduced to ensure that new value is not
       equal to the default.
*/
IF NOT l_date_end_old_value = l_date_end_new_value
  AND
   NOT l_absence_type_id_new_value = l_default
THEN
 (
  /* 02b. Set the return flag to "Y"es to allow this person change to cause an
          "absence end" life event.

     NOTE the default for the flag is "N"o.
  */
  l_yn = ''Y''
 )

RETURN l_yn
';

    debug(l_proc_name,37);
    SELECT formula_type_id
    INTO   l_formula_type_id
    FROM   ff_formula_types
    WHERE  formula_type_name = l_formula_type;

    debug(l_proc_name,39);
    l_formula_count := l_formula_count + 1;
    INSERT INTO ff_formulas_f
      (formula_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,legislation_code
      ,formula_type_id
      ,formula_name
      ,description
      ,formula_text
      ,sticky_flag)
    VALUES(ff_formulas_s.NEXTVAL
      ,l_effective_start_date
      ,l_effective_end_date
      ,l_business_group_id
      ,l_legislation_code
      ,l_formula_type_id
      ,l_formula_name
      ,l_description
      ,NULL
      ,NULL
       )
--    WHERE NOT EXISTS
--           (SELECT 1
--            FROM   ff_formulas_f
--            WHERE  formula_name = l_formula_name
--              AND  business_group_id = l_business_group_id
--           )
    RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

  END IF;
  CLOSE csr_get_formula_id;

  END;
--
-- End of Person Change Causes Life Event rule for the Absence End LER
--
--
-- Start of Person Change Causes Life Event rule for the Absence Start LER
--
  BEGIN
    debug(l_proc_name,40);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB
      (--         1         2         3         4         5         6         7
       --1234567890123456789012345678901234567890123456789012345678901234567890
        'PQP_GB_BEN_LER_ABSENCE_START_EVENT_PERSON_CHANGES_RULE'
       --||l_uniquestamp
      ,1,80);

  OPEN csr_get_formula_id(p_business_group_id,l_formula_name);
  FETCH csr_get_formula_id INTO l_check_ler_formulas;
  IF csr_get_formula_id%NOTFOUND THEN
    debug(l_proc_name,42);
    l_formula_type:=  -- VARCHAR2(80)
      'Person Change Causes Life Event';
    l_description:= -- VARCHAR2(240)
       'Sample rule to detect a new or changed absence entry.';
    debug(l_proc_name,45);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_LER_ABSENCE_START_EVENT_PERSON_CHANGES_RULE
  Formula Type: Person Change Causes Life Event
  Description : Sample formula to detect a new or changed absence entry.

DISCLAIMER  :
 In future releases of HRMS programs, Oracle Corporation may change or
 upgrade this formula, and all other definitions for the predefined template
 of which this formula is a part.  We do not guarantee that the  formula and the
 predefined template will provide a ready-made solution to be used in your
 environment. If the formula does not reflect your business rules,  you are
 responsible for writing a formula of your own to meet your particular
 requirements. Any use of this  formula and the predefined extract is subject to
 the terms of the Oracle license agreement for the HRMS programs and
 documentation.

**Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/
/*
Set default values.
*/
DEFAULT FOR BEN_ABA_IN_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABS_INFORMATION1           IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABS_INFORMATION1           IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABS_INFORMATION2           IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABS_INFORMATION2           IS ''_DEFAULT_''

/* Other inputs available are
DEFAULT FOR BEN_ABA_IN_PERSON_ID                  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_PERSON_ID                  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABS_ATTENDANCE_REASON_ID   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABS_ATTENDANCE_REASON_ID   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_SICKNESS_START_DATE        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_SICKNESS_START_DATE        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_SICKNESS_END_DATE          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_SICKNESS_END_DATE          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_DAYS               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_DAYS               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABSENCE_HOURS              IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABSENCE_HOURS              IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_NOTIFICATION          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_NOTIFICATION          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_DATE_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_DATE_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_PROJECTED_END         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_TIME_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_TIME_PROJECTED_START       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABS_INFORMATION1           IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ABS_INFORMATION2           IS ''_DEFAULT_''
...
DEFAULT FOR BEN_ABA_IN_ABS_INFORMATION30          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABS_INFORMATION1           IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ABS_INFORMATION2           IS ''_DEFAULT_''
...
DEFAULT FOR BEN_ABA_IO_ABS_INFORMATION30          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ATTRIBUTE1                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IN_ATTRIBUTE2                 IS ''_DEFAULT_''
...
DEFAULT FOR BEN_ABA_IN_ATTRIBUTE20                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ATTRIBUTE1                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABA_IO_ATTRIBUTE2                 IS ''_DEFAULT_''
...
DEFAULT FOR BEN_ABA_IO_ATTRIBUTE20                IS ''_DEFAULT_''
*/

/*
Declare Input values.

NOTE the naming convention followed
     BEN_ABA_IN_<Column Name> - New Values
     BEN_ABA_IO_<Column Name> - Old Values
*/

INPUTS ARE BEN_ABA_IN_DATE_START(TEXT)
          ,BEN_ABA_IO_DATE_START(TEXT)
          ,BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
          ,BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
          ,BEN_ABA_IO_ABS_INFORMATION1(TEXT)
          ,BEN_ABA_IN_ABS_INFORMATION1(TEXT)
          ,BEN_ABA_IO_ABS_INFORMATION2(TEXT)
          ,BEN_ABA_IN_ABS_INFORMATION2(TEXT)
/* Other inputs available are
          ,BEN_ABA_IN_PERSON_ID(TEXT)
          ,BEN_ABA_IO_PERSON_ID(TEXT)
          ,BEN_ABA_IN_DATE_END(TEXT)
          ,BEN_ABA_IO_DATE_END(TEXT)
          ,BEN_ABA_IN_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABA_IO_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABA_IN_SICKNESS_START_DATE(TEXT)
          ,BEN_ABA_IO_SICKNESS_START_DATE(TEXT)
          ,BEN_ABA_IN_SICKNESS_END_DATE(TEXT)
          ,BEN_ABA_IO_SICKNESS_END_DATE(TEXT)
          ,BEN_ABA_IN_ABSENCE_DAYS(TEXT)
          ,BEN_ABA_IO_ABSENCE_DAYS(TEXT)
          ,BEN_ABA_IN_ABSENCE_HOURS(TEXT)
          ,BEN_ABA_IO_ABSENCE_HOURS(TEXT)
          ,BEN_ABA_IN_DATE_NOTIFICATION(TEXT)
          ,BEN_ABA_IO_DATE_NOTIFICATION(TEXT)
          ,BEN_ABA_IN_DATE_PROJECTED_END(TEXT)
          ,BEN_ABA_IO_DATE_PROJECTED_END(TEXT)
          ,BEN_ABA_IN_DATE_PROJECTED_START(TEXT)
          ,BEN_ABA_IO_DATE_PROJECTED_START(TEXT)
          ,BEN_ABA_IN_TIME_END(TEXT)
          ,BEN_ABA_IO_TIME_END(TEXT)
          ,BEN_ABA_IN_TIME_PROJECTED_END(TEXT)
          ,BEN_ABA_IO_TIME_PROJECTED_END(TEXT)
          ,BEN_ABA_IN_TIME_PROJECTED_START(TEXT)
          ,BEN_ABA_IO_TIME_PROJECTED_START(TEXT)
*/

/*
Initialise values.
*/

l_default                      = ''_DEFAULT_'' /* TEXT */
l_yn                           = ''N''         /* TEXT */

/* Begin Absence Start Date Section
*/

/* 01. Determine the old and new values for DATE_START

   NOTE Though these values are stored as dates or numbers they are made
   available to the formula as TEXT inputs.

   The dates are available in the default canoncial format of
   "YYYY/MM/DD HH24:MI:SS".
   Where required, use TO_DATE to convert text into a date.

   The numbers are available in the default canonical format.
   Where required, use TO_NUMBER to convert into text into a number.
*/

l_date_start_old_value         = BEN_ABA_IO_DATE_START
l_date_start_new_value         = BEN_ABA_IN_DATE_START
l_absence_type_id_new_value    = BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID

/* 02a. Check that there is a difference between the old and new values of
       DATE_START.

   NOTE When an absence is deleted, the absence_type_id new value will be
   defaulted. To record an absence delete a seperate life event reason has
   to be setup. To prevent a absence start change from being logged on a
   delete, an additional check is introduced to ensure that new value is not
   equal to the default.
*/

IF NOT l_date_start_old_value = l_date_start_new_value
  AND
   NOT l_absence_type_id_new_value = l_default
THEN
 (
  /* 02b. Set the return flag to "Y"es to allow this person change to cause an
          "absence start" life event.

     NOTE the default for the flag is "N"o.
  */
  l_yn = ''Y''
 )

/* End Absence Start Date Section
*/

l_debug_message = ''End Absence Start Date Section:''||l_yn
l_debug = DEBUG(l_debug_message)


/* Begin Absence Information 1 - Start Date Fraction Section
*/

/* 03a. Check that there is a difference between the old and new values of
       ABS_INFORMATION1.

   NOTE This is an example of how this formula may be extended to trigger the
   absence start life event reason for other changes on absences.

   First check that life event flag is set to "N", i.e. the previous absence
   change hasn''t already caused a valid person change to cause the life event.
*/

IF l_yn = ''N'' THEN
 (

  l_abs_information1_old_value = BEN_ABA_IO_ABS_INFORMATION1
  l_abs_information1_new_value = BEN_ABA_IN_ABS_INFORMATION1

  IF NOT l_abs_information1_old_value = l_abs_information1_new_value
    AND
     NOT l_absence_type_id_new_value = l_default
  THEN
   (
    l_yn = ''Y''
   )
 )

/* End Absence Information 1 - Start Date Fraction Section
*/

l_debug_message = ''End Absence Information 1 Section:''||l_yn
l_debug = DEBUG(l_debug_message)


/* Begin Absence Information 2 - End Date Fraction Section
*/

/* 03a. Check that there is a difference between the old and new values of
       ABS_INFORMATION1.

   NOTE This is an example of how this formula may be extended to trigger the
   absence start life event reason for other changes on absences.

   First check that life event flag is set to "N", i.e. the previous absence
   change hasn''t already caused a valid person change to cause the life event.
*/

IF l_yn = ''N'' THEN
 (

  l_abs_information2_old_value = BEN_ABA_IO_ABS_INFORMATION2
  l_abs_information2_new_value = BEN_ABA_IN_ABS_INFORMATION2

  IF NOT l_abs_information2_old_value = l_abs_information2_new_value
    AND
     NOT l_absence_type_id_new_value = l_default
  THEN
   (
    l_yn = ''Y''
   )
 )

/* End Absence Information 2 - End Date Fraction Section
*/

/* Begin Absence Days Section
*/

/* 03a. Check that there is a difference between the old and new values of
       ABSENCE_DAYS.

   NOTE This is an example of how this formula may be extended to trigger the
   absence start life event reason for other changes on absences.

   First check that life event flag is set to "N", i.e. the previous absence
   change hasn''t already caused a valid person change to cause the life event.
*/

/*
IF l_yn = ''N'' THEN
 (
  l_absence_days_old_value = BEN_ABA_IO_ABSENCE_DAYS
  l_absence_days_new_value = BEN_ABA_IN_ABSENCE_DAYS

  IF NOT l_absence_days_old_value = l_absence_days_new_value
    AND
     NOT l_absence_type_id_new_value = l_default
  THEN
   (
    l_yn = ''Y''
   )
 )
*/

/* End Absence Days Section
*/

RETURN l_yn
';
    debug(l_proc_name,47);
    SELECT formula_type_id
    INTO   l_formula_type_id
    FROM   ff_formula_types
    WHERE  formula_type_name = l_formula_type;

    debug(l_proc_name,49);
    l_formula_count := l_formula_count + 1;
    INSERT INTO ff_formulas_f
      (formula_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,legislation_code
      ,formula_type_id
      ,formula_name
      ,description
      ,formula_text
      ,sticky_flag)
    VALUES(ff_formulas_s.NEXTVAL
      ,l_effective_start_date
      ,l_effective_end_date
      ,l_business_group_id
      ,l_legislation_code
      ,l_formula_type_id
      ,l_formula_name
      ,l_description
      ,NULL
      ,NULL
       )
--    WHERE NOT EXISTS
--           (SELECT 1
--            FROM   ff_formulas_f
--            WHERE  formula_name = l_formula_name
--              AND  business_group_id = l_business_group_id
--           )
    RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

  END IF;
  CLOSE csr_get_formula_id;

  END;
--
-- End of Person Change Causes Life Event rule for the Absence Start LER
--
--
-- Start of OSP specific section
--
  IF UPPER(p_absence_pay_plan_category) = 'SICKNESS' THEN
--
-- Start of OSP Participation and Rate Eligibility rule.
--
  BEGIN
    debug(l_proc_name,50);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB(l_base_name||
            --         1         2         3         4         5
            --12345678901234567890123456789012345678901234567890
             '_OSP_PARTICIPATION_ELIGIBILTY_PROFILE_OTHER_RULE'
             ,1,80);
    debug(l_proc_name,52);
    l_formula_type:=  -- VARCHAR2(80)
      'Participation and Rate Eligibility';
    l_description:= -- VARCHAR2(240)
       'Sample OSP rule for a benefits elibility profile to check for valid'||
       ' OSP absence types.';
    debug(l_proc_name,55);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_OSP_PARTICIPATION_ELIGIBILTY_PROFILE_OTHER_RULE
  Formula Type: Participation and Rate Eligibility
  Description : Sample OSP rule for a benefits elibility profile to check for
                valid OSP absence types.

                NOTE: If you have multiple OSP Plans this formula must either be
                extended and/or used with other attribute definitions of the
                eligibilty profile to ensure that an employee can only be
                eligible to one OSP plan at a time.

DISCLAIMER  :
  In future releases of HRMS programs, Oracle Corporation may change or
  upgrade this formula, and all other definitions for the predefined template
  of which this formula is a part.  We do not guarantee that the  formula and
  the predefined template will provide a ready-made solution to be used in your
  environment. If the formula does not reflect your business rules,  you are
  responsible for writing a formula of your own to meet your particular
  requirements. Any use of this  formula and the predefined extract is subject
  to the terms of the Oracle license agreement for the HRMS programs and
  documentation.

  Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/
/*
Set default values.
*/
  DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY IS ''_DEFAULT_''
  DEFAULT FOR BEN_ABS_ABSENCE_TYPE_ID  IS -987123654

/*
Initialise values.
*/

  l_yn                           = ''N'' /* Text Return value - Not eligible */
  l_error                        = 0     /* Number */
  l_absence_type_lookup_code     = '' '' /* Text */
  l_absence_type_list_name       = '' '' /* Text */
  l_truncated_yes_no             = '' '' /* Text */
  l_error_message                = '' '' /* Text */
  l_absence_type_meaning         = '' '' /* Text */
  l_absence_category             = '' '' /* Text */


  /* 01. Determine the type of the current absence.

     NOTE we need to convert the type identifier into TEXT as this identifier
     is used later as a lookup code.
  */

  l_absence_type_lookup_code = TO_TEXT(BEN_ABS_ABSENCE_TYPE_ID)

  /* 02. Determine the name of the list of eligible absence types for this OSP
         plan.

     NOTE the absence types "list name" is stored in a flexfield segment on
     the element extra information related to current plan.
  */

  l_error =
    PQP_GB_OSP_GET_EXTRA_PLAN_INFORMATION
     (''Absence Types List Name''
     ,l_absence_type_list_name
     ,l_truncated_yes_no
     ,l_error_message
     )

  /* 03a. Check that the absence type is one of those listed in the absence
          types list for this OSP plan.

     NOTE to check that the absence type is a valid, get the lookup meaning
     using the absence type identifier as a lookup code with the absence type
     list name as the lookup type.
  */
  IF l_error = 0 THEN
   (
    l_absence_type_meaning
      = GET_LOOKUP_MEANING
        (l_absence_type_list_name
        ,l_absence_type_lookup_code
        )

    /* 03b. Check that the absence type is one of those listed in the absence
            types list for this OSP plan.

       NOTE if a lookup meaning was found then type of the current
       absence is a eligible one. Return eligible flag as "Y"es.
    */

    IF NOT ISNULL(l_absence_type_meaning) = ''Y'' THEN
     (
      l_yn = ''Y''
     )

   )

  ELIGIBLE = l_yn
  RETURN ELIGIBLE
';

  debug(l_proc_name,57);
  SELECT formula_type_id
  INTO   l_formula_type_id
  FROM   ff_formula_types
  WHERE  formula_type_name = l_formula_type;

  debug(l_proc_name,59);
  l_formula_count := l_formula_count + 1;
  INSERT INTO ff_formulas_f
    (formula_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_type_id
    ,formula_name
    ,description
    ,formula_text
    ,sticky_flag)
  VALUES(ff_formulas_s.NEXTVAL
    ,p_effective_date
    ,l_effective_end_date
    ,l_business_group_id
    ,l_legislation_code
    ,l_formula_type_id
    ,l_formula_name
    ,l_description
    ,NULL
    ,NULL
    )
--  WHERE NOT EXISTS
--         (SELECT 1
--          FROM   ff_formulas_f
--          WHERE  formula_name = l_formula_name
--            AND  business_group_id = l_business_group_id
--         )
  RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

  END;
--
-- End of OSP Participation and Rate Eligibility rule.
--
--
-- Start of OSP Rate Value Calculation rule.
--
  BEGIN

  debug(l_proc_name,60);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB(l_base_name||
            --         1         2         3         4         5
            --12345678901234567890123456789012345678901234567890
             '_OSP_STANDARD_RATES_CALCULATION_METHOD_VALUE_RULE'
             --||l_uniquestamp
             ,1,80);
  debug(l_proc_name,62);
    l_formula_type:=  -- VARCHAR2(80)
      'Rate Value Calculation';
    l_description:= -- VARCHAR2(240)
      'Sample OSP rule for a benefits standard rate to calculate length of'||
      ' service.';

  debug(l_proc_name,65);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_OSP_STANDARD_RATES_CALCULATION_METHOD_VALUE_RULE
  Formula Type: Rate Value Calculation
  Description : Sample OSP rule for a benefits standard rate to calculate length
                of service.

DISCLAIMER  :
  In future releases of HRMS programs, Oracle Corporation may change or
  upgrade this formula, and all other definitions for the predefined template
  of which this formula is a part.  We do not guarantee that the  formula and
  the predefined template will provide a ready-made solution to be used in your
  environment. If the formula does not reflect your business rules,  you are
  responsible for writing a formula of your own to meet your particular
  requirements. Any use of this  formula and the predefined extract is subject
  to the terms of the Oracle license agreement for the HRMS programs and
  documentation.

  Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/
/*
Set default values.
*/
  DEFAULT FOR BEN_ABS_DATE_START IS ''1951/01/01 00:00:00''(date)
  DEFAULT FOR EMP_HIRE_DATE      IS ''1951/01/01 00:00:00''(date)

/*
Initialise standard default values.
*/
  l_null                         = RPAD(''X'',0,''Y'')
  l_default                      = ''_DEFAULT_''
  l_default_date                 = ''1951/01/01 00:00:00''(date)
  l_default_canonical_date       = ''1951/01/01 00:00:00''
  l_default_number               = -987123654
  l_default_canonical_number     = ''-987123654''


  l_length_of_service            = -987123654

/* 01. Determine the absence start date and the employee hire date.
*/
  l_absence_start_date           = BEN_ABS_DATE_START
  l_employee_hire_date           = EMP_HIRE_DATE

  /* 02a. Check that a absence start date is available for processing.

     NOTE If an absence start date was not found, it will be set as default.
     This may occur if this rate value calulcation formula is being used in a
     plan which does not have an absence "context" available. Please check, and
     if required correct,
      i. the Option Type of the associated Plan Type is set as "Absences".
     ii. the Type of the associated Life Event Reasons are set as "Absence".
  */
  IF NOT l_absence_start_date = l_default_date THEN
   (
    /* 02b. Check that a absence start date is available for processing.

       NOTE If an employee hire date was not found, it will be defaulted.
       This may occur if the the person was not of an eligible person type.
       Please check, and if required correct, the associated eligibilty
       profile to ensure that only people with a Person Type of "Employee"
       are selected for plan enrollment.
    */
    IF NOT l_employee_hire_date = l_default_date THEN
     (
      /* 03. Calculate the length of service.

         NOTE the sample OSP scheme uses "Months" as the unit of measure for
         evaluating length of service based eligibility of OSP entitlements.
         The month is rounded down to the nearest interger, by using the
         FLOOR function.

      */

      l_length_of_service
        = FLOOR
           (MONTHS_BETWEEN
             (l_absence_start_date  /* later date first */
             ,l_employee_hire_date
             )
           )
     )

   )

LENGTH_OF_SERVICE = l_length_of_service
RETURN LENGTH_OF_SERVICE
    ';

  debug(l_proc_name,67);
  SELECT formula_type_id
  INTO   l_formula_type_id
  FROM   ff_formula_types
  WHERE  formula_type_name = l_formula_type;

  debug(l_proc_name,69);
  l_formula_count := l_formula_count + 1;
  INSERT INTO ff_formulas_f
    (formula_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_type_id
    ,formula_name
    ,description
    ,formula_text
    ,sticky_flag)
  VALUES(ff_formulas_s.NEXTVAL
    ,p_effective_date
    ,l_effective_end_date
    ,l_business_group_id
    ,l_legislation_code
    ,l_formula_type_id
    ,l_formula_name
    ,l_description
    ,NULL
    ,NULL
    )
--  WHERE NOT EXISTS
--         (SELECT 1
--          FROM   ff_formulas_f
--          WHERE  formula_name = l_formula_name
--            AND  business_group_id = l_business_group_id
--         )
  RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

--hr_utility.trace('Updated '||SQL%ROWCOUNT||' formulae.');


  END;
--
-- End of OSP Rate Value Calculation rule.
--
--
-- Start of OSP (Extra Inputs) Rate Value Calculation rule.
--
  BEGIN

  debug(l_proc_name,70);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB(l_base_name||
            --         1         2         3         4         5
            --12345678901234567890123456789012345678901234567890
             '_OSP_STANDARD_RATES_GENERAL_EXTRA_INPUT_RULE'
             --||l_uniquestamp
             ,1,80);
  debug(l_proc_name,72);
    l_formula_type:=  -- VARCHAR2(80)
      'Extra Input'; -- to change with new formula type ??BEN??
    l_description:= -- VARCHAR2(240)
      'Sample OSP rule for a benefits standard rate to feed extra input'||
      ' values to an element entry.';

  debug(l_proc_name,75);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_OSP_STANDARD_RATES_GENERAL_EXTRA_INPUT_RULE
  Formula Type: Rate Value Calculation
  Description : Sample OSP rule for a benefits standard rate to feed extra input
                values to an element entry.

DISCLAIMER  :
  In future releases of HRMS programs, Oracle Corporation may change or
  upgrade this formula, and all other definitions for the predefined template
  of which this formula is a part.  We do not guarantee that the  formula and
  the predefined template will provide a ready-made solution to be used in your
  environment. If the formula does not reflect your business rules,  you are
  responsible for writing a formula of your own to meet your particular
  requirements. Any use of this  formula and the predefined extract is subject
  to the terms of the Oracle license agreement for the HRMS programs and
  documentation.

  Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/

/*
Set default values for database items.
*/
DEFAULT FOR BEN_ABS_ABSENCE_TYPE          IS ''_DEFAULT_''
DEFAULT FOR BEN_PLN_PL_ID                 IS -987123654

/* Other DB Items available
DEFAULT FOR BEN_ABS_ABSENCE_TYPE_ID       IS -987123654
DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY      IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY_CODE IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY_ID   IS -987123654
DEFAULT FOR BEN_ABS_REASON                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_REASON_CODE           IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_REASON_ID             IS -987123654
DEFAULT FOR BEN_ABS_DATE_START            IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_DATE_END              IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_SICKNESS_START_DATE   IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_SICKNESS_END_DATE     IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_DATE_NOTIFIED         IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_DUE_DATE              IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_MPP_START_DATE        IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_ACTUAL_BIRTH_DATE     IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_LIVE_BIRTH_FLAG       IS ''Y''
DEFAULT FOR BEN_SSP_EVIDENCE_DATE         IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SSP_EVIDENCE_SOURCE       IS ''_DEFAULT_''
DEFAULT FOR BEN_SSP_MEDICAL_TYPE          IS ''SICKNESS''
DEFAULT FOR BEN_SSP_EVIDENCE_STATUS       IS ''ACTIVE''
DEFAULT FOR BEN_SSP_SELF_CERTIFICATE      IS ''N''

DEFAULT FOR BEN_ABS_ACCEPT_LATE_NOTIFICATION_FLAG IS ''Y''
DEFAULT FOR BEN_ABS_PREGNANCY_RELATED_ILLNESS IS ''N''
DEFAULT FOR BEN_SMP_NOTIFICATION_OF_BIRTH_DATE IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SSP_EVIDENCE_RECEIVED_DATE IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SSP_ACCEPT_LATE_EVIDENCE_FLAG IS ''Y''
*/

/*
Set default values for formula inputs.
*/
DEFAULT FOR BEN_ABS_IV_ABSENCE_ATTENDANCE_ID      IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABSENCE_DAYS               IS ''_DEFAULT_''

/* Other Inputs Available
DEFAULT FOR BEN_ABS_IV_ABS_ATTENDANCE_REASON_ID  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABSENCE_HOURS             IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_NOTIFICATION         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_PROJECTED_END        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_PROJECTED_START      IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_SSP1_ISSUED               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_LINKED_ABSENCE_ID         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_SICKNESS_START_DATE       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_SICKNESS_END_DATE         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_PREGNANCY_RELATED_ILLNESS IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_MATERNITY_ID              IS ''_DEFAULT_''
DEFAULT FOR BEN_PIL_IV_PER_IN_LER_ID             IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE_CATEGORY        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE1                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE2                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE3                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE4                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE5                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE6                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE7                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION_CATEGORY  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION1          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION2          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION3          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION4          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION5          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION6          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION7          IS ''_DEFAULT_''
*/

/*
Declare Input values.

NOTE the naming convention followed
     BEN_ABS_IV_<Column Name>
*/

INPUTS ARE BEN_ABS_IV_ABSENCE_ATTENDANCE_ID(TEXT)
          ,BEN_ABS_IV_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
          ,BEN_ABS_IV_DATE_START(TEXT)
          ,BEN_ABS_IV_DATE_END(TEXT)
          ,BEN_ABS_IV_ABSENCE_DAYS(TEXT)
/* Other Inputs Available
          ,BEN_ABS_IV_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABS_IV_ABSENCE_HOURS(TEXT)
          ,BEN_ABS_IV_DATE_NOTIFICATION(TEXT)
          ,BEN_ABS_IV_DATE_PROJECTED_END(TEXT)
          ,BEN_ABS_IV_DATE_PROJECTED_START(TEXT)
          ,BEN_ABS_IV_SSP1_ISSUED(TEXT)
          ,BEN_ABS_IV_LINKED_ABSENCE_ID(TEXT)
          ,BEN_ABS_IV_SICKNESS_START_DATE(TEXT)
          ,BEN_ABS_IV_SICKNESS_END_DATE(TEXT)
          ,BEN_ABS_IV_PREGNANCY_RELATED_ILLNESS(TEXT)
          ,BEN_ABS_IV_MATERNITY_ID(TEXT)
          ,BEN_PIL_IV_PER_IN_LER_ID(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE_CATEGORY(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE1(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE2(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE3(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE4(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE5(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE6(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE7(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION_CATEGORY(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION1(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION2(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION3(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION4(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION5(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION6(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION7(TEXT)
*/


/*
Initialise standard default values.
*/
l_null                         = RPAD(''X'',0,''Y'')
l_default                      = ''_DEFAULT_''
l_default_date                 = ''1951/01/01 00:00:00''(date)
l_default_canonical_date       = ''1951/01/01 00:00:00''
l_default_number               = -987123654
l_default_canonical_number     = ''-987123654''



l_absence_id_iv = BEN_ABS_IV_ABSENCE_ATTENDANCE_ID

/* 01a. Check that the absence attendance id input was not defaulted

   NOTE If an absence attendance id was not found, it will be set as default.
   This may occur if this rate value calulcation formula is being used in a
   plan which does not have an absence "context" available.
   Please check, and if required correct,
    i. the Option Type of the associated Plan Type is set as "Absences".
   ii. the Type of the associated Life Event Reasons are set as "Absence".
*/
IF NOT l_absence_id_iv = l_default THEN
 (
  /* 02a. Determine the absence details that need to be fed to element input
       values.

   NOTE Though these values are stored as dates or numbers they are made
   available to the formula as TEXT inputs.

   The dates are available in the default canonical format of
   "YYYY/MM/DD HH24:MI:SS".
   Where required, use TO_DATE to convert text into a date.

   The numbers are available in the default canonical format.
   Where required, use TO_NUMBER to convert into text into a number.
  */

  l_absence_id = TO_NUMBER(l_absence_id_iv)

  l_plan_id = BEN_PLN_PL_ID

  /*l_absence_start_date_dt_iv = l_default_date*/
  l_absence_start_date_dt_iv = TO_DATE(BEN_ABS_IV_DATE_START,''YYYY/MM/DD HH24:MI:SS'')

  l_absence_start_date = PQP_DATE_TO_DISPLAYDATE(l_absence_start_date_dt_iv)

  l_absence_type = BEN_ABS_ABSENCE_TYPE

  l_absence_end_date_iv = BEN_ABS_IV_DATE_END

  /* 02b. Check that absence end date is available.
  */
  IF NOT l_absence_end_date_iv = l_default THEN
   (
     l_absence_end_date
       = PQP_DATE_TO_DISPLAYDATE(TO_DATE(l_absence_end_date_iv,''YYYY/MM/DD HH24:MI:SS''))
   )
  ELSE
   (
     l_absence_end_date = l_null
   )

  /* 03. Set the reserved return value "SUBPRIORITY".

   NOTE
   SUBPRIORITY - is a reserved return value name for this formula type.
   This value is used the populate the Subpriority field of the element entry,
   which the asscoiated standard rate feeds.

   Element entry subpriority is used to control the processing order of entries
   of element types with multiple entries allowed.

   Absences for OSP/OMP purposes must be processed in the chronological order of
   their occurence and not in the order in which they were entered in the
   system.

   For this purpose, it is recommended that SUBPRIORITY must always be a number
   directly proportional to the absence start date.

   If multiple element entries are used to process pay for the same absence then
   the element designated as the primary element may need to be processed before
   the secondary elements.

   This formula uses a seeded function,
   PQP_GAP_GET_ABSENCE_ELEMENT_ENTRY_SUBPRIORITY, that computes a SUBPRIORITY
   based on the Julian value of a given date. The given date being the
   absence start date.

  */

   SUBPRIORITY =
     PQP_GAP_GET_ABSENCE_ELEMENT_ENTRY_SUBPRIORITY(l_absence_start_date_dt_iv)


 )
/* 02b. Check that the absence attendance id input was not defaulted

   NOTE If an absence attendance id was not found, it will be set as default.
   all return values should then be returned as null
*/
ELSE
 (
  l_absence_id                   = l_default_number
  l_plan_id                      = l_default_number
  l_absence_start_date           = l_null
  l_absence_end_date             = l_null
  l_absence_type                 = l_null
  SUBPRIORITY                    = TO_NUMBER(l_null)
 )

RETURN l_absence_id
      ,l_plan_id
      ,l_absence_start_date
      ,l_absence_end_date
      ,l_absence_type
      ,SUBPRIORITY
';

  debug(l_proc_name,77);
  SELECT formula_type_id
  INTO   l_formula_type_id
  FROM   ff_formula_types
  WHERE  formula_type_name = l_formula_type;

  debug(l_proc_name,79);
  l_formula_count := l_formula_count + 1;
  INSERT INTO ff_formulas_f
    (formula_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_type_id
    ,formula_name
    ,description
    ,formula_text
    ,sticky_flag)
  VALUES(ff_formulas_s.NEXTVAL
    ,p_effective_date
    ,l_effective_end_date
    ,l_business_group_id
    ,l_legislation_code
    ,l_formula_type_id
    ,l_formula_name
    ,l_description
    ,NULL
    ,NULL
    )
--  WHERE NOT EXISTS
--         (SELECT 1
--          FROM   ff_formulas_f
--          WHERE  formula_name = l_formula_name
--            AND  business_group_id = l_business_group_id
--         )
   RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

  END;
--
-- End of OSP (Extra Inputs) Rate Value Calculation rule.
--

  END IF; -- IF UPPER(p_absence_pay_plan_category) = 'SICKNESS' THEN

  IF UPPER(p_absence_pay_plan_category) = 'MATERNITY' THEN
--
-- Start of Participation and Rate Eligibility rule.
--
  BEGIN
  debug(l_proc_name,80);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB(l_base_name||
            --         1         2         3         4         5
            --12345678901234567890123456789012345678901234567890
             '_OMP_PARTICIPATION_ELIGIBILTY_PROFILE_OTHER_RULE'
             --||l_uniquestamp
             ,1,80);
  debug(l_proc_name,82);
    l_formula_type:=  -- VARCHAR2(80)
      'Participation and Rate Eligibility';
    l_description:= -- VARCHAR2(240)

       'Sample OMP rule for a benefits elibility profile to check for valid'||
       ' OMP absence types.';

  debug(l_proc_name,85);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_OMP_PARTICIPATION_ELIGIBILTY_PROFILE_OTHER_RULE
  Formula Type: Participation and Rate Eligibility
  Description : Sample OMP rule for a benefits elibility profile to check for
                valid OMP absence types.

                NOTE: If you have multiple OMP Plans this formula must either be
                extended and/or used with other attribute definitions of the
                eligibilty profile to ensure that an employee can only be
                eligible to one OMP plan at a time.

DISCLAIMER  :
  In future releases of HRMS programs, Oracle Corporation may change or
  upgrade this formula, and all other definitions for the predefined template
  of which this formula is a part.  We do not guarantee that the  formula and
  the predefined template will provide a ready-made solution to be used in your
  environment. If the formula does not reflect your business rules,  you are
  responsible for writing a formula of your own to meet your particular
  requirements. Any use of this  formula and the predefined extract is subject
  to the terms of the Oracle license agreement for the HRMS programs and
  documentation.

  Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/
/*
Set default values.
*/
  DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY IS ''_DEFAULT_''
  DEFAULT FOR BEN_ABS_ABSENCE_TYPE_ID  IS -987123654

/*
Initialise values.
*/

  l_yn                           = ''N'' /* Text Return value - Not eligible */
  l_error                        = 0     /* Number */
  l_absence_type_lookup_code     = '' '' /* Text */
  l_absence_type_list_name       = '' '' /* Text */
  l_truncated_yes_no             = '' '' /* Text */
  l_error_message                = '' '' /* Text */
  l_absence_type_meaning         = '' '' /* Text */
  l_absence_category             = '' '' /* Text */

  /* 02. Determine the type of the current absence.

     NOTE we need to convert the type identifier into TEXT as this identifier
     is used later as a lookup code.
  */

  l_absence_type_lookup_code = TO_TEXT(BEN_ABS_ABSENCE_TYPE_ID)

  /* 03. Determine the name of the list of eligible absence types for this OMP
         plan.

     NOTE the absence types "list name" is stored in a flexfield segment on
     the element extra information related to current plan.
  */

  l_error_code =
    PQP_GB_OMP_GET_EXTRA_PLAN_INFORMATION
     (''Absence Type List Name''
     ,l_absence_type_list_name
     ,l_truncated_yes_no
     ,l_error_message
     )

  /* 04a. Check that the absence type is one of those listed in the absence
          types list for this OMP plan.

     NOTE to check that the absence type is a valid, get the lookup meaning
     using the absence type identifier as a lookup code with the absence type
     list name as the lookup type.
  */
  IF l_error_code = 0 THEN
   (
    l_absence_type_meaning
      = GET_LOOKUP_MEANING
        (l_absence_type_list_name
        ,l_absence_type_lookup_code
        )

    /* 04b. Check that the absence type is one of those listed in the absence
            types list for this OMP plan.

       NOTE if a lookup meaning was found then type of the current
       absence is a eligible one. Return eligible flag as "Y"es.
    */

    IF NOT ISNULL(l_absence_type_meaning) = ''Y'' THEN
     (
      l_yn = ''Y''
     )

   ) /* END IF l_error_code = 0 PQP_GB_OMP_GET_EXTRA_PLAN_INFORMATION */

  ELIGIBLE = l_yn
  RETURN ELIGIBLE
';
  debug(l_proc_name,87);
  SELECT formula_type_id
  INTO   l_formula_type_id
  FROM   ff_formula_types
  WHERE  formula_type_name = l_formula_type;

  debug(l_proc_name,89);
  l_formula_count := l_formula_count + 1;
  INSERT INTO ff_formulas_f
    (formula_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_type_id
    ,formula_name
    ,description
    ,formula_text
    ,sticky_flag)
  VALUES(ff_formulas_s.NEXTVAL
    ,p_effective_date
    ,l_effective_end_date
    ,l_business_group_id
    ,l_legislation_code
    ,l_formula_type_id
    ,l_formula_name
    ,l_description
    ,NULL
    ,NULL
     )
--  WHERE NOT EXISTS
--         (SELECT 1
--          FROM   ff_formulas_f
--          WHERE  formula_name = l_formula_name
--            AND  business_group_id = l_business_group_id
--         )
  RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

  END;
--
-- End of Participation and Rate Eligibility rule.
--
--
-- Start of Rate Value Calculation rule.
--
  BEGIN
  debug(l_proc_name,90);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB(l_base_name||
            --         1         2         3         4         5
            --12345678901234567890123456789012345678901234567890
             '_OMP_STANDARD_RATES_CALCULATION_METHOD_VALUE_RULE'
             --||l_uniquestamp
             ,1,80);
  debug(l_proc_name,92);
    l_formula_type:=  -- VARCHAR2(80)
      'Rate Value Calculation';
    l_description:= -- VARCHAR2(240)
      'Sample OMP rule for a benefits standard rate to calculate length of'||
      ' service.';
  debug(l_proc_name,95);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_OMP_STANDARD_RATES_CALCULATION_METHOD_VALUE_RULE
  Formula Type: Rate Value Calculation
  Description : Sample OMP rule for a benefits standard rate to calculate length
                of service.

DISCLAIMER  :
  In future releases of HRMS programs, Oracle Corporation may change or
  upgrade this formula, and all other definitions for the predefined template
  of which this formula is a part.  We do not guarantee that the  formula and
  the predefined template will provide a ready-made solution to be used in your
  environment. If the formula does not reflect your business rules,  you are
  responsible for writing a formula of your own to meet your particular
  requirements. Any use of this  formula and the predefined extract is subject
  to the terms of the Oracle license agreement for the HRMS programs and
  documentation.

  Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/
/*
Set default values.
*/
  DEFAULT FOR BEN_ABS_DATE_START IS ''1951/01/01 00:00:00''(date)
  DEFAULT FOR EMP_HIRE_DATE      IS ''1951/01/01 00:00:00''(date)

/*
Initialise standard default values.
*/
  l_null                         = RPAD(''X'',0,''Y'')
  l_default                      = ''_DEFAULT_''
  l_default_date                 = ''1951/01/01 00:00:00''(date)
  l_default_canonical_date       = ''1951/01/01 00:00:00''
  l_default_number               = -987123654
  l_default_canonical_number     = ''-987123654''


  l_length_of_service            = -987123654

/* 01. Determine the absence start date and the employee hire date.
*/
  l_absence_start_date           = BEN_ABS_DATE_START
  l_employee_hire_date           = EMP_HIRE_DATE

/* 02a. Check that a absence start date is available for processing.

   NOTE If an absence start date was not found, it will be set as default.
   This may occur if this rate value calulcation formula is being used in a
   plan which does not have an absence "context" available. Please check, and if
   required correct,
    i. the Option Type of the associated Plan Type is set as "Absences".
   ii. the Type of the associated Life Event Reasons are set as "Absence".
*/
  IF NOT l_absence_start_date = l_default_date THEN
   (

    /* 02b. Check that a absence start date is available for processing.

       NOTE If an employee hire date was not found, it will be defaulted.
       This may occur if the the person was not of an eligible person type.
       Please check, and if required correct, the associated eligibilty
       profile to ensure that only people with a Person Type of "Employee"
       are selected for plan enrollment.
    */
    IF NOT l_employee_hire_date = l_default_date THEN
     (
      /* 03a. Determine the OMP Qualifying date.

         NOTE As a first step determine the OMP Qualifying Date Type.
         This can three possible values
         "S" - For SMP Qualifying Date
         "M" - For Maternity Start Date
         "P" - For a given duration Prior to the Expected Week of Confinement
               (EWC)
      */

      l_omp_qualifying_date_type = l_default
      l_truncated_yes_no         = l_default
      l_error_message            = l_default

      l_error_code =
        PQP_GB_OMP_GET_EXTRA_PLAN_INFORMATION
         (''OMP Qualifying Date Type''
         ,l_omp_qualifying_date_type
         ,l_truncated_yes_no
         ,l_error_message
         )

      IF l_error_code = 0 THEN
       (
        /* 03b. Determine the OMP Qualifying date.

           NOTE If the OMP Qualifying Date Type is ''S'' then it means that it
           is the same as SMP Qualifying Date. This date is available on the
           Maternity form as the field "Qualifying Week".
        */

        l_omp_qualifying_date = l_default_date

        IF l_omp_qualifying_date_type = ''S'' THEN
         (

          l_smp_qualifying_date_text =
             BEN_GET_MATERNITY
              (''Qualifying Week''
              ,l_error_code
              ,l_error_message
              )

          IF l_error_code = 0 THEN
           (
            l_omp_qualifying_date = TO_DATE(l_smp_qualifying_date_text,''YYYY/MM/DD HH24:MI:SS'')
           )
         )

        /* 03b. Determine the OMP Qualifying date.

           NOTE If the OMP Qualifying Date Type is ''M'' then it means that it
           is the same as Maternity Start Date. Maternity Start Date is start
           date of the maternity absence.
        */

        IF l_omp_qualifying_date_type = ''M'' THEN
         (
          l_omp_qualifying_date = l_absence_start_date
         )

        /* 03b. Determine the OMP Qualifying date.

           NOTE If the OMP Qualifying Date Type is ''P'' then it means that the
           OMP Qualifying Date has to be derived as a given period prior to the
           expected week of confinement (EWC).

           The period is defined as extra information on the OMP Plan(as setup
           in the OMP template form). The period is defined as a given
           "Duration" of a certain "UOM", prior to the EWC.

           EWC is available on the Maternity form.
        */


        IF l_omp_qualifying_date_type = ''P'' THEN
         (

          /* 03c. Determine the "Prior to EWC Duration".

             NOTE To access the OMP Plan rules and regulations as defined on the
             OMP template form. Use PQP_GB_OMP_GET_EXTRA_PLAN_INFORMATION.
             All values returned by this function are always TEXT datatype. If
             the expected value is a NUMBER/DATE appropriate conversions might
             be required before using the value.
          */

          l_prior_to_ewc_duration_text = l_default_canonical_number
          l_error_code =
           PQP_GB_OMP_GET_EXTRA_PLAN_INFORMATION
            (''Prior to EWC Duration''
            ,l_prior_to_ewc_duration_text
            ,l_truncated_yes_no
            ,l_error_message
            )
          l_prior_to_ewc_duration = TO_NUMBER(l_prior_to_ewc_duration_text)

          /* 03c. Determine the "Prior to EWC UOM".

             NOTE To access the OMP Plan rules and regulations as defined on the
             OMP template form. Use PQP_GB_OMP_GET_EXTRA_PLAN_INFORMATION.
             All values returned by this function are always TEXT datatype. If
             the expected value is a NUMBER/DATE appropriate conversions might
             be required before using the value.

             "Prior to EWC UOM" has three possible values.

               i. DAYS
              ii. WEEKS
             iii. MONTHS
          */
          l_prior_to_ewc_uom = l_default
          l_error_code =
           PQP_GB_OMP_GET_EXTRA_PLAN_INFORMATION
            (''Prior to EWC UOM''
            ,l_prior_to_ewc_uom
            ,l_truncated_yes_no
            ,l_error_message
            )

          /* 03c. Determine the EWC date.

             NOTE This value is available on the Maternity form. To access
             details as seen on the Maternity form use the PQP_GET_MATERNITY
             function, passing the appropriate field name.
             All values returned by the this function are always TEXT
             datatype.If the expected value is a NUMBER/DATE appropriate
             conversions might be required before using the value.
          */
          l_ewc_text =
               BEN_GET_MATERNITY
                  (''EWC''
                  ,l_error_code
                  ,l_error_message
                  )

          IF l_error_code = 0 THEN
           (
            l_ewc = TO_DATE(l_ewc_text,''YYYY/MM/DD HH24:MI:SS'')

            /* 03c. Calculate the OMP Qualifying Date as

                 EWC - (Duration) Days
               or
                 EWC - (Duration)*7 Days (If UOM is Weeks)
               or
                 EWC - (Duration) Months
            */

            IF l_prior_to_ewc_uom = ''DAYS'' THEN
             (
               l_omp_qualifying_date =
                 ADD_DAYS
                  (l_ewc
                  ,- l_prior_to_ewc_duration
                  )
             )

            IF l_prior_to_ewc_uom = ''WEEKS'' THEN
             (
               l_omp_qualifying_date =
                 ADD_DAYS
                  (l_ewc
                  ,-l_prior_to_ewc_duration * 7
                 )
             )

            IF l_prior_to_ewc_uom = ''MONTHS'' THEN
             (
               l_omp_qualifying_date =
                 ADD_MONTHS
                  (l_ewc
                  ,-l_prior_to_ewc_duration
                  )
             )

           ) /* END IF NOT l_error_code = 0 BEN_GET_MATERNITY(EWC) */

         ) /* END IF l_omp_qualifying_date_type = ''P'' */

        /* 04. Calculate the length of service as the period between the
               employee hire date and the OMP qualifying date.

           NOTE The length of service for the sample OMP scheme is measured
           in weeks.The week is rounded down to the nearest interger, by
           using the FLOOR function.
        */

        IF NOT l_omp_qualifying_date = l_default_date THEN
         (
           l_length_of_service =
             FLOOR(DAYS_BETWEEN(l_omp_qualifying_date,l_employee_hire_date)/7)
         )

       ) /* END IF NOT l_error_code = 0 OMP Qualifying Date Type */

     ) /* END IF NOT l_employee_hire_date = l_default_date */

   ) /* END IF NOT l_absence_start_date = l_default_date THEN */

RETURN l_length_of_service
';

  debug(l_proc_name,97);
  SELECT formula_type_id
  INTO   l_formula_type_id
  FROM   ff_formula_types
  WHERE  formula_type_name = l_formula_type;

  debug(l_proc_name,99);
  l_formula_count := l_formula_count + 1;
  INSERT INTO ff_formulas_f
    (formula_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_type_id
    ,formula_name
    ,description
    ,formula_text
    ,sticky_flag)
  VALUES(ff_formulas_s.NEXTVAL
    ,p_effective_date
    ,l_effective_end_date
    ,l_business_group_id
    ,l_legislation_code
    ,l_formula_type_id
    ,l_formula_name
    ,l_description
    ,NULL
    ,NULL
    )
-- WHERE NOT EXISTS
--        (SELECT 1
--         FROM   ff_formulas_f
--         WHERE  formula_name = l_formula_name
--           AND  business_group_id = l_business_group_id
--        )
  RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

  END;
--
-- End of Rate Value Calculation rule.
--
--
-- Start of (Extra Inputs) Rate Value Calculation rule.
--
  BEGIN

  debug(l_proc_name,100);
    l_formula_name:=  -- VARCHAR2(80)
      SUBSTRB(l_base_name||
            --         1         2         3         4         5
            --12345678901234567890123456789012345678901234567890
             '_OMP_STANDARD_RATES_GENERAL_EXTRA_INPUT_RULE'
             --||l_uniquestamp
             ,1,80);

  debug(l_proc_name,102);
    l_formula_type:=  -- VARCHAR2(80)
      'Extra Input'; -- to change with new formula type ??BEN?? -- done
    l_description:= -- VARCHAR2(240)
      'Sample OMP rule for a benefits standard rate to feed extra input'||
      ' values to an element entry.';

  debug(l_proc_name,105);
    l_text:='
/*==============================================================================
  $Header: pqpgbofm.pkb 120.1 2005/10/04 08:31:03 rrazdan noship $
  Formula Name: PQP_GB_BEN_OMP_STANDARD_RATES_GENERAL_EXTRA_INPUT_RULE
  Formula Type: Rate Value Calculation
  Description : Sample OMP rule for a benefits standard rate to feed extra input
                values to an element entry.

DISCLAIMER  :
  In future releases of HRMS programs, Oracle Corporation may change or
  upgrade this formula, and all other definitions for the predefined template
  of which this formula is a part.  We do not guarantee that the  formula and
  the predefined template will provide a ready-made solution to be used in your
  environment. If the formula does not reflect your business rules,  you are
  responsible for writing a formula of your own to meet your particular
  requirements. Any use of this  formula and the predefined extract is subject
  to the terms of the Oracle license agreement for the HRMS programs and
  documentation.

  Change List
  ===========
  Name           Date        Version Bug     Text
  ============== =========== ======= ======= ===================================
  rrazdan       29-JUL-2002  110.0           Created.
==============================================================================*/

/********1*********2*********3*********4*********5*********6*********7*********8
123456789012345678901234567890123456789012345678901234567890123456789012345678*/

/*
Set default values for database items.
*/
DEFAULT FOR BEN_ABS_ABSENCE_TYPE          IS ''_DEFAULT_''
DEFAULT FOR BEN_PLN_PL_ID                 IS -987123654

/* Other DB Items available
DEFAULT FOR BEN_ABS_ABSENCE_TYPE_ID       IS -987123654
DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY      IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY_CODE IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_ABSENCE_CATEGORY_ID   IS -987123654
DEFAULT FOR BEN_ABS_REASON                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_REASON_CODE           IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_REASON_ID             IS -987123654
DEFAULT FOR BEN_ABS_DATE_START            IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_DATE_END              IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_SICKNESS_START_DATE   IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_SICKNESS_END_DATE     IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_ABS_DATE_NOTIFIED         IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_DUE_DATE              IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_MPP_START_DATE        IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_ACTUAL_BIRTH_DATE     IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SMP_LIVE_BIRTH_FLAG       IS ''Y''
DEFAULT FOR BEN_SSP_EVIDENCE_DATE         IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SSP_EVIDENCE_SOURCE       IS ''_DEFAULT_''
DEFAULT FOR BEN_SSP_MEDICAL_TYPE          IS ''SICKNESS''
DEFAULT FOR BEN_SSP_EVIDENCE_STATUS       IS ''ACTIVE''
DEFAULT FOR BEN_SSP_SELF_CERTIFICATE      IS ''N''
DEFAULT FOR BEN_ABS_ACCEPT_LATE_NOTIFICATION_FLAG IS ''Y''
DEFAULT FOR BEN_ABS_PREGNANCY_RELATED_ILLNESS     IS ''N''
DEFAULT FOR BEN_SSP_ACCEPT_LATE_EVIDENCE_FLAG     IS ''Y''
DEFAULT FOR BEN_SMP_NOTIFICATION_OF_BIRTH_DATE IS ''1951/01/01 00:00:00''(DATE)
DEFAULT FOR BEN_SSP_EVIDENCE_RECEIVED_DATE     IS ''1951/01/01 00:00:00''(DATE)
*/

/*
Set default values for formula inputs.
*/
DEFAULT FOR BEN_ABS_IV_ABSENCE_ATTENDANCE_ID      IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABSENCE_ATTENDANCE_TYPE_ID IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_START                 IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_END                   IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABSENCE_DAYS               IS ''_DEFAULT_''
/* Other Inputs Available
DEFAULT FOR BEN_ABS_IV_ABS_ATTENDANCE_REASON_ID  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABSENCE_HOURS             IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_NOTIFICATION         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_PROJECTED_END        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_DATE_PROJECTED_START      IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_SSP1_ISSUED               IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_LINKED_ABSENCE_ID         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_SICKNESS_START_DATE       IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_SICKNESS_END_DATE         IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_PREGNANCY_RELATED_ILLNESS IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_MATERNITY_ID              IS ''_DEFAULT_''
DEFAULT FOR BEN_PIL_IV_PER_IN_LER_ID             IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE_CATEGORY        IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE1                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE2                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE3                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE4                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE5                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE6                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ATTRIBUTE7                IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION_CATEGORY  IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION1          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION2          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION3          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION4          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION5          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION6          IS ''_DEFAULT_''
DEFAULT FOR BEN_ABS_IV_ABS_INFORMATION7          IS ''_DEFAULT_''
*/

/*
Declare Input values.

NOTE the naming convention followed
     BEN_ABS_IV_<Column Name> - New Values
*/

INPUTS ARE BEN_ABS_IV_ABSENCE_ATTENDANCE_ID(TEXT)
          ,BEN_ABS_IV_ABSENCE_ATTENDANCE_TYPE_ID(TEXT)
          ,BEN_ABS_IV_DATE_START(TEXT)
          ,BEN_ABS_IV_DATE_END(TEXT)
          ,BEN_ABS_IV_ABSENCE_DAYS(TEXT)
/* Other Inputs Available
          ,BEN_ABS_IV_ABS_ATTENDANCE_REASON_ID(TEXT)
          ,BEN_ABS_IV_ABSENCE_HOURS(TEXT)
          ,BEN_ABS_IV_DATE_NOTIFICATION(TEXT)
          ,BEN_ABS_IV_DATE_PROJECTED_END(TEXT)
          ,BEN_ABS_IV_DATE_PROJECTED_START(TEXT)
          ,BEN_ABS_IV_SSP1_ISSUED(TEXT)
          ,BEN_ABS_IV_LINKED_ABSENCE_ID(TEXT)
          ,BEN_ABS_IV_SICKNESS_START_DATE(TEXT)
          ,BEN_ABS_IV_SICKNESS_END_DATE(TEXT)
          ,BEN_ABS_IV_PREGNANCY_RELATED_ILLNESS(TEXT)
          ,BEN_ABS_IV_MATERNITY_ID(TEXT)
          ,BEN_PIL_IV_PER_IN_LER_ID(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE_CATEGORY(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE1(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE2(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE3(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE4(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE5(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE6(TEXT)
          ,BEN_ABS_IV_ATTRIBUTE7(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION_CATEGORY(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION1(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION2(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION3(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION4(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION5(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION6(TEXT)
          ,BEN_ABS_IV_ABS_INFORMATION7(TEXT)
*/

/*
Initialise standard default values.
*/
l_null                         = RPAD(''X'',0,''Y'')
l_default                      = ''_DEFAULT_''
l_default_date                 = ''1951/01/01 00:00:00''(date)
l_default_canonical_date       = ''1951/01/01 00:00:00''
l_default_number               = -987123654
l_default_canonical_number     = ''-987123654''



l_absence_id_iv = BEN_ABS_IV_ABSENCE_ATTENDANCE_ID

/* 01. Check that the absence attendance id input was not defaulted

   NOTE If an absence attendance id was not found, it will be set as default.
   This may occur if this rate value calulcation formula is being used in a
   plan which does not have an absence "context" available.
   Please check, and if required correct,
    i. the Option Type of the associated Plan Type is set as "Absences".
   ii. the Type of the associated Life Event Reasons are set as "Absence".
*/
IF NOT l_absence_id_iv = l_default THEN
 (
  /* 02a. Determine the absence details that need to be fed to element input
       values.

     NOTE Though these values are stored as dates or numbers they are made
     available to the formula as TEXT inputs.

     The dates are available in the default canonical format of
     "YYYY/MM/DD HH24:MI:SS".
     Where required, use TO_DATE to convert text into a date.

     The numbers are available in the default canonical format.
     Where required, use TO_NUMBER to convert into text into a number.
  */

  l_absence_id = TO_NUMBER(l_absence_id_iv)

  l_plan_id = BEN_PLN_PL_ID

  /*l_absence_start_date_dt_iv = l_default_date*/
  l_absence_start_date_dt_iv = TO_DATE(BEN_ABS_IV_DATE_START,''YYYY/MM/DD HH24:MI:SS'')

  l_maternity_start_date =
    PQP_DATE_TO_DISPLAYDATE(l_absence_start_date_dt_iv)

  l_absence_type = BEN_ABS_ABSENCE_TYPE

  l_absence_end_date_iv = BEN_ABS_IV_DATE_END

  /* 02b. Check that absence end date is available.
  */
  IF NOT l_absence_end_date_iv = l_default THEN
   (
     l_maternity_end_date
       = PQP_DATE_TO_DISPLAYDATE(TO_DATE(l_absence_end_date_iv,''YYYY/MM/DD HH24:MI:SS''))
   )
  ELSE
   (
     l_maternity_end_date = l_null
   )

  /* 03. Determine the EWC date.

     NOTE This value is available on the Maternity form. To access details as
     seen on the Maternity form use the PQP_GET_MATERNITY function, passing the
     appropriate field name. All values returned by the this function are always
     TEXT datatype.If the expected value is a NUMBER/DATE appropriate
     conversions might be required before using the value.
  */

  l_error_code = 0
  l_error_message = l_default
  l_ewc =
    BEN_GET_MATERNITY
     (''EWC''
     ,l_error_code
     ,l_error_message
     )

  IF l_error_code = 0 THEN
   (
    l_ewc = PQP_DATE_TO_DISPLAYDATE(TO_DATE(l_ewc,''YYYY/MM/DD HH24:MI:SS''))
   )

  /* 04. Set the reserved return value "SUBPRIORITY".

     NOTE
     SUBPRIORITY - is a reserved return value name for this formula type.
     This value is used the populate the Subpriority field of the element entry,
     which the asscoiated standard rate feeds.

     Element entry subpriority is used to control the processing order of
     entries of element types with multiple entries allowed.

     Absences for OSP/OMP purposes must be processed in the chronological order
     of their occurence and not in the order in which they were entered in the
     system.

     For this purpose, it is recommended that SUBPRIORITY must always be a
     number directly proportional to the absence start date.

     If multiple element entries are used to process pay for the same absence
     then the element designated as the primary element may need to be processed
     before the secondary elements.

     This formula uses a seeded function,
     PQP_GAP_GET_ABSENCE_ELEMENT_ENTRY_SUBPRIORITY, that computes a SUBPRIORITY
     based on the Julian value of a given date. The given date being the
     absence start date.
  */
   SUBPRIORITY =
     PQP_GAP_GET_ABSENCE_ELEMENT_ENTRY_SUBPRIORITY(l_absence_start_date_dt_iv)

 )
/* 02b. Check that the absence attendance id input was not defaulted

   NOTE If an absence attendance id was not found, it will be set as default.
   all return values should then be returned as null or default.
*/
ELSE
 (
  l_absence_id                   = l_default_number
  l_plan_id                      = l_default_number
  l_maternity_start_date         = l_null
  l_maternity_end_date           = l_null
  l_absence_type                 = l_null
  l_ewc                          = l_null
  SUBPRIORITY                    = TO_NUMBER(l_null)
 )

RETURN  l_absence_id
       ,l_plan_id
       ,l_maternity_start_date
       ,l_maternity_end_date
       ,l_absence_type
       ,l_ewc
       ,SUBPRIORITY
';

  debug(l_proc_name,107);
  SELECT formula_type_id
  INTO   l_formula_type_id
  FROM   ff_formula_types
  WHERE  formula_type_name = l_formula_type;

  --DELETE FROM ff_formulas_f WHERE formula_name = l_formula_name;

  debug(l_proc_name,109);
  l_formula_count := l_formula_count + 1;
  INSERT INTO ff_formulas_f
    (formula_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_type_id
    ,formula_name
    ,description
    ,formula_text
    ,sticky_flag)
  VALUES(ff_formulas_s.NEXTVAL
    ,p_effective_date
    ,l_effective_end_date
    ,l_business_group_id
    ,l_legislation_code
    ,l_formula_type_id
    ,l_formula_name
    ,l_description
    ,NULL
    ,NULL
    )
--  WHERE NOT EXISTS
--         (SELECT 1
--          FROM   ff_formulas_f
--          WHERE  formula_name = l_formula_name
--            AND  business_group_id = l_business_group_id
--         )
  RETURNING formula_id INTO p_formulas(l_formula_count);

    UPDATE ff_formulas_f
       SET formula_text = l_text
     WHERE formula_id = p_formulas(l_formula_count);

  END;
--
-- End of (Extra Inputs) Rate Value Calculation rule.
--
  END IF; --IF UPPER(p_absence_pay_plan_category) = 'MATERNITY' THEN

  END IF; -- if g_use_this_functionality then

  debug(l_proc_name,110);
  debug_exit(l_proc_name);

  EXCEPTION

    WHEN OTHERS THEN
      debug(SQLCODE);
      debug(SQLERRM);
      debug(l_proc_name,-10);
      debug_exit(l_proc_name);
      RAISE;
  END create_ben_formulas;

--
--
--
  PROCEDURE delete_ben_formulas
    (p_business_group_id            IN     NUMBER
    ,p_effective_date               IN     DATE
    ,p_absence_pay_plan_category    IN     VARCHAR2
    ,p_base_name                    IN     VARCHAR2
    ,p_error_code                      OUT NOCOPY NUMBER
    ,p_error_message                   OUT NOCOPY VARCHAR2
    )
  IS

    l_proc_name  VARCHAR2(61):= g_proc_name||'delete_ben_formulas';


    l_formula_name_prefix VARCHAR2(100);
    l_formula_name ff_formulas_f.formula_name%TYPE;

  BEGIN
    debug_enter(l_proc_name);     -- comment to switch tracing on

    p_error_code := 0;
    p_error_message := NULL;

IF g_use_this_functionality THEN

    IF UPPER(p_absence_pay_plan_category) = 'SICKNESS' THEN
      l_formula_name_prefix := UPPER(p_base_name)||'_OSP_';
      debug(l_proc_name,10);
    ELSE
      l_formula_name_prefix := UPPER(p_base_name)||'_OMP_';
      debug(l_proc_name,15);
    END IF;

    debug(l_proc_name,30);

    l_formula_name := l_formula_name_prefix||
          'PARTICIPATION_ELIGIBILTY_PROFILE_OTHER_RULE';
    debug(l_formula_name);

    FOR l_formula IN csr_get_formula_id(p_business_group_id,l_formula_name)
    LOOP
      debug(l_formula.formula_id);
      pqp_utilities.delete_formula
      (p_formula_id         => l_formula.formula_id
      ,p_error_code         => p_error_code
      ,p_error_message      => p_error_message
      );
      debug(l_proc_name,35);
    END LOOP;

    debug(l_proc_name,40);

    l_formula_name := l_formula_name_prefix||
          'STANDARD_RATES_CALCULATION_METHOD_VALUE_RULE';
    debug(l_formula_name);

    FOR l_formula IN csr_get_formula_id(p_business_group_id,l_formula_name)
    LOOP
      debug(l_formula.formula_id);
      pqp_utilities.delete_formula
      (p_formula_id         => l_formula.formula_id
      ,p_error_code         => p_error_code
      ,p_error_message      => p_error_message
      );
      debug(l_proc_name,45);
    END LOOP;

    debug(l_proc_name,50);

    l_formula_name := l_formula_name_prefix||
          'STANDARD_RATES_GENERAL_EXTRA_INPUT_RULE';
    debug(l_formula_name);

    FOR l_formula IN csr_get_formula_id(p_business_group_id,l_formula_name)
    LOOP
      debug(l_formula.formula_id);
      pqp_utilities.delete_formula
      (p_formula_id         => l_formula.formula_id
      ,p_error_code         => p_error_code
      ,p_error_message      => p_error_message
      );
      debug(l_proc_name,55);
    END LOOP;


END IF;-- if g_use_this_functionality then

    debug_exit(l_proc_name);

  EXCEPTION

    WHEN OTHERS THEN
      debug(SQLCODE);
      debug(SQLERRM);
      debug(l_proc_name,-10);
      debug_exit(l_proc_name);
      RAISE;
  END delete_ben_formulas;
--
--
--
BEGIN
 g_use_this_functionality := FALSE;
END pqp_gb_gap_ben_formulas;

/
