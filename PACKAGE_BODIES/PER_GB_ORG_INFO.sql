--------------------------------------------------------
--  DDL for Package Body PER_GB_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_ORG_INFO" AS
/* $Header: pegborgp.pkb 120.6.12010000.4 2009/05/05 09:01:21 krreddy ship $ */
 PROCEDURE CREATE_GB_ORG_INFO(
         p_organization_id             NUMBER
        ,p_org_info_type_code          VARCHAR2
        ,p_org_information1            VARCHAR2
        ,p_org_information3            VARCHAR2 --Added for bug 7338614
        ,p_org_information10           VARCHAR2
        ) is
  l_tax_string             varchar2(30) ;
  l_tax_district_reference varchar2(10);
  l_tax_reference_number   varchar2(15);

--
Cursor csr_org_info_exists is
select 1
from   hr_organization_information
where  organization_id   = p_organization_id
and    org_information_context = p_org_info_type_code
and    org_information1  = p_org_information1;
--
l_found NUMBER;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
    --
    IF (p_org_info_type_code = 'Tax Details References') THEN
      open csr_org_info_exists;
      fetch csr_org_info_exists into l_found;
      if csr_org_info_exists%found then
         close csr_org_info_exists;
         hr_utility.set_message (800, 'HR_GB_78132_EMP_PAYE_REF_EXIST');
         hr_utility.set_message_token('PAYE_REF', p_org_information1);
         hr_utility.raise_error;
      end if;
      close csr_org_info_exists;

--Modification starts - Moving the below error inside the above IF condition for the bug 8479004
	--Added for bug 7338614
    IF length(p_org_information3)>35 THEN
       hr_utility.set_message (800, 'HR_GB_78140_EMP_STAT_NAME_MAX');
       hr_utility.raise_error;
    END IF;
	--Bug 7338614 Ends
--Modification ends - Moving the below error inside the above IF condition for the bug 8479004

    END IF;
    --

    IF p_org_information10 = 'UK' THEN /*Bug 5084055*/
       IF (p_org_info_type_code = 'Tax Details References') THEN
          BEGIN
            l_tax_district_reference := substr( p_org_information1, 1, INSTR(p_org_information1,'/')-1 );
            l_tax_reference_number   := substr( p_org_information1, INSTR(p_org_information1,'/')+1 , length(p_org_information1) );

            IF (l_tax_district_reference is NULL OR l_tax_reference_number is NULL
               OR length(l_tax_district_reference) <> 3
               OR length(l_tax_reference_number) < 0 OR  length(l_tax_reference_number) > 10
               OR pay_gb_eoy_magtape.validate_input(l_tax_reference_number, 'PAYE_REF') <> 0) THEN
                  hr_utility.set_message (800, 'HR_GB_78049_INV_EMP_PAYE_REF');
                  hr_utility.raise_error;
            END IF;

            IF( to_number(l_tax_district_reference) = to_number(l_tax_district_reference) ) THEN
               IF to_number(l_tax_district_reference) < 1 then
                  hr_utility.set_message (800, 'HR_GB_78049_INV_EMP_PAYE_REF');
                  hr_utility.raise_error;
               ELSE
                  null;
               END IF;
            END IF;
          EXCEPTION
          WHEN OTHERS THEN
            hr_utility.set_message (800, 'HR_GB_78049_INV_EMP_PAYE_REF');
            hr_utility.raise_error;
          END;
       END IF;
    END IF;
  END IF;
END CREATE_GB_ORG_INFO;



PROCEDURE UPDATE_GB_ORG_INFO(
         p_org_info_type_code     VARCHAR2
        ,p_org_information1       VARCHAR2
        ,p_org_information3       VARCHAR2 --Added for bug 7338614
        ,p_org_information10      VARCHAR2
        ,p_org_information_id     NUMBER
        ) is

  l_tax_district_reference varchar2(10);
  l_tax_reference_number   varchar2(15);

--
Cursor csr_org_info_exists is
select 1
from   hr_organization_information
where  organization_id   = (select organization_id
                            from   hr_organization_information
                            where  org_information_id = p_org_information_id)
and    org_information_context = p_org_info_type_code
and    org_information1        = p_org_information1
and    org_information_id     <> p_org_information_id;
--
l_found NUMBER;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    IF (p_org_info_type_code = 'Tax Details References') THEN
      IF (p_org_information1 <> hr_api.g_varchar2) THEN
        open csr_org_info_exists;
        fetch csr_org_info_exists into l_found;
        if csr_org_info_exists%found then
           close csr_org_info_exists;
           hr_utility.set_message (800, 'HR_GB_78132_EMP_PAYE_REF_EXIST');
           hr_utility.set_message_token('PAYE_REF', p_org_information1);
           hr_utility.raise_error;
        end if;
        close csr_org_info_exists;
      END IF;
--Modification starts - Moving the below error inside the above IF condition for the bug 8479004
    --Added for bug 7338614
    IF length(p_org_information3)>35 THEN
       hr_utility.set_message (800, 'HR_GB_78140_EMP_STAT_NAME_MAX');
       hr_utility.raise_error;
    END IF;
    --Bug 7338614 Ends
--Modification ends - Moving the below error inside the above IF condition for the bug 8479004
    END IF;
    --

    IF p_org_information10 = 'UK' then /*Bug 5084055*/
      IF (p_org_info_type_code = 'Tax Details References') THEN
        IF (p_org_information1 <> hr_api.g_varchar2) THEN
          BEGIN
            l_tax_district_reference := substr( p_org_information1, 1, INSTR(p_org_information1,'/')-1 );
            l_tax_reference_number   := substr( p_org_information1, INSTR(p_org_information1,'/')+1 , length(p_org_information1) );
            IF (l_tax_district_reference is NULL OR  l_tax_reference_number is NULL
               OR length(l_tax_district_reference) <> 3
               OR length(l_tax_reference_number) < 0 OR  length(l_tax_reference_number) > 10
               OR pay_gb_eoy_magtape.validate_input(l_tax_reference_number, 'PAYE_REF') <> 0 ) THEN
             hr_utility.set_message (800, 'HR_GB_78049_INV_EMP_PAYE_REF');
             hr_utility.raise_error;
            END IF;

            IF (to_number(l_tax_district_reference) = to_number(l_tax_district_reference) ) THEN
               IF to_number(l_tax_district_reference) < 1 then
                  hr_utility.set_message (800, 'HR_GB_78049_INV_EMP_PAYE_REF');
                  hr_utility.raise_error;
               ELSE
                  null;
               END IF;
            END IF;
          EXCEPTION
          WHEN OTHERS THEN
             hr_utility.set_message (800, 'HR_GB_78049_INV_EMP_PAYE_REF');
             hr_utility.raise_error;
          END;
        END IF;
      END IF;
    END IF;
  END IF;
END UPDATE_GB_ORG_INFO;

END PER_GB_ORG_INFO;

/
