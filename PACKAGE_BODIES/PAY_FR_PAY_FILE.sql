--------------------------------------------------------
--  DDL for Package Body PAY_FR_PAY_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_PAY_FILE" as
/* $Header: pyfrpfcr.pkb 115.2 2002/10/16 15:30:37 srjadhav noship $
**
**  Copyright (c) 2000 Oracle Corporation
**  All Rights Reserved
**
**  French Payment Output File
**
**  Change List
**  ===========
**
**  Date        Author    Version  Bug       Description
**  -----------+---------+-------+----------+------------------
**  10-Oct-2002 srjadhav   115.0   2610927    Created stub version
**  16-Oct-2002 srjadhav   115.1   2610927    Created the body
**  16-Oct-2002 srjadhav   115.2  	      Removed GSCC warning
*/
-- private globals for caching used by get_payers_id and valid_org

TYPE g_estab_rec IS RECORD (
  estab_id        hr_all_organization_units.ORGANIZATION_ID%TYPE,
  company_id      hr_all_organization_units.ORGANIZATION_ID%TYPE);
TYPE g_estab_typ IS TABLE OF g_estab_rec Index by BINARY_INTEGER;
g_estab_tbl     g_estab_typ;
--
g_org_id     hr_all_organization_units.organization_id%TYPE;
g_org_class  hr_organization_information.org_information1%TYPE;

-- end of private globals for caching used by get_payers_id and valid_org


FUNCTION get_payers_id (p_opm_id      in number,
                        P_bg_id       in number,
                        P_date_earned in date)
                        return varchar2
IS

  L_opm_id_chr varchar2(20);
  L_payers_id  varchar2(14);
BEGIN
  L_opm_id_chr := fnd_number.number_to_canonical(p_opm_id);
  --
  Select distinct org.organization_id,
         ori_class.org_information1,
         decode(ori_class.org_information1,
                'FR_SOCIETE', ori_info.org_information15, -- new segment
                'FR_ETABLISSEMENT', ori_info.org_information2) -- SIRET
  into   g_org_id,
         g_org_class,
         L_payers_id
  From   hr_organization_information     ori_opm,
         hr_organization_information     ori_class,
         hr_organization_information     ori_info,
         hr_all_organization_units       org
  Where  ori_opm.org_information1        = L_opm_id_chr
  And    ori_opm.org_information_context = 'FR_DYN_PAYMETH_MAPPING_INFO'
  And    ori_class.organization_id       = ori_opm.organization_id
  And    ori_class.org_information_context = 'CLASS'
  And    ori_class.org_information1 in ('FR_SOCIETE', 'FR_ETABLISSEMENT')
  And    ori_info.organization_id        = ori_opm.organization_id
  And    ori_info.org_information_context in ('FR_COMP_INFO',
                                              'FR_ESTAB_INFO')
  And    org.organization_id             = ori_opm.organization_id
  And    org.business_group_id           = p_bg_id
  And    P_date_earned between org.date_from
                           And nvl(org.date_to, hr_general.end_of_time);
  --
  if L_payers_id is null then
    return lpad(' ',16);
  elsif g_org_class = 'FR_SOCIETE' then
    return ')2'|| L_payers_id;
  else
    return ')1'|| L_payers_id;
  end if;
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    Return 'PAY_75037_TOO_MANY_SPEC_OPMS';
  WHEN NO_DATA_FOUND THEN
    return lpad(' ',16);
END get_payers_id;
--
FUNCTION valid_org (p_estab_id in number) return varchar2 IS
  L_estab_tbl_ind  BINARY_INTEGER;
  --
  cursor csr_get_company is
  select fnd_number.canonical_to_number(hoi.ORG_INFORMATION1)
  from   hr_organization_information   hoi
  where  hoi.organization_id         = p_estab_id
  AND    hoi.org_information_context = 'FR_ESTAB_INFO';
BEGIN
  If g_org_class = 'FR_ETABLISSEMENT' THEN
    Return hr_general.bool_to_char(p_estab_id = g_org_id);
  ElsIf g_org_class = 'FR_SOCIETE' THEN
    l_estab_tbl_ind := DBMS_UTILITY.get_hash_value(p_estab_id,1,1048576);
    if not g_estab_tbl.exists(l_estab_tbl_ind)
    or g_estab_tbl(l_estab_tbl_ind).estab_id <> p_estab_id
    then
      g_estab_tbl(l_estab_tbl_ind).estab_id := p_estab_id;
      Open csr_get_company;
      Fetch csr_get_company into g_estab_tbl(l_estab_tbl_ind).Company_id;
      Close csr_get_company;
    end if;
    Return hr_general.bool_to_char
       (g_estab_tbl(l_estab_tbl_ind).Company_id = g_org_id);
  else
    return 'TRUE';
  end if;
END valid_org;


end pay_fr_pay_file;

/
