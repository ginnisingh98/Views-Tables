--------------------------------------------------------
--  DDL for Package Body PAY_CA_PMED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_PMED" AS
/* $Header: pycapmcl.pkb 115.1 2003/03/20 00:34:20 ssattini noship $ */

----------------------------- get_source_id ------------------------------
/*
 * NAME
 *   get_source_id
 * DESCRIPTION
 *   This function find the correct Source Id for the assignment.
 * PARAMETERS
 *   p_jurisdiction_code - the jurisdiction code context
 *   p_tax_unit_id       - the tax unit id context
 *   p_different_jd      - the default account number for the given jurisdiction
 *                         is used to calculate the source id if no account
 *                         number parameter has been provided.
 *   p_account_number    - used to calculate the source id.
 * RETURN
 *   NUMBER - Source Id
 */
FUNCTION get_source_id(p_jurisdiction_code VARCHAR2,
                       p_tax_unit_id       NUMBER,
                       p_business_group_id NUMBER,
                       p_different_jd      VARCHAR2,
                       p_account_number    IN OUT NOCOPY VARCHAR2)
  RETURN NUMBER IS

CURSOR csr_get_src_id1(p_juris       VARCHAR2,
                       p_ac_no       VARCHAR2,
                       p_bg_no       number) IS
  SELECT pma.source_id
  FROM   pay_ca_pmed_accounts        pma
  WHERE  pma.account_number    = p_ac_no
  AND    pma.enabled           = 'Y'
  AND    pma.business_group_id = p_bg_no;

CURSOR csr_get_src_id2 (p_juris       VARCHAR2,
                        p_gre         NUMBER, p_bg_no NUMBER) IS
  SELECT pma.source_id,
         pma.account_number
  FROM   hr_organization_information ogi1,
         hr_organization_information ogi2,
         pay_ca_pmed_accounts        pma,
         hr_organization_information ogi3,
         hr_organization_information ogi4
  WHERE  ogi1.organization_id  = p_gre
  AND    ogi1.org_information_context = 'CLASS'
  AND    ogi1.org_information1 = 'HR_LEGAL'
  AND    ogi1.org_information2 = 'Y'
  AND    ogi2.organization_id  = p_gre
  AND    ogi2.org_information_context = 'Provincial Reporting Info.'
  AND    ogi2.org_information1 = p_juris
  AND    ogi2.org_information3 = pma.account_number
  AND    pma.enabled           = 'Y'
  AND    pma.business_group_id = p_bg_no
  AND    ogi3.organization_id   = pma.organization_id
  AND    ogi3.org_information_context = 'CLASS'
  AND    ogi3.org_information1 = 'CA_PMED'
  AND    ogi3.org_information2 = 'Y'
  AND    ogi4.organization_id   = pma.organization_id
  AND    ogi4.org_information_context = 'Provincial Information'
  AND    ogi4.org_information1 = p_juris;

CURSOR csr_get_src_id3(p_juris       VARCHAR2,
                       p_gre         NUMBER, p_bg_no NUMBER) IS
  SELECT pma.source_id,
         pma.account_number
  FROM   hr_organization_information ogi1,
         hr_organization_information ogi2,
         pay_ca_pmed_accounts        pma,
         hr_organization_information ogi3,
         hr_organization_information ogi4
  WHERE  ogi1.organization_id  = p_gre
  AND    ogi1.org_information_context = 'CLASS'
  AND    ogi1.org_information1 = 'HR_LEGAL'
  AND    ogi1.org_information2 = 'Y'
  AND    ogi2.organization_id  = p_gre
  AND    ogi2.org_information_context = 'Provincial Reporting Info.'
  AND    ogi2.org_information1 = p_juris
  AND    ogi2.org_information3 = pma.account_number
  AND    pma.enabled           = 'Y'
  AND    pma.business_group_id = p_bg_no
  AND    ogi3.organization_id   = pma.organization_id
  AND    ogi3.org_information_context = 'CLASS'
  AND    ogi3.org_information1 = 'CA_PMED'
  AND    ogi3.org_information2 = 'Y'
  AND    ogi4.organization_id   = pma.organization_id
  AND    ogi4.org_information_context = 'Provincial Information'
  AND    ogi4.org_information1 = p_juris;

l_source_id     NUMBER;

BEGIN

hr_utility.set_location('pay_ca_pmed', 10);
  IF p_account_number IS NOT NULL AND
     p_account_number <> 'NOT ENTERED' THEN
    hr_utility.set_location('pay_ca_pmed', 20);
    OPEN csr_get_src_id1(p_jurisdiction_code,
                         p_account_number,p_business_group_id);
    FETCH csr_get_src_id1 INTO l_source_id;
    CLOSE csr_get_src_id1;
  ELSIF p_different_jd IS NOT NULL AND
        p_different_jd <> 'NOT ENTERED' THEN
    hr_utility.set_location('pay_ca_pmed', 30);
    OPEN csr_get_src_id2(p_different_jd,
                         p_tax_unit_id,p_business_group_id);
    FETCH csr_get_src_id2 INTO l_source_id,
                               p_account_number;
    CLOSE csr_get_src_id2;
  ELSE
    hr_utility.set_location('pay_ca_pmed', 40);
    OPEN csr_get_src_id3(p_jurisdiction_code,
                         p_tax_unit_id,p_business_group_id);
    FETCH csr_get_src_id3 INTO l_source_id,
                               p_account_number;
    CLOSE csr_get_src_id3;
  END IF;

  hr_utility.set_location('pay_ca_pmed', 50);
  RETURN l_source_id;

END;

END pay_ca_pmed;

/
