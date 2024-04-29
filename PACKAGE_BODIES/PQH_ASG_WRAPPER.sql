--------------------------------------------------------
--  DDL for Package Body PQH_ASG_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ASG_WRAPPER" AS
/* $Header: peasgmup.pkb 120.1 2005/11/21 02:58:36 ayegappa noship $ */
  --
  g_package  varchar2(33) := '  pqh_asg_wrapper.';
  g_org_hierarchy_id    number;
  g_org_starting_node   number;
  g_org_hierarchy_root  number;
  g_pos_hierarchy_id    number;
  g_pos_starting_node   number;
  g_pos_hierarchy_root  number;
  g_txn_id              number;
  --
  -- ---------------------------------------------------------------------------+
  -- |----------------------------< SHOW_WORKER_NUMBER >------------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION show_worker_number
    (p_employee_number  IN VARCHAR2
    ,p_npw_number       IN VARCHAR2
   -- ,p_applicant_number IN VARCHAR2
    ) RETURN VARCHAR2 IS
    --
    l_worker_number VARCHAR2(80) := NULL;
    --
  BEGIN
    --
    IF p_employee_number IS NOT NULL THEN
      --
      l_worker_number := p_employee_number;
      --
    END IF;
    --
    IF p_npw_number IS NOT NULL THEN
      --
      IF l_worker_number IS NOT NULL THEN
        --
        l_worker_number := l_worker_number||','||p_npw_number;
        --
      ELSE
        --
        l_worker_number := p_npw_number;
        --
      END IF;
      --
    END IF;
    --
/* Removed the part that attaches applicant number to Full name */
    --
    RETURN(l_worker_number);
    --
  END show_worker_number;
  --
  -- ---------------------------------------------------------------------------+
  -- |------------------------< GET_ASSIGNMENT_STATUS_TYPE >--------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION get_assignment_status_type
    (p_assignment_status_type_id IN NUMBER) RETURN VARCHAR2 IS
    --
    CURSOR get_status_type IS
      SELECT p.per_system_status
      FROM   per_assignment_status_types p
      WHERE  p.assignment_status_type_id = p_assignment_status_type_id;
    --
    l_proc VARCHAR2(72) := g_package||'get_assignment_status_type';
    l_assignment_status_type per_assignment_status_types.per_system_status%TYPE;

  BEGIN
    --
    hr_utility.set_location('Entering : '||l_proc, 10);
    --
    OPEN get_status_type;
    FETCH get_status_type INTO l_assignment_status_type;
    --
    IF get_status_type%NOTFOUND THEN
      --
      hr_utility.set_location(l_proc, 20);
      --
      CLOSE get_status_type;
      --
      hr_utility.set_message(801,'HR_7940_ASG_INV_ASG_STAT_TYPE');
      hr_utility.raise_error;
      --
    ELSE
      --
      hr_utility.set_location(l_proc, 30);
      --
      CLOSE get_status_type;
      --
    END IF;
    --
    hr_utility.set_location('Leaving  : '||l_proc,100);
    --
    RETURN(l_assignment_status_type);
    --
  END get_assignment_status_type;
  --
  -- ---------------------------------------------------------------------------+
  -- |------------------------< IS_TYPE_AN_APPLICANT_TYPE >---------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Type_An_Applicant_Type
    (p_person_type_id            IN per_person_types.person_type_id%TYPE)
    RETURN CHAR IS
    --
    Cursor c_get_system_person_type Is
    Select information22
    from   pqh_copy_entity_attribs
    Where  information22 IS NOT NULL
    And    row_type_cd                = 'CRITERIA'
    And    copy_entity_txn_id         = pqh_gen_form.g_txn_id;
    --
    Cursor c_get_system_type_name(p_person_type_id IN
                                  per_person_types.person_type_id%TYPE) Is
    Select ppt.system_person_type
    From   per_person_types ppt
    Where  ppt.person_type_id = p_person_type_id;
    --
    v_system_person_type           per_person_types.system_person_type%TYPE := NULL;
    v_criteria_system_person_type  per_person_types.system_person_type%TYPE := NULL;
    v_dummy_field                  varchar2(50) := NULL;
    v_return_value                 varchar2(5);
    --
    l_proc                         varchar2(72) := g_package||'Is_Type_An_Applicant_Type';
    --
  BEGIN
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Check to see if a system person type has been
    -- entered as part of the query criteria in the form.
    --
    Open  c_get_system_person_type;
    Fetch c_get_system_person_type into v_criteria_system_person_type;
    --
    hr_utility.set_location(l_proc,20);
    --
    -- If no system person type has been entered then
    -- check that the employee is either an Applicant
    -- or an Employee_Applicant.
    --
    If c_get_system_person_type%NOTFOUND Then
      --
      hr_utility.set_location(l_proc,30);
      --
      close c_get_system_person_type;
      --
      -- Retrieve the system person type for this employee
      --
      Open  c_get_system_type_name(p_person_type_id);
      Fetch c_get_system_type_name Into v_system_person_type;
      Close c_get_system_type_name;
      --
      hr_utility.set_location(l_proc,40);
      --
      -- If the person is an Applicant or Employee_Applicant
      -- then set the return value to TRUE else set to FALSE
      --
      If v_system_person_type in ('APL','EMP_APL') then
        --
        v_return_value := 'TRUE';
        --
      Else
        --
        v_return_value := 'FALSE';
        --
      End If;
    --
    -- If a system person type has been entered then check
    -- that the person's system person type matches the
    -- one entered as part of the query criteria.
    --
    Else
      --
      hr_utility.set_location(l_proc,50);
      --
      -- Retrieve the system person type for this employee
      --
      Open  c_get_system_type_name(p_person_type_id);
      Fetch c_get_system_type_name Into v_system_person_type;
      Close c_get_system_type_name;
      --
      -- Return TRUE if the persons system type matches
      -- the one entered as part of the query criteria
      --
      If v_system_person_type = v_criteria_system_person_type Then
      --
        v_return_value := 'TRUE';
      --
      -- If the persons system type is an Employee_Applicant or
      -- Applicant AND the query criteria is for BOTH then return
      -- TRUE.
      --
      Elsif v_criteria_system_person_type = 'BOTH' and
            v_system_person_type IN ('APL','EMP_APL') Then
      --
        v_return_value := 'TRUE';
      --
      -- If they don't match return FALSE
      --
      Else
        --
        v_return_value := 'FALSE';
        --
      End If;
      --
    End If;
    --
    hr_utility.set_location('Leaving '||l_proc,80);
    --
    RETURN(v_return_value);
    --
  END Is_Type_An_Applicant_Type;
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------< IS_TYPE_A_SYSTEM_TYPE >------------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Type_A_System_Type2
    (p_person_type_id            IN per_person_types.person_type_id%TYPE)
    RETURN CHAR IS
    --
    Cursor c_get_system_person_type Is
    Select information22
    from   pqh_copy_entity_attribs
    Where  information22 IS NOT NULL
    And    row_type_cd                = 'CRITERIA'
    And    copy_entity_txn_id         = pqh_gen_form.g_txn_id;
    --
    Cursor c_get_system_type_name(p_person_type_id IN
                                  per_person_types.person_type_id%TYPE) Is
    Select ppt.system_person_type
    From   per_person_types ppt
    Where  ppt.person_type_id = p_person_type_id;
    --
    v_system_person_type           per_person_types.system_person_type%TYPE := NULL;
    v_criteria_system_person_type  per_person_types.system_person_type%TYPE := NULL;
    v_dummy_field                  varchar2(50) := NULL;
    v_return_value                 varchar2(5);
    --
    l_proc                         varchar2(72) := g_package||'Is_Type_A_System_Type';
    --
  BEGIN
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Check to see if a system person type has been
    -- entered as part of the query criteria in the form.
    --
    Open  c_get_system_person_type;
    Fetch c_get_system_person_type into v_criteria_system_person_type;
    --
    hr_utility.set_location(l_proc,20);
    --
    -- If no system person type has been entered then
    -- check that the employee is either an Employee
    -- or an Employee_Applicant.
    --
    If c_get_system_person_type%NOTFOUND Then
      --
      hr_utility.set_location(l_proc,30);
      --
      close c_get_system_person_type;
      --
      -- Retrieve the system person type for this employee
      --
      Open  c_get_system_type_name(p_person_type_id);
      Fetch c_get_system_type_name Into v_system_person_type;
      Close c_get_system_type_name;
      --
      hr_utility.set_location(l_proc,40);
      --
      -- If the person is an Employee or Employee_Applicant
      -- then set the return value to TRUE else set to FALSE
      --
      If v_system_person_type in ('EMP','EMP_APL') then
        --
        v_return_value := 'TRUE';
        --
      Else
        --
        v_return_value := 'FALSE';
        --
      End If;
    --
    -- If a system person type has been entered then check
    -- that the person's system person type matches the
    -- one entered as part of the query criteria.
    --
    Else
      --
      hr_utility.set_location(l_proc,50);
      --
      -- Retrieve the system person type for this employee
      --
      Open  c_get_system_type_name(p_person_type_id);
      Fetch c_get_system_type_name Into v_system_person_type;
      Close c_get_system_type_name;
      --
      -- Return TRUE if the persons system type matches
      -- the one entered as part of the query criteria
      --
      If v_system_person_type = v_criteria_system_person_type Then
      --
        v_return_value := 'TRUE';
      --
      -- If the persons system type is an Employee_Applicant or
      -- Employee AND the query criteria is for BOTH then return
      -- TRUE.
      --
      Elsif v_criteria_system_person_type = 'BOTH' and
            v_system_person_type IN ('EMP','EMP_APL') Then
      --
        v_return_value := 'TRUE';
      --
      -- If they don't match return FALSE
      --
      Else
        --
        v_return_value := 'FALSE';
        --
      End If;
      --
    End If;
    --
    hr_utility.set_location('Leaving '||l_proc,80);
    --
    RETURN(v_return_value);
    --
  END Is_Type_A_System_Type2;
  --
  -- ---------------------------------------------------------------------------+
  -- |------------------------< IS_PERSON_CORRECT_TYPE >------------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Person_Correct_Type
    (p_person_type_id            IN per_person_types.person_type_id%TYPE)
    RETURN CHAR IS
    --
    Cursor c_get_criteria_person_type Is
    Select NVL(check_information1,'N'),
           NVL(check_information2,'N'),
           NVL(check_information3,'N')
    from   pqh_copy_entity_attribs
    Where  (check_information1 IS NOT NULL OR
            check_information2 IS NOT NULL OR
            check_information3 IS NOT NULL)
    and    row_type_cd                = 'CRITERIA'
    And    copy_entity_txn_id         = pqh_gen_form.g_txn_id;
    --
    Cursor c_get_system_type_name(p_person_type_id IN
                                  per_person_types.person_type_id%TYPE) Is
    Select ppt.system_person_type
    From   per_person_types ppt
    Where  ppt.person_type_id = p_person_type_id;
    --
    v_system_person_type  per_person_types.system_person_type%TYPE := NULL;
    v_emp                 VARCHAR2(3) := NULL;
    v_apl                 VARCHAR2(3) := NULL;
    v_cwk                 VARCHAR2(3) := NULL;
    v_dummy_field         VARCHAR2(50) := NULL;
    v_return_value        VARCHAR2(5);
    --
    l_proc                VARCHAR2(72) := g_package||'Is_Person_Correct_Type';
    --
  BEGIN
    --
    hr_utility.set_location('Entering:'||pqh_gen_form.g_txn_id||'/'|| l_proc, 10);
    --
    IF pqh_gen_form.g_txn_id IS NULL THEN
       --
       hr_utility.set_location(l_proc,15);
       --
       pqh_gen_form.g_txn_id := pqh_generic.g_txn_id; -- #3553723
      --  RETURN ( 'TRUE');-- #3553723
       --
    END IF;
    --
    OPEN  c_get_criteria_person_type;
    FETCH c_get_criteria_person_type INTO v_emp, v_cwk, v_apl;
    --
    hr_utility.set_location(l_proc||v_emp||v_cwk||v_apl,20);
    --
    IF c_get_criteria_person_type%FOUND Then
      --
      hr_utility.set_location(l_proc,30);
      --
      CLOSE c_get_criteria_person_type;
      --
      -- Fetch the persons system person type name
      --
      OPEN  c_get_system_type_name(p_person_type_id);
      FETCH c_get_system_type_name INTO v_system_person_type;
      CLOSE c_get_system_type_name;
      --
      hr_utility.set_location(l_proc||v_system_person_type,40);
      --
      v_return_value := 'FALSE';
      --
      IF v_system_person_type IN ('EMP', 'EMP_APL') AND
         v_emp = 'Y' THEN
        --
        hr_utility.set_location(l_proc,50);
        --
        v_return_value := 'TRUE';
        --
      ELSIF v_system_person_type IN ('APL', 'APL_EX_APL', 'EMP_APL', 'EX_EMP_APL') AND
            v_apl = 'Y' THEN
        --
        hr_utility.set_location(l_proc,60);
        --
        v_return_value := 'TRUE';
        --
      ELSIF v_system_person_type IN ('CWK') AND
            v_cwk = 'Y' THEN
        --
        hr_utility.set_location(l_proc,70);
        --
        v_return_value := 'TRUE';
        --
      END IF;
      --
      hr_utility.set_location(l_proc,80);
      --
    END IF;
    --
    -- Bug fix 3547257
    if ( nvl(v_emp,'N') <>'Y' and nvl(v_cwk,'N') <>'Y') then
       hr_utility.set_message(800,'HR_449558_NO_CHECK_BOX');
       hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,999);
    --
    RETURN(v_return_value);
    --
  END Is_Person_Correct_Type;
  --
  -- ---------------------------------------------------------------------------+
  -- |------------------------< IS_TYPE_A_SYSTEM_TYPE >-------------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Type_A_System_Type
    (p_person_type_id            IN per_person_types.person_type_id%TYPE)
    RETURN CHAR IS
    --
    Cursor c_get_system_person_type Is
    Select information22
    from   pqh_copy_entity_attribs
    Where  information22 IS NOT NULL
    And    row_type_cd                = 'CRITERIA'
    And    copy_entity_txn_id         = pqh_gen_form.g_txn_id;
    --
    Cursor c_compare_person_type(p_system_person_type IN
                                 per_person_types.system_person_type%TYPE) Is
    Select 'x'
    From   per_person_types ppt
    Where  ppt.system_person_type = p_system_person_type
    and    ppt.person_type_id     = p_person_type_id;
    --
    Cursor c_get_system_type_name(p_person_type_id IN
                                  per_person_types.person_type_id%TYPE) Is
    Select ppt.system_person_type
    From   per_person_types ppt
    Where  ppt.person_type_id = p_person_type_id;
    --
    v_system_person_type  per_person_types.system_person_type%TYPE := NULL;
    v_dummy_field         Varchar2(50) := NULL;
    v_return_value        varchar2(5);
    --
    l_proc                varchar2(72) := g_package||'Is_Type_A_System_Type';
    --
  BEGIN
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    Open  c_get_system_person_type;
    Fetch c_get_system_person_type into v_system_person_type;
    --
    hr_utility.set_location(l_proc,20);
    --
    If c_get_system_person_type%NOTFOUND Then
      --
      hr_utility.set_location(l_proc,30);
      --
      close c_get_system_person_type;
      --
      Open  c_get_system_type_name(p_person_type_id);
      Fetch c_get_system_type_name Into v_system_person_type;
      Close c_get_system_type_name;
      --
      hr_utility.set_location(l_proc,40);
      --
      If v_system_person_type in ('EMP','EMP_APL') then
        --
        v_return_value := 'TRUE';
        --
      Else
        --
        v_return_value := 'FALSE';
        --
      End If;
      --
    Else
      --
      hr_utility.set_location(l_proc,50);
      --
      Open  c_compare_person_type(v_system_person_type);
      Fetch c_compare_person_type Into v_dummy_field;
      --
      If c_compare_person_type%NOTFOUND Then
       --
       hr_utility.set_location(l_proc,60);
       --
       close c_compare_person_type;
       v_return_value := 'FALSE';
       --
      Else
       --
       hr_utility.set_location(l_proc,70);
       --
       close c_compare_person_type;
       v_return_value := 'TRUE';
       --
      End If;
      --
    End If;
    --
    hr_utility.set_location('Leaving '||l_proc,80);
    --
    RETURN(v_return_value);
    --
  END Is_Type_A_System_Type;
  --
  --
  -- ---------------------------------------------------------------------------+
  -- |------------------------------< IS_ORG_A_NODE >---------------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Org_A_Node
    (p_search_org_id             IN hr_organization_units.organization_id%TYPE
    ,p_organization_structure_id IN per_org_structure_versions_v.organization_structure_id%TYPE)
    RETURN CHAR IS
    --
     Cursor   c_get_structure_version Is
      Select posvv.org_structure_version_id version_id
      From   per_organization_structures_v  posv,
             per_org_structure_versions_v   posvv,
             fnd_sessions                   fs
      Where  posvv.organization_structure_id = posv.organization_structure_id
      and    fs.effective_date Between posvv.date_from
                                   and NVL(posvv.date_to,hr_general.end_of_time)
      And    posv.organization_structure_id  = p_organization_structure_id
      And    fs.session_id = userenv('sessionid');
    --
    -- Bug fix 3648688.
    -- Cursor modified to improve performance.
    -- per_org_structure_elements is used instead of per_org_structure_elements_v.

    Cursor   c_orgs_in_hierarchy
     (p_version_id IN per_org_structure_versions_v.organization_structure_id%TYPE) IS
      select posev.organization_id_parent org_id
      from   per_org_structure_elements   posev
      where  posev.org_Structure_version_id  = p_version_id
      UNION
      select posev.organization_id_child org_id
      from   per_org_structure_elements   posev
      where  posev.org_Structure_version_id  = p_version_id;
    --
    v_org_in_hierarchy    BOOLEAN       := FALSE;
    v_users_starting_node VARCHAR2(240) := NULL;
    v_return_message      VARCHAR2(5);
    --
    v_version_id per_org_structure_versions_v.organization_structure_id%TYPE := NULL;
    --
    l_proc varchar2(72) := g_package||'Is_Org_A_Node';
    --
  BEGIN
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    Open  c_get_structure_version;
    Fetch c_get_structure_version Into v_version_id;
    Close c_get_structure_version;
    --
    hr_utility.set_location(l_proc,20);
    --
    For c_rec in c_orgs_in_hierarchy(v_version_id) Loop
      --
      If c_rec.org_id = p_search_org_id Then
        --
        v_org_in_hierarchy := TRUE;
        --
      End If;
      --
      Exit When v_org_in_hierarchy;
      --
    End Loop;
    --
    hr_utility.set_location(l_proc,30);
    --
    if v_org_in_hierarchy Then
      --
      v_return_message := 'TRUE';
      --
      hr_utility.set_location(l_proc,40);
      --
    ElsIf Not v_org_in_hierarchy Then
      --
      v_return_message := 'FALSE';
      --
      hr_utility.set_location(l_proc,50);
      --
    End If;
    --
    hr_utility.set_location('Leaving'|| l_proc, 999);
    --
    Return(v_return_message);
    --
  END Is_Org_A_Node;
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------< IS_ORG_IN_HIERARCHY >--------------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Org_In_Hierarchy
    (p_search_org_id IN hr_organization_units.organization_id%TYPE)
    RETURN CHAR IS
    --
    Cursor c_is_field_populated Is
      Select to_number(information2),
             to_number(information3)
      from   pqh_copy_entity_attribs
      Where  information2 IS NOT NULL
      And    row_type_cd                = 'CRITERIA'
      And    copy_entity_txn_id         = pqh_gen_form.g_txn_id;
    --
    Cursor c_get_hierarchy_root(p_org_hierarchy_id number) is
      select organization_id_parent
        from per_org_structure_elements ose,
	     per_org_structure_versions osv
       where osv.organization_structure_id = p_org_hierarchy_id
         and hr_general.effective_date between osv.date_from
	             and nvl(osv.date_to,hr_general.end_of_time)
	 and osv.org_structure_version_id = ose.org_structure_version_id
         and not exists
              (select 'X'
                 from per_org_structure_elements ose2
		where ose.organization_id_parent = ose2.organization_id_child
		 and osv.org_structure_version_id=ose2.org_structure_version_id);
    --
    v_org_in_hierarchy    BOOLEAN := FALSE;
    v_return_message      VARCHAR2(5);
    v_org_hierarchy_id    number;
    v_starting_node       number;
    l_dummy               varchar2(1);
    --
    l_proc                varchar2(72) := g_package||'Is_Org_In_hierarchy';
    --
  BEGIN
    --
    hr_utility.set_location('Entering:'|| l_proc||'/'||p_search_org_Id, 10);
    --
    /*
    ** This tells us whether org hierarchy query criteria
    ** has been entered for this mass update.
    */
    Open  c_is_field_populated;
    Fetch c_is_field_populated into v_org_hierarchy_id, v_starting_node;
    Close c_is_field_populated;

    if v_org_hierarchy_id is null then
      /*
      ** No org criteria has been entered so exit returning TRUE.
      */
      hr_utility.set_location(l_proc,20);

      return('TRUE');

    else

      if g_org_hierarchy_id is null then
        /*
        ** Global org hierarchy not set...
        */
        g_org_hierarchy_id := v_org_hierarchy_id;
        g_org_starting_node := v_starting_node;
	g_org_hierarchy_root := null;
        if v_starting_node is null then
          /*
	  ** derive the root node.
  	  */
          hr_utility.set_location(l_proc,22);
          open c_get_hierarchy_root(v_org_hierarchy_id);
 	  fetch c_get_hierarchy_root into g_org_hierarchy_root;
          close c_get_hierarchy_root;
        end if;
      end if;

      if g_org_hierarchy_id <> v_org_hierarchy_id OR
         nvl(g_org_starting_node,hr_api.g_number) <>
	           nvl(v_starting_node,hr_api.g_number) then
        /*
        ** Org hierarchy has changed...
        */
        g_org_hierarchy_id := v_org_hierarchy_id;
        g_org_starting_node := v_starting_node;
	g_org_hierarchy_root := null;
	if v_starting_node is null then
          /*
	  ** derive the root node.
	  */
	  hr_utility.set_location(l_proc,25);
	  open c_get_hierarchy_root(v_org_hierarchy_id);
	  fetch c_get_hierarchy_root into g_org_hierarchy_root;
	  close c_get_hierarchy_root;
        end if;
      end if;

      hr_utility.set_location(l_proc||'/'||g_org_hierarchy_id||'/'||
                              g_org_starting_node||'/'||g_org_hierarchy_root,30);
      --
      --
      If g_org_starting_node IS NULL and
         p_search_org_id <> g_org_hierarchy_root Then
        --
        hr_utility.set_location(l_proc,50);
	/*
	** I've got an org hierarchy but no starting node so the search org
	** can appear anywhere in the hierarchy. We'll implement this as a tree
	** walk up to the root node.
	*/
	begin
 	  l_dummy := null;
          select 'X'
	    into l_dummy
            from dual
           where g_org_hierarchy_root in (
             SELECT  o.organization_id_parent
               FROM  per_org_structure_elements o
         CONNECT BY o.organization_id_child  = PRIOR o.organization_id_parent
             AND    o.org_structure_version_id = PRIOR o.org_structure_version_id
         START WITH o.organization_id_child = p_search_org_id
             AND    o.org_structure_version_id   =
                   (SELECT v.org_structure_version_id
                      FROM   per_org_structure_versions v
                     WHERE  v.organization_structure_id = g_org_hierarchy_id
                       AND  hr_general.effective_date BETWEEN v.date_from
                       AND NVL(v.date_to, hr_general.end_of_time)));
          if l_dummy = 'X' then
    	    hr_utility.set_location(l_proc,52);
	    v_org_in_hierarchy := TRUE;
	  end if;
        exception
          when no_data_found then
  	    hr_utility.set_location(l_proc,55);
	    v_org_in_hierarchy := FALSE;

	  when others then
	    raise;

	end;
	--
      Elsif g_org_starting_node IS NULL and
            p_search_org_id = g_org_hierarchy_root Then
	--
	hr_utility.set_location(l_proc,60);
	/*
	** I've not got a starting node but the search node is the root
	** node
	*/
	v_org_in_hierarchy := TRUE;
        --
      ElsIf g_org_starting_node IS NOT NULL AND
            g_org_starting_node = p_search_org_id Then
        --
        hr_utility.set_location(l_proc,65);
	/*
	** I've got a starting node and it's the search org
	*/
        --
        v_org_in_hierarchy := TRUE;
        --
      ElsIf g_org_starting_node IS NOT NULL AND
            g_org_starting_node <> p_search_org_id Then
        --
        hr_utility.set_location(l_proc,70);
	/*
	** I've got a starting node, it's not the search org so search
	** the hierarchy from the search org looking for the
	** starting node.
	*/
        begin
  	  l_dummy := null;
          select 'X'
	    into l_dummy
            from dual
           where g_org_starting_node in (
             SELECT  o.organization_id_parent
               FROM  per_org_structure_elements o
         CONNECT BY o.organization_id_child  = PRIOR o.organization_id_parent
             AND    o.org_structure_version_id = PRIOR o.org_structure_version_id
         START WITH o.organization_id_child = p_search_org_id
             AND    o.org_structure_version_id   =
                   (SELECT v.org_structure_version_id
                      FROM   per_org_structure_versions v
                     WHERE  v.organization_structure_id = g_org_hierarchy_id
                       AND  hr_general.effective_date BETWEEN v.date_from
                       AND NVL(v.date_to, hr_general.end_of_time)));
          if l_dummy = 'X' then
	    v_org_in_hierarchy := TRUE;
	  end if;
	exception
          when no_data_found then
  	    hr_utility.set_location(l_proc,75);
	    v_org_in_hierarchy := FALSE;

	  when others then
	    raise;

	end;
        --
      End If;
      --
    End If;
    --
    If v_org_in_hierarchy Then
      --
      v_return_message := 'TRUE';
      --
    ElsIf Not v_org_in_hierarchy Then
      --
      v_return_message := 'FALSE';
      --
    End If;
    --
    hr_utility.set_location('Leaving: '||l_proc||' returning '
                            ||v_return_message,999);
    --
    Return(v_return_message);
    --
  END Is_Org_In_Hierarchy;
  --
  -- ---------------------------------------------------------------------------+
  -- |------------------------------< IS_POS_A_NODE >---------------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Pos_A_Node
    (p_search_pos_id         IN per_positions.position_id%TYPE
    ,p_position_structure_id IN per_pos_structure_versions_v.position_structure_id%TYPE
    ,p_effective_date        IN DATE)
    RETURN CHAR IS
    --
    Cursor   c_get_structure_version Is
      Select ppsvv.pos_structure_version_id version_id
      From   per_position_structures_v      ppsv,
             per_pos_structure_versions_v   ppsvv
      Where  ppsvv.position_structure_id  = ppsv.position_structure_id
      And    ppsv.position_structure_id   = p_position_structure_id
      and    p_effective_date between to_date(date_from,'DD/MM/YYYY') and
                              NVL(to_date(date_to,'DD/MM/YYYY'),p_effective_date);
    --
    -- Bug fix 3648688.
    -- cursor modified to improve performance.
    -- per_pos_structure_elements is used instead of per_pos_structure_elements_v.

    Cursor   c_pos_in_hierarchy
     (p_version_id IN per_pos_structure_versions_v.position_structure_id%TYPE) IS
      select ppsev.parent_position_id         pos_id
      from   per_pos_structure_elements   ppsev
      where  ppsev.pos_structure_version_id = p_version_id
      UNION
      select ppsev.subordinate_position_id     pos_id
      from   per_pos_structure_elements    ppsev
      where  ppsev.pos_structure_version_id  = p_version_id;
    --
    v_pos_in_hierarchy    BOOLEAN       := FALSE;
    v_users_starting_node VARCHAR2(240) := NULL;
    v_return_message      VARCHAR2(5);
    --
    v_version_id per_pos_structure_versions_v.position_structure_id%TYPE := NULL;
    --
    l_proc                varchar2(72) := g_package||'Is_Pos_A_Node';
    --
  BEGIN
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    Open  c_get_structure_version;
    Fetch c_get_structure_version Into v_version_id;
    Close c_get_structure_version;
    --
    hr_utility.set_location(l_proc,20);
    --
    For c_rec in c_pos_in_hierarchy(v_version_id) Loop
      --
      If c_rec.pos_id = p_search_pos_id Then
        --
        v_pos_in_hierarchy := TRUE;
        --
      End If;
      --
      Exit When v_pos_in_hierarchy;
      --
    End Loop;
    --
    hr_utility.set_location('Leaving: '||l_proc,30);
    --
    if v_pos_in_hierarchy Then
      --
      v_return_message := 'TRUE';
      --
    ElsIf Not v_pos_in_hierarchy Then
      --
      v_return_message := 'FALSE';
      --
    End If;
    --
    hr_utility.set_location('Leaving: '||l_proc,40);
    --
    Return(v_return_message);
    --
  END Is_Pos_A_Node;
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------< IS_POSITION_IN_HIERARCHY >---------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION Is_Position_In_Hierarchy
    (p_search_pos_id IN hr_all_positions_f.position_id%TYPE)
    RETURN CHAR IS
    --
    Cursor c_get_hierarchy_root(p_pos_hierarchy_id number) is
      select parent_position_id
        from per_pos_structure_elements ose,
	     per_pos_structure_versions osv
       where osv.position_structure_id = p_pos_hierarchy_id
         and hr_general.effective_date between osv.date_from
	             and nvl(osv.date_to,hr_general.end_of_time)
	 and osv.pos_structure_version_id = ose.pos_structure_version_id
         and not exists
              (select 'X'
                 from per_pos_structure_elements ose2
		where ose.parent_position_id= ose2.subordinate_position_id
		 and osv.pos_structure_version_id=ose2.pos_structure_version_id);
    --
    Cursor c_is_field_populated Is
      Select to_number(information8),
             to_number(information9)
      from   pqh_copy_entity_attribs
      Where  information8 IS NOT NULL
      And    row_type_cd                = 'CRITERIA'
      And    copy_entity_txn_id         = pqh_gen_form.g_txn_id;
    --
    v_pos_in_hierarchy    BOOLEAN := FALSE;
    v_return_message      VARCHAR2(5);
    v_pos_hierarchy       number;
    v_starting_node       number;
    l_dummy               varchar2(1);
    --
    l_proc                varchar2(72) := g_package||'Is_Position_In_Hierarchy';
    --
  BEGIN
    --
    hr_utility.set_location('Entering: '||l_proc||'/'||p_search_pos_id,10);
    Open  c_is_field_populated;
    Fetch c_is_field_populated into v_pos_hierarchy, v_starting_node;
    Close c_is_field_populated;
    --
    --
    If v_pos_hierarchy is null Then
      /*
      ** No pos hierarchy criteria  has been entered or the
      ** assignment has no position so exit returning TRUE.
      */
      hr_utility.set_location(l_proc,20);

      return('TRUE');
      --
    Else
      --
      if g_pos_hierarchy_id is null then
        /*
        ** Global pos hierarchy not set...
        */
        g_pos_hierarchy_id := v_pos_hierarchy;
        g_pos_starting_node := v_starting_node;
	g_pos_hierarchy_root := null;
        if v_starting_node is null then
          /*
	  ** derive the root node.
  	  */
          hr_utility.set_location(l_proc,22);
          open c_get_hierarchy_root(v_pos_hierarchy);
 	  fetch c_get_hierarchy_root into g_pos_hierarchy_root;
          close c_get_hierarchy_root;
        end if;
      end if;

      if g_pos_hierarchy_id <> v_pos_hierarchy OR
         nvl(g_pos_starting_node,hr_api.g_number) <>
	           nvl(v_starting_node,hr_api.g_number)then
        /*
        ** Org hierarchy has changed...
        */
        g_pos_hierarchy_id := v_pos_hierarchy;
        g_pos_starting_node := v_starting_node;
	g_pos_hierarchy_root := null;
	if v_starting_node is null then
          /*
	  ** derive the root node.
	  */
	  hr_utility.set_location(l_proc,25);
	  open c_get_hierarchy_root(v_pos_hierarchy);
	  fetch c_get_hierarchy_root into g_pos_hierarchy_root;
	  close c_get_hierarchy_root;
        end if;
      end if;

      hr_utility.set_location(l_proc||'/'||g_pos_hierarchy_id||'/'||
                              g_pos_starting_node||'/'||g_pos_hierarchy_root,30);
      --
      if g_pos_starting_node IS NULL and
         p_search_pos_id <> g_pos_hierarchy_root then

	hr_utility.set_location(l_proc,40);
	/*
        ** I've got a pos hierarchy but no starting node so the search pos
	** just needs to appear in the hierarchy. Implement this as a tree
	** walk up the hierarchy to the root node.
	*/
	begin
 	  l_dummy := null;
          select 'X'
	    into l_dummy
            from dual
           where g_pos_hierarchy_root in (
             SELECT  o.parent_position_id
               FROM  per_pos_structure_elements o
         CONNECT BY o.subordinate_position_id = PRIOR o.parent_position_id
             AND    o.pos_structure_version_id = PRIOR o.pos_structure_version_id
         START WITH o.subordinate_position_id = p_search_pos_id
             AND    o.pos_structure_version_id   =
                   (SELECT v.pos_structure_version_id
                      FROM per_pos_structure_versions v
                     WHERE v.position_structure_id = g_pos_hierarchy_id
                       AND hr_general.effective_date BETWEEN v.date_from
                       AND NVL(v.date_to, hr_general.end_of_time)));
          if l_dummy = 'X' then
    	    hr_utility.set_location(l_proc,50);
	    v_pos_in_hierarchy := TRUE;
	  end if;
        exception
          when no_data_found then
  	    hr_utility.set_location(l_proc,60);
	    v_pos_in_hierarchy := FALSE;

	  when others then
	    raise;

	end;
      Elsif g_pos_starting_node IS NULL and
            p_search_pos_id = g_pos_hierarchy_root Then
	--
	hr_utility.set_location(l_proc,70);
	/*
	** I've not got a starting node but the search node is the root
	** node
	*/
	v_pos_in_hierarchy := TRUE;
        --
      ElsIf g_pos_starting_node IS NOT NULL AND
            g_pos_starting_node = p_search_pos_id Then
        --
        hr_utility.set_location(l_proc,80);
	/*
	** I've got a starting node and it's the search pos
	*/
        --
        v_pos_in_hierarchy := TRUE;
        --
      ElsIf g_pos_starting_node IS NOT NULL AND
            g_pos_starting_node <> p_search_pos_id Then
        --
        hr_utility.set_location(l_proc,90);
	/*
	** I've got a starting node, it's not the search pos so search
	** the hierarchy from the search pos looking for the
	** starting node.
	*/
	begin
 	  l_dummy := null;
          select 'X'
	    into l_dummy
            from dual
           where g_pos_starting_node in (
             SELECT  o.parent_position_id
               FROM  per_pos_structure_elements o
         CONNECT BY o.subordinate_position_id = PRIOR o.parent_position_id
             AND    o.pos_structure_version_id = PRIOR o.pos_structure_version_id
         START WITH o.subordinate_position_id = p_search_pos_id
             AND    o.pos_structure_version_id   =
                   (SELECT v.pos_structure_version_id
                      FROM per_pos_structure_versions v
                     WHERE v.position_structure_id = g_pos_hierarchy_id
                       AND hr_general.effective_date BETWEEN v.date_from
                       AND NVL(v.date_to, hr_general.end_of_time)));
          if l_dummy = 'X' then
    	    hr_utility.set_location(l_proc,100);
	    v_pos_in_hierarchy := TRUE;
	  end if;
        exception
          when no_data_found then
  	    hr_utility.set_location(l_proc,110);
	    v_pos_in_hierarchy := FALSE;

	  when others then
	    raise;

	end;
        --
      End If;
      --
    End If;
    --
    If v_pos_in_hierarchy Then
      --
      v_return_message := 'TRUE';
      --
    ElsIf Not v_pos_in_hierarchy Then
      --
      v_return_message := 'FALSE';
      --
    End If;
    --
    hr_utility.set_location('Leaving: '||l_proc||' returning '
                            ||v_return_message,120);
    --
    Return(v_return_message);
    --
  END Is_Position_In_Hierarchy;
  --
  -- ---------------------------------------------------------------------------+
  -- |------------------------------< WRITE_HEADER >----------------------------+
  -- ---------------------------------------------------------------------------+
  --
  PROCEDURE Write_Header(p_assignment_number IN
                         per_assignments_f.assignment_number%TYPE) IS
    --
    l_proc                varchar2(72) := g_package||'Write_Header';
    --
  BEGIN
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,'Errors For Assignment Number '||p_assignment_number);
    fnd_file.put_line(fnd_file.log,'==================================');
    --fnd_file.new_line(fnd_file.log,1);
    --
    hr_utility.set_location('Leaving: '||l_proc,20);
    --
  END Write_Header;
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------------< LOG_ERROR >------------------------------+
  -- ---------------------------------------------------------------------------+
  --
  PROCEDURE Log_Error(p_type              IN    VARCHAR2,
                      p_assignment_number IN    per_assignments_f.assignment_number%TYPE,
                      p_warning_message   IN    VARCHAR2,
                      p_already_errored   IN OUT NOCOPY BOOLEAN) IS
    --
    v_error_message VARCHAR2(255) := NULL;
    --
    l_proc          VARCHAR2(72) := g_package||'Log_Error';
    --
    l_already_errored  BOOLEAN := p_already_errored;
    --
  BEGIN
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    If p_already_errored = FALSE Then
      --
      Write_Header(p_assignment_number);
      p_already_errored := TRUE;
      --
    End If;
    --
    fnd_file.put_line(fnd_file.log,'TYPE = '||p_type);
    --
    If p_type = 'ERROR' Then
      --
      hr_utility.set_location(l_proc,20);
      --
      fnd_file.new_line(fnd_file.log,1);
      fnd_file.put_line(fnd_file.log,SQLERRM);
      --
      --v_error_message := rtrim(substr(SQLERRM,1,INSTR(SQLERRM,'Cause:')-1),' ');
      --fnd_file.put_line(fnd_file.log,v_error_message);
      --
      -- v_error_message :=
	  -- substr(SQLERRM,INSTR(SQLERRM,'Cause:'),INSTR(SQLERRM,'Action:')-1);
      -- fnd_file.put_line(fnd_file.log,v_error_message);
      --
    ElsIf p_type = 'WARNING' Then
      --
      hr_utility.set_location(l_proc,30);
      --
      fnd_file.put_line(fnd_file.log,p_warning_message);
      --
    End If;
    --
    hr_utility.set_location('Leaving: '||l_proc,40);
    --
  EXCEPTION
    when others then
       p_already_errored := l_already_errored;
       RAISE;

  END Log_Error;
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------< CHK_FOR_NON_APL_FIELDS >-----------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION chk_for_non_apl_fields
    (p_hourly_salaried_code          IN     VARCHAR2
    ,p_labour_union_member_flag      IN     VARCHAR2
    ,p_project_title                 IN     VARCHAR2
    ,p_vendor_assignment_number      IN     VARCHAR2
    ,p_vendor_employee_number        IN     VARCHAR2
    ,p_vendor_id                     IN     NUMBER
    ,p_vendor_site_id                IN     NUMBER ) RETURN BOOLEAN IS
    --
    l_return_value BOOLEAN := FALSE;
    --
  BEGIN
    --
    IF p_hourly_salaried_code          IS NOT NULL OR
       p_labour_union_member_flag      IS NOT NULL OR
       p_project_title                 IS NOT NULL OR
       p_vendor_assignment_number      IS NOT NULL OR
       p_vendor_employee_number        IS NOT NULL OR
       p_vendor_id                     IS NOT NULL OR
       p_vendor_site_id                IS NOT NULL THEN
      --
      l_return_value := TRUE;
      --
    END IF;
    --
    RETURN(l_return_value);
    --
  END chk_for_non_apl_fields;
  --
 -- ---------------------------------------------------------------------------+
  -- |-------------------------< CHK_FOR_NON_EMP_FIELDS >-----------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION chk_for_non_emp_fields
    (p_application_id                IN     NUMBER
    ,p_person_referred_by_id         IN     NUMBER
    ,p_project_title                 IN     VARCHAR2
    ,p_recruiter_id                  IN     NUMBER
    ,p_recruitment_activity_id       IN     NUMBER
    ,p_source_organization_id        IN     NUMBER
    ,p_vacancy_id                    IN     NUMBER
    ,p_vendor_assignment_number      IN     VARCHAR2
    ,p_vendor_employee_number        IN     VARCHAR2
    ,p_vendor_id                     IN     NUMBER
    ,p_vendor_site_id                IN     NUMBER
    ,p_projected_assignment_end      IN     DATE) RETURN BOOLEAN IS
    --
    l_return_value BOOLEAN := FALSE;
    --
  BEGIN
    --
   IF nvl(p_application_id,hr_api.g_number)              <> hr_api.g_number   OR
       nvl(p_person_referred_by_id, hr_api.g_number)     <> hr_api.g_number   OR
       nvl(p_project_title, hr_api.g_varchar2)           <> hr_api.g_varchar2 OR
       nvl(p_recruiter_id, hr_api.g_number)              <> hr_api.g_number   OR
       nvl(p_recruitment_activity_id,hr_api.g_number)    <> hr_api.g_number   OR
       nvl(p_source_organization_id, hr_api.g_number)    <> hr_api.g_number   OR
       nvl(p_vacancy_id, hr_api.g_number)                <> hr_api.g_number   OR
       nvl(p_vendor_assignment_number, hr_api.g_varchar2)<> hr_api.g_varchar2 OR
       nvl(p_vendor_employee_number,  hr_api.g_varchar2) <> hr_api.g_varchar2 OR
       nvl(p_vendor_id,  hr_api.g_number)                <> hr_api.g_number   OR
       nvl(p_vendor_site_id,hr_api.g_number)             <> hr_api.g_number   OR
       nvl(p_projected_assignment_end,hr_api.g_date)     <> hr_api.g_date     THEN
      --
       l_return_value := TRUE;
      --
    END IF;
    --
    RETURN(l_return_value);
    --
  END chk_for_non_emp_fields;
  --
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------< CHK_FOR_NON_CWK_FIELDS >-----------------------+
  -- ---------------------------------------------------------------------------+
  --
  FUNCTION chk_for_non_cwk_fields
    (p_application_id                IN     NUMBER
    ,p_bargaining_unit_code          IN     VARCHAR2
    ,p_cag_segment1                  IN     VARCHAR2
    ,p_cag_segment10                 IN     VARCHAR2
    ,p_cag_segment11                 IN     VARCHAR2
    ,p_cag_segment12                 IN     VARCHAR2
    ,p_cag_segment13                 IN     VARCHAR2
    ,p_cag_segment14                 IN     VARCHAR2
    ,p_cag_segment15                 IN     VARCHAR2
    ,p_cag_segment16                 IN     VARCHAR2
    ,p_cag_segment17                 IN     VARCHAR2
    ,p_cag_segment18                 IN     VARCHAR2
    ,p_cag_segment19                 IN     VARCHAR2
    ,p_cag_segment2                  IN     VARCHAR2
    ,p_cag_segment20                 IN     VARCHAR2
    ,p_cag_segment3                  IN     VARCHAR2
    ,p_cag_segment4                  IN     VARCHAR2
    ,p_cag_segment5                  IN     VARCHAR2
    ,p_cag_segment6                  IN     VARCHAR2
    ,p_cag_segment7                  IN     VARCHAR2
    ,p_cag_segment8                  IN     VARCHAR2
    ,p_cag_segment9                  IN     VARCHAR2
    ,p_cagr_id_flex_num              IN     NUMBER
    ,p_collective_agreement_id       IN     NUMBER
    ,p_contract_id                   IN     NUMBER
    ,p_date_probation_end            IN     DATE
    ,p_grade_ladder_pgm_id           IN     NUMBER
    ,p_grade_id                      IN     NUMBER
    ,p_hourly_salaried_code          IN     VARCHAR2
    ,p_pay_basis_id                  IN     NUMBER
    ,p_payroll_id                    IN     NUMBER
    ,p_perf_review_period            IN     NUMBER
    ,p_perf_review_period_frequency  IN     VARCHAR2
    ,p_person_referred_by_id         IN     NUMBER
    ,p_probation_period              IN     NUMBER
    ,p_probation_unit                IN     VARCHAR2
    ,p_recruiter_id                  IN     NUMBER
    ,p_recruitment_activity_id       IN     NUMBER
    ,p_sal_review_period             IN     NUMBER
    ,p_sal_review_period_frequency   IN     VARCHAR2
    ,p_source_organization_id        IN     NUMBER
    ,p_special_ceiling_step_id       IN     NUMBER
    ,p_vacancy_id                    IN     NUMBER) RETURN BOOLEAN IS
    --
    l_return_value BOOLEAN := FALSE;
    --
  BEGIN
    --
    IF nvl(p_application_id,hr_api.g_number)               <> hr_api.g_number  OR
      nvl(p_bargaining_unit_code, hr_api.g_varchar2)       <> hr_api.g_varchar2 OR
      nvl(p_cag_segment1 , hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment10, hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment11 , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment12 , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment13, hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment14 , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment15 , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment16, hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment17, hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment18 , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment19 , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment2 , hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment20 , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment3, hr_api.g_varchar2)               <> hr_api.g_varchar2 OR
      nvl(p_cag_segment4, hr_api.g_varchar2)               <> hr_api.g_varchar2 OR
      nvl(p_cag_segment5  , hr_api.g_varchar2)             <> hr_api.g_varchar2 OR
      nvl(p_cag_segment6, hr_api.g_varchar2)               <> hr_api.g_varchar2 OR
      nvl(p_cag_segment7 , hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment8 , hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cag_segment9 , hr_api.g_varchar2)              <> hr_api.g_varchar2 OR
      nvl(p_cagr_id_flex_num, hr_api.g_number)             <> hr_api.g_number  OR
      nvl(p_collective_agreement_id, hr_api.g_number)      <> hr_api.g_number  OR
      nvl(p_contract_id, hr_api.g_number)                  <> hr_api.g_number  OR
      nvl(p_date_probation_end , hr_api.g_date)            <> hr_api.g_date OR
      nvl(p_grade_ladder_pgm_id, hr_api.g_number)          <> hr_api.g_number  OR
      nvl(p_grade_id, hr_api.g_number)			   <> hr_api.g_number  OR
      nvl(p_hourly_salaried_code, hr_api.g_varchar2)       <> hr_api.g_varchar2 OR
      nvl(p_pay_basis_id, hr_api.g_number)                 <> hr_api.g_number  OR
      nvl(p_payroll_id, hr_api.g_number)                   <> hr_api.g_number  OR
      nvl(p_perf_review_period, hr_api.g_number)           <> hr_api.g_number  OR
      nvl(p_perf_review_period_frequency,hr_api.g_varchar2) <> hr_api.g_varchar2 OR
      nvl(p_person_referred_by_id, hr_api.g_number)        <> hr_api.g_number  OR
      nvl(p_probation_period , hr_api.g_number)            <> hr_api.g_number  OR
      nvl(p_probation_unit , hr_api.g_varchar2)            <> hr_api.g_varchar2 OR
      nvl(p_recruiter_id, hr_api.g_number)                 <> hr_api.g_number  OR
      nvl(p_recruitment_activity_id, hr_api.g_number)      <> hr_api.g_number  OR
      nvl(p_sal_review_period ,hr_api.g_number)            <> hr_api.g_number  OR
      nvl(p_sal_review_period_frequency, hr_api.g_varchar2) <> hr_api.g_varchar2 OR
      nvl(p_source_organization_id, hr_api.g_number)      <> hr_api.g_number  OR
      nvl(p_special_ceiling_step_id, hr_api.g_number)     <> hr_api.g_number  OR
      nvl(p_vacancy_id, hr_api.g_number)                  <> hr_api.g_number  THEN
      --
      l_return_value := TRUE;
      --
    END IF;
    --
    RETURN(l_return_value);
    --
  END chk_for_non_cwk_fields;
  --
  --
  -- ---------------------------------------------------------------------------+
  -- |---------------------------------< UPD_ASG >------------------------------+
  -- ---------------------------------------------------------------------------+
  --
  PROCEDURE upd_asg (
    p_ASS_ATTRIBUTE_CATEGORY       IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE1               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE10              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE11              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE12              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE13              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE14              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE15              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE16              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE17              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE18              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE19              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE2               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE20              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE21              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE22              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE23              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE24              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE25              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE26              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE27              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE28              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE29              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE3               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE30              IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE4               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE5               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE6               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE7               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE8               IN     VARCHAR2 ,
    p_ASS_ATTRIBUTE9               IN     VARCHAR2 ,
    p_ASSIGNMENT_ID                IN     NUMBER   ,
    p_ASSIGNMENT_NUMBER            IN     VARCHAR2 ,
    p_ASSIGNMENT_STATUS_TYPE_ID    IN     NUMBER   ,
    p_BARGAINING_UNIT_CODE         IN     VARCHAR2 ,
    p_CAGR_GRADE_DEF_ID            IN  OUT NOCOPY NUMBER   ,
    p_CAGR_ID_FLEX_NUM             IN     NUMBER   ,
    p_CHANGE_REASON                IN     VARCHAR2 ,
    p_COLLECTIVE_AGREEMENT_ID      IN     NUMBER   ,
    p_COMMENT_ID                      OUT NOCOPY NUMBER   ,
    p_CONTRACT_ID                  IN     NUMBER   ,
    p_DATE_PROBATION_END           IN     DATE     ,
    p_DEFAULT_CODE_COMB_ID         IN     NUMBER   ,
    p_ESTABLISHMENT_ID             IN     NUMBER   ,
    p_EMPLOYMENT_CATEGORY          IN     VARCHAR2 ,
    p_FREQUENCY                    IN     VARCHAR2 ,
    p_GRADE_ID                     IN     NUMBER  ,
    p_HOURLY_SALARIED_CODE         IN     VARCHAR2 ,
    p_INTERNAL_ADDRESS_LINE        IN     VARCHAR2 ,
    p_JOB_ID                       IN     NUMBER  ,
    p_LABOUR_UNION_MEMBER_FLAG     IN     VARCHAR2 ,
    p_LOCATION_ID                  IN     NUMBER  ,
    p_MANAGER_FLAG                 IN     VARCHAR2 ,
    p_NORMAL_HOURS                 IN     NUMBER   ,
    p_OBJECT_VERSION_NUMBER        IN OUT NOCOPY NUMBER   ,
    p_ORGANIZATION_ID              IN OUT NOCOPY NUMBER  ,
    p_PAY_BASIS_ID                 IN     NUMBER  ,
    p_PAYROLL_ID                   IN     NUMBER  ,
    p_PERF_REVIEW_PERIOD           IN     NUMBER   ,
    p_PERF_REVIEW_PERIOD_FREQUENCY IN     VARCHAR2 ,
    p_POSITION_ID                  IN     NUMBER  ,
    p_PROBATION_PERIOD             IN     NUMBER   ,
    p_PROBATION_UNIT               IN     VARCHAR2 ,
    p_SAL_REVIEW_PERIOD            IN     NUMBER   ,
    p_SAL_REVIEW_PERIOD_FREQUENCY  IN     VARCHAR2 ,
    p_SET_OF_BOOKS_ID              IN     NUMBER   ,
    p_SOFT_CODING_KEYFLEX_ID          OUT NOCOPY NUMBER   ,
    p_SOURCE_TYPE                  IN     VARCHAR2 ,
    p_SPECIAL_CEILING_STEP_ID      IN OUT NOCOPY NUMBER  ,
    p_SUPERVISOR_ID                IN     NUMBER   ,
    P_SUPERVISOR_ASSIGNMENT_ID     IN     NUMBER  ,
    p_TIME_NORMAL_FINISH           IN     VARCHAR2 ,
    p_TIME_NORMAL_START            IN     VARCHAR2 ,
    p_TITLE                        IN     VARCHAR2 ,
    p_ENTRIES_CHANGED_WARNING         OUT NOCOPY VARCHAR2,
    p_GROUP_NAME                      OUT NOCOPY VARCHAR2,
    p_ORG_NOW_NO_MANAGER_WARNING      OUT NOCOPY BOOLEAN ,
    p_PEOPLE_GROUP_ID                 OUT NOCOPY NUMBER  ,
    p_SPP_DELETE_WARNING              OUT NOCOPY BOOLEAN ,
    p_TAX_DISTRICT_CHANGED_WARNING    OUT NOCOPY BOOLEAN ,
    p_CAG_SEGMENT1                 IN     VARCHAR2 ,
    p_CAG_SEGMENT10                IN     VARCHAR2 ,
    p_CAG_SEGMENT11                IN     VARCHAR2 ,
    p_CAG_SEGMENT12                IN     VARCHAR2 ,
    p_CAG_SEGMENT13                IN     VARCHAR2 ,
    p_CAG_SEGMENT14                IN     VARCHAR2 ,
    p_CAG_SEGMENT15                IN     VARCHAR2 ,
    p_CAG_SEGMENT16                IN     VARCHAR2 ,
    p_CAG_SEGMENT17                IN     VARCHAR2 ,
    p_CAG_SEGMENT18                IN     VARCHAR2 ,
    p_CAG_SEGMENT19                IN     VARCHAR2 ,
    p_CAG_SEGMENT2                 IN     VARCHAR2 ,
    p_CAG_SEGMENT20                IN     VARCHAR2 ,
    p_CAG_SEGMENT3                 IN     VARCHAR2 ,
    p_CAG_SEGMENT4                 IN     VARCHAR2 ,
    p_CAG_SEGMENT5                 IN     VARCHAR2 ,
    p_CAG_SEGMENT6                 IN     VARCHAR2 ,
    p_CAG_SEGMENT7                 IN     VARCHAR2 ,
    p_CAG_SEGMENT8                 IN     VARCHAR2 ,
    p_CAG_SEGMENT9                 IN     VARCHAR2 ,
    p_CAGR_CONCATENATED_SEGMENTS      OUT NOCOPY VARCHAR2 ,
    p_COMMENTS                     IN     VARCHAR2 ,
    p_CONCAT_SEGMENTS              IN     VARCHAR2 ,
    p_CONCATENATED_SEGMENTS        IN OUT NOCOPY VARCHAR2 ,
    p_DATETRACK_UPDATE_MODE        IN     VARCHAR2 ,
    p_EFFECTIVE_DATE               IN     DATE     ,
    p_EFFECTIVE_END_DATE              OUT NOCOPY DATE     ,
    p_EFFECTIVE_START_DATE            OUT NOCOPY DATE     ,
    p_NO_MANAGERS_WARNING             OUT NOCOPY BOOLEAN  ,
    p_OTHER_MANAGER_WARNING           OUT NOCOPY BOOLEAN  ,
    p_GSP_POST_PROCESS_WARNING        OUT NOCOPY VARCHAR2  ,
    p_SEGMENT1                     IN     VARCHAR2 ,
    p_SEGMENT10                    IN     VARCHAR2 ,
    p_SEGMENT11                    IN     VARCHAR2 ,
    p_SEGMENT12                    IN     VARCHAR2 ,
    p_SEGMENT13                    IN     VARCHAR2 ,
    p_SEGMENT14                    IN     VARCHAR2 ,
    p_SEGMENT15                    IN     VARCHAR2 ,
    p_SEGMENT16                    IN     VARCHAR2 ,
    p_SEGMENT17                    IN     VARCHAR2 ,
    p_SEGMENT18                    IN     VARCHAR2 ,
    p_SEGMENT19                    IN     VARCHAR2 ,
    p_SEGMENT2                     IN     VARCHAR2 ,
    p_SEGMENT20                    IN     VARCHAR2 ,
    p_SEGMENT21                    IN     VARCHAR2 ,
    p_SEGMENT22                    IN     VARCHAR2 ,
    p_SEGMENT23                    IN     VARCHAR2 ,
    p_SEGMENT24                    IN     VARCHAR2 ,
    p_SEGMENT25                    IN     VARCHAR2 ,
    p_SEGMENT26                    IN     VARCHAR2 ,
    p_SEGMENT27                    IN     VARCHAR2 ,
    p_SEGMENT28                    IN     VARCHAR2 ,
    p_SEGMENT29                    IN     VARCHAR2 ,
    p_SEGMENT3                     IN     VARCHAR2 ,
    p_SEGMENT30                    IN     VARCHAR2 ,
    p_SEGMENT4                     IN     VARCHAR2 ,
    p_SEGMENT5                     IN     VARCHAR2 ,
    p_SEGMENT6                     IN     VARCHAR2 ,
    p_SEGMENT7                     IN     VARCHAR2 ,
    p_SEGMENT8                     IN     VARCHAR2 ,
    p_SEGMENT9                     IN     VARCHAR2 ,
    p_SCL_SEGMENT1                 IN     VARCHAR2 ,
    p_SCL_SEGMENT10                IN     VARCHAR2 ,
    p_SCL_SEGMENT11                IN     VARCHAR2 ,
    p_SCL_SEGMENT12                IN     VARCHAR2 ,
    p_SCL_SEGMENT13                IN     VARCHAR2 ,
    p_SCL_SEGMENT14                IN     VARCHAR2 ,
    p_SCL_SEGMENT15                IN     VARCHAR2 ,
    p_SCL_SEGMENT16                IN     VARCHAR2 ,
    p_SCL_SEGMENT17                IN     VARCHAR2 ,
    p_SCL_SEGMENT18                IN     VARCHAR2 ,
    p_SCL_SEGMENT19                IN     VARCHAR2 ,
    p_SCL_SEGMENT2                 IN     VARCHAR2 ,
    p_SCL_SEGMENT20                IN     VARCHAR2 ,
    p_SCL_SEGMENT21                IN     VARCHAR2 ,
    p_SCL_SEGMENT22                IN     VARCHAR2 ,
    p_SCL_SEGMENT23                IN     VARCHAR2 ,
    p_SCL_SEGMENT24                IN     VARCHAR2 ,
    p_SCL_SEGMENT25                IN     VARCHAR2 ,
    p_SCL_SEGMENT26                IN     VARCHAR2 ,
    p_SCL_SEGMENT27                IN     VARCHAR2 ,
    p_SCL_SEGMENT28                IN     VARCHAR2 ,
    p_SCL_SEGMENT29                IN     VARCHAR2 ,
    p_SCL_SEGMENT3                 IN     VARCHAR2 ,
    p_SCL_SEGMENT30                IN     VARCHAR2 ,
    p_SCL_SEGMENT4                 IN     VARCHAR2 ,
    p_SCL_SEGMENT5                 IN     VARCHAR2 ,
    p_SCL_SEGMENT6                 IN     VARCHAR2 ,
    p_SCL_SEGMENT7                 IN     VARCHAR2 ,
    p_SCL_SEGMENT8                 IN     VARCHAR2 ,
    p_SCL_SEGMENT9                 IN     VARCHAR2 ,
    p_GRADE_LADDER_PGM_ID          IN     NUMBER   ,
    p_VALIDATE                     IN     BOOLEAN  ) IS
    --
    cursor csr_check_estab is
    select count(organization_id)
	  from hr_organization_information hoi_estab
	 where hoi_estab.organization_id = p_organization_id
       and hoi_estab.org_information_context || '' = 'CLASS'
       and hoi_estab.org_information1 = 'FR_ETABLISSEMENT'
       and hoi_estab.org_information2= 'Y';
    ---
    cursor csr_get_org is
    select organization_id
      from per_all_assignments_f
     where assignment_id = p_assignment_id
       and p_effective_date between effective_start_date and effective_end_date;
    ---
    v_log_message                VARCHAR2(255);
    v_already_errored            BOOLEAN := FALSE;
    l_asg_future_changes_warning BOOLEAN := FALSE;
    l_entries_changed_warning    VARCHAR2(10);
    l_pay_proposal_warning       BOOLEAN := FALSE;
    l_proc                       VARCHAR2(72) := g_package||'upd_asg';
    l_effective_date             DATE;
    l_assignment_status          per_assignment_status_types.per_system_status%TYPE;
    --
    l_message_text               VARCHAR2(255);
    --
    l_OBJECT_VERSION_NUMBER        NUMBER := p_OBJECT_VERSION_NUMBER ;
--    l_ORGANIZATION_ID              NUMBER := p_ORGANIZATION_ID ;
    L_CAGR_GRADE_DEF_ID            NUMBER := P_CAGR_GRADE_DEF_ID;
    l_SPECIAL_CEILING_STEP_ID      NUMBER := p_SPECIAL_CEILING_STEP_ID ;
    l_CONCATENATED_SEGMENTS        VARCHAR2(4000) := p_CONCATENATED_SEGMENTS ;
    l_concat_segments               VARCHAR2(4000):= p_concat_segments;
    l_dummy_b                     boolean;
    l_dummy_n                     number := null;
    l_dummy_v                     varchar2(4000);
    -- Checking for duplicate assignments
    l_establishment_id            number;
    l_organization_id             number;
    l_duplicate_assignment        number;
    --
  BEGIN
    --
    --hr_utility.trace_on(NULL,'ORACLE'); --ynegoro
    hr_utility.set_location('Entering : '|| l_proc, 10);

    -- check for duplicate assignments
    l_duplicate_assignment := 0;
    if p_asg_id.first is not null then
       for i in p_asg_id.first..p_asg_id.last
       loop
          if p_asg_id(i) = p_assignment_id then
             l_duplicate_assignment := 1;
             hr_utility.set_location('Assignment already updated'||l_proc, 5);
          end if;
       end loop;
    end if;
    if l_duplicate_assignment = 0 then
       if p_asg_id.last is not null then
          p_asg_id(p_asg_id.last + 1) := p_assignment_id;
       else
          p_asg_id(1) := p_assignment_id;
       end if;
       hr_utility.set_location('Assignment appended to plsql table'||l_proc, 5);
       hr_utility.set_location('p_asg_id.last'||p_asg_id.last, 5);
    --
    -- Issue a savepoint.
    --
    SAVEPOINT upd_asg;
    --
    l_effective_date := TRUNC(p_effective_date);
    --
    -- Check the organization for establishment
    BEGIN
    OPEN csr_check_estab;
    fetch csr_check_estab into l_establishment_id;
    close csr_check_estab;
    if l_establishment_id > 0 then
       -- The organization is an establishment
       l_establishment_id := p_organization_id;
       open csr_get_org;
       fetch csr_get_org into l_organization_id;
       close csr_get_org;

       hr_utility.set_location('it is establishment', 55);
       hr_utility.set_location('l_establishment_id'||l_establishment_id, 55);
       hr_utility.set_location('l_organization_id'||l_organization_id, 55);
    else
       l_establishment_id := p_establishment_id;
       l_organization_id := p_organization_id;
       hr_utility.set_location('it is not establishment', 55);
       hr_utility.set_location('l_establishment_id'||l_establishment_id, 55);
       hr_utility.set_location('l_organization_id'||l_organization_id, 55);
    end if;
    end;
    --
    BEGIN
      --
	     hr_utility.set_location(l_proc,15);
	     --
      hr_assignment_api.update_emp_asg (
        P_VALIDATE                      =>  P_VALIDATE                      ,
        P_EFFECTIVE_DATE                =>  L_EFFECTIVE_DATE                ,
        P_DATETRACK_UPDATE_MODE         =>  P_DATETRACK_UPDATE_MODE         ,
        P_ASSIGNMENT_ID                 =>  P_ASSIGNMENT_ID                 ,
        P_OBJECT_VERSION_NUMBER         =>  P_OBJECT_VERSION_NUMBER         ,
        P_SUPERVISOR_ID                 =>  P_SUPERVISOR_ID                 ,
	P_SUPERVISOR_ASSIGNMENT_ID      =>  P_SUPERVISOR_ASSIGNMENT_ID      ,
        P_ASSIGNMENT_NUMBER             =>  P_ASSIGNMENT_NUMBER             ,
        P_CHANGE_REASON                 =>  P_CHANGE_REASON                 ,
        P_COMMENTS                      =>  P_COMMENTS                      ,
        P_DATE_PROBATION_END            =>  P_DATE_PROBATION_END            ,
        P_DEFAULT_CODE_COMB_ID          =>  P_DEFAULT_CODE_COMB_ID          ,
        P_FREQUENCY                     =>  P_FREQUENCY                     ,
        P_INTERNAL_ADDRESS_LINE         =>  P_INTERNAL_ADDRESS_LINE         ,
        P_MANAGER_FLAG                  =>  P_MANAGER_FLAG                  ,
        P_NORMAL_HOURS                  =>  P_NORMAL_HOURS                  ,
        P_PERF_REVIEW_PERIOD            =>  P_PERF_REVIEW_PERIOD            ,
        P_PERF_REVIEW_PERIOD_FREQUENCY  =>  P_PERF_REVIEW_PERIOD_FREQUENCY  ,
        P_PROBATION_PERIOD              =>  P_PROBATION_PERIOD              ,
        P_PROBATION_UNIT                =>  P_PROBATION_UNIT                ,
        P_SAL_REVIEW_PERIOD             =>  P_SAL_REVIEW_PERIOD             ,
        P_SAL_REVIEW_PERIOD_FREQUENCY   =>  P_SAL_REVIEW_PERIOD_FREQUENCY   ,
        P_SET_OF_BOOKS_ID               =>  P_SET_OF_BOOKS_ID               ,
        P_SOURCE_TYPE                   =>  P_SOURCE_TYPE                   ,
        P_TIME_NORMAL_FINISH            =>  P_TIME_NORMAL_FINISH            ,
        P_TIME_NORMAL_START             =>  P_TIME_NORMAL_START             ,
        P_BARGAINING_UNIT_CODE          =>  P_BARGAINING_UNIT_CODE          ,
        P_LABOUR_UNION_MEMBER_FLAG      =>  P_LABOUR_UNION_MEMBER_FLAG      ,
        P_HOURLY_SALARIED_CODE          =>  P_HOURLY_SALARIED_CODE          ,
        P_ASS_ATTRIBUTE_CATEGORY        =>  P_ASS_ATTRIBUTE_CATEGORY        ,
        P_ASS_ATTRIBUTE1                =>  P_ASS_ATTRIBUTE1                ,
        P_ASS_ATTRIBUTE2                =>  P_ASS_ATTRIBUTE2                ,
        P_ASS_ATTRIBUTE3                =>  P_ASS_ATTRIBUTE3                ,
        P_ASS_ATTRIBUTE4                =>  P_ASS_ATTRIBUTE4                ,
        P_ASS_ATTRIBUTE5                =>  P_ASS_ATTRIBUTE5                ,
        P_ASS_ATTRIBUTE6                =>  P_ASS_ATTRIBUTE6                ,
        P_ASS_ATTRIBUTE7                =>  P_ASS_ATTRIBUTE7                ,
        P_ASS_ATTRIBUTE8                =>  P_ASS_ATTRIBUTE8                ,
        P_ASS_ATTRIBUTE9                =>  P_ASS_ATTRIBUTE9                ,
        P_ASS_ATTRIBUTE10               =>  P_ASS_ATTRIBUTE10               ,
        P_ASS_ATTRIBUTE11               =>  P_ASS_ATTRIBUTE11               ,
        P_ASS_ATTRIBUTE12               =>  P_ASS_ATTRIBUTE12               ,
        P_ASS_ATTRIBUTE13               =>  P_ASS_ATTRIBUTE13               ,
        P_ASS_ATTRIBUTE14               =>  P_ASS_ATTRIBUTE14               ,
        P_ASS_ATTRIBUTE15               =>  P_ASS_ATTRIBUTE15               ,
        P_ASS_ATTRIBUTE16               =>  P_ASS_ATTRIBUTE16               ,
        P_ASS_ATTRIBUTE17               =>  P_ASS_ATTRIBUTE17               ,
        P_ASS_ATTRIBUTE18               =>  P_ASS_ATTRIBUTE18               ,
        P_ASS_ATTRIBUTE19               =>  P_ASS_ATTRIBUTE19               ,
        P_ASS_ATTRIBUTE20               =>  P_ASS_ATTRIBUTE20               ,
        P_ASS_ATTRIBUTE21               =>  P_ASS_ATTRIBUTE21               ,
        P_ASS_ATTRIBUTE22               =>  P_ASS_ATTRIBUTE22               ,
        P_ASS_ATTRIBUTE23               =>  P_ASS_ATTRIBUTE23               ,
        P_ASS_ATTRIBUTE24               =>  P_ASS_ATTRIBUTE24               ,
        P_ASS_ATTRIBUTE25               =>  P_ASS_ATTRIBUTE25               ,
        P_ASS_ATTRIBUTE26               =>  P_ASS_ATTRIBUTE26               ,
        P_ASS_ATTRIBUTE27               =>  P_ASS_ATTRIBUTE27               ,
        P_ASS_ATTRIBUTE28               =>  P_ASS_ATTRIBUTE28               ,
        P_ASS_ATTRIBUTE29               =>  P_ASS_ATTRIBUTE29               ,
        P_ASS_ATTRIBUTE30               =>  P_ASS_ATTRIBUTE30               ,
        P_TITLE                         =>  P_TITLE                         ,
        P_SEGMENT1                      =>  P_SCL_SEGMENT1                  ,
        P_SEGMENT2                      =>  P_SCL_SEGMENT2                  ,
        P_SEGMENT3                      =>  P_SCL_SEGMENT3                  ,
        P_SEGMENT4                      =>  P_SCL_SEGMENT4                  ,
        P_SEGMENT5                      =>  P_SCL_SEGMENT5                  ,
        P_SEGMENT6                      =>  P_SCL_SEGMENT6                  ,
        P_SEGMENT7                      =>  P_SCL_SEGMENT7                  ,
        P_SEGMENT8                      =>  P_SCL_SEGMENT8                  ,
        P_SEGMENT9                      =>  P_SCL_SEGMENT9                  ,
        P_SEGMENT10                     =>  P_SCL_SEGMENT10                 ,
        P_SEGMENT11                     =>  P_SCL_SEGMENT11                 ,
        P_SEGMENT12                     =>  P_SCL_SEGMENT12                 ,
        P_SEGMENT13                     =>  P_SCL_SEGMENT13                 ,
        P_SEGMENT14                     =>  P_SCL_SEGMENT14                 ,
        P_SEGMENT15                     =>  P_SCL_SEGMENT15                 ,
        P_SEGMENT16                     =>  P_SCL_SEGMENT16                 ,
        P_SEGMENT17                     =>  P_SCL_SEGMENT17                 ,
        P_SEGMENT18                     =>  P_SCL_SEGMENT18                 ,
        P_SEGMENT19                     =>  P_SCL_SEGMENT19                 ,
        P_SEGMENT20                     =>  P_SCL_SEGMENT20                 ,
        P_SEGMENT21                     =>  P_SCL_SEGMENT21                 ,
        P_SEGMENT22                     =>  P_SCL_SEGMENT22                 ,
        P_SEGMENT23                     =>  P_SCL_SEGMENT23                 ,
        P_SEGMENT24                     =>  P_SCL_SEGMENT24                 ,
        P_SEGMENT25                     =>  P_SCL_SEGMENT25                 ,
        P_SEGMENT26                     =>  P_SCL_SEGMENT26                 ,
        P_SEGMENT27                     =>  P_SCL_SEGMENT27                 ,
        P_SEGMENT28                     =>  P_SCL_SEGMENT28                 ,
        P_SEGMENT29                     =>  P_SCL_SEGMENT29                 ,
        P_SEGMENT30                     =>  P_SCL_SEGMENT30                 ,
        P_CONCAT_SEGMENTS               =>  L_CONCAT_SEGMENTS               ,
        --P_CONTRACT_ID                   =>  P_CONTRACT_ID                 ,
        P_ESTABLISHMENT_ID              =>  l_establishment_id              ,
        P_COLLECTIVE_AGREEMENT_ID       =>  P_COLLECTIVE_AGREEMENT_ID       ,
        --P_CAGR_ID_FLEX_NUM              =>  P_CAGR_ID_FLEX_NUM            ,
        P_CAG_SEGMENT1                  =>  P_CAG_SEGMENT1                  ,
        P_CAG_SEGMENT2                  =>  P_CAG_SEGMENT2                  ,
        P_CAG_SEGMENT3                  =>  P_CAG_SEGMENT3                  ,
        P_CAG_SEGMENT4                  =>  P_CAG_SEGMENT4                  ,
        P_CAG_SEGMENT5                  =>  P_CAG_SEGMENT5                  ,
        P_CAG_SEGMENT6                  =>  P_CAG_SEGMENT6                  ,
        P_CAG_SEGMENT7                  =>  P_CAG_SEGMENT7                  ,
        P_CAG_SEGMENT8                  =>  P_CAG_SEGMENT8                  ,
        P_CAG_SEGMENT9                  =>  P_CAG_SEGMENT9                  ,
        P_CAG_SEGMENT10                 =>  P_CAG_SEGMENT10                 ,
        P_CAG_SEGMENT11                 =>  P_CAG_SEGMENT11                 ,
        P_CAG_SEGMENT12                 =>  P_CAG_SEGMENT12                 ,
        P_CAG_SEGMENT13                 =>  P_CAG_SEGMENT13                 ,
        P_CAG_SEGMENT14                 =>  P_CAG_SEGMENT14                 ,
        P_CAG_SEGMENT15                 =>  P_CAG_SEGMENT15                 ,
        P_CAG_SEGMENT16                 =>  P_CAG_SEGMENT16                 ,
        P_CAG_SEGMENT17                 =>  P_CAG_SEGMENT17                 ,
        P_CAG_SEGMENT18                 =>  P_CAG_SEGMENT18                 ,
        P_CAG_SEGMENT19                 =>  P_CAG_SEGMENT19                 ,
        P_CAG_SEGMENT20                 =>  P_CAG_SEGMENT20                 ,
        P_CAGR_GRADE_DEF_ID             =>  L_CAGR_GRADE_DEF_ID             ,
        P_CAGR_CONCATENATED_SEGMENTS    =>  P_CAGR_CONCATENATED_SEGMENTS    ,
        P_CONCATENATED_SEGMENTS         =>  P_CONCATENATED_SEGMENTS         ,
        P_SOFT_CODING_KEYFLEX_ID        =>  P_SOFT_CODING_KEYFLEX_ID        ,
        P_COMMENT_ID                    =>  P_COMMENT_ID                    ,
        P_EFFECTIVE_START_DATE          =>  P_EFFECTIVE_START_DATE          ,
        P_EFFECTIVE_END_DATE            =>  P_EFFECTIVE_END_DATE            ,
        P_NO_MANAGERS_WARNING           =>  P_NO_MANAGERS_WARNING           ,
        P_OTHER_MANAGER_WARNING         =>  P_OTHER_MANAGER_WARNING         ,
        P_HOURLY_SALARIED_WARNING       =>  l_dummy_b                       ,
        P_GSP_POST_PROCESS_WARNING      =>  P_GSP_POST_PROCESS_WARNING      );
      --
      hr_utility.set_location(l_proc, 20);
      --
      If p_no_managers_warning = TRUE Then
        --
        hr_utility.set_message(800,'HR_289214_NO_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => v_already_errored);
        --
      ElsIf p_other_manager_warning = TRUE Then
        --
        hr_utility.set_message(800,'HR_289215_DUPLICATE_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => v_already_errored);
        --
      End If;
      --
      if p_gsp_post_process_warning is not null then
        --
        fnd_message.set_name('PQH',p_gsp_post_process_warning);
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => v_already_errored);
        --
      end if;

      hr_utility.set_location(l_proc, 30);
      --
      EXCEPTION
        --
        When OTHERS Then
          --
          hr_utility.set_location(l_proc, 35);
          --
          ROLLBACK TO upd_asg;
          --
          Log_Error(p_type              => 'ERROR',
                    p_assignment_number => p_assignment_number,
                    p_warning_message   => NULL,
                    p_already_errored   => v_already_errored);
          RAISE;
      --
    END;
    --
    BEGIN
      --
      hr_utility.set_location(l_proc, 40);
      --
      hr_assignment_api.update_emp_asg_criteria (
        P_VALIDATE                      =>  P_VALIDATE                      ,
        P_EFFECTIVE_DATE                =>  L_EFFECTIVE_DATE                ,
        P_DATETRACK_UPDATE_MODE         =>  P_DATETRACK_UPDATE_MODE         ,
        P_CALLED_FROM_MASS_UPDATE       =>  TRUE                            ,
        P_ASSIGNMENT_ID                 =>  P_ASSIGNMENT_ID                 ,
        P_OBJECT_VERSION_NUMBER         =>  P_OBJECT_VERSION_NUMBER         ,
        P_GRADE_ID                      =>  P_GRADE_ID                      ,
        P_POSITION_ID                   =>  P_POSITION_ID                   ,
        P_JOB_ID                        =>  P_JOB_ID                        ,
        P_PAYROLL_ID                    =>  P_PAYROLL_ID                    ,
        P_LOCATION_ID                   =>  P_LOCATION_ID                   ,
        P_SPECIAL_CEILING_STEP_ID       =>  P_SPECIAL_CEILING_STEP_ID       ,
        P_ORGANIZATION_ID               =>  l_organization_id               ,
        P_PAY_BASIS_ID                  =>  P_PAY_BASIS_ID                  ,
        P_SEGMENT1                      =>  P_SEGMENT1                      ,
        P_SEGMENT2                      =>  P_SEGMENT2                      ,
        P_SEGMENT3                      =>  P_SEGMENT3                      ,
        P_SEGMENT4                      =>  P_SEGMENT4                      ,
        P_SEGMENT5                      =>  P_SEGMENT5                      ,
        P_SEGMENT6                      =>  P_SEGMENT6                      ,
        P_SEGMENT7                      =>  P_SEGMENT7                      ,
        P_SEGMENT8                      =>  P_SEGMENT8                      ,
        P_SEGMENT9                      =>  P_SEGMENT9                      ,
        P_SEGMENT10                     =>  P_SEGMENT10                     ,
        P_SEGMENT11                     =>  P_SEGMENT11                     ,
        P_SEGMENT12                     =>  P_SEGMENT12                     ,
        P_SEGMENT13                     =>  P_SEGMENT13                     ,
        P_SEGMENT14                     =>  P_SEGMENT14                     ,
        P_SEGMENT15                     =>  P_SEGMENT15                     ,
        P_SEGMENT16                     =>  P_SEGMENT16                     ,
        P_SEGMENT17                     =>  P_SEGMENT17                     ,
        P_SEGMENT18                     =>  P_SEGMENT18                     ,
        P_SEGMENT19                     =>  P_SEGMENT19                     ,
        P_SEGMENT20                     =>  P_SEGMENT20                     ,
        P_SEGMENT21                     =>  P_SEGMENT21                     ,
        P_SEGMENT22                     =>  P_SEGMENT22                     ,
        P_SEGMENT23                     =>  P_SEGMENT23                     ,
        P_SEGMENT24                     =>  P_SEGMENT24                     ,
        P_SEGMENT25                     =>  P_SEGMENT25                     ,
        P_SEGMENT26                     =>  P_SEGMENT26                     ,
        P_SEGMENT27                     =>  P_SEGMENT27                     ,
        P_SEGMENT28                     =>  P_SEGMENT28                     ,
        P_SEGMENT29                     =>  P_SEGMENT29                     ,
        P_SEGMENT30                     =>  P_SEGMENT30                     ,
        P_CONCAT_SEGMENTS               =>  P_CONCAT_SEGMENTS               ,
        P_GROUP_NAME                    =>  P_GROUP_NAME                    ,
        P_EMPLOYMENT_CATEGORY           =>  P_EMPLOYMENT_CATEGORY           ,
        P_EFFECTIVE_START_DATE          =>  P_EFFECTIVE_START_DATE          ,
        P_EFFECTIVE_END_DATE            =>  P_EFFECTIVE_END_DATE            ,
        P_PEOPLE_GROUP_ID               =>  P_PEOPLE_GROUP_ID               ,
        P_GRADE_LADDER_PGM_ID           =>  P_GRADE_LADDER_PGM_ID           ,
        P_ORG_NOW_NO_MANAGER_WARNING    =>  P_ORG_NOW_NO_MANAGER_WARNING    ,
        P_OTHER_MANAGER_WARNING         =>  P_OTHER_MANAGER_WARNING         ,
        P_SPP_DELETE_WARNING            =>  P_SPP_DELETE_WARNING            ,
        P_ENTRIES_CHANGED_WARNING       =>  P_ENTRIES_CHANGED_WARNING       ,
        P_TAX_DISTRICT_CHANGED_WARNING  =>  P_TAX_DISTRICT_CHANGED_WARNING  ,
        P_SOFT_CODING_KEYFLEX_ID        =>  l_dummy_n                       ,
        P_CONCATENATED_SEGMENTS         =>  l_dummy_v                       ,
        P_GSP_POST_PROCESS_WARNING      =>  P_GSP_POST_PROCESS_WARNING      );
      --
      hr_utility.set_location(l_proc, 50);
        --
      If p_spp_delete_warning = TRUE Then
        --
        hr_utility.set_message(800,'HR_289826_SPP_DELETE_WARN_API');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => v_already_errored);
        --
       end if;
      --
      If p_org_now_no_manager_warning = TRUE Then
        --
        hr_utility.set_message(800,'HR_289214_NO_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => v_already_errored);
        --
      ElsIf p_other_manager_warning = TRUE Then
        --
        hr_utility.set_message(800,'HR_289215_DUPLICATE_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => v_already_errored);
        --
      End If;
      --
      If p_gsp_post_process_warning is not null Then
        --
        fnd_message.set_name('PQH',p_gsp_post_process_warning);
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => v_already_errored);
        --
      End If;
      --
      hr_utility.set_location(l_proc, 60);
      --
      EXCEPTION
        --
        When OTHERS Then
          --
          hr_utility.set_location(l_proc, 65);
          --
          ROLLBACK TO upd_asg;
          --
          Log_Error(p_type              => 'ERROR',
                    p_assignment_number => p_assignment_number,
                    p_warning_message   => NULL,
                    p_already_errored   => v_already_errored);
          RAISE;
        --
    END;
    --
    hr_utility.set_location(l_proc, 70);
    --
    BEGIN
      --
      -- Retrieve the Assignment Status from the id past in.
      --
      l_assignment_status :=
        get_assignment_status_type
          (p_assignment_status_type_id => p_assignment_status_type_id);
      --
      hr_utility.set_location(l_proc, 80);
      --
      -- Call the correct assignment status API
      -- depending on what the assignment status is being
      -- changed to.
      --
      IF l_assignment_status = 'SUSP_ASSIGN' THEN
        --
        hr_utility.set_location(l_proc, 90);
        --
        hr_assignment_api.suspend_emp_asg
          (p_validate                     => p_validate
          ,p_effective_date               => l_effective_date
          ,p_datetrack_update_mode        => 'CORRECTION' --p_datetrack_update_mode
          ,p_assignment_id                => p_assignment_id
          ,p_change_reason                => p_change_reason
          ,p_object_version_number        => p_object_version_number
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          ,p_effective_start_date         => p_effective_start_date
          ,p_effective_end_date           => p_effective_end_date);
        --
        hr_utility.set_location(l_proc, 100);
        --
      ELSIF l_assignment_status = 'TERM_ASSIGN' THEN
        --
        hr_utility.set_location(l_proc, 110);
        --
        hr_assignment_api.actual_termination_emp_asg
          (p_validate                     => p_validate
          ,p_assignment_id                => p_assignment_id
          ,p_object_version_number        => p_object_version_number
          ,p_actual_termination_date      => l_effective_date
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          ,p_effective_start_date         => p_effective_start_date
          ,p_effective_end_date           => p_effective_end_date
          ,p_asg_future_changes_warning   => l_asg_future_changes_warning
          ,p_entries_changed_warning      => l_entries_changed_warning
          ,p_pay_proposal_warning         => l_pay_proposal_warning);
        --
        hr_utility.set_location(l_proc, 120);
        --
        IF l_asg_future_changes_warning = TRUE THEN
          --
          hr_utility.set_message(800,'HR_289216_FUTURE_CHANGES_REMOV');
          l_message_text := 'WARNING: '||hr_utility.get_message;
          --
          Log_Error
            (p_type              => 'WARNING'
            ,p_assignment_number => p_assignment_number
            ,p_warning_message   => l_message_text
            ,p_already_errored   => v_already_errored);
          --
        ELSIF l_entries_changed_warning <> 'N' THEN
          --
          hr_utility.set_message(800,'HR_289218_ENTRIES_CHANGED');
          l_message_text := 'WARNING: '||hr_utility.get_message;
          --
          Log_Error
            (p_type              => 'WARNING'
            ,p_assignment_number => p_assignment_number
            ,p_warning_message   => l_message_text
            ,p_already_errored   => v_already_errored);
          --
        ELSIF l_pay_proposal_warning THEN
          --
          hr_utility.set_message(800,'HR_289217_PAY_PROPOSAL_REMOVED');
          l_message_text := 'WARNING: '||hr_utility.get_message;
          --
          Log_Error
            (p_type              => 'WARNING'
            ,p_assignment_number => p_assignment_number
            ,p_warning_message   => l_message_text
            ,p_already_errored   => v_already_errored);
          --
        END IF;
        --
      ELSE
        --
        hr_utility.set_location(l_proc, 130);
        --
        hr_assignment_api.activate_emp_asg
          (p_validate                     => p_validate
          ,p_effective_date               => l_effective_date
          ,p_datetrack_update_mode        => 'CORRECTION' --p_datetrack_update_mode
          ,p_assignment_id                => p_assignment_id
          ,p_change_reason                => p_change_reason
          ,p_object_version_number        => p_object_version_number
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          ,p_effective_start_date         => p_effective_start_date
          ,p_effective_end_date           => p_effective_end_date);
        --
        hr_utility.set_location(l_proc, 140);
        --
      END IF;
      --
      EXCEPTION
        --
        WHEN OTHERS THEN
          --
          hr_utility.set_location(l_proc, 145);
          --
          p_OBJECT_VERSION_NUMBER       := l_OBJECT_VERSION_NUMBER ;
          p_ORGANIZATION_ID             := l_ORGANIZATION_ID ;
          p_SPECIAL_CEILING_STEP_ID     := l_SPECIAL_CEILING_STEP_ID ;
          p_CONCATENATED_SEGMENTS       := l_CONCATENATED_SEGMENTS ;
          p_CAGR_GRADE_DEF_ID           := l_CAGR_GRADE_DEF_ID;

	  p_COMMENT_ID                  := null;
          p_SOFT_CODING_KEYFLEX_ID      := null;
          p_ENTRIES_CHANGED_WARNING     := null;
          p_GROUP_NAME                  := null;
          p_ORG_NOW_NO_MANAGER_WARNING  := null;
          p_PEOPLE_GROUP_ID             := null;
          p_SPP_DELETE_WARNING          := null;
          p_TAX_DISTRICT_CHANGED_WARNING := null;
          p_CAGR_CONCATENATED_SEGMENTS  := null;
          p_EFFECTIVE_END_DATE          := null;
          p_EFFECTIVE_START_DATE        := null;
          p_NO_MANAGERS_WARNING         := null;
          p_OTHER_MANAGER_WARNING       := null;

          ROLLBACK TO upd_asg;
          --
          Log_Error(p_type              => 'ERROR',
                    p_assignment_number => p_assignment_number,
                    p_warning_message   => NULL,
                    p_already_errored   => v_already_errored);
          --
          RAISE;
      --
    END;
    else
       hr_utility.set_location('duplicate assignment'||l_proc, 995);
    end if; --ends duplicate assignment checking
    --
    hr_utility.set_location('Leaving : '||l_proc, 999);
    --
  END upd_asg;
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------< UPDATE_APPLICANT_ASG >-------------------------+
  -- ---------------------------------------------------------------------------+
  --
  PROCEDURE update_applicant_asg
    (p_validate                     in     boolean  default false
    ,p_effective_date               in     date
    ,p_datetrack_update_mode        in     varchar2
    ,p_assignment_id                in     number
    ,p_object_version_number        in out nocopy number
    ,p_recruiter_id                 in     number   default hr_api.g_number
    ,p_grade_id                     in     number   default hr_api.g_number
    ,p_position_id                  in     number   default hr_api.g_number
    ,p_job_id                       in     number   default hr_api.g_number
    ,p_payroll_id                   in     number   default hr_api.g_number
    ,p_location_id                  in     number   default hr_api.g_number
    ,p_person_referred_by_id        in     number   default hr_api.g_number
    ,p_assignment_status_type_id    in     number   default hr_api.g_number
    ,p_supervisor_id                in     number   default hr_api.g_number
    ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT hr_api.g_number
    ,p_special_ceiling_step_id      in     number   default hr_api.g_number
    ,p_recruitment_activity_id      in     number   default hr_api.g_number
    ,p_source_organization_id       in     number   default hr_api.g_number
    ,p_organization_id              in     number   default hr_api.g_number
    ,p_vacancy_id                   in     number   default hr_api.g_number
    ,p_pay_basis_id                 in     number   default hr_api.g_number
    ,p_application_id               in     number   default hr_api.g_number
    ,p_change_reason                in     varchar2 default hr_api.g_varchar2
    ,p_comments                     in     varchar2 default hr_api.g_varchar2
    ,p_date_probation_end           in     date     default hr_api.g_date
    ,p_default_code_comb_id         in     number   default hr_api.g_number
    ,p_employment_category          in     varchar2 default hr_api.g_varchar2
    ,p_frequency                    in     varchar2 default hr_api.g_varchar2
    ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
    ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
    ,p_normal_hours                 in     number   default hr_api.g_number
    ,p_perf_review_period           in     number   default hr_api.g_number
    ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
    ,p_probation_period             in     number   default hr_api.g_number
    ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
    ,p_sal_review_period            in     number   default hr_api.g_number
    ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
    ,p_set_of_books_id              in     number   default hr_api.g_number
    ,p_source_type                  in     varchar2 default hr_api.g_varchar2
    ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
    ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
    ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
    ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
    ,p_title                        in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment1                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment2                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment3                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment4                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment5                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment6                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment7                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment8                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment9                 in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment10                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment11                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment12                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment13                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment14                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment15                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment16                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment17                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment18                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment19                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment20                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment21                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment22                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment23                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment24                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment25                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment26                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment27                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment28                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment29                in     varchar2 default hr_api.g_varchar2
    ,p_scl_segment30                in     varchar2 default hr_api.g_varchar2
    ,p_concatenated_segments        in out nocopy varchar2
    ,p_pgp_segment1                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment2                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment3                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment4                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment5                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment6                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment7                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment8                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment9                 in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment10                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment11                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment12                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment13                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment14                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment15                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment16                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment17                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment18                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment19                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment20                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment21                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment22                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment23                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment24                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment25                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment26                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment27                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment28                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment29                in     varchar2 default hr_api.g_varchar2
    ,p_pgp_segment30                in     varchar2 default hr_api.g_varchar2
    ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
    ,p_contract_id                  in     number   default hr_api.g_number
    ,p_establishment_id             in     number   default hr_api.g_number
    ,p_collective_agreement_id      in     number   default hr_api.g_number
    ,p_cagr_id_flex_num             in     number   default hr_api.g_number
    ,p_cag_segment1                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment2                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment3                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment4                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment5                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment6                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment7                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment8                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment9                 in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment10                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment11                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment12                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment13                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment14                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment15                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment16                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment17                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment18                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment19                in     varchar2 default hr_api.g_varchar2
    ,p_cag_segment20                in     varchar2 default hr_api.g_varchar2
    ,p_grade_ladder_pgm_id          in     number   default hr_api.g_number
    ,p_cagr_grade_def_id            in  out nocopy number
    ,p_cagr_concatenated_segments      out nocopy varchar2
    ,p_group_name                      out nocopy varchar2
    ,p_comment_id                      out nocopy number
    ,p_people_group_id                 out nocopy number
    ,p_soft_coding_keyflex_id          out nocopy number
    ,p_effective_start_date            out nocopy date
    ,p_effective_end_date              out nocopy date     ) is
    --
    -- Procedure Return Variables
    --
    l_group_name                 varchar2(240) := NULL;
    l_comment_id                 number   := NULL;
    l_people_group_id            number   := NULL;
    l_soft_coding_keyflex_id     number   := NULL;
    l_cagr_grade_def_id          number := p_cagr_grade_def_id;
    l_cagr_concatenated_segments varchar2(240);
    l_scl_concat_segments        hr_soft_Coding_keyflex.concatenated_segments%TYPE;
    --
    -- General Variables

    l_object_version_number      number          := p_object_version_number ;
    l_concatenated_segments      varchar2(4000)  := p_concatenated_segments ;
    --
    --
    l_proc                       varchar2(72) := g_package||'Update_Applicant_Asg';
    v_log_message                varchar2(255);
    v_already_errored            boolean := FALSE;
    --
    l_effective_date             DATE;
    l_assignment_status          per_assignment_status_types.per_system_status%TYPE;
    --
    l_message_text               VARCHAR2(255);
    --
  BEGIN
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    l_effective_date      := TRUNC(p_effective_date);
    --
    l_scl_concat_segments := p_concatenated_segments;
    --
    BEGIN
      --
      hr_utility.set_location(l_proc,20);
      --
      hr_assignment_api.update_apl_asg
        (p_validate                         => p_validate
        ,p_effective_date                   => l_effective_date
        ,p_datetrack_update_mode            => p_datetrack_update_mode
        ,p_assignment_id                    => p_assignment_id
        ,p_object_version_number            => p_object_version_number
        ,p_recruiter_id                     => p_recruiter_id
        ,p_grade_id                         => p_grade_id
        ,p_grade_ladder_pgm_id              => p_grade_ladder_pgm_id
        ,p_position_id                      => p_position_id
        ,p_job_id                           => p_job_id
        ,p_payroll_id                       => p_payroll_id
        ,p_location_id                      => p_location_id
        ,p_person_referred_by_id            => p_person_referred_by_id
        ,p_supervisor_id                    => p_supervisor_id
	,p_supervisor_assignment_id         => p_supervisor_assignment_id
        ,p_special_ceiling_step_id          => p_special_ceiling_step_id
        ,p_recruitment_activity_id          => p_recruitment_activity_id
        ,p_source_organization_id           => p_source_organization_id
        ,p_organization_id                  => p_organization_id
        ,p_vacancy_id                       => p_vacancy_id
        ,p_pay_basis_id                     => p_pay_basis_id
        ,p_application_id                   => p_application_id
        ,p_change_reason                    => p_change_reason
        ,p_comments                         => p_comments
        ,p_date_probation_end               => p_date_probation_end
        ,p_default_code_comb_id             => p_default_code_comb_id
        ,p_employment_category              => p_employment_category
        ,p_frequency                        => p_frequency
        ,p_internal_address_line            => p_internal_address_line
        ,p_manager_flag                     => p_manager_flag
        ,p_normal_hours                     => p_normal_hours
        ,p_perf_review_period               => p_perf_review_period
        ,p_perf_review_period_frequency     => p_perf_review_period_frequency
        ,p_probation_period                 => p_probation_period
        ,p_probation_unit                   => p_probation_unit
        ,p_sal_review_period                => p_sal_review_period
        ,p_sal_review_period_frequency      => p_sal_review_period_frequency
        ,p_set_of_books_id                  => p_set_of_books_id
        ,p_source_type                      => p_source_type
        ,p_time_normal_finish               => p_time_normal_finish
        ,p_time_normal_start                => p_time_normal_start
        ,p_bargaining_unit_code             => p_bargaining_unit_code
        ,p_ass_attribute_category           => p_ass_attribute_category
        ,p_ass_attribute1                   => p_ass_attribute1
        ,p_ass_attribute2                   => p_ass_attribute2
        ,p_ass_attribute3                   => p_ass_attribute3
        ,p_ass_attribute4                   => p_ass_attribute4
        ,p_ass_attribute5                   => p_ass_attribute5
        ,p_ass_attribute6                   => p_ass_attribute6
        ,p_ass_attribute7                   => p_ass_attribute7
        ,p_ass_attribute8                   => p_ass_attribute8
        ,p_ass_attribute9                   => p_ass_attribute9
        ,p_ass_attribute10                  => p_ass_attribute10
        ,p_ass_attribute11                  => p_ass_attribute11
        ,p_ass_attribute12                  => p_ass_attribute12
        ,p_ass_attribute13                  => p_ass_attribute13
        ,p_ass_attribute14                  => p_ass_attribute14
        ,p_ass_attribute15                  => p_ass_attribute15
        ,p_ass_attribute16                  => p_ass_attribute16
        ,p_ass_attribute17                  => p_ass_attribute17
        ,p_ass_attribute18                  => p_ass_attribute18
        ,p_ass_attribute19                  => p_ass_attribute19
        ,p_ass_attribute20                  => p_ass_attribute20
        ,p_ass_attribute21                  => p_ass_attribute21
        ,p_ass_attribute22                  => p_ass_attribute22
        ,p_ass_attribute23                  => p_ass_attribute23
        ,p_ass_attribute24                  => p_ass_attribute24
        ,p_ass_attribute25                  => p_ass_attribute25
        ,p_ass_attribute26                  => p_ass_attribute26
        ,p_ass_attribute27                  => p_ass_attribute27
        ,p_ass_attribute28                  => p_ass_attribute28
        ,p_ass_attribute29                  => p_ass_attribute29
        ,p_ass_attribute30                  => p_ass_attribute30
        ,p_title                            => p_title
        ,p_scl_segment1                     => p_scl_segment1
        ,p_scl_segment2                     => p_scl_segment2
        ,p_scl_segment3                     => p_scl_segment3
        ,p_scl_segment4                     => p_scl_segment4
        ,p_scl_segment5                     => p_scl_segment5
        ,p_scl_segment6                     => p_scl_segment6
        ,p_scl_segment7                     => p_scl_segment7
        ,p_scl_segment8                     => p_scl_segment8
        ,p_scl_segment9                     => p_scl_segment9
        ,p_scl_segment10                    => p_scl_segment10
        ,p_scl_segment11                    => p_scl_segment11
        ,p_scl_segment12                    => p_scl_segment12
        ,p_scl_segment13                    => p_scl_segment13
        ,p_scl_segment14                    => p_scl_segment14
        ,p_scl_segment15                    => p_scl_segment15
        ,p_scl_segment16                    => p_scl_segment16
        ,p_scl_segment17                    => p_scl_segment17
        ,p_scl_segment18                    => p_scl_segment18
        ,p_scl_segment19                    => p_scl_segment19
        ,p_scl_segment20                    => p_scl_segment20
        ,p_scl_segment21                    => p_scl_segment21
        ,p_scl_segment22                    => p_scl_segment22
        ,p_scl_segment23                    => p_scl_segment23
        ,p_scl_segment24                    => p_scl_segment24
        ,p_scl_segment25                    => p_scl_segment25
        ,p_scl_segment26                    => p_scl_segment26
        ,p_scl_segment27                    => p_scl_segment27
        ,p_scl_segment28                    => p_scl_segment28
        ,p_scl_segment29                    => p_scl_segment29
        ,p_scl_segment30                    => p_scl_segment30
        ,p_scl_concat_segments              => l_scl_concat_segments
        ,p_concatenated_segments            => p_concatenated_segments
        ,p_pgp_segment1                     => p_pgp_segment1
        ,p_pgp_segment2                     => p_pgp_segment2
        ,p_pgp_segment3                     => p_pgp_segment3
        ,p_pgp_segment4                     => p_pgp_segment4
        ,p_pgp_segment5                     => p_pgp_segment5
        ,p_pgp_segment6                     => p_pgp_segment6
        ,p_pgp_segment7                     => p_pgp_segment7
        ,p_pgp_segment8                     => p_pgp_segment8
        ,p_pgp_segment9                     => p_pgp_segment9
        ,p_pgp_segment10                    => p_pgp_segment10
        ,p_pgp_segment11                    => p_pgp_segment11
        ,p_pgp_segment12                    => p_pgp_segment12
        ,p_pgp_segment13                    => p_pgp_segment13
        ,p_pgp_segment14                    => p_pgp_segment14
        ,p_pgp_segment15                    => p_pgp_segment15
        ,p_pgp_segment16                    => p_pgp_segment16
        ,p_pgp_segment17                    => p_pgp_segment17
        ,p_pgp_segment18                    => p_pgp_segment18
        ,p_pgp_segment19                    => p_pgp_segment19
        ,p_pgp_segment20                    => p_pgp_segment20
        ,p_pgp_segment21                    => p_pgp_segment21
        ,p_pgp_segment22                    => p_pgp_segment22
        ,p_pgp_segment23                    => p_pgp_segment23
        ,p_pgp_segment24                    => p_pgp_segment24
        ,p_pgp_segment25                    => p_pgp_segment25
        ,p_pgp_segment26                    => p_pgp_segment26
        ,p_pgp_segment27                    => p_pgp_segment27
        ,p_pgp_segment28                    => p_pgp_segment28
        ,p_pgp_segment29                    => p_pgp_segment29
        ,p_pgp_segment30                    => p_pgp_segment30
        ,p_concat_segments                  => p_concat_segments
        --,p_contract_id                      => p_contract_id
        ,p_establishment_id                 => p_establishment_id
        --,p_collective_agreement_id          => p_collective_agreement_id
        --,p_cagr_id_flex_num                 => p_cagr_id_flex_num
        ,p_cag_segment1                     => p_cag_segment1
        ,p_cag_segment2                     => p_cag_segment2
        ,p_cag_segment3                     => p_cag_segment3
        ,p_cag_segment4                     => p_cag_segment4
        ,p_cag_segment5                     => p_cag_segment5
        ,p_cag_segment6                     => p_cag_segment6
        ,p_cag_segment7                     => p_cag_segment7
        ,p_cag_segment8                     => p_cag_segment8
        ,p_cag_segment9                     => p_cag_segment9
        ,p_cag_segment10                    => p_cag_segment10
        ,p_cag_segment11                    => p_cag_segment11
        ,p_cag_segment12                    => p_cag_segment12
        ,p_cag_segment13                    => p_cag_segment13
        ,p_cag_segment14                    => p_cag_segment14
        ,p_cag_segment15                    => p_cag_segment15
        ,p_cag_segment16                    => p_cag_segment16
        ,p_cag_segment17                    => p_cag_segment17
        ,p_cag_segment18                    => p_cag_segment18
        ,p_cag_segment19                    => p_cag_segment19
        ,p_cag_segment20                    => p_cag_segment20
        ,p_cagr_grade_def_id                => l_cagr_grade_def_id
        ,p_cagr_concatenated_segments       => p_cagr_concatenated_segments
        ,p_group_name                       => p_group_name
        ,p_comment_id                       => p_comment_id
        ,p_people_group_id                  => p_people_group_id
        ,p_soft_coding_keyflex_id           => p_soft_coding_keyflex_id
        ,p_effective_start_date             => p_effective_start_date
        ,p_effective_end_date               => p_effective_end_date);
      --
      hr_utility.set_location(l_proc,30);
      --
    EXCEPTION
      --
      WHEN OTHERS THEN
        --
        log_error
          (p_type              => 'ERROR'
          ,p_assignment_number => p_assignment_id
          ,p_warning_message   => NULL
          ,p_already_errored   => v_already_errored);
        --
        RAISE;
      --
    END;
    --
    BEGIN
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Retrieve the Assignment Status from the id past in.
      --
      l_assignment_status :=
        get_assignment_status_type
          (p_assignment_status_type_id => p_assignment_status_type_id);
      --
      hr_utility.set_location(l_proc, 50);
      --
      -- Call the correct assignment status API
      -- depending on what the assignment status is being
      -- changed to.
      --
      IF l_assignment_status = 'ACCEPTED' THEN
        --
        hr_utility.set_location(l_proc, 60);
        --
        hr_assignment_api.accept_apl_asg
         (p_validate                     => p_validate
         ,p_effective_date               => l_effective_date
         ,p_datetrack_update_mode        => 'CORRECTION'
         ,p_assignment_id                => p_assignment_id
         ,p_object_version_number        => p_object_version_number
         ,p_assignment_status_type_id    => p_assignment_status_type_id
         ,p_change_reason                => p_change_reason
         ,p_effective_start_date         => p_effective_start_date
         ,p_effective_end_date           => p_effective_end_date
         );
        --
        hr_utility.set_location(l_proc, 100);
        --
      ELSIF l_assignment_status = 'ACTIVE_APL' THEN
        --
        hr_utility.set_location(l_proc, 110);
        --
        hr_assignment_api.activate_apl_asg
          (p_validate                     => p_validate
          ,p_effective_date               => l_effective_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => p_assignment_id
          ,p_object_version_number        => p_object_version_number
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          ,p_change_reason                => p_change_reason
          ,p_effective_start_date         => p_effective_start_date
          ,p_effective_end_date           => p_effective_end_date);
        --
        hr_utility.set_location(l_proc, 120);
        --
      ELSIF l_assignment_status = 'OFFER' THEN
        --
        hr_utility.set_location(l_proc,130);
        --
        hr_assignment_api.offer_apl_asg
          (p_validate                     => p_validate
          ,p_effective_date               => l_effective_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => p_assignment_id
          ,p_object_version_number        => p_object_version_number
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          ,p_change_reason                => p_change_reason
          ,p_effective_start_date         => p_effective_start_date
          ,p_effective_end_date           => p_effective_end_date);
        --
        hr_utility.set_location(l_proc,140);
        --
      ELSE
        --
        hr_utility.set_location(l_proc, 130);
        --
        hr_assignment_internal.update_status_type_apl_asg
         (p_effective_date            => l_effective_date
         ,p_datetrack_update_mode     => 'CORRECTION'
         ,p_assignment_id             => p_assignment_id
         ,p_object_version_number     => p_object_version_number
         ,p_expected_system_status    => l_assignment_status
         ,p_assignment_status_type_id => p_assignment_status_type_id
         ,p_change_reason             => p_change_reason
         ,p_effective_start_date      => p_effective_start_date
         ,p_effective_end_date        => p_effective_end_date);
        --
        hr_utility.set_location(l_proc, 140);
        --
      END IF;
      --
      EXCEPTION
        --
        WHEN OTHERS THEN
          --

          p_object_version_number    := l_object_version_number ;
          p_concatenated_segments    := l_concatenated_segments ;
          p_cagr_grade_def_id        := l_CAGR_GRADE_DEF_ID ;

	  p_cagr_concatenated_segments := null ;
          p_group_name                 := null ;
          p_comment_id                 := null ;
          p_people_group_id            := null ;
          p_soft_coding_keyflex_id     := null ;
          p_effective_start_date       := null ;
          p_effective_end_date         := null ;

          Log_Error(p_type              => 'ERROR',
                    p_assignment_number => p_assignment_id,
                    p_warning_message   => NULL,
                    p_already_errored   => v_already_errored);
          --
          RAISE;
      --
    END;
    --
    hr_utility.set_location('Leaving '||l_proc, 70);
    --
  END update_applicant_asg;
  --
  -- ---------------------------------------------------------------------------+
  -- |-----------------------< UPDATE_CWK_ASSIGNMENT >--------------------------+
  -- ---------------------------------------------------------------------------+
  --
  PROCEDURE update_cwk_assignment
    (p_validate                     IN     BOOLEAN  DEFAULT FALSE
    ,p_effective_date               IN     DATE     DEFAULT hr_api.g_date
    ,p_datetrack_update_mode        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_assignment_id                IN     NUMBER   DEFAULT hr_api.g_number
    ,p_object_version_number        IN OUT NOCOPY NUMBER
    ,p_assignment_category          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_assignment_number            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_change_reason                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_comments                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_default_code_comb_id         IN     NUMBER   DEFAULT hr_api.g_number
    ,p_establishment_id             IN     NUMBER   DEFAULT hr_api.g_number
    ,p_frequency                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_internal_address_line        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_manager_flag                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_normal_hours                 IN     NUMBER   DEFAULT hr_api.g_number
    ,p_project_title		              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_set_of_books_id              IN     NUMBER   DEFAULT hr_api.g_number
    ,p_source_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_supervisor_id                IN     NUMBER   DEFAULT hr_api.g_number
    ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT hr_api.g_number
    ,p_time_normal_finish           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_time_normal_start            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_title                        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_vendor_assignment_number     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_vendor_employee_number       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_vendor_id                    IN     NUMBER   DEFAULT hr_api.g_number
    ,p_vendor_site_id               IN     NUMBER   DEFAULT hr_api.g_number
    ,p_assignment_status_type_id    IN     NUMBER   DEFAULT hr_api.g_number
    ,p_concat_segments              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute_category           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute1                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute2                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute3                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute4                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute5                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute6                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute7                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute8                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute9                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute10                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute11                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute12                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute13                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute14                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute15                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute16                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute17                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute18                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute19                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute20                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute21                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute22                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute23                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute24                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute25                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute26                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute27                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute28                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute29                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_attribute30                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment4                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment5                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment6                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment7                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment8                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment9                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment10                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment11                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment12                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment13                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment14                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment15                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment16                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment17                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment18                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment19                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment20                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment21                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment22                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment23                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment24                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment25                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment26                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment27                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment28                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment29                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment30                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  --,p_grade_id                     IN     NUMBER   DEFAULT hr_api.g_number
    ,p_position_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_job_id                       IN     NUMBER   DEFAULT hr_api.g_number
    ,p_location_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_organization_id              IN     NUMBER   DEFAULT hr_api.g_number
    ,p_segment1                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment2                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment3                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment4                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment5                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment6                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment7                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment8                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment9                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment10                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment11                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment12                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment13                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment14                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment15                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment16                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment17                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment18                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment19                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment20                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment21                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment22                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment23                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment24                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment25                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment26                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment27                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment28                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment29                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment30                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_projected_assignment_end     IN     DATE     DEFAULT hr_api.g_date
    ,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
    ,p_effective_start_date            OUT NOCOPY DATE
    ,p_effective_end_date              OUT NOCOPY DATE
    ,p_comment_id                      OUT NOCOPY NUMBER
    ,p_no_managers_warning             OUT NOCOPY BOOLEAN
    ,p_other_manager_warning           OUT NOCOPY BOOLEAN
    ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
    ,p_concatenated_segments           OUT NOCOPY VARCHAR2
    ,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
    ,p_scl_concat_segments             OUT NOCOPY VARCHAR2
    ,p_people_group_name               OUT NOCOPY VARCHAR2
    ,p_people_group_id                 OUT NOCOPY NUMBER
    ,p_spp_delete_warning              OUT NOCOPY BOOLEAN
    ,p_entries_changed_warning         OUT NOCOPY VARCHAR2
    ,p_tax_district_changed_warning    OUT NOCOPY BOOLEAN) IS
    --
    -- Define Local Variables
    --
    l_proc                       VARCHAR2(72) := g_package||'update_cwk_assignment';
    l_effective_date             DATE;
    l_message_text               VARCHAR2(255);
    l_log_message                VARCHAR2(255);
    l_already_errored            BOOLEAN := FALSE;
    --
    -- OUT Parameters for update_cwk_asg
    --
    l_object_version_number      NUMBER := p_object_version_number;
    l_orig_ovn                   NUMBER := p_object_version_number;
    l_org_now_no_manager_warning BOOLEAN;
    l_effective_start_date       DATE;
    l_effective_end_date         DATE;
    l_comment_id                 NUMBER;
    l_no_managers_warning        BOOLEAN;
    l_other_manager_warning      BOOLEAN;
    l_soft_coding_keyflex_id     NUMBER;
    l_concatenated_segments      VARCHAR2(2000);
    l_hourly_salaried_warning    BOOLEAN;
    --
    -- OUT Parameters for update_cwk_asg_Criteria
    --
    l_people_group_name               VARCHAR2(240);
    l_people_group_id                 NUMBER;
    l_spp_delete_warning              BOOLEAN;
    l_entries_changed_warning         VARCHAR2(10);
    l_tax_district_changed_warning    BOOLEAN;
    l_scl_concat_segments             VARCHAR2(4000);
    --
  BEGIN
    --
    hr_utility.set_location('Entering : '|| l_proc, 10);
    --
    -- Issue a savepoint.
    --
    SAVEPOINT update_cwk_assignment;
    --
    l_effective_date := TRUNC(p_effective_date);
    --
    BEGIN
      --
      hr_assignment_api.update_cwk_asg
        (p_validate                     => p_validate
        ,p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_category          => p_assignment_category
        ,p_assignment_number            => p_assignment_number
        ,p_change_reason                => p_change_reason
        ,p_comments                     => p_comments
        ,p_default_code_comb_id         => p_default_code_comb_id
        ,p_establishment_id             => p_establishment_id
        ,p_frequency                    => p_frequency
        ,p_internal_address_line        => p_internal_address_line
        ,p_labour_union_member_flag     => p_labour_union_member_flag
        ,p_manager_flag                 => p_manager_flag
        ,p_normal_hours                 => p_normal_hours
        ,p_project_title		              => p_project_title
        ,p_set_of_books_id              => p_set_of_books_id
        ,p_source_type                  => p_source_type
        ,p_supervisor_id                => p_supervisor_id
	,p_supervisor_assignment_id     => p_supervisor_assignment_id
        ,p_time_normal_finish           => p_time_normal_finish
        ,p_time_normal_start            => p_time_normal_start
        ,p_title                        => p_title
        ,p_vendor_assignment_number     => p_vendor_assignment_number
        ,p_vendor_employee_number       => p_vendor_employee_number
        ,p_vendor_id                    => p_vendor_id
        ,p_vendor_site_id               => p_vendor_site_id
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_concat_segments              => p_concat_segments
        ,p_attribute_category           => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_attribute21                  => p_attribute21
        ,p_attribute22                  => p_attribute22
        ,p_attribute23                  => p_attribute23
        ,p_attribute24                  => p_attribute24
        ,p_attribute25                  => p_attribute25
        ,p_attribute26                  => p_attribute26
        ,p_attribute27                  => p_attribute27
        ,p_attribute28                  => p_attribute28
        ,p_attribute29                  => p_attribute29
        ,p_attribute30                  => p_attribute30
        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment2                 => p_scl_segment2
        ,p_scl_segment3                 => p_scl_segment3
        ,p_scl_segment4                 => p_scl_segment4
        ,p_scl_segment5                 => p_scl_segment5
        ,p_scl_segment6                 => p_scl_segment6
        ,p_scl_segment7                 => p_scl_segment7
        ,p_scl_segment8                 => p_scl_segment8
        ,p_scl_segment9                 => p_scl_segment9
        ,p_scl_segment10                => p_scl_segment10
        ,p_scl_segment11                => p_scl_segment11
        ,p_scl_segment12                => p_scl_segment12
        ,p_scl_segment13                => p_scl_segment13
        ,p_scl_segment14                => p_scl_segment14
        ,p_scl_segment15                => p_scl_segment15
        ,p_scl_segment16                => p_scl_segment16
        ,p_scl_segment17                => p_scl_segment17
        ,p_scl_segment18                => p_scl_segment18
        ,p_scl_segment19                => p_scl_segment19
        ,p_scl_segment20                => p_scl_segment20
        ,p_scl_segment21                => p_scl_segment21
        ,p_scl_segment22                => p_scl_segment22
        ,p_scl_segment23                => p_scl_segment23
        ,p_scl_segment24                => p_scl_segment24
        ,p_scl_segment25                => p_scl_segment25
        ,p_scl_segment26                => p_scl_segment26
        ,p_scl_segment27                => p_scl_segment27
        ,p_scl_segment28                => p_scl_segment28
        ,p_scl_segment29                => p_scl_segment29
        ,p_scl_segment30                => p_scl_segment30
	,p_projected_assignment_end     => p_projected_assignment_end
        ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        ,p_comment_id                   => l_comment_id
        ,p_no_managers_warning          => l_no_managers_warning
        ,p_other_manager_warning        => l_other_manager_warning
        ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
        ,p_concatenated_segments        => l_concatenated_segments
        ,p_hourly_salaried_warning      => l_hourly_salaried_warning);
      --
      hr_utility.set_location(l_proc, 20);
      --
      IF l_no_managers_warning = TRUE THEN
        --
        hr_utility.set_message(800,'HR_289214_NO_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
        --
      ELSIF l_other_manager_warning = TRUE THEN
        --
        hr_utility.set_message(800,'HR_289215_DUPLICATE_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
        --
      ELSIF l_hourly_salaried_warning = TRUE THEN
        --
        hr_utility.set_message(800,'HR_289648_CWK_HR_CODE_NOT_NULL');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
        --
      END IF;
      --
      hr_utility.set_location(l_proc, 30);
      --
    END;
    --
    BEGIN
      --
      hr_assignment_api.update_cwk_asg_criteria
        (p_validate                     => p_validate
        ,p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_assignment_id                => p_assignment_id
	,p_called_from_mass_update      => TRUE
        ,p_object_version_number        => l_object_version_number
    --  ,p_grade_id                     => p_grade_id
        ,p_position_id                  => p_position_id
        ,p_job_id                       => p_job_id
        ,p_location_id                  => p_location_id
        ,p_organization_id              => p_organization_id
        --
        -- p_pay_basis_id for future phases of cwk
        --
        --,p_pay_basis_id                 => NULL
        ,p_segment1                     => p_segment1
        ,p_segment2                     => p_segment2
        ,p_segment3                     => p_segment3
        ,p_segment4                     => p_segment4
        ,p_segment5                     => p_segment5
        ,p_segment6                     => p_segment6
        ,p_segment7                     => p_segment7
        ,p_segment8                     => p_segment8
        ,p_segment9                     => p_segment9
        ,p_segment10                    => p_segment10
        ,p_segment11                    => p_segment11
        ,p_segment12                    => p_segment12
        ,p_segment13                    => p_segment13
        ,p_segment14                    => p_segment14
        ,p_segment15                    => p_segment15
        ,p_segment16                    => p_segment16
        ,p_segment17                    => p_segment17
        ,p_segment18                    => p_segment18
        ,p_segment19                    => p_segment19
        ,p_segment20                    => p_segment20
        ,p_segment21                    => p_segment21
        ,p_segment22                    => p_segment22
        ,p_segment23                    => p_segment23
        ,p_segment24                    => p_segment24
        ,p_segment25                    => p_segment25
        ,p_segment26                    => p_segment26
        ,p_segment27                    => p_segment27
        ,p_segment28                    => p_segment28
        ,p_segment29                    => p_segment29
        ,p_segment30                    => p_segment30
        ,p_concat_segments              => l_scl_concat_segments
        ,p_people_group_name            => l_people_group_name
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        ,p_people_group_id              => l_people_group_id
        ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
        ,p_other_manager_warning        => l_other_manager_warning
        ,p_spp_delete_warning           => l_spp_delete_warning
        ,p_entries_changed_warning      => l_entries_changed_warning
        ,p_tax_district_changed_warning => l_tax_district_changed_warning);
      --
      hr_utility.set_location(l_proc, 40);
      --
      IF l_org_now_no_manager_warning = TRUE THEN
        --
        hr_utility.set_message(800,'HR_289214_NO_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
        --
      ELSIF l_other_manager_warning = TRUE THEN
        --
        hr_utility.set_message(800,'HR_289215_DUPLICATE_MANAGERS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
        --
      ELSIF l_spp_delete_warning = TRUE THEN
        --
        hr_utility.set_message(800,'HR_289826_SPP_DELETE_WARN_API');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
        --
      END IF;
      --
      hr_utility.set_location(l_proc, 50);
      --
    END;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    IF p_validate THEN
      --
      RAISE hr_api.validate_enabled;
     	--
    END IF;
    --
    -- Set all out parameters
    --
    p_org_now_no_manager_warning      := l_org_now_no_manager_warning;
    p_effective_start_date            := l_effective_start_date;
    p_effective_end_date              := l_effective_end_date;
    p_comment_id                      := l_comment_id;
    p_no_managers_warning             := l_no_managers_warning;
    p_other_manager_warning           := l_other_manager_warning;
    p_soft_coding_keyflex_id          := l_soft_coding_keyflex_id;
    p_concatenated_segments           := l_concatenated_segments;
    p_hourly_salaried_warning         := l_hourly_salaried_warning;
    p_scl_concat_segments             := l_scl_concat_segments;
    p_people_group_name               := l_people_group_name;
    p_people_group_id                 := l_people_group_id  ;
    p_spp_delete_warning              := l_spp_delete_warning;
    p_entries_changed_warning         := l_entries_changed_warning;
    p_tax_district_changed_warning    := l_tax_district_changed_warning;
    --
    hr_utility.set_location('Leaving  : '||l_proc, 997);
    --
  EXCEPTION
    --
    WHEN hr_api.validate_enabled THEN
      --
      hr_utility.set_location('Leaving  : '||l_proc, 998);
      --
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      ROLLBACK TO update_cwk_asg;
      --
      -- Only set output warning arguments
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_org_now_no_manager_warning      := l_org_now_no_manager_warning;
      p_effective_start_date            := NULL;
      p_effective_end_date              := NULL;
      p_comment_id                      := NULL;
      p_no_managers_warning             := l_no_managers_warning;
      p_other_manager_warning           := l_other_manager_warning;
      p_soft_coding_keyflex_id          := NULL;
      p_concatenated_segments           := NULL;
      p_hourly_salaried_warning         := l_hourly_salaried_warning;
      p_scl_concat_segments             := NULL;
      p_people_group_name               := NULL;
      p_people_group_id                 := NULL;
      p_spp_delete_warning              := l_spp_delete_warning;
      p_entries_changed_warning         := l_entries_changed_warning;
      p_tax_district_changed_warning    := l_tax_district_changed_warning;
      --
    WHEN OTHERS THEN
      --
      hr_utility.set_location('Leaving  : '||l_proc, 999);
      --
      ROLLBACK TO update_cwk_asg;
      --
      -- Only set output warning arguments
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_org_now_no_manager_warning      := NULL;
      p_effective_start_date            := NULL;
      p_effective_end_date              := NULL;
      p_comment_id                      := NULL;
      p_no_managers_warning             := NULL;
      p_other_manager_warning           := NULL;
      p_soft_coding_keyflex_id          := NULL;
      p_concatenated_segments           := NULL;
      p_hourly_salaried_warning         := NULL;
      p_scl_concat_segments             := NULL;
      p_people_group_name               := NULL;
      p_people_group_id                 := NULL;
      p_spp_delete_warning              := NULL;
      p_entries_changed_warning         := NULL;
      p_tax_district_changed_warning    := NULL;
      p_object_version_number           := l_orig_ovn;
      --
      Log_Error(p_type              => 'ERROR',
                p_assignment_number => p_assignment_number,
                p_warning_message   => NULL,
                p_already_errored   => l_already_errored);
      --
      RAISE;
      --
  END update_cwk_assignment;
  --
  -- ---------------------------------------------------------------------------+
  -- |-------------------------< UPDATE_ASSIGNMENT >----------------------------+
  -- ---------------------------------------------------------------------------+
  --
  PROCEDURE update_assignment
    (p_validate                     IN     BOOLEAN  DEFAULT FALSE
    ,p_datetrack_update_mode        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_object_version_number        IN OUT NOCOPY NUMBER
    ,p_ass_attribute_category       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute1               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute10              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute11              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute12              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute13              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute14              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute15              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute16              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute17              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute18              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute19              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute2               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute20              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute21              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute22              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute23              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute24              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute25              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute26              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute27              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute28              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute29              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute3               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute30              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute4               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute5               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute6               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute7               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute8               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute9               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_assignment_id                IN     NUMBER   DEFAULT hr_api.g_number
    ,p_assignment_number            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_assignment_status_type_id    IN     NUMBER   DEFAULT hr_api.g_number
    ,p_bargaining_unit_code         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cagr_id_flex_num             IN     NUMBER   DEFAULT hr_api.g_number
    ,p_change_reason                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_collective_agreement_id      IN     NUMBER   DEFAULT hr_api.g_number
    ,p_contract_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_date_probation_end           IN     DATE     DEFAULT hr_api.g_date
    ,p_default_code_comb_id         IN     NUMBER   DEFAULT hr_api.g_number
    ,p_establishment_id             IN     NUMBER   DEFAULT hr_api.g_number
    ,p_employment_category          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_frequency                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_grade_id                     IN     NUMBER   DEFAULT hr_api.g_number
    ,p_hourly_salaried_code         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_internal_address_line        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_job_id                       IN     NUMBER   DEFAULT hr_api.g_number
    ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_location_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_manager_flag                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_normal_hours                 IN     NUMBER   DEFAULT hr_api.g_number
    ,p_pay_basis_id                 IN     NUMBER   DEFAULT hr_api.g_number
    ,p_payroll_id                   IN     NUMBER   DEFAULT hr_api.g_number
    ,p_perf_review_period           IN     NUMBER   DEFAULT hr_api.g_number
    ,p_perf_review_period_frequency IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_position_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_probation_period             IN     NUMBER   DEFAULT hr_api.g_number
    ,p_probation_unit               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_sal_review_period            IN     NUMBER   DEFAULT hr_api.g_number
    ,p_sal_review_period_frequency  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_set_of_books_id              IN     NUMBER   DEFAULT hr_api.g_number
    ,p_source_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_supervisor_id                IN     NUMBER   DEFAULT hr_api.g_number
    ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT hr_api.g_number
    ,p_time_normal_finish           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_time_normal_start            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_title                        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment10                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment11                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment12                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment13                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment14                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment15                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment16                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment17                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment18                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment19                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment20                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment4                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment5                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment6                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment7                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment8                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment9                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_comments                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_concat_segments              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_effective_date               IN     DATE     DEFAULT hr_api.g_date
    ,p_segment1                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment10                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment11                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment12                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment13                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment14                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment15                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment16                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment17                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment18                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment19                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment2                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment20                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment21                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment22                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment23                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment24                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment25                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment26                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment27                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment28                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment29                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment3                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment30                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment4                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment5                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment6                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment7                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment8                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment9                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment10                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment11                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment12                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment13                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment14                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment15                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment16                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment17                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment18                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment19                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment20                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment21                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment22                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment23                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment24                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment25                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment26                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment27                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment28                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment29                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment30                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment4                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment5                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment6                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment7                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment8                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment9                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_grade_ladder_pgm_id          IN     NUMBER   DEFAULT hr_api.g_number
    ,p_recruiter_id                 IN     NUMBER   DEFAULT hr_api.g_number
    ,p_person_referred_by_id        IN     NUMBER   DEFAULT hr_api.g_number
    ,p_recruitment_activity_id      IN     NUMBER   DEFAULT hr_api.g_number
    ,p_source_organization_id       IN     NUMBER   DEFAULT hr_api.g_number
    ,p_vacancy_id                   IN     NUMBER   DEFAULT hr_api.g_number
    ,p_application_id               IN     NUMBER   DEFAULT hr_api.g_number
    ,p_vendor_assignment_number     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_vendor_employee_number       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_vendor_id                    IN     NUMBER   DEFAULT hr_api.g_number
    ,p_vendor_site_id               IN     NUMBER   DEFAULT hr_api.g_number
    ,p_project_title                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_projected_assignment_end     IN     DATE     DEFAULT hr_api.g_date
    ,p_organization_id              IN OUT NOCOPY NUMBER
    ,p_concatenated_segments        IN OUT NOCOPY VARCHAR2
    ,p_special_ceiling_step_id      IN OUT NOCOPY NUMBER
    ,p_cagr_grade_def_id               IN OUT NOCOPY NUMBER
    ,p_comment_id                      OUT NOCOPY NUMBER
    ,p_cagr_concatenated_segments      OUT NOCOPY VARCHAR2
    ,p_effective_end_date              OUT NOCOPY DATE
    ,p_effective_start_date            OUT NOCOPY DATE
    ,p_no_managers_warning             OUT NOCOPY BOOLEAN
    ,p_other_manager_warning           OUT NOCOPY BOOLEAN
    ,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
    ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
    ,p_entries_changed_warning         OUT NOCOPY VARCHAR2
    ,p_group_name                      OUT NOCOPY VARCHAR2
    ,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
    ,p_people_group_id                 OUT NOCOPY NUMBER
    ,p_spp_delete_warning              OUT NOCOPY BOOLEAN
    ,p_tax_district_changed_warning    OUT NOCOPY BOOLEAN  ) IS
    --
    l_log_message                  VARCHAR2(255);
    l_already_errored              BOOLEAN := FALSE;
    l_pay_proposal_warning         BOOLEAN := FALSE;
    l_proc                         VARCHAR2(72) := g_package||'update_assignment';
    l_effective_date               DATE;
    l_assignment_status            per_assignment_status_types.per_system_status%TYPE;
    --
    l_non_person_type_fields       BOOLEAN := FALSE;
    l_message_text                 VARCHAR2(255);
    l_dummy_b                      BOOLEAN;
    l_dummy_n                      NUMBER := null;
    l_dummy_v                      VARCHAR2(4000);
    l_assignment_type              per_all_assignments_f.assignment_type%TYPE;
    --
    l_object_version_number        NUMBER := p_object_version_number ;
    l_organization_id              NUMBER := p_organization_id ;
    l_special_ceiling_step_id      NUMBER := p_special_ceiling_step_id ;
    L_CAGR_GRADE_DEF_ID            NUMBER := p_CAGR_GRADE_DEF_ID;
    l_concatenated_segments        VARCHAR2(4000) := p_concatenated_segments ;
    l_concat_segments              VARCHAR2(4000):= p_concat_segments;
    l_org_now_no_manager_warning   BOOLEAN;
    l_effective_start_date         DATE;
    l_effective_end_date           DATE;
    l_comment_id                   NUMBER;
    l_no_managers_warning          BOOLEAN;
    l_other_manager_warning        BOOLEAN;
    l_soft_coding_keyflex_id       NUMBER;
    l_hourly_salaried_warning      BOOLEAN;
    l_scl_concat_segments          VARCHAR2(4000);
    l_people_group_name            VARCHAR2(240);
    l_people_group_id              NUMBER;
    l_spp_delete_warning           BOOLEAN;
    l_entries_changed_warning      VARCHAR2(10);
    l_tax_district_changed_warning BOOLEAN;
    --
    CURSOR csr_assignment_type IS
      SELECT assignment_type
      FROM   per_assignments_f paf
      WHERE  paf.assignment_id = p_assignment_id
      AND    l_effective_date BETWEEN paf.effective_start_Date
                                  AND paf.effective_end_date;
    --
  BEGIN
    --
    --hr_utility.trace_on(NULL,'ORACLE'); --ynegoro
    hr_utility.set_location('Entering : '|| l_proc, 10);
    --
    -- Issue a savepoint.
    --
    SAVEPOINT upd_asg;
    --
    l_effective_date := TRUNC(p_effective_date);
    --
    OPEN csr_assignment_type;
    FETCH csr_assignment_type INTO l_assignment_type;
    --
    IF csr_assignment_type%NOTFOUND THEN
      --
      CLOSE csr_assignment_type;
      --
      hr_utility.set_message(801,'HR_449903_INV_ASG_TYPE');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF l_assignment_type = 'E' THEN
      --
      upd_asg
        (p_ass_attribute_category       => p_ass_attribute_category
        ,p_ass_attribute1               => p_ass_attribute1
        ,p_ass_attribute10              => p_ass_attribute10
        ,p_ass_attribute11              => p_ass_attribute11
        ,p_ass_attribute12              => p_ass_attribute12
        ,p_ass_attribute13              => p_ass_attribute13
        ,p_ass_attribute14              => p_ass_attribute14
        ,p_ass_attribute15              => p_ass_attribute15
        ,p_ass_attribute16              => p_ass_attribute16
        ,p_ass_attribute17              => p_ass_attribute17
        ,p_ass_attribute18              => p_ass_attribute18
        ,p_ass_attribute19              => p_ass_attribute19
        ,p_ass_attribute2               => p_ass_attribute2
        ,p_ass_attribute20              => p_ass_attribute20
        ,p_ass_attribute21              => p_ass_attribute21
        ,p_ass_attribute22              => p_ass_attribute22
        ,p_ass_attribute23              => p_ass_attribute23
        ,p_ass_attribute24              => p_ass_attribute24
        ,p_ass_attribute25              => p_ass_attribute25
        ,p_ass_attribute26              => p_ass_attribute26
        ,p_ass_attribute27              => p_ass_attribute27
        ,p_ass_attribute28              => p_ass_attribute28
        ,p_ass_attribute29              => p_ass_attribute29
        ,p_ass_attribute3               => p_ass_attribute3
        ,p_ass_attribute30              => p_ass_attribute30
        ,p_ass_attribute4               => p_ass_attribute4
        ,p_ass_attribute5               => p_ass_attribute5
        ,p_ass_attribute6               => p_ass_attribute6
        ,p_ass_attribute7               => p_ass_attribute7
        ,p_ass_attribute8               => p_ass_attribute8
        ,p_ass_attribute9               => p_ass_attribute9
        ,p_assignment_id                => p_assignment_id
        ,p_assignment_number            => p_assignment_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_bargaining_unit_code         => p_bargaining_unit_code
        ,p_cagr_id_flex_num             => p_cagr_id_flex_num
        ,p_change_reason                => p_change_reason
        ,p_collective_agreement_id      => p_collective_agreement_id
        ,p_contract_id                  => p_contract_id
        ,p_date_probation_end           => p_date_probation_end
        ,p_default_code_comb_id         => p_default_code_comb_id
        ,p_establishment_id             => p_establishment_id
        ,p_employment_category          => p_employment_category
        ,p_frequency                    => p_frequency
        ,p_grade_id                     => p_grade_id
        ,p_hourly_salaried_code         => p_hourly_salaried_code
        ,p_internal_address_line        => p_internal_address_line
        ,p_job_id                       => p_job_id
        ,p_labour_union_member_flag     => p_labour_union_member_flag
        ,p_location_id                  => p_location_id
        ,p_manager_flag                 => p_manager_flag
        ,p_normal_hours                 => p_normal_hours
        ,p_pay_basis_id                 => p_pay_basis_id
        ,p_payroll_id                   => p_payroll_id
        ,p_perf_review_period           => p_perf_review_period
        ,p_perf_review_period_frequency => p_perf_review_period_frequency
        ,p_position_id                  => p_position_id
        ,p_probation_period             => p_probation_period
        ,p_probation_unit               => p_probation_unit
        ,p_sal_review_period            => p_sal_review_period
        ,p_sal_review_period_frequency  => p_sal_review_period_frequency
        ,p_set_of_books_id              => p_set_of_books_id
        ,p_source_type                  => p_source_type
        ,p_supervisor_id                => p_supervisor_id
	,p_supervisor_assignment_id     => p_supervisor_assignment_id
        ,p_time_normal_finish           => p_time_normal_finish
        ,p_time_normal_start            => p_time_normal_start
        ,p_title                        => p_title
        ,p_cag_segment1                 => p_cag_segment1
        ,p_cag_segment10                => p_cag_segment10
        ,p_cag_segment11                => p_cag_segment11
        ,p_cag_segment12                => p_cag_segment12
        ,p_cag_segment13                => p_cag_segment13
        ,p_cag_segment14                => p_cag_segment14
        ,p_cag_segment15                => p_cag_segment15
        ,p_cag_segment16                => p_cag_segment16
        ,p_cag_segment17                => p_cag_segment17
        ,p_cag_segment18                => p_cag_segment18
        ,p_cag_segment19                => p_cag_segment19
        ,p_cag_segment2                 => p_cag_segment2
        ,p_cag_segment20                => p_cag_segment20
        ,p_cag_segment3                 => p_cag_segment3
        ,p_cag_segment4                 => p_cag_segment4
        ,p_cag_segment5                 => p_cag_segment5
        ,p_cag_segment6                 => p_cag_segment6
        ,p_cag_segment7                 => p_cag_segment7
        ,p_cag_segment8                 => p_cag_segment8
        ,p_cag_segment9                 => p_cag_segment9
        ,p_comments                     => p_comments
        ,p_concat_segments              => p_concat_segments
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_effective_date               => p_effective_date
        ,p_segment1                     => p_segment1
        ,p_segment10                    => p_segment10
        ,p_segment11                    => p_segment11
        ,p_segment12                    => p_segment12
        ,p_segment13                    => p_segment13
        ,p_segment14                    => p_segment14
        ,p_segment15                    => p_segment15
        ,p_segment16                    => p_segment16
        ,p_segment17                    => p_segment17
        ,p_segment18                    => p_segment18
        ,p_segment19                    => p_segment19
        ,p_segment2                     => p_segment2
        ,p_segment20                    => p_segment20
        ,p_segment21                    => p_segment21
        ,p_segment22                    => p_segment22
        ,p_segment23                    => p_segment23
        ,p_segment24                    => p_segment24
        ,p_segment25                    => p_segment25
        ,p_segment26                    => p_segment26
        ,p_segment27                    => p_segment27
        ,p_segment28                    => p_segment28
        ,p_segment29                    => p_segment29
        ,p_segment3                     => p_segment3
        ,p_segment30                    => p_segment30
        ,p_segment4                     => p_segment4
        ,p_segment5                     => p_segment5
        ,p_segment6                     => p_segment6
        ,p_segment7                     => p_segment7
        ,p_segment8                     => p_segment8
        ,p_segment9                     => p_segment9
        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment10                => p_scl_segment10
        ,p_scl_segment11                => p_scl_segment11
        ,p_scl_segment12                => p_scl_segment12
        ,p_scl_segment13                => p_scl_segment13
        ,p_scl_segment14                => p_scl_segment14
        ,p_scl_segment15                => p_scl_segment15
        ,p_scl_segment16                => p_scl_segment16
        ,p_scl_segment17                => p_scl_segment17
        ,p_scl_segment18                => p_scl_segment18
        ,p_scl_segment19                => p_scl_segment19
        ,p_scl_segment2                 => p_scl_segment2
        ,p_scl_segment20                => p_scl_segment20
        ,p_scl_segment21                => p_scl_segment21
        ,p_scl_segment22                => p_scl_segment22
        ,p_scl_segment23                => p_scl_segment23
        ,p_scl_segment24                => p_scl_segment24
        ,p_scl_segment25                => p_scl_segment25
        ,p_scl_segment26                => p_scl_segment26
        ,p_scl_segment27                => p_scl_segment27
        ,p_scl_segment28                => p_scl_segment28
        ,p_scl_segment29                => p_scl_segment29
        ,p_scl_segment3                 => p_scl_segment3
        ,p_scl_segment30                => p_scl_segment30
        ,p_scl_segment4                 => p_scl_segment4
        ,p_scl_segment5                 => p_scl_segment5
        ,p_scl_segment6                 => p_scl_segment6
        ,p_scl_segment7                 => p_scl_segment7
        ,p_scl_segment8                 => p_scl_segment8
        ,p_scl_segment9                 => p_scl_segment9
        ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
        ,p_validate                     => p_validate
        ,p_cagr_grade_def_id            => l_cagr_grade_def_id
        ,p_concatenated_segments        => l_concatenated_segments
        ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
        ,p_effective_end_date           => p_effective_end_date
        ,p_effective_start_date         => p_effective_start_date
        ,p_no_managers_warning          => p_no_managers_warning
        ,p_other_manager_warning        => p_other_manager_warning
        ,p_gsp_post_process_warning     => p_gsp_post_process_warning
        ,p_special_ceiling_step_id      => l_special_ceiling_step_id
        ,p_entries_changed_warning      => p_entries_changed_warning
        ,p_group_name                   => p_group_name
        ,p_org_now_no_manager_warning   => p_org_now_no_manager_warning
        ,p_people_group_id              => p_people_group_id
        ,p_spp_delete_warning           => p_spp_delete_warning
        ,p_tax_district_changed_warning => p_tax_district_changed_warning
        ,p_comment_id                   => p_comment_id
        ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
        ,p_object_version_number        => l_object_version_number
        ,p_organization_id              => l_organization_id);
      --
      l_non_person_type_fields :=
        chk_for_non_emp_fields
          (p_application_id             => p_application_id
          ,p_person_referred_by_id      => p_person_referred_by_id
          ,p_project_title              => p_project_title
          ,p_recruiter_id               => p_recruiter_id
          ,p_recruitment_activity_id    => p_recruitment_activity_id
          ,p_source_organization_id     => p_source_organization_id
          ,p_vacancy_id                 => p_vacancy_id
          ,p_vendor_assignment_number   => p_vendor_assignment_number
          ,p_vendor_employee_number     => p_vendor_employee_number
          ,p_vendor_id                  => p_vendor_id
          ,p_vendor_site_id             => p_vendor_site_id
	  ,p_projected_assignment_end   => p_projected_assignment_end);
      --
      -- IF non EMP fields have been entered in the mass update
      -- then raise a Warning message so the user knows that non-EMP
      -- fields have been entered but will not get updated.
      --
      IF l_non_person_type_fields THEN
        --
        hr_utility.set_message(800,'HR_449904_NON_EMP_FIELDS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
      END IF;
      --
    /*
    --
    -- Removed as new template will now only cater for
    -- EMployees and Contingent Workers.
    --
    ELSIF l_assignment_type = 'A' THEN
      --
      update_applicant_asg
        (p_validate                     => p_validate
        ,p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => p_object_version_number
        ,p_recruiter_id                 => p_recruiter_id
        ,p_grade_id                     => p_grade_id
        ,p_position_id                  => p_position_id
        ,p_job_id                       => p_job_id
        ,p_payroll_id                   => p_payroll_id
        ,p_location_id                  => p_location_id
        ,p_person_referred_by_id        => p_person_referred_by_id
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_supervisor_id                => p_supervisor_id
        ,p_special_ceiling_step_id      => p_special_ceiling_step_id
        ,p_recruitment_activity_id      => p_recruitment_activity_id
        ,p_source_organization_id       => p_source_organization_id
        ,p_organization_id              => p_organization_id
        ,p_vacancy_id                   => p_vacancy_id
        ,p_pay_basis_id                 => p_pay_basis_id
        ,p_application_id               => p_application_id
        ,p_change_reason                => p_change_reason
        ,p_comments                     => p_comments
        ,p_date_probation_end           => p_date_probation_end
        ,p_default_code_comb_id         => p_default_code_comb_id
        ,p_employment_category          => p_employment_category
        ,p_frequency                    => p_frequency
        ,p_internal_address_line        => p_internal_address_line
        ,p_manager_flag                 => p_manager_flag
        ,p_normal_hours                 => p_normal_hours
        ,p_perf_review_period           => p_perf_review_period
        ,p_perf_review_period_frequency => p_perf_review_period_frequency
        ,p_probation_period             => p_probation_period
        ,p_probation_unit               => p_probation_unit
        ,p_sal_review_period            => p_sal_review_period
        ,p_sal_review_period_frequency  => p_sal_review_period_frequency
        ,p_set_of_books_id              => p_set_of_books_id
        ,p_source_type                  => p_source_type
        ,p_time_normal_finish           => p_time_normal_finish
        ,p_time_normal_start            => p_time_normal_start
        ,p_bargaining_unit_code         => p_bargaining_unit_code
        ,p_ass_attribute_category       => p_ass_attribute_category
        ,p_ass_attribute1               => p_ass_attribute1
        ,p_ass_attribute2               => p_ass_attribute2
        ,p_ass_attribute3               => p_ass_attribute3
        ,p_ass_attribute4               => p_ass_attribute4
        ,p_ass_attribute5               => p_ass_attribute5
        ,p_ass_attribute6               => p_ass_attribute6
        ,p_ass_attribute7               => p_ass_attribute7
        ,p_ass_attribute8               => p_ass_attribute8
        ,p_ass_attribute9               => p_ass_attribute9
        ,p_ass_attribute10              => p_ass_attribute10
        ,p_ass_attribute11              => p_ass_attribute11
        ,p_ass_attribute12              => p_ass_attribute12
        ,p_ass_attribute13              => p_ass_attribute13
        ,p_ass_attribute14              => p_ass_attribute14
        ,p_ass_attribute15              => p_ass_attribute15
        ,p_ass_attribute16              => p_ass_attribute16
        ,p_ass_attribute17              => p_ass_attribute17
        ,p_ass_attribute18              => p_ass_attribute18
        ,p_ass_attribute19              => p_ass_attribute19
        ,p_ass_attribute20              => p_ass_attribute20
        ,p_ass_attribute21              => p_ass_attribute21
        ,p_ass_attribute22              => p_ass_attribute22
        ,p_ass_attribute23              => p_ass_attribute23
        ,p_ass_attribute24              => p_ass_attribute24
        ,p_ass_attribute25              => p_ass_attribute25
        ,p_ass_attribute26              => p_ass_attribute26
        ,p_ass_attribute27              => p_ass_attribute27
        ,p_ass_attribute28              => p_ass_attribute28
        ,p_ass_attribute29              => p_ass_attribute29
        ,p_ass_attribute30              => p_ass_attribute30
        ,p_title                        => p_title
        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment2                 => p_scl_segment2
        ,p_scl_segment3                 => p_scl_segment3
        ,p_scl_segment4                 => p_scl_segment4
        ,p_scl_segment5                 => p_scl_segment5
        ,p_scl_segment6                 => p_scl_segment6
        ,p_scl_segment7                 => p_scl_segment7
        ,p_scl_segment8                 => p_scl_segment8
        ,p_scl_segment9                 => p_scl_segment9
        ,p_scl_segment10                => p_scl_segment10
        ,p_scl_segment11                => p_scl_segment11
        ,p_scl_segment12                => p_scl_segment12
        ,p_scl_segment13                => p_scl_segment13
        ,p_scl_segment14                => p_scl_segment14
        ,p_scl_segment15                => p_scl_segment15
        ,p_scl_segment16                => p_scl_segment16
        ,p_scl_segment17                => p_scl_segment17
        ,p_scl_segment18                => p_scl_segment18
        ,p_scl_segment19                => p_scl_segment19
        ,p_scl_segment20                => p_scl_segment20
        ,p_scl_segment21                => p_scl_segment21
        ,p_scl_segment22                => p_scl_segment22
        ,p_scl_segment23                => p_scl_segment23
        ,p_scl_segment24                => p_scl_segment24
        ,p_scl_segment25                => p_scl_segment25
        ,p_scl_segment26                => p_scl_segment26
        ,p_scl_segment27                => p_scl_segment27
        ,p_scl_segment28                => p_scl_segment28
        ,p_scl_segment29                => p_scl_segment29
        ,p_scl_segment30                => p_scl_segment30
        ,p_concatenated_segments        => p_concatenated_segments
        ,p_pgp_segment1                 => p_segment1
        ,p_pgp_segment2                 => p_segment2
        ,p_pgp_segment3                 => p_segment3
        ,p_pgp_segment4                 => p_segment4
        ,p_pgp_segment5                 => p_segment5
        ,p_pgp_segment6                 => p_segment6
        ,p_pgp_segment7                 => p_segment7
        ,p_pgp_segment8                 => p_segment8
        ,p_pgp_segment9                 => p_segment9
        ,p_pgp_segment10                => p_segment10
        ,p_pgp_segment11                => p_segment11
        ,p_pgp_segment12                => p_segment12
        ,p_pgp_segment13                => p_segment13
        ,p_pgp_segment14                => p_segment14
        ,p_pgp_segment15                => p_segment15
        ,p_pgp_segment16                => p_segment16
        ,p_pgp_segment17                => p_segment17
        ,p_pgp_segment18                => p_segment18
        ,p_pgp_segment19                => p_segment19
        ,p_pgp_segment20                => p_segment20
        ,p_pgp_segment21                => p_segment21
        ,p_pgp_segment22                => p_segment22
        ,p_pgp_segment23                => p_segment23
        ,p_pgp_segment24                => p_segment24
        ,p_pgp_segment25                => p_segment25
        ,p_pgp_segment26                => p_segment26
        ,p_pgp_segment27                => p_segment27
        ,p_pgp_segment28                => p_segment28
        ,p_pgp_segment29                => p_segment29
        ,p_pgp_segment30                => p_segment30
        ,p_concat_segments              => p_concat_segments
        ,p_contract_id                  => p_contract_id
        ,p_establishment_id             => p_establishment_id
        ,p_collective_agreement_id      => p_collective_agreement_id
        ,p_cagr_id_flex_num             => p_cagr_id_flex_num
        ,p_cag_segment1                 => p_cag_segment1
        ,p_cag_segment2                 => p_cag_segment2
        ,p_cag_segment3                 => p_cag_segment3
        ,p_cag_segment4                 => p_cag_segment4
        ,p_cag_segment5                 => p_cag_segment5
        ,p_cag_segment6                 => p_cag_segment6
        ,p_cag_segment7                 => p_cag_segment7
        ,p_cag_segment8                 => p_cag_segment8
        ,p_cag_segment9                 => p_cag_segment9
        ,p_cag_segment10                => p_cag_segment10
        ,p_cag_segment11                => p_cag_segment11
        ,p_cag_segment12                => p_cag_segment12
        ,p_cag_segment13                => p_cag_segment13
        ,p_cag_segment14                => p_cag_segment14
        ,p_cag_segment15                => p_cag_segment15
        ,p_cag_segment16                => p_cag_segment16
        ,p_cag_segment17                => p_cag_segment17
        ,p_cag_segment18                => p_cag_segment18
        ,p_cag_segment19                => p_cag_segment19
        ,p_cag_segment20                => p_cag_segment20
        ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
        ,p_cagr_grade_def_id            => l_cagr_grade_def_id
        ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
        ,p_group_name                   => p_group_name
        ,p_comment_id                   => p_comment_id
        ,p_people_group_id              => p_people_group_id
        ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
        ,p_effective_start_date         => p_effective_start_date
        ,p_effective_end_date           => p_effective_end_date);
      --
      l_non_person_type_fields :=
        chk_for_non_apl_fields
          (p_hourly_salaried_code       => p_hourly_salaried_code
          ,p_labour_union_member_flag   => p_labour_union_member_flag
          ,p_project_title              => p_project_title
          ,p_vendor_assignment_number   => p_vendor_assignment_number
          ,p_vendor_employee_number     => p_vendor_employee_number
          ,p_vendor_id                  => p_vendor_id
          ,p_vendor_site_id             => p_vendor_site_id);
      --
      -- IF non APL fields have been entered in the mass update
      -- then raise a Warning message so the user knows that non-APL
      -- fields have been entered but will not get updated.
      --
      IF l_non_person_type_fields THEN
        --
        hr_utility.set_message(800,'HR_449906_NON_APL_FIELDS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
      END IF;
      --   */
    ELSIF l_assignment_type = 'C' THEN
      --
      update_cwk_assignment
        (p_validate                     => p_validate
        ,p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_category          => p_employment_category
        ,p_assignment_number            => p_assignment_number
        ,p_change_reason                => p_change_reason
        ,p_comments                     => p_comments
        ,p_default_code_comb_id         => p_default_code_comb_id
        ,p_establishment_id             => p_establishment_id
        ,p_frequency                    => p_frequency
        ,p_internal_address_line        => p_internal_address_line
        ,p_labour_union_member_flag     => p_labour_union_member_flag
        ,p_manager_flag                 => p_manager_flag
        ,p_normal_hours                 => p_normal_hours
        ,p_project_title		              => p_project_title
        ,p_set_of_books_id              => p_set_of_books_id
        ,p_source_type                  => p_source_type
        ,p_supervisor_id                => p_supervisor_id
	,p_supervisor_assignment_id     => p_supervisor_assignment_id
        ,p_time_normal_finish           => p_time_normal_finish
        ,p_time_normal_start            => p_time_normal_start
        ,p_title                        => p_title
        ,p_vendor_assignment_number     => p_vendor_assignment_number
        ,p_vendor_employee_number       => p_vendor_employee_number
        ,p_vendor_id                    => p_vendor_id
        ,p_vendor_site_id               => p_vendor_site_id
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_concat_segments              => p_concat_segments
        ,p_attribute_category           => p_ass_attribute_category
        ,p_attribute1                   => p_ass_attribute1
        ,p_attribute2                   => p_ass_attribute2
        ,p_attribute3                   => p_ass_attribute3
        ,p_attribute4                   => p_ass_attribute4
        ,p_attribute5                   => p_ass_attribute5
        ,p_attribute6                   => p_ass_attribute6
        ,p_attribute7                   => p_ass_attribute7
        ,p_attribute8                   => p_ass_attribute8
        ,p_attribute9                   => p_ass_attribute9
        ,p_attribute10                  => p_ass_attribute10
        ,p_attribute11                  => p_ass_attribute11
        ,p_attribute12                  => p_ass_attribute12
        ,p_attribute13                  => p_ass_attribute13
        ,p_attribute14                  => p_ass_attribute14
        ,p_attribute15                  => p_ass_attribute15
        ,p_attribute16                  => p_ass_attribute16
        ,p_attribute17                  => p_ass_attribute17
        ,p_attribute18                  => p_ass_attribute18
        ,p_attribute19                  => p_ass_attribute19
        ,p_attribute20                  => p_ass_attribute20
        ,p_attribute21                  => p_ass_attribute21
        ,p_attribute22                  => p_ass_attribute22
        ,p_attribute23                  => p_ass_attribute23
        ,p_attribute24                  => p_ass_attribute24
        ,p_attribute25                  => p_ass_attribute25
        ,p_attribute26                  => p_ass_attribute26
        ,p_attribute27                  => p_ass_attribute27
        ,p_attribute28                  => p_ass_attribute28
        ,p_attribute29                  => p_ass_attribute29
        ,p_attribute30                  => p_ass_attribute30
        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment2                 => p_scl_segment2
        ,p_scl_segment3                 => p_scl_segment3
        ,p_scl_segment4                 => p_scl_segment4
        ,p_scl_segment5                 => p_scl_segment5
        ,p_scl_segment6                 => p_scl_segment6
        ,p_scl_segment7                 => p_scl_segment7
        ,p_scl_segment8                 => p_scl_segment8
        ,p_scl_segment9                 => p_scl_segment9
        ,p_scl_segment10                => p_scl_segment10
        ,p_scl_segment11                => p_scl_segment11
        ,p_scl_segment12                => p_scl_segment12
        ,p_scl_segment13                => p_scl_segment13
        ,p_scl_segment14                => p_scl_segment14
        ,p_scl_segment15                => p_scl_segment15
        ,p_scl_segment16                => p_scl_segment16
        ,p_scl_segment17                => p_scl_segment17
        ,p_scl_segment18                => p_scl_segment18
        ,p_scl_segment19                => p_scl_segment19
        ,p_scl_segment20                => p_scl_segment20
        ,p_scl_segment21                => p_scl_segment21
        ,p_scl_segment22                => p_scl_segment22
        ,p_scl_segment23                => p_scl_segment23
        ,p_scl_segment24                => p_scl_segment24
        ,p_scl_segment25                => p_scl_segment25
        ,p_scl_segment26                => p_scl_segment26
        ,p_scl_segment27                => p_scl_segment27
        ,p_scl_segment28                => p_scl_segment28
        ,p_scl_segment29                => p_scl_segment29
        ,p_scl_segment30                => p_scl_segment30
    --  ,p_grade_id                     => p_grade_id
        ,p_position_id                  => p_position_id
        ,p_job_id                       => p_job_id
        ,p_location_id                  => p_location_id
        ,p_organization_id              => p_organization_id
        ,p_segment1                     => p_segment1
        ,p_segment2                     => p_segment2
        ,p_segment3                     => p_segment3
        ,p_segment4                     => p_segment4
        ,p_segment5                     => p_segment5
        ,p_segment6                     => p_segment6
        ,p_segment7                     => p_segment7
        ,p_segment8                     => p_segment8
        ,p_segment9                     => p_segment9
        ,p_segment10                    => p_segment10
        ,p_segment11                    => p_segment11
        ,p_segment12                    => p_segment12
        ,p_segment13                    => p_segment13
        ,p_segment14                    => p_segment14
        ,p_segment15                    => p_segment15
        ,p_segment16                    => p_segment16
        ,p_segment17                    => p_segment17
        ,p_segment18                    => p_segment18
        ,p_segment19                    => p_segment19
        ,p_segment20                    => p_segment20
        ,p_segment21                    => p_segment21
        ,p_segment22                    => p_segment22
        ,p_segment23                    => p_segment23
        ,p_segment24                    => p_segment24
        ,p_segment25                    => p_segment25
        ,p_segment26                    => p_segment26
        ,p_segment27                    => p_segment27
        ,p_segment28                    => p_segment28
        ,p_segment29                    => p_segment29
        ,p_segment30                    => p_segment30
	,p_projected_assignment_end     => p_projected_assignment_end
        ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        ,p_comment_id                   => l_comment_id
        ,p_no_managers_warning          => l_no_managers_warning
        ,p_other_manager_warning        => l_other_manager_warning
        ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
        ,p_concatenated_segments        => l_concatenated_segments
        ,p_hourly_salaried_warning      => l_hourly_salaried_warning
        ,p_scl_concat_segments          => l_scl_concat_segments
        ,p_people_group_name            => l_people_group_name
        ,p_people_group_id              => l_people_group_id
        ,p_spp_delete_warning           => l_spp_delete_warning
        ,p_entries_changed_warning      => l_entries_changed_warning
        ,p_tax_district_changed_warning => l_tax_district_changed_warning);
      --
      l_non_person_type_fields :=
        chk_for_non_cwk_fields
          (p_application_id                => p_application_id
          ,p_bargaining_unit_code          => p_bargaining_unit_code
          ,p_cag_segment1                  => p_cag_segment1
          ,p_cag_segment10                 => p_cag_segment10
          ,p_cag_segment11                 => p_cag_segment11
          ,p_cag_segment12                 => p_cag_segment12
          ,p_cag_segment13                 => p_cag_segment13
          ,p_cag_segment14                 => p_cag_segment14
          ,p_cag_segment15                 => p_cag_segment15
          ,p_cag_segment16                 => p_cag_segment16
          ,p_cag_segment17                 => p_cag_segment17
          ,p_cag_segment18                 => p_cag_segment18
          ,p_cag_segment19                 => p_cag_segment19
          ,p_cag_segment2                  => p_cag_segment2
          ,p_cag_segment20                 => p_cag_segment20
          ,p_cag_segment3                  => p_cag_segment3
          ,p_cag_segment4                  => p_cag_segment4
          ,p_cag_segment5                  => p_cag_segment5
          ,p_cag_segment6                  => p_cag_segment6
          ,p_cag_segment7                  => p_cag_segment7
          ,p_cag_segment8                  => p_cag_segment8
          ,p_cag_segment9                  => p_cag_segment9
          ,p_cagr_id_flex_num              => p_cagr_id_flex_num
          ,p_collective_agreement_id       => p_collective_agreement_id
          ,p_contract_id                   => p_contract_id
          ,p_date_probation_end            => p_date_probation_end
          ,p_grade_ladder_pgm_id           => p_grade_ladder_pgm_id
	  ,p_grade_id           => p_grade_id
          ,p_hourly_salaried_code          => p_hourly_salaried_code
          ,p_pay_basis_id                  => p_pay_basis_id
          ,p_payroll_id                    => p_payroll_id
          ,p_perf_review_period            => p_perf_review_period
          ,p_perf_review_period_frequency  => p_perf_review_period_frequency
          ,p_person_referred_by_id         => p_person_referred_by_id
          ,p_probation_period              => p_probation_period
          ,p_probation_unit                => p_probation_unit
          ,p_recruiter_id                  => p_recruiter_id
          ,p_recruitment_activity_id       => p_recruitment_activity_id
          ,p_sal_review_period             => p_sal_review_period
          ,p_sal_review_period_frequency   => p_sal_review_period_frequency
          ,p_source_organization_id        => p_source_organization_id
          ,p_special_ceiling_step_id       => p_special_ceiling_step_id
          ,p_vacancy_id                    => p_vacancy_id);
      --
      -- IF non CWK fields have been entered in the mass update
      -- then raise a Warning message so the user knows that non-cwk
      -- fields have been entered but will not get updated.
      --
      IF l_non_person_type_fields THEN
        --
        hr_utility.set_message(800,'HR_449905_NON_CWK_FIELDS');
        l_message_text := 'WARNING: '||hr_utility.get_message;
        --
        Log_Error(p_type              => 'WARNING',
                  p_assignment_number => p_assignment_number,
                  p_warning_message   => l_message_text,
                  p_already_errored   => l_already_errored);
      END IF;
    --
    -- If assignment type is not one of the above
    -- then raise an error.
    --
    ELSE
      --
      hr_utility.set_message(801,'HR_449903_INV_ASG_TYPE');
      hr_utility.raise_error;
      --
    END IF;
    --
    hr_utility.set_location('Leaving : '||l_proc, 999);
    --
  END update_assignment;
  --
BEGIN
  g_txn_id := null;
  g_org_hierarchy_id := null;
  g_org_starting_node := null;
  g_org_hierarchy_root := null;
  g_pos_hierarchy_id := null;
  g_pos_starting_node := null;
  g_pos_hierarchy_root := null;
END pqh_asg_wrapper;

/
