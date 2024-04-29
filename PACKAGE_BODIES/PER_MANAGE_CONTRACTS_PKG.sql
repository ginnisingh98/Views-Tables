--------------------------------------------------------
--  DDL for Package Body PER_MANAGE_CONTRACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MANAGE_CONTRACTS_PKG" AS
  /* $Header: pemancon.pkb 115.3 2002/12/06 11:56:19 pkakar noship $ */
  --
  --
  -- Returns a summary flag indicating the type of association between a person and their contracts.
  --
  -- 'N' - Person has no contracts.
  -- 'Y' - Person has contracts
  --
  FUNCTION contract_association
  (p_person_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cContract(p_person_id NUMBER) IS
      SELECT 'Y'
      FROM   per_people_f      per
	    ,per_contracts_f   con
	    ,fnd_sessions      ses
      WHERE  per.person_id       = p_person_id
	AND  con.person_id       = per.person_id
	AND  ses.session_id      = USERENV('sessionid')
	AND  ses.effective_date BETWEEN per.effective_start_date
				    AND per.effective_end_date
	AND  ses.effective_date BETWEEN con.effective_start_date
				    AND con.effective_end_date;
     v_contracts_flag char;
  BEGIN
    OPEN  cContract(p_person_id);
    FETCH cContract INTO v_contracts_flag;
    IF cContract%NOTFOUND THEN
      -- Person has no contracts.
      --
      CLOSE cContract;
      RETURN 'N';
    ELSE
      -- Person has contracts.
      --
      CLOSE cContract;
      RETURN v_contracts_flag;
    END IF;
  END contract_association;
  --
  -- Returns the flexfield structures for a business group.
  --
  PROCEDURE get_flex_structures
  (p_business_group_id      IN NUMBER
  ,p_grade_structure        IN OUT NOCOPY NUMBER
  ,p_people_group_structure IN OUT NOCOPY NUMBER
  ,p_job_structure          IN OUT NOCOPY NUMBER
  ,p_position_structure     IN OUT NOCOPY NUMBER) IS
    CURSOR cFlexStructures(p_business_group_id NUMBER) IS
      SELECT grade_structure
            ,people_group_structure
            ,job_structure
            ,position_structure
      FROM   per_business_groups
      WHERE  business_group_id = p_business_group_id;
  BEGIN
     OPEN  cFlexStructures(p_business_group_id);
     FETCH cFlexStructures INTO p_grade_structure
                               ,p_people_group_structure
                               ,p_job_structure
                               ,p_position_structure;
     CLOSE cFlexStructures;
  END get_flex_structures;
  --
  -- Calls hr_contract_api.update_contract in date-track CORRECTION mode for all records
  -- matching supplied contract_id argument, (excluding that which matches the supplied object_version_number
  -- if the exclude flag is set to 'Y'), passing only the required arguements plus current values for
  -- user_status and user_status_date_change.
  --
  PROCEDURE update_contracts
  (p_contract_id                    IN     number
  ,p_object_version_number          IN OUT NOCOPY number
  ,p_doc_status                     IN     varchar2
  ,p_doc_status_change_date         IN     date
  ,p_exclude_flag                   IN     char)
  IS
  --
  CURSOR c_all_con IS
  SELECT contract_id,
	 effective_start_date,
	 object_version_number,
	 person_id,
         reference,
	 type,
         status
  FROM per_contracts_f
  WHERE contract_id = p_contract_id;
  --
  CURSOR c_exc_con IS
  SELECT contract_id,
	 effective_start_date,
	 object_version_number,
	 person_id,
         reference,
	 type,
         status
  FROM per_contracts_f
  WHERE contract_id = p_contract_id
  AND object_version_number <> p_object_version_number;
  --
  l_con                    c_all_con%ROWTYPE;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_object_version_number  number;
  l_dt_mode                varchar2(30) := 'CORRECTION';
  l_get_current_ovn        boolean := FALSE;
  --
  BEGIN
  --
  -- Use the appropriate cursor to use, based on flag parameter.
  --
    IF p_exclude_flag = 'N' THEN
   --
   -- update all records, including the current one (matching ovn)
      OPEN c_all_con;
      FETCH c_all_con INTO l_con;
      WHILE c_all_con%FOUND LOOP
       -- for each record, set the doc_status and doc_status_change_date attributes via
       -- a call to hr_contract_api.update_contract using CORRECTION dt mode.
       --
        l_object_version_number := l_con.object_version_number;
       --
       -- if we are at the current record (same ovn), then set flag indicating we
       -- should get the new ovn returned for the for current iteration.
	IF l_object_version_number = p_object_version_number THEN
          l_get_current_ovn := TRUE;
	END IF;
       --
        hr_contract_api.update_contract
        (p_contract_id                   => l_con.contract_id
        ,p_effective_start_date          => l_effective_start_date
        ,p_effective_end_date            => l_effective_end_date
        ,p_object_version_number         => l_object_version_number
        ,p_person_id                     => l_con.person_id
        ,p_reference                     => l_con.reference
        ,p_type                          => l_con.type
        ,p_status                        => l_con.status
        ,p_doc_status                    => p_doc_status
        ,p_doc_status_change_date        => p_doc_status_change_date
        ,p_effective_date                => l_con.effective_start_date
        ,p_datetrack_mode                => l_dt_mode);
       --
       -- pass out the new ovn for the current record
	IF l_get_current_ovn THEN
	  p_object_version_number := l_object_version_number;
	  l_get_current_ovn := FALSE;
        END IF;
       --
        FETCH c_all_con INTO l_con;
       --
      END LOOP;
      CLOSE c_all_con;
     --
    ELSIF p_exclude_flag = 'Y' THEN
     --
     -- update all records, excluding the current one (matching ovn)
      OPEN c_exc_con;
      FETCH c_exc_con INTO l_con;
      WHILE c_exc_con%FOUND LOOP
       -- for each record, set the doc_status and doc_status_change_date attributes via
       -- a call to hr_contract_api.update_contract using CORRECTION dt mode.
       --
        l_object_version_number := l_con.object_version_number;
       --
        hr_contract_api.update_contract
        (p_contract_id                   => l_con.contract_id
        ,p_effective_start_date          => l_effective_start_date
        ,p_effective_end_date            => l_effective_end_date
        ,p_object_version_number         => l_object_version_number
        ,p_person_id                     => l_con.person_id
        ,p_reference                     => l_con.reference
        ,p_type                          => l_con.type
        ,p_status                        => l_con.status
        ,p_doc_status                    => p_doc_status
        ,p_doc_status_change_date        => p_doc_status_change_date
        ,p_effective_date                => l_con.effective_start_date
        ,p_datetrack_mode                => l_dt_mode);
       --
        FETCH c_exc_con INTO l_con;
       --
      END LOOP;
      CLOSE c_exc_con;
     -- pass back a null ovn value.
      p_object_version_number := NULL;
     --
     --
    END IF;
   --
  END update_contracts;
 --
END per_manage_contracts_pkg;

/
