--------------------------------------------------------
--  DDL for Package Body HR_PERSON_TYPE_USAGE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_TYPE_USAGE_INFO" AS
/* $Header: hrptuinf.pkb 120.0.12010000.4 2009/11/12 05:44:44 sidsaxen ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_person_type_usage_info.';
g_debug boolean := hr_utility.debug_enabled;
--
--
-- ------------------------------------------------------------------------------
-- |---------------------< get_user_person_type_separator >---------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_user_person_type_separator
RETURN g_user_person_type_separator%TYPE
IS
BEGIN
  RETURN g_user_person_type_separator;
END get_user_person_type_separator;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< get_default_person_type_id >-----------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_default_person_type_id
  (p_person_type_id               IN     NUMBER
  )
RETURN NUMBER
IS
  CURSOR csr_person_types
    (p_person_type_id               IN     NUMBER
    )
  IS
    SELECT dft.person_type_id
      FROM per_person_types dft
          ,per_person_types typ
     WHERE dft.active_flag = 'Y'
       AND dft.default_flag = 'Y'
       AND dft.business_group_id = typ.business_group_id
       AND dft.system_person_type = typ.system_person_type
       AND typ.person_type_id = p_person_type_id;
  l_person_type                  csr_person_types%ROWTYPE;
BEGIN
  OPEN csr_person_types
    (p_person_type_id               => p_person_type_id
    );
  FETCH csr_person_types INTO l_person_type;
  CLOSE csr_person_types;
  RETURN l_person_type.person_type_id;
END get_default_person_type_id;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< get_default_person_type_id >-----------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_default_person_type_id
  (p_business_group_id            IN     NUMBER
  ,p_system_person_type           IN     VARCHAR2
  )
RETURN NUMBER
IS
  CURSOR csr_person_types
    (p_business_group_id            IN     NUMBER
    ,p_system_person_type           IN     VARCHAR2
    )
  IS
    SELECT dft.person_type_id
      FROM per_person_types dft
     WHERE dft.active_flag = 'Y'
       AND dft.default_flag = 'Y'
       AND dft.business_group_id = p_business_group_id
       AND dft.system_person_type = p_system_person_type;
  l_person_type                  csr_person_types%ROWTYPE;
BEGIN
  OPEN csr_person_types
    (p_business_group_id            => p_business_group_id
    ,p_system_person_type           => p_system_person_type
    );
  FETCH csr_person_types INTO l_person_type;
  CLOSE csr_person_types;
  RETURN l_person_type.person_type_id;
END get_default_person_type_id;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< get_user_person_type >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2
IS
  CURSOR csr_person_types
    (p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    )
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
     WHERE ttl.language = userenv('LANG')
       AND ttl.person_type_id = typ.person_type_id
       AND typ.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','CWK','EX_CWK','OTHER')
       AND typ.person_type_id = ptu.person_type_id
       AND p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
       AND ptu.person_id = p_person_id
  ORDER BY DECODE(typ.system_person_type
                 ,'EMP'   ,1
                 ,'CWK'   ,2
                 ,'APL'   ,3
                 ,'EX_EMP',4
                 ,'EX_CWK',5
                 ,'EX_APL',6
                          ,7
                 );
  l_user_person_type             VARCHAR2(2000);
  l_separator                    g_user_person_type_separator%TYPE;
BEGIN
  l_separator := get_user_person_type_separator();
  FOR l_person_type IN csr_person_types
    (p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    )
  LOOP
    IF (l_user_person_type IS NULL)
    THEN
      l_user_person_type := l_person_type.user_person_type;
    ELSE
      l_user_person_type := l_user_person_type
                         || l_separator
                         || l_person_type.user_person_type;
    END IF;
  END LOOP;
  RETURN l_user_person_type;
END get_user_person_type;
--
-- -----------------------------------------------------------------------------
-- |----------------------< get_worker_user_person_type >----------------------|
-- -----------------------------------------------------------------------------
FUNCTION get_worker_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2
IS
  CURSOR csr_person_types
    (p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    )
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
     WHERE ttl.language = userenv('LANG')
       AND ttl.person_type_id = typ.person_type_id
       AND typ.system_person_type IN ('EMP','CWK')
       AND typ.person_type_id = ptu.person_type_id
       AND p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
       AND ptu.person_id = p_person_id
  ORDER BY DECODE(typ.system_person_type
                 ,'EMP'   ,1
                 ,'CWK'   ,2
                 );
  l_user_person_type             VARCHAR2(2000);
  l_separator                    g_user_person_type_separator%TYPE;
BEGIN
  l_separator := get_user_person_type_separator();
  FOR l_person_type IN csr_person_types
    (p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    )
  LOOP
    IF (l_user_person_type IS NULL)
    THEN
      l_user_person_type := l_person_type.user_person_type;
    ELSE
      l_user_person_type := l_user_person_type
                         || l_separator
                         || l_person_type.user_person_type;
    END IF;
  END LOOP;
  RETURN l_user_person_type;
END get_worker_user_person_type;
--
-- -----------------------------------------------------------------------------
-- |----------------------< get_worker_number >--------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION get_worker_number
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2
IS

  --
  -- Fetch the person's worker number details.
  --
  CURSOR csr_get_person_details IS
  SELECT papf.employee_number
        ,papf.npw_number
        ,papf.current_employee_flag
        ,papf.current_npw_flag
    FROM per_all_people_f papf
   WHERE papf.person_id = p_person_id
     AND p_effective_date BETWEEN
         papf.effective_start_date AND papf.effective_end_date;

  l_employee_number       per_all_people_f.employee_number%TYPE;
  l_npw_number            per_all_people_f.npw_number%TYPE;
  l_current_employee_flag per_all_people_f.current_employee_flag%TYPE;
  l_current_npw_flag      per_all_people_f.current_npw_flag%TYPE;
  l_worker_number         per_all_people_f.employee_number%TYPE;

BEGIN

    OPEN  csr_get_person_details;
    FETCH csr_get_person_details INTO l_employee_number
                                     ,l_npw_number
                                     ,l_current_employee_flag
                                     ,l_current_npw_flag;
    CLOSE csr_get_person_details;

    --
    -- Set the worker number based on the status of the
    -- current flags.  If the person is not an active worker,
    -- the worker number will not be set.
    --
    IF NVL(l_current_employee_flag, 'N') = 'Y' THEN
      l_worker_number := l_employee_number;
    ELSIF NVL(l_current_npw_flag, 'N') = 'Y' THEN
      l_worker_number := l_npw_number;
    END IF;

    RETURN l_worker_number;

END get_worker_number;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< get_apl_user_person_type >---------------------|
-- -----------------------------------------------------------------------------
FUNCTION get_apl_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2
IS
  CURSOR csr_person_types
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
     WHERE ttl.language = userenv('LANG')
       AND ttl.person_type_id = typ.person_type_id
       AND typ.system_person_type IN ('APL','EX_APL')
       AND typ.person_type_id = ptu.person_type_id
       AND p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
       AND ptu.person_id = p_person_id;

  l_user_person_type             per_person_types_tl.user_person_type%type;
BEGIN
  open csr_person_types;
  fetch csr_person_types into l_user_person_type;
  if csr_person_types%notfound then
    close csr_person_types;
    l_user_person_type:=null;
  else
    close csr_person_types;
  end if;
  RETURN l_user_person_type;
END get_apl_user_person_type;
--

FUNCTION get_emp_person_type_id
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2
IS
CURSOR emp_person_type IS
  SELECT ptu.person_type_id FROM
  per_person_type_usages_f ptu, per_person_types ppt WHERE
  ptu.person_id = p_person_id and
  p_effective_date between ptu.effective_start_date and ptu.effective_end_date
  and ptu.person_type_id = ppt.person_type_id and ppt.system_person_type='EMP';
l_emp_person_type_id	number;
BEGIN
  OPEN emp_person_type;
  FETCH emp_person_type into l_emp_person_type_id;
  CLOSE emp_person_type;
  return l_emp_person_type_id;
END get_emp_person_type_id;

--
-- ------------------------------------------------------------------------------
-- |--------------------------< get_emp_user_person_type >----------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_emp_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2
IS
  CURSOR csr_person_types
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
     WHERE ttl.language = userenv('LANG')
       AND ttl.person_type_id = typ.person_type_id
       AND typ.system_person_type IN ('EMP','EX_EMP')
       AND typ.person_type_id = ptu.person_type_id
       AND p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
       AND ptu.person_id = p_person_id;

  l_user_person_type             per_person_types_tl.user_person_type%type;
BEGIN
  open csr_person_types;
  fetch csr_person_types into l_user_person_type;
  if csr_person_types%notfound then
    close csr_person_types;
    l_user_person_type:=null;
  else
    close csr_person_types;
  end if;
  RETURN l_user_person_type;
END get_emp_user_person_type;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< GetSystemPersonType >---------------------------|
-- ------------------------------------------------------------------------------
FUNCTION GetSystemPersonType
  (p_person_type_id           IN     NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_system_person_type
    (p_person_type_id            IN     NUMBER)
  IS
    SELECT ppt.system_person_type
      FROM per_person_types ppt
     WHERE ppt.person_type_id = p_person_type_id;

  l_system_person_type            per_person_types.system_person_type%type;

BEGIN

  OPEN c_system_person_type(p_person_type_id);

  FETCH c_system_person_type INTO l_system_person_type;

  CLOSE c_system_person_type;

  RETURN l_system_person_type;

END GetSystemPersonType;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< IsNonCoreHRPersonType >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION IsNonCoreHRPersonType
  (p_person_type_usage_id           IN     NUMBER
  ,p_effective_date		    IN	   DATE)
RETURN BOOLEAN
IS
  CURSOR c_corehr_person_type
    (p_person_type_usage_id            IN     NUMBER,
     p_effective_date			IN 	DATE)
  IS
    SELECT  	ppt.system_person_type
    FROM 	per_person_types 	 ppt	,
		per_person_type_usages_f ptu
    WHERE 	ptu.person_type_usage_id = p_person_type_usage_id
    AND		p_effective_date between
		ptu.effective_start_date and
		nvl(ptu.effective_end_date,to_date('31/12/4712','DD/MM/YYYY'))
    AND		ptu.person_type_id	= ppt.person_type_id;

  l_system_person_type       per_person_types.system_person_type%type;

BEGIN

  OPEN c_corehr_person_type(p_person_type_usage_id,p_effective_date);

  FETCH c_corehr_person_type INTO l_system_person_type;
  if  c_corehr_person_type%NOTFOUND then
  CLOSE c_corehr_person_type;
  hr_utility.set_message(801,'NO_PTU_RECORD_EXISTS');
  hr_utility.raise_error;
  end if;

  CLOSE c_corehr_person_type;

  if not hr_api.not_exists_in_hrstanlookups
    (p_effective_date               => p_effective_date
    ,p_lookup_type                  => 'HR_SYS_PTU'
    ,p_lookup_code                  => l_system_person_type
    )
  then return FALSE;
  else
  return TRUE;
  end if;

END IsNonCoreHRPersonType;
--
-- ------------------------------------------------------------------------------|
-- |--------------------------< FutSamePerTypeChgExists >------------------------|
-- ------------------------------------------------------------------------------|
FUNCTION FutSamePerTypeChgExists
  (p_person_type_usage_id           IN     NUMBER
  ,p_effective_date                 IN     DATE)
RETURN BOOLEAN
IS
  CURSOR c_ptu_record
    (p_person_type_usage_id            IN     NUMBER,
     p_effective_date                   IN      DATE)
  IS
    SELECT      GetSystemPersonType(ptu.person_type_id),
                ptu.effective_start_date,
                ptu.effective_end_date
    FROM        per_person_type_usages_f ptu
    WHERE       ptu.person_type_usage_id = p_person_type_usage_id
    AND         ptu.effective_start_date > p_effective_date
    order by ptu.effective_start_date ;

  --start changes for bug 8628859
  CURSOR csr_pop_back_to_back
     ( p_date_start IN DATE
      ,p_person_id  IN NUMBER)
  IS
    SELECT pp.period_of_placement_id
    FROM   per_periods_of_placement pp
    WHERE  pp.person_id  = p_person_id
    AND    pp.actual_termination_date = p_date_start -1;
  --
  CURSOR csr_pos_back_to_back
     ( p_date_start IN DATE
      ,p_person_id  IN NUMBER)
  IS
    SELECT ps.period_of_service_id
    FROM   per_periods_of_service ps
    WHERE  ps.person_id  = p_person_id
    AND    ps.actual_termination_date = p_date_start -1;

  l_is_back2back_hire              NUMBER;
  l_person_id                      NUMBER;
  --End changes for bug 8628859

  l_person_type_id                 NUMBER(10);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
  l_current_system_person_type     per_person_types.system_person_type%type;
  l_future_system_person_type      per_person_types.system_person_type%type;

BEGIN

  SELECT   GetSystemPersonType(ptu.person_type_id), ptu.person_id
  INTO     l_current_system_person_type, l_person_id
  FROM     per_person_type_usages_f ptu
  WHERE    ptu.person_type_usage_id = p_person_type_usage_id
  AND      p_effective_date between
           ptu.effective_start_date and ptu.effective_end_date;

  OPEN c_ptu_record(p_person_type_usage_id,p_effective_date);

  loop

  FETCH c_ptu_record INTO l_future_system_person_type,
                          l_effective_start_date,
                          l_effective_end_date;
  if  c_ptu_record%NOTFOUND then
  CLOSE c_ptu_record;
  return FALSE;
  end if;

  if l_current_system_person_type <> l_future_system_person_type
  then
    close c_ptu_record;
    return TRUE;

  --Start changes for bug 8628859
  elsif l_current_system_person_type = 'EMP' then

     open csr_pos_back_to_back(l_effective_start_date, l_person_id);
     fetch csr_pos_back_to_back into l_is_back2back_hire;
     if csr_pos_back_to_back%FOUND then
        close c_ptu_record;
        close csr_pos_back_to_back;
        return TRUE;
     end if;
     close csr_pos_back_to_back;

  elsif l_current_system_person_type = 'CWK' then

     open csr_pop_back_to_back(l_effective_start_date, l_person_id);
     fetch csr_pop_back_to_back into l_is_back2back_hire;
     if csr_pop_back_to_back%FOUND then
        close c_ptu_record;
        close csr_pop_back_to_back;
        return TRUE;
     end if;
     close csr_pop_back_to_back;
  --End changes for bug 8628859

  end if;

  end loop;

END FutSamePerTypeChgExists;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< FutSysPerTypeChgExists >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION FutSysPerTypeChgExists
  (p_person_type_usage_id           IN     NUMBER
  ,p_effective_date                 IN     DATE)
RETURN BOOLEAN IS

  l_result    boolean := FALSE;
BEGIN

  l_result := FutSamePerTypeChgExists(p_person_type_usage_id, p_effective_date);
  return(l_result);

END FutSysPerTypeChgExists;
--
--  3194314: Overloaded
-- ----------------------------------------------------------------------------|
-- |--------------------------< FutSysPerTypeChgExists >-----------------------|
-- ----------------------------------------------------------------------------|
FUNCTION FutSysPerTypeChgExists
  (p_person_type_usage_id           IN     NUMBER
  ,p_effective_date                 IN     DATE
  ,p_person_id                      IN     NUMBER)
RETURN BOOLEAN
IS
  CURSOR c_ptu_record
    (p_person_type_usage_id            IN     NUMBER,
     p_effective_date                  IN     DATE
    ,p_person_id                       IN     NUMBER)
  IS
    SELECT      GetSystemPersonType(ptu.person_type_id),
                ptu.effective_start_date,
                ptu.effective_end_date
    FROM        per_person_type_usages_f ptu
    WHERE       ptu.person_id = p_person_id
    AND         ptu.effective_start_date > p_effective_date
    order by ptu.effective_start_date ;

  CURSOR csr_pop_back_to_back
     ( p_date_start IN DATE
      ,p_person_id  IN NUMBER)
  IS
    SELECT pp.period_of_placement_id
    FROM   per_periods_of_placement pp
    WHERE  pp.person_id  = p_person_id
    AND    pp.actual_termination_date = p_date_start -1;
  --
  CURSOR csr_pos_back_to_back
     ( p_date_start IN DATE
      ,p_person_id  IN NUMBER)
  IS
    SELECT ps.period_of_service_id
    FROM   per_periods_of_service ps
    WHERE  ps.person_id  = p_person_id
    AND    ps.actual_termination_date = p_date_start -1;
  --

  l_person_type_id                 NUMBER(10);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
  l_current_system_person_type     per_person_types.system_person_type%type;
  l_future_system_person_type      per_person_types.system_person_type%type;
  l_current_end_date               DATE;
  l_is_back2back_hire              number;
  l_future_person                  BOOLEAN;


BEGIN

  SELECT   GetSystemPersonType(ptu.person_type_id), ptu.effective_end_date
  INTO     l_current_system_person_type, l_current_end_date
  FROM     per_person_type_usages_f ptu
  WHERE    ptu.person_type_usage_id = p_person_type_usage_id
  AND      ptu.person_id = p_person_id
  AND      p_effective_date between
           ptu.effective_start_date and ptu.effective_end_date;

  OPEN c_ptu_record(p_person_type_usage_id,p_effective_date,p_person_id);

 LOOP -- Added for fix of 3285486
  FETCH c_ptu_record INTO l_future_system_person_type,
                          l_effective_start_date,
                          l_effective_end_date;


  if  c_ptu_record%NOTFOUND then
      CLOSE c_ptu_record;
      return FALSE;

  elsif l_current_system_person_type <> l_future_system_person_type
  then
     close c_ptu_record;
     return TRUE;

  elsif l_current_system_person_type = 'EMP' then

     open csr_pos_back_to_back(l_effective_start_date, p_person_id);
     fetch csr_pos_back_to_back into l_is_back2back_hire;
     if csr_pos_back_to_back%FOUND then
        close c_ptu_record;
        close csr_pos_back_to_back;
        return TRUE;
     end if;
     close csr_pos_back_to_back;

  elsif l_current_system_person_type = 'CWK' then

     open csr_pop_back_to_back(l_effective_start_date, p_person_id);
     fetch csr_pop_back_to_back into l_is_back2back_hire;
     if csr_pop_back_to_back%FOUND then
        close c_ptu_record;
        close csr_pop_back_to_back;
        return TRUE;
     end if;
     close csr_pop_back_to_back;

  end if;
 End loop; -- Added for the fix of 3285486.
--Commented the following part for fix of 3285486.
/*
  loop

  FETCH c_ptu_record INTO l_future_system_person_type,
                          l_effective_start_date,
                          l_effective_end_date;


  if  c_ptu_record%NOTFOUND then
  CLOSE c_ptu_record;
  return FALSE;
  end if;

  if l_current_system_person_type <> l_future_system_person_type
  then
     close c_ptu_record;
     return TRUE;
  end if;

  end loop;*/

END FutSysPerTypeChgExists;
--
--
-- ------------------------------------------------------------------------------
-- |--------------------------< is_person_of_type >-----------------------------|
-- ------------------------------------------------------------------------------
FUNCTION is_person_of_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_system_person_type           IN     VARCHAR2
  )
RETURN BOOLEAN
IS

  l_found BOOLEAN := FALSE;
  l_dummy NUMBER;

  CURSOR csr_person_type
  IS
    SELECT  null
      FROM  per_person_types typ
           ,per_person_type_usages_f ptu
      WHERE typ.system_person_type = p_system_person_type
       AND  typ.person_type_id = ptu.person_type_id
       AND  p_effective_date BETWEEN ptu.effective_start_date
                                 AND ptu.effective_end_date
       AND  ptu.person_id = p_person_id;

BEGIN

  OPEN  csr_person_type;
  FETCH csr_person_type INTO l_dummy;

  IF csr_person_type%FOUND THEN
    l_found := TRUE;
  ELSE
    l_found := FALSE;
  END IF;

  CLOSE csr_person_type;

  RETURN l_found;

END is_person_of_type;
--
-- ------------------------------------------------------------------------------
-- |-------------------------< is_person_a_worker >-----------------------------|
-- ------------------------------------------------------------------------------
--
FUNCTION is_person_a_worker
  (p_effective_date IN     DATE
  ,p_person_id      IN     per_all_people_f.person_id%TYPE) RETURN BOOLEAN IS
  --
  -- Declare Local Variables
  --
  l_worker BOOLEAN := FALSE;
  l_proc   VARCHAR2(72);
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  IF g_debug THEN
    --
    l_proc  := g_package||'is_person_a_worker';
    --
    hr_utility.set_location('Entering : '||l_proc,10);
    --
  END IF;
  --
  l_worker := hr_person_type_usage_info.is_person_of_type
                (p_effective_date      => p_effective_date
                ,p_person_id           => p_person_id
                ,p_system_person_type  => 'EMP');
  --
  IF NOT l_worker THEN
    --
    IF g_debug THEN
      --
      hr_utility.set_location(l_proc,20);
      --
    END IF;
    --
    l_worker := hr_person_type_usage_info.is_person_of_type
                  (p_effective_date      => p_effective_date
                  ,p_person_id           => p_person_id
                  ,p_system_person_type  => 'CWK');
    --
  ELSE
    --
    l_worker := FALSE;
    --
  END IF;
  --
  IF g_debug THEN
    --
    hr_utility.set_location('Leaving  : '||l_proc,999);
    --
  END IF;
  --
  RETURN l_worker;
  --
END is_person_a_worker;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< get_person_actions >----------------------------|
-- ------------------------------------------------------------------------------
--
FUNCTION get_person_actions
  (p_person_id                          IN     NUMBER
  ,p_effective_date                     IN     DATE
  ,p_customized_restriction_id          IN     NUMBER DEFAULT NULL)
RETURN g_actions_t IS

  l_actions g_actions_t;
  i         number := 1;

/*This cursor fetches all actions that are available to the current
  person subject to various limitations around their PTU records
  (as specified in per_form_functions). For example, a person who is
  just an EMP will have 'Create Applicant' whereas a person who is
  already an EMP and APL will not.

  If an action-based customized restriction exists the
  action list is further restricted based on the CustomForm entrires.*/

  CURSOR csr_get_actions IS
  select distinct pff.result action
        ,hr_general.decode_lookup('HR_PTU_ACTION_TYPES',pff.result) meaning
  from   per_form_functions pff
  where  pff.form =     'PERWSEPI'
  and    pff.function = 'ACTION_RESTRICTIONS'
  and  ((p_person_id is null and pff.input is null)
     or (p_person_id is not null
     and exists
           (select null
            from   per_person_types ppt
                  ,per_person_type_usages_f ptu
            where  ptu.person_type_id = ppt.person_Type_id
            and    p_effective_date between
                   ptu.effective_start_date and ptu.effective_end_date
            and    ptu.person_id = p_person_id
            and    ppt.system_person_type = pff.input)
     and not exists
           (select null
            from   per_person_types ppt2
                  ,per_person_type_usages_f ptu2
            where  ptu2.person_type_id = ppt2.person_type_id
            and    p_effective_date between
                   ptu2.effective_start_date and ptu2.effective_end_date
            and    ptu2.person_id = p_person_id
            and    decode(pff.restriction_value, null, 0,
                          instr(pff.restriction_value,
                                ppt2.system_person_type)) > 0)))
  and  ((p_customized_restriction_id is null)
   or   (p_customized_restriction_id is not null
     and (exists
           (select null
            from   pay_restriction_values prv
            where  prv.customized_restriction_id = p_customized_restriction_id
            and    prv.restriction_code = 'PERSON_ACTION'
            and    prv.value = pff.result)
          or not exists
           (select null
            from   pay_restriction_values prv2
            where  prv2.customized_restriction_id = p_customized_restriction_id
            and    prv2.restriction_code = 'PERSON_ACTION'))))
  order by 2;


BEGIN

  IF l_actions.COUNT > 0 THEN
    --
    -- Flush the list.
    --
    FOR j IN l_actions.FIRST..l_actions.LAST LOOP
      l_actions.DELETE(j);
    END LOOP;

  END IF;

  --
  -- Loop through the list of available actions and populate
  -- the pl/sql table.
  --
  FOR csr_rec in csr_get_actions LOOP

    l_actions(i).action := csr_rec.action;
    l_actions(i).meaning := csr_rec.meaning;

    i := i + 1;

  END LOOP;

  RETURN l_actions;

END get_person_actions;

--
END hr_person_type_usage_info;

/
