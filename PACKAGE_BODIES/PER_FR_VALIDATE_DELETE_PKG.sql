--------------------------------------------------------
--  DDL for Package Body PER_FR_VALIDATE_DELETE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_VALIDATE_DELETE_PKG" AS
/* $Header: pefrorvd.pkb 115.4 2003/12/18 06:52:55 hwinsor noship $ */

procedure validate_delete(x_organization_id in number)
is

cursor csr_estab_comp   is
	SELECT '1'
	FROM HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT = 'FR_ESTAB_INFO'
	AND TO_NUMBER(ORG_INFORMATION1) = x_organization_id;

cursor csr_estab_urssaf is

	SELECT '1'
	FROM HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT = 'FR_ESTAB_URSSAF'
	AND TO_NUMBER(ORG_INFORMATION1) = x_organization_id;

cursor csr_estab_assedic is
	SELECT '1'
	FROM HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT = 'FR_ESTAB_ASSEDIC'
	AND TO_NUMBER(ORG_INFORMATION1) = x_organization_id;

cursor csr_estab_pens is
	SELECT '1'
	FROM HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT = 'FR_ESTAB_PE_PRVS'
	AND TO_NUMBER(ORG_INFORMATION1) = x_organization_id;

cursor csr_estab_insu is
	SELECT '1'
	FROM HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT = 'FR_ESTAB_INS_PRV'
	AND TO_NUMBER(ORG_INFORMATION1) = x_organization_id;

cursor csr_comp_urssaf is
	SELECT '1'
	FROM  HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT = 'FR_COMP_INFO'
	AND x_organization_id = to_number(ORG_INFORMATION3);

cursor csr_comp_dads_estab is
	select 1
	from hr_organization_information oi, hr_all_organization_units ou
	where oi.organization_id = ou.organization_id
	and oi.organization_id = x_organization_id
	and oi.org_information_context = 'FR_ESTAB_INFO'
	and to_number (oi.org_information1) =
	(select ou.organization_id
 	from hr_all_organization_units ou, hr_organization_information oi
 	where to_number (oi.org_information4) = x_organization_id
 	and oi.organization_id = ou.organization_id
 	and oi.org_information_context = 'FR_COMP_INFO');

cursor csr_comp_heaq_estab is
	select 1
	from hr_organization_information oi, hr_all_organization_units ou
	where oi.organization_id = ou.organization_id
	and oi.organization_id = x_organization_id
	and oi.org_information_context = 'FR_ESTAB_INFO'
	and to_number (oi.org_information1) =
	(select ou.organization_id
 	from hr_all_organization_units ou, hr_organization_information oi
 	where to_number (oi.org_information5) = x_organization_id
 	and oi.organization_id = ou.organization_id
 	and oi.org_information_context = 'FR_COMP_INFO');

cursor csr_comp_pens is
	SELECT '1'
	FROM  HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT (+)  = 'FR_COMP_PE_PRVS'
	AND x_organization_id = to_number(ORG_INFORMATION1);

cursor csr_comp_insu is
	SELECT '1'
	FROM  HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT (+)  = 'FR_COMP_INS_PRVS'
	AND x_organization_id = to_number(ORG_INFORMATION1);


cursor csr_employer  is
	select '1'
	from per_collective_agreements_v
	where employer_organization_id = x_organization_id;

cursor csr_barg_units  is
	select '1'
	from per_collective_agreements_v
	where bargaining_organization_id = x_organization_id;

cursor csr_cpam  is
	select '1'
	from per_all_people_f pap
	where pap.per_information_category = 'FR'
                        and   to_number(pap.per_information11)
                                                         = x_organization_id;

cursor csr_assignments is
	select '1'
	from per_all_assignments_f paa
	where paa.establishment_id = x_organization_id;

l_dummy varchar2(1);

BEGIN
   hr_utility.set_location('pefrorrvd package entered', 1);

if hr_organization_units_pkg.get_org_class(X_Organization_Id, 'FR_SOCIETE') then
  open csr_estab_comp;
  fetch csr_estab_comp into l_dummy;
   hr_utility.set_location('FR societe!!', 10);
  if csr_estab_comp%found then
   hr_utility.set_location('FR societe failure!!', 10);
     hr_utility.set_message(800,'PER_74848_ORG_DEL_EST');
     hr_utility.raise_error;
  end if;
  close csr_estab_comp;
end if;

if hr_organization_units_pkg.get_org_class(X_Organization_Id,'FR_CENTRE_URSSAF') then
   hr_utility.set_location('FR centre urssaf!!', 10);
  open csr_estab_urssaf;
  fetch csr_estab_urssaf into l_dummy;
  if csr_estab_urssaf%found then
   hr_utility.set_location('FR centre urssaf failure!!', 10);
     hr_utility.set_message(800,'PER_74848_ORG_DEL_EST');
     hr_utility.raise_error;
  end if;
  close csr_estab_urssaf;

  open csr_comp_urssaf;
  fetch csr_comp_urssaf into l_dummy;
   hr_utility.set_location('FR comp urssaf!!', 10);
  if csr_comp_urssaf%found then
   hr_utility.set_location('FR comp urssaf!!', 10);
     hr_utility.set_message(800,'PER_74849_ORG_DEL_COM');
     hr_utility.raise_error;
  end if;
  close csr_comp_urssaf;
end if;

if hr_organization_units_pkg.get_org_class(X_Organization_Id,'FR_CENTRE_ASSEDIC') then
   hr_utility.set_location('FR centre assedic!!', 10);
  open csr_estab_assedic;
  fetch csr_estab_assedic into l_dummy;
  if csr_estab_assedic%found then
   hr_utility.set_location('FR centre assedic failure!!', 10);
     hr_utility.set_message(800,'PER_74848_ORG_DEL_EST');
     hr_utility.raise_error;
  end if;
  close csr_estab_assedic;
end if;

if hr_organization_units_pkg.get_org_class(X_Organization_Id,'FR_PENSION') then
   hr_utility.set_location('FR pension!!', 9);
  open csr_estab_pens;
   hr_utility.set_location('FR pension!!', 10);
  fetch csr_estab_pens into l_dummy;
  if csr_estab_pens%found then
   hr_utility.set_location('FR pension failure!!', 10);
     hr_utility.set_message(800,'PER_74848_ORG_DEL_EST');
     hr_utility.raise_error;
  end if;
   hr_utility.set_location('FR pension!!', 11);
  close csr_estab_pens;
   hr_utility.set_location('FR pension!!', 12);

  open csr_comp_pens;
   hr_utility.set_location('FR pension!!', 13);
  fetch csr_comp_pens into l_dummy;
   hr_utility.set_location('FR comp pens!!', 10);
  if csr_comp_pens%found then
   hr_utility.set_location('FR comp pens failure!!', 10);
     hr_utility.set_message(800,'PER_74849_ORG_DEL_COM');
     hr_utility.raise_error;
  end if;
  close csr_comp_pens;
end if;

if hr_organization_units_pkg.get_org_class(X_Organization_Id,'FR_ASSURANCE') then
   hr_utility.set_location('FR assurance!!', 10);
  open csr_estab_insu;
  fetch csr_estab_insu into l_dummy;
  if csr_estab_insu%found then
   hr_utility.set_location('FR assurance failure!!', 10);
     hr_utility.set_message(800,'PER_74848_ORG_DEL_EST');
     hr_utility.raise_error;
  end if;
  close csr_estab_insu;

  open csr_comp_insu;
  fetch csr_comp_insu into l_dummy;
   hr_utility.set_location('FR comp insu!!', 10);
  if csr_comp_insu%found then
   hr_utility.set_location('FR comp insu failure!!', 10);
     hr_utility.set_message(800,'PER_74849_ORG_DEL_COM');
     hr_utility.raise_error;
  end if;
  close csr_comp_insu;
end if;

if hr_organization_units_pkg.get_org_class(X_Organization_Id,'FR_ETABLISSEMENT') then
   hr_utility.set_location('FR etablissement!!', 10);
  open csr_comp_dads_estab;
  fetch csr_comp_dads_estab into l_dummy;
  if csr_comp_dads_estab%found then
   hr_utility.set_location('FR etablissement failure!!', 10);
     hr_utility.set_message(800,'PER_74849_ORG_DEL_COM');
     hr_utility.raise_error;
  end if;
  close csr_comp_dads_estab;

  open csr_comp_heaq_estab;
  fetch csr_comp_heaq_estab into l_dummy;
   hr_utility.set_location('FR comp heaq estab!!', 10);
  if csr_comp_heaq_estab%found then
   hr_utility.set_location('FR comp heaq estab failure!!', 10);
     hr_utility.set_message(800,'PER_74849_ORG_DEL_COM');
     hr_utility.raise_error;
  end if;
  close csr_comp_heaq_estab;

  open csr_assignments;
  fetch csr_assignments into l_dummy;
   hr_utility.set_location('FR assignments!!', 10);
  if csr_assignments%found then
   hr_utility.set_location('FR assignments failure!!', 10);
     hr_utility.set_message(800,'PER_74853_ORG_DEL_ASG');
     hr_utility.raise_error;
  end if;
  close csr_assignments;
end if;

if hr_organization_units_pkg.get_org_class(X_Organization_Id,'FR_CPAM' )then
   hr_utility.set_location('FR cpam!!', 10);
  open csr_cpam;
  fetch csr_cpam into l_dummy;
  if csr_cpam%found then
   hr_utility.set_location('FR cpam failure!!', 10);
     hr_utility.set_message(800,'PER_74852_ORG_DEL_PER');
     hr_utility.raise_error;
  end if;
  close csr_cpam;
end if;
   hr_utility.set_location('end of pefrorvd package', 10);

end validate_delete;
--
END PER_FR_VALIDATE_DELETE_PKG;

/
