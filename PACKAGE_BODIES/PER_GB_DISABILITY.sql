--------------------------------------------------------
--  DDL for Package Body PER_GB_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_DISABILITY" AS
/* $Header: pegbdisp.pkb 120.0.12000000.2 2007/02/20 09:41:22 npershad noship $ */

PROCEDURE VALIDATE_CREATE_DISABILITY(p_category in  varchar2,
                                     p_person_id in number,
				     p_effective_date date)
AS


cursor csr_get_securityid
is
select distinct security_group_id
from  per_all_people_f ppf
     ,per_business_groups pbg
where ppf.person_id = p_person_id
and ppf.business_group_id= pbg.business_group_id
and p_effective_date between
    ppf.effective_start_date and ppf.effective_end_date;


cursor csr_get_owner(p_security_id number) is
select flv.last_updated_by upd
  from fnd_lookup_values flv
  where flv.lookup_type='DISABILITY_CATEGORY'
   and  flv.language = userenv('LANG')
   and  flv.security_group_id = p_security_id
   and flv.lookup_code = p_category;

 cursor csr_get_owner_std(p_security_id number) is
select flv.last_updated_by upd
  from fnd_lookup_values flv
  where flv.lookup_type='DISABILITY_CATEGORY'
   and  flv.language = userenv('LANG')
   and  flv.security_group_id =p_security_id
   and flv.lookup_code = p_category;


   v_csr csr_get_owner%rowtype;
   l_security_id number := 0;
   l_upd number;

  BEGIN
    IF p_category is not null THEN

    open csr_get_securityid;
    fetch csr_get_securityid into l_security_id;

      open csr_get_owner(l_security_id);
      fetch csr_get_owner into l_upd;
      if csr_get_owner%notfound then
          l_security_id := 0;
          open csr_get_owner_std(l_security_id);
	  fetch csr_get_owner_std into l_upd;
	  close csr_get_owner_std;
      end if;

        IF p_category not in ('Y','N','ND') and l_upd in (0,1,2) THEN
          hr_utility.set_message(800, 'HR_GB_78125_INVALID_CATEGORY');
          hr_utility.raise_error;
        END IF;
      close csr_get_owner;
   close csr_get_securityid;

   END IF;

 END VALIDATE_CREATE_DISABILITY;


 PROCEDURE VALIDATE_UPDATE_DISABILITY(p_category  in  varchar2,
				      p_disability_id number,
				      p_effective_date date)
 AS


cursor csr_get_securityid
is
select distinct security_group_id
from  per_disabilities_f pdf
     ,per_all_people_f  ppf
     ,per_business_groups pbg
where ppf.person_id = pdf.person_id
and   ppf.business_group_id= pbg.business_group_id
and   pdf.disability_id = p_disability_id
and   p_effective_date between
      ppf.effective_start_date and ppf.effective_end_date;
--and   p_effective_date between  pdf.effective_start_date and pdf.effective_end_date;

cursor csr_get_owner(p_security_id number) is
select flv.last_updated_by upd
  from fnd_lookup_values flv
  where flv.lookup_type='DISABILITY_CATEGORY'
   and  flv.language = userenv('LANG')
   and  flv.security_group_id =p_security_id
   and flv.lookup_code = p_category;


cursor csr_get_owner_std(p_security_id number) is
select flv.last_updated_by upd
  from fnd_lookup_values flv
  where flv.lookup_type='DISABILITY_CATEGORY'
   and  flv.language = userenv('LANG')
   and  flv.security_group_id =p_security_id
   and flv.lookup_code = p_category;

   v_csr csr_get_owner%rowtype;
   l_security_id number;
   l_upd number;

  BEGIN

  IF p_category is not null THEN

    open csr_get_securityid;
    fetch csr_get_securityid into l_security_id;

      open csr_get_owner(l_security_id);
      fetch csr_get_owner into l_upd;
        if csr_get_owner%notfound then
          l_security_id := 0;
          open csr_get_owner_std(l_security_id);
	  fetch csr_get_owner_std into l_upd;
	  close csr_get_owner_std;
        end if;

	IF p_category not in ('Y','N','ND') and l_upd in (0,1,2) THEN
	   hr_utility.set_message(800, 'HR_GB_78125_INVALID_CATEGORY');
	   hr_utility.raise_error;
	END IF;
      close csr_get_owner;
    close csr_get_securityid;

    END IF;

 END VALIDATE_UPDATE_DISABILITY;

END per_gb_disability;

/
