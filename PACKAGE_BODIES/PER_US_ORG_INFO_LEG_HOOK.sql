--------------------------------------------------------
--  DDL for Package Body PER_US_ORG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_ORG_INFO_LEG_HOOK" AS
/* $Header: peusvald.pkb 120.0.12010000.3 2009/04/01 19:42:09 rnestor noship $ */

 PROCEDURE UPDATE_US_ORG_INFO
         (P_ORG_INFORMATION_ID          IN     NUMBER
         ,p_org_info_type_code          IN     VARCHAR2
         ,p_org_information1            IN     VARCHAR2
         ,p_org_information2            IN     VARCHAR2
        )
IS
  --
  CURSOR csr_tax_rules
    (p_organization_id              IN     NUMBER
    ,p_org_info_type_code           IN     VARCHAR2
    ,p_org_information1             IN     VARCHAR2

    )
  IS
    select 'Y'
    from hr_organization_information
        where ORG_INFORMATION_CONTEXT like p_org_info_type_code
        and ORG_INFORMATION_CONTEXT in
               ( 'State Tax Rules', 'State Tax Rules 2', 'Local Tax Rules')  --RLN 7421633
         and org_information1 = p_org_information1
         and organization_id = p_organization_id
         and org_information_id <> P_ORG_INFORMATION_ID
      ;

   l_found    varchar2(1);
   l_org_id   number;
--

BEGIN
  --
  --
  --
    l_found := 'N';
    --
    -- Check tax rule does not exist elsewhere
    --
    l_org_id := -99999;
    begin
        select hoi.organization_id
        into   l_org_id
        from hr_organization_information hoi
        where P_ORG_INFORMATION_ID = hoi.org_information_id
--        and   ORG_INFORMATION_CONTEXT = p_org_info_type_code
        and rownum = 1;

    exception
        when others then
           l_org_id := -99999;
    end;

    if l_org_id <> -99999 THEN


        OPEN csr_tax_rules(l_org_id
                           ,p_org_info_type_code
                           ,p_org_information1

                         );
        FETCH csr_tax_rules INTO l_found;
        IF (csr_tax_rules%FOUND) THEN
          CLOSE csr_tax_rules;
          fnd_message.set_name  ('PAY','PAY_US_TAX_RULES_EXIST');
          fnd_message.raise_error;
        ELSE
          CLOSE csr_tax_rules;
        END IF;
    end if;
  --

--
END UPDATE_US_ORG_INFO;



PROCEDURE INSERT_US_ORG_INFO
         (p_organization_id             IN     NUMBER
         ,p_org_info_type_code         IN     VARCHAR2
         ,p_org_information1            IN     VARCHAR2
         ,p_org_information2            IN     VARCHAR2
        )
IS
  --
  CURSOR csr_tax_rules
    (p_organization_id              IN     NUMBER
    ,p_org_info_type_code           IN     VARCHAR2
    ,p_org_information1             IN     VARCHAR2

    )
  IS
    select 'Y'
    from hr_organization_information
        where ORG_INFORMATION_CONTEXT like p_org_info_type_code
        and ORG_INFORMATION_CONTEXT in
               ( 'State Tax Rules', 'State Tax Rules 2', 'Local Tax Rules') --RLN 7421633
         and org_information1 = p_org_information1
         and organization_id = p_organization_id
      ;

   l_found    varchar2(1);
--

BEGIN
  --
  --
  --
    l_found := 'N';
    --
    -- Check tax rule does not exist elsewhere
    --
    OPEN csr_tax_rules(p_organization_id
                       ,p_org_info_type_code
                       ,p_org_information1
                       );
    FETCH csr_tax_rules INTO l_found;
    IF (csr_tax_rules%FOUND) THEN
      CLOSE csr_tax_rules;
      fnd_message.set_name  ('PAY','PAY_US_TAX_RULES_EXIST');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_tax_rules;
    END IF;
  --

--

END INSERT_US_ORG_INFO;


/**PROCEDURE check_duplicate_tax_rules
  (p_organization_id             IN     NUMBER
  ,p_org_information_context     IN     VARCHAR2
  ,p_org_information1            IN     VARCHAR2

  )
IS
  --
  CURSOR csr_tax_rules
    (p_organization_id              IN     NUMBER
    ,p_org_information_context      IN     VARCHAR2
    ,p_org_information1             IN     VARCHAR2

    )
  IS
    select 'Y'
    from hr_organization_information
        where ORG_INFORMATION_CONTEXT like p_org_information_context
         and org_information1 = p_org_information1
         and organization_id = p_organization_id
      ;

   l_found    varchar2(1);
--

BEGIN
  --
  --
  --
    l_found = 'N';
    --
    -- Check tax rule does not exist elsewhere
    --
    OPEN csr_tax_rules(p_organization_id
                       ,p_org_information_context
                       ,p_org_information1

                     );
    FETCH csr_tax_rules INTO l_found;
    IF (csr_tax_rules%FOUND) THEN
      CLOSE csr_business_group_name;
      fnd_message.set_name  ('PAY','PAY_US_TAX_RULES_EXIST');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_tax_rules;
    END IF;
  --

--
END check_duplicate_tax_rules;**/

END PER_US_ORG_INFO_LEG_HOOK;


/
