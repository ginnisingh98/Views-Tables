--------------------------------------------------------
--  DDL for Package Body HR_SA_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SA_ORG_INFO" AS
/* $Header: pesaorgi.pkb 115.2 2004/01/14 07:09:47 abppradh noship $ */

--
--
-- Cursor which fetches Organizations from the named hierarchy - bottom to top
--
CURSOR organization_hierarchy(p_org_id NUMBER, p_org_structure_version_id NUMBER, p_org_exists_in_hierarchy VARCHAR2) IS
          SELECT p_org_id organization_id_parent
                ,0 lev
            FROM dual
           WHERE p_org_exists_in_hierarchy = 'Y'
           UNION
          SELECT organization_id_parent
                ,level lev
            FROM per_org_structure_elements
           WHERE org_structure_version_id = p_org_structure_version_id
      START WITH organization_id_child    = p_org_id
CONNECT BY PRIOR organization_id_parent   = organization_id_child
             AND org_structure_version_id = p_org_structure_version_id
        ORDER BY lev;
--
CURSOR org_hierarchy(p_org_id NUMBER, p_org_structure_version_id NUMBER, p_org_exists_in_hierarchy VARCHAR2) IS
          SELECT p_org_id organization_id_parent
                ,0 lev
            FROM dual
           WHERE p_org_exists_in_hierarchy = 'Y'
           UNION
          SELECT organization_id_parent
                ,level lev
            FROM per_org_structure_elements
           WHERE org_structure_version_id = p_org_structure_version_id
      START WITH organization_id_child    = p_org_id
CONNECT BY PRIOR organization_id_parent   = organization_id_child
             AND org_structure_version_id = p_org_structure_version_id
        ORDER BY lev;
--
--
-- Service function to return the current named hioerarchy.
--
FUNCTION named_hierarchy
(p_organization_id NUMBER) RETURN NUMBER IS
  --
  --
  -- Cursor to return the current named hierarchy.
  --
  CURSOR c_hierarchy(p_organization_id NUMBER) IS
    SELECT TO_NUMBER(inf.org_information1) organization_structure_id
    FROM   hr_organization_information inf
          ,hr_all_organization_units   org
    WHERE  org.organization_id         = p_organization_id
      AND  inf.organization_id         = org.business_group_id
      AND  inf.org_information_context = 'SA_HR_BG_INFO'
      AND  inf.org_information1        IS NOT NULL;
  --
  --
  -- Local Variables.
  --
  l_rec c_hierarchy%ROWTYPE;
BEGIN
  --
  --
  -- Find the current named organization hierarchy.
  --
  OPEN  c_hierarchy(p_organization_id => p_organization_id);
  FETCH c_hierarchy INTO l_rec;
  CLOSE c_hierarchy;
  --
  --
  -- Return ID.
  --
  RETURN l_rec.organization_structure_id;
END named_hierarchy;
--
--
-- Service function to return the current version of the named hioerarchy.
--
FUNCTION latest_named_hierarchy_vers
(p_organization_id NUMBER) RETURN NUMBER IS
  --
  --
  -- Cursor to return the current named hierarchy version.
  --
  CURSOR c_hierarchy_version(p_organization_id NUMBER, p_organization_structure_id NUMBER) IS
    SELECT sv.org_structure_version_id, sv.version_number
    FROM   per_org_structure_versions  sv
          ,fnd_sessions                ses
    WHERE  sv.organization_structure_id = p_organization_structure_id
      AND  ses.session_id               = USERENV('sessionid')
      AND  ses.effective_date BETWEEN sv.date_from AND NVL(sv.date_to, TO_DATE('31/12/4712','DD/MM/YYYY'))
    ORDER BY sv.version_number DESC;
  --
  --
  -- Local Variables.
  --
  l_rec c_hierarchy_version%ROWTYPE;
BEGIN
  --
  --
  -- Find the current primary organization hierarchy.
  --
  OPEN  c_hierarchy_version(p_organization_id           => p_organization_id
                           ,p_organization_structure_id => named_hierarchy(p_organization_id));
  FETCH c_hierarchy_version INTO l_rec;
  CLOSE c_hierarchy_version;
  --
  --
  -- Return ID.
  --
  RETURN l_rec.org_structure_version_id;
END latest_named_hierarchy_vers;
--
--
-- Service function to see if organization belongs to the current named hioerarchy.
--
FUNCTION org_exists_in_hierarchy
(p_organization_id NUMBER) RETURN VARCHAR2 IS
  --
  --
  -- Cursor to see if the organization belongs to the current named hierarchy.
  --
  CURSOR c_org_exists(p_organization_id NUMBER, p_org_structure_version_id NUMBER) IS
    SELECT se.organization_id_child
    FROM   per_org_structure_elements se
    WHERE  se.org_structure_version_id = p_org_structure_version_id
      AND  (se.organization_id_parent  = p_organization_id OR
            se.organization_id_child   = p_organization_id);
  --
  --
  -- Local Variables.
  --
  l_rec c_org_exists%ROWTYPE;
BEGIN
  OPEN  c_org_exists(p_organization_id          => p_organization_id
                    ,p_org_structure_version_id => latest_named_hierarchy_vers(p_organization_id));
  FETCH c_org_exists INTO l_rec;
  IF c_org_exists%FOUND THEN
    CLOSE c_org_exists;
    RETURN 'Y';
  ELSE
    CLOSE c_org_exists;
    RETURN 'N';
  END IF;
END org_exists_in_hierarchy;

/*------------------------------------------------------------------------------
The following procedure checks if the Organization passed in exists in the Prima
ry Hierarchy. Called in HREMEA.pll to validate the Organization Name on the Assi
gnment form
--------------------------------------------------------------------------------*/
PROCEDURE chk_for_org_in_hierarchy(p_org_id in hr_organization_units.organization_id%TYPE,
                                   p_exists out nocopy varchar2) IS
 l_organization_id      hr_organization_units.organization_id%TYPE;
 l_level 	        number;
BEGIN
  p_exists := org_exists_in_hierarchy(p_org_id);
END chk_for_org_in_hierarchy;

PROCEDURE get_employer_name (p_org_id in hr_organization_units.organization_id%TYPE,
                             p_employer_name out nocopy varchar2,
			     p_business_group_id hr_organization_units.organization_id%TYPE) IS
cursor csr_employer (p_organization_id hr_organization_units.organization_id%TYPE,
			 p_bus_group_id hr_organization_units.organization_id%TYPE) is
	select hou.name
	from hr_organization_units hou,
		hr_organization_information hoi1,
		hr_organization_information hoi2
	where (hou.business_group_id= p_bus_group_id
	OR (hou.business_group_id=hou.organization_id and
	hou.business_group_id <> p_bus_group_id   )) and
	trunc(sysdate) between hou.date_from and nvl(hou.date_to,
	to_date('4712/12/31','YYYY/MM/DD')) and
	hou.organization_id = hoi1.organization_id and
	hou.organization_id = p_organization_id  and
	hoi1.org_information_context = 'CLASS' and
	hoi1.org_information1 = 'HR_LEGAL' and
	Hoi1.organization_id = hoi2.organization_id and
	Hoi2.org_information_context = 'SA_EMPLOYER_GOSI_DETAILS'
	order by hou.name;
l_results varchar2(240);
BEGIN
if 'Y' <> org_exists_in_hierarchy(p_org_id) then
	p_employer_name := 'NO_EMPLOYER_FOUND';
end if;
	FOR hier_org IN ORG_HIERARCHY (p_org_id, latest_named_hierarchy_vers(p_org_id),org_exists_in_hierarchy(p_org_id)) LOOP
		OPEN csr_employer(hier_org.organization_id_parent,p_business_group_id);
		FETCH csr_employer INTO l_results;
--		CLOSE csr_employer;

		if csr_employer%FOUND then
			p_employer_name := l_results;
			CLOSE csr_employer;
			exit;
		else
			p_employer_name := 'NO_EMPLOYER_FOUND';
			CLOSE csr_employer;
		end if;

	END LOOP;

end get_employer_name;

PROCEDURE get_employer_name (p_org_id in hr_organization_units.organization_id%TYPE,
                             p_employer_name out nocopy varchar2,
			     p_business_group_id hr_organization_units.organization_id%TYPE,
                             p_structure_version_id number) IS
cursor csr_employer (p_organization_id hr_organization_units.organization_id%TYPE,
			 p_bus_group_id hr_organization_units.organization_id%TYPE) is
	select hou.name
	from hr_organization_units hou,
		hr_organization_information hoi1,
		hr_organization_information hoi2
	where (hou.business_group_id= p_bus_group_id
	OR (hou.business_group_id=hou.organization_id and
	hou.business_group_id <> p_bus_group_id   )) and
	trunc(sysdate) between hou.date_from and nvl(hou.date_to,
	to_date('4712/12/31','YYYY/MM/DD')) and
	hou.organization_id = hoi1.organization_id and
	hou.organization_id = p_organization_id  and
	hoi1.org_information_context = 'CLASS' and
	hoi1.org_information1 = 'HR_LEGAL' and
	Hoi1.organization_id = hoi2.organization_id and
	Hoi2.org_information_context = 'SA_EMPLOYER_GOSI_DETAILS'
	order by hou.name;
l_results varchar2(240);
BEGIN
	FOR hier_org IN ORG_HIERARCHY (p_org_id, p_structure_version_id,'Y') LOOP
		OPEN csr_employer(hier_org.organization_id_parent,p_business_group_id);
		FETCH csr_employer INTO l_results;
--		CLOSE csr_employer;

		if csr_employer%FOUND then
			p_employer_name := l_results;
			CLOSE csr_employer;
			exit;
		else
			p_employer_name := 'NO_EMPLOYER_FOUND';
			CLOSE csr_employer;
		end if;

	END LOOP;

end get_employer_name;


FUNCTION get_employer_name (p_org_id in hr_organization_units.organization_id%TYPE,
			     p_business_group_id hr_organization_units.organization_id%TYPE,
                             p_structure_version_id number default null) RETURN VARCHAR2 IS
cursor csr_employer (p_organization_id hr_organization_units.organization_id%TYPE,
			 p_bus_group_id hr_organization_units.organization_id%TYPE) is
	select hou.name
	from hr_organization_units hou,
		hr_organization_information hoi1,
		hr_organization_information hoi2
	where (hou.business_group_id= p_bus_group_id
	OR (hou.business_group_id=hou.organization_id and
	hou.business_group_id <> p_bus_group_id   )) and
	trunc(sysdate) between hou.date_from and nvl(hou.date_to,
	to_date('4712/12/31','YYYY/MM/DD')) and
	hou.organization_id = hoi1.organization_id and
	hou.organization_id = p_organization_id  and
	hoi1.org_information_context = 'CLASS' and
	hoi1.org_information1 = 'HR_LEGAL' and
	Hoi1.organization_id = hoi2.organization_id and
	Hoi2.org_information_context = 'SA_EMPLOYER_GOSI_DETAILS'
	order by hou.name;
  l_employer_name varchar2(240);
  l_results       varchar2(240);
BEGIN
  IF p_structure_version_id is not null then
	FOR hier_org IN ORG_HIERARCHY (p_org_id, p_structure_version_id,'Y') LOOP
		OPEN csr_employer(hier_org.organization_id_parent,p_business_group_id);
		FETCH csr_employer INTO l_results;
--		CLOSE csr_employer;

		if csr_employer%FOUND then
			l_employer_name := l_results;
			CLOSE csr_employer;
			exit;
		else
			l_employer_name := null;
			CLOSE csr_employer;
		end if;

	END LOOP;
  ELSE
    if 'Y' <> org_exists_in_hierarchy(p_org_id) then
	l_employer_name := null;
    end if;
	FOR hier_org IN ORG_HIERARCHY (p_org_id, latest_named_hierarchy_vers(p_org_id),org_exists_in_hierarchy(p_org_id)) LOOP
		OPEN csr_employer(hier_org.organization_id_parent,p_business_group_id);
		FETCH csr_employer INTO l_results;
--		CLOSE csr_employer;
		if csr_employer%FOUND then
			l_employer_name := l_results;
			CLOSE csr_employer;
			exit;
		else
			l_employer_name := null;
			CLOSE csr_employer;
		end if;

	END LOOP;
  END IF;

  RETURN l_employer_name;

end get_employer_name;

END HR_SA_ORG_INFO;



/
