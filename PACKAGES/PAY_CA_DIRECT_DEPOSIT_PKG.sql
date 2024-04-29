--------------------------------------------------------
--  DDL for Package PAY_CA_DIRECT_DEPOSIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_DIRECT_DEPOSIT_PKG" AUTHID CURRENT_USER AS
/* $Header: pycatapd.pkh 120.0 2005/05/29 03:48:01 appldev noship $ */
--
-- ROYAL BANK OF CANADA (RBC) CURSORS
--
CURSOR rbc_header IS
select
       'ORG_PAY_METHOD_ID=C', opm.org_payment_method_id
,      'TRANSFER_ORG_PAY_METH=P', fnd_number.number_to_canonical(opm.org_payment_method_id)
,      'ORIGINATOR_ID=P', opm.pmeth_information2
,      'ORIGINATOR_NAME=P', opm.pmeth_information3
,      'TRANSFER_PAY_ACT_ID=P', fnd_number.number_to_canonical(ppa.payroll_action_id)
,      'TRANSFER_DD_DATE=P', nvl(to_char(ppa.overriding_dd_date,'YYYYDDD'),
                             to_char(ppa.effective_date,'YYYYDDD'))
,      'BUSINESS_GROUP_ID=P', fnd_number.number_to_canonical(ppa.business_group_id)
from   pay_org_payment_methods_f opm
,      pay_payroll_actions       ppa
where  ppa.payroll_action_id =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppa.org_payment_method_id = opm.org_payment_method_id
and    ppa.effective_date between opm.effective_start_date
                              and opm.effective_end_date;
--
--
CURSOR rbc_multi_payments IS
select
       'TRANSFER_COUNT=P', count(paf.person_id)
,      'TRANSFER_PERSON_ID=P', paf.person_id
from
       pay_pre_payments ppp
,      per_assignments paf
,      pay_assignment_actions paa
where
       paa.payroll_action_id        =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    paa.pre_payment_id           = ppp.pre_payment_id
and    paf.assignment_id            = paa.assignment_id
group by paf.person_id;
--
--
CURSOR rbc_payment IS
select
       'CPA_CODE=P', opm.pmeth_information7
,      'ORIGINATOR_ID=P', opm.pmeth_information2
,      'CUSTOMER_NUMBER=P', paf.assignment_number
,      'ASSIGNMENT_ID=P', paf.assignment_id
,      'TRANSIT_NUMBER=P', pea.segment4
,      'BANK_NUMBER=P', pea.segment7
,      'ACCOUNT_NUMBER=P', pea.segment3
,      'AMOUNT=P', ppp.value * 100
,      'CUSTOMER_NAME=P', ppf.full_name
,      'ORIGINATOR_SHR_NAME=P', opm.pmeth_information4
,      'CURRENCY_CODE=P', opm.currency_code
from
       pay_org_payment_methods opm
,      pay_personal_payment_methods ppm
,      pay_external_accounts pea
,      pay_pre_payments ppp
,      per_people ppf
,      per_assignments paf
,      pay_assignment_actions paa
where  paa.payroll_action_id =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    ppm.external_account_id = pea.external_account_id
and    ppp.personal_payment_method_id = ppm.personal_payment_method_id
and    paa.pre_payment_id             = ppp.pre_payment_id
and    paf.person_id = ppf.person_id
and    paf.assignment_id = paa.assignment_id
and    ppf.person_id =
             pay_magtape_generic.get_parameter_value('TRANSFER_PERSON_ID')
order by paf.assignment_number;
--
--
-- BANK OF Montreal (BMO) CURSORS
--
CURSOR bmo_header IS
select
       'ORG_PAY_METHOD_ID=C',     opm.org_payment_method_id
,      'TRANSFER_ORG_PAY_METH=P', fnd_number.number_to_canonical(opm.org_payment_method_id)
,      'ORIGINATOR_ID=P',         opm.pmeth_information2
,      'ORIGINATOR_NAME=P',       opm.pmeth_information3
,      'ORIGINATOR_SHR_NAME=P',   opm.pmeth_information4
,      'TRANSFER_PAY_ACT_ID=P',   fnd_number.number_to_canonical(ppa.payroll_action_id)
,      'TRANSFER_DD_DATE=P',      nvl(to_char(ppa.overriding_dd_date,'YYDDD'),to_char(ppa.effective_date,'YYDDD'))
,      'DES_DATA_CENTRE=P',         opm.pmeth_information8
,      'CPA_CODE=P',                opm.pmeth_information7
,      'RETURN_BANK_NUMBER=P',      substr(opm.pmeth_information5,2,3)
,      'RETURN_TRANSIT_NUMBER=P',   substr(opm.pmeth_information5,5,5)
,      'RETURN_ACCOUNT_NUMBER=P',   opm.pmeth_information6
,      'BUSINESS_GROUP_ID=P', fnd_number.number_to_canonical(ppa.business_group_id)
from   pay_org_payment_methods_f opm
,      pay_payroll_actions       ppa
where  ppa.payroll_action_id =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppa.org_payment_method_id = opm.org_payment_method_id
and    ppa.effective_date between opm.effective_start_date
                              and opm.effective_end_date;
--
--
CURSOR bmo_multi_payments IS
select
       'TRANSFER_COUNT=P', count(paf.person_id)
,      'TRANSFER_PERSON_ID=P', paf.person_id
from
       pay_pre_payments ppp
,      per_assignments paf
,      pay_assignment_actions paa
where
       paa.payroll_action_id        =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    paa.pre_payment_id           = ppp.pre_payment_id
and    paf.assignment_id            = paa.assignment_id
group by paf.person_id;
--
--
CURSOR bmo_payment IS
select
       'CPA_CODE=P', opm.pmeth_information7
,      'ORIGINATOR_ID=P', opm.pmeth_information2
,      'CUSTOMER_NUMBER=P', paf.assignment_number
,      'ASSIGNMENT_ID=P', paf.assignment_id
,      'TRANSIT_NUMBER=P', pea.segment4
,      'BANK_NUMBER=P', pea.segment7
,      'ACCOUNT_NUMBER=P', pea.segment3
,      'AMOUNT=P', ppp.value * 100
,      'CUSTOMER_NAME=P', ppf.full_name
,      'ORIGINATOR_SHR_NAME=P', opm.pmeth_information4
,      'CURRENCY_CODE=P', opm.currency_code
from
       pay_org_payment_methods opm
,      pay_personal_payment_methods ppm
,      pay_external_accounts pea
,      pay_pre_payments ppp
,      per_people ppf
,      per_assignments paf
,      pay_assignment_actions paa
where  paa.payroll_action_id =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    ppm.external_account_id = pea.external_account_id
and    ppp.personal_payment_method_id = ppm.personal_payment_method_id
and    paa.pre_payment_id             = ppp.pre_payment_id
and    paf.person_id = ppf.person_id
and    paf.assignment_id = paa.assignment_id
and    ppf.person_id =
             pay_magtape_generic.get_parameter_value('TRANSFER_PERSON_ID')
order by paf.assignment_number;
--
--
-- National Bank (BNC) CURSORS
--
--
CURSOR bnc_header IS
select
       'ORG_PAY_METHOD_ID=C',     opm.org_payment_method_id
,      'TRANSFER_ORG_PAY_METH=P', fnd_number.number_to_canonical(opm.org_payment_method_id)
,      'ORIGINATOR_ID=P',         opm.pmeth_information2
,      'ORIGINATOR_NAME=P',       opm.pmeth_information3
,      'ORIGINATOR_SHR_NAME=P',   opm.pmeth_information4
,      'TRANSFER_PAY_ACT_ID=P',   fnd_number.number_to_canonical(ppa.payroll_action_id)
,      'TRANSFER_DD_DATE=P',      nvl(to_char(ppa.overriding_dd_date,'YYDDD'),to_char(ppa.effective_date,'YYDDD'))
,      'CPA_CODE=P',                opm.pmeth_information7
,      'RETURN_BANK_NUMBER=P',      substr(opm.pmeth_information5,2,3)
,      'RETURN_TRANSIT_NUMBER=P',   substr(opm.pmeth_information5,5,5)
,      'RETURN_ACCOUNT_NUMBER=P',   opm.pmeth_information6
,      'BUSINESS_GROUP_ID=P', fnd_number.number_to_canonical(ppa.business_group_id)
from   pay_org_payment_methods_f opm
,      pay_payroll_actions       ppa
where  ppa.payroll_action_id =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppa.org_payment_method_id = opm.org_payment_method_id
and    ppa.effective_date between opm.effective_start_date
                              and opm.effective_end_date;
--
--
CURSOR bnc_multi_payments IS
select
       'TRANSFER_COUNT=P', count(paf.person_id)
,      'TRANSFER_PERSON_ID=P', paf.person_id
from
       pay_pre_payments ppp
,      per_assignments paf
,      pay_assignment_actions paa
where
       paa.payroll_action_id        =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    paa.pre_payment_id           = ppp.pre_payment_id
and    paf.assignment_id            = paa.assignment_id
group by paf.person_id;
--
--
CURSOR bnc_payment IS
select
       'CPA_CODE=P', opm.pmeth_information7
,      'ORIGINATOR_ID=P', opm.pmeth_information2
,      'CUSTOMER_NUMBER=P', paf.assignment_number
,      'ASSIGNMENT_ID=P', paf.assignment_id
,      'TRANSIT_NUMBER=P', pea.segment4
,      'BANK_NUMBER=P', pea.segment7
,      'ACCOUNT_NUMBER=P', pea.segment3
,      'AMOUNT=P', ppp.value * 100
,      'CUSTOMER_LAST_NAME=P', ppf.last_name
,      'CUSTOMER_FIRST_NAME=P', ppf.first_name
,      'ORIGINATOR_SHR_NAME=P', opm.pmeth_information4
,      'CURRENCY_CODE=P', opm.currency_code
from
       pay_org_payment_methods opm
,      pay_personal_payment_methods ppm
,      pay_external_accounts pea
,      pay_pre_payments ppp
,      per_people ppf
,      per_assignments paf
,      pay_assignment_actions paa
where  paa.payroll_action_id =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    ppm.external_account_id = pea.external_account_id
and    ppp.personal_payment_method_id = ppm.personal_payment_method_id
and    paa.pre_payment_id             = ppp.pre_payment_id
and    paf.person_id = ppf.person_id
and    paf.assignment_id = paa.assignment_id
and    ppf.person_id =
             pay_magtape_generic.get_parameter_value('TRANSFER_PERSON_ID')
order by paf.assignment_number;

/* Bank of Nova Scotia */

CURSOR bnvsc_header IS
select
       'ORG_PAY_METHOD_ID=C',     opm.org_payment_method_id
,      'TRANSFER_ORG_PAY_METH=P', fnd_number.number_to_canonical(opm.org_payment_method_id)
,      'ORIGINATOR_ID=P',         opm.pmeth_information2
,      'ORIGINATOR_NAME=P',       opm.pmeth_information3
,      'ORIGINATOR_SHR_NAME=P',   opm.pmeth_information4
,      'TRANSFER_PAY_ACT_ID=P',   fnd_number.number_to_canonical(ppa.payroll_action_id)
,      'TRANSFER_DD_DATE=P',      nvl(to_char(ppa.overriding_dd_date,'YYDDD'),to_char(ppa.effective_date,'YYDDD'))
,      'CPA_CODE=P',                opm.pmeth_information7
,      'RETURN_BANK_NUMBER=P',      substr(opm.pmeth_information5,2,3)
,      'RETURN_TRANSIT_NUMBER=P',   substr(opm.pmeth_information5,5,5)
,      'RETURN_ACCOUNT_NUMBER=P',   opm.pmeth_information6
,      'DES_DATA_CENTRE=P',         opm.pmeth_information8
,      'RETURN_BANK_TRANSIT_NUMBER=P',          pea.segment4
,      'BANK_NUMBER=P',             pea.segment7
,      'BUSINESS_GROUP_ID=P', fnd_number.number_to_canonical(ppa.business_group_id)
from   pay_org_payment_methods_f opm,
       pay_external_accounts     pea
,      pay_payroll_actions       ppa
where  ppa.payroll_action_id =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppa.org_payment_method_id = opm.org_payment_method_id
and    ppa.effective_date between opm.effective_start_date
                              and opm.effective_end_date
and    opm.external_account_id = pea.external_account_id;
--
--
CURSOR bnvsc_multi_payments IS
select
       'TRANSFER_COUNT=P', count(paf.person_id)
,      'TRANSFER_PERSON_ID=P', paf.person_id
from
       pay_pre_payments ppp
,      per_assignments paf
,      pay_assignment_actions paa
where
       paa.payroll_action_id        =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    paa.pre_payment_id           = ppp.pre_payment_id
and    paf.assignment_id            = paa.assignment_id
group by paf.person_id;
--
--
CURSOR bnvsc_payment IS
select
       'CPA_CODE=P', opm.pmeth_information7
,      'ORIGINATOR_ID=P', opm.pmeth_information2
,      'CUSTOMER_NUMBER=P', paf.assignment_number
,      'ASSIGNMENT_ID=P', paf.assignment_id
,      'TRANSIT_NUMBER=P', pea.segment4
,      'BANK_NUMBER=P', pea.segment7
,      'ACCOUNT_NUMBER=P', pea.segment3
,      'AMOUNT=P', ppp.value * 100
,      'CUSTOMER_NAME=P', ppf.full_name
,      'ORIGINATOR_SHR_NAME=P', opm.pmeth_information4
,      'CURRENCY_CODE=P', opm.currency_code
from
       pay_org_payment_methods opm
,      pay_personal_payment_methods ppm
,      pay_external_accounts pea
,      pay_pre_payments ppp
,      per_people ppf
,      per_assignments paf
,      pay_assignment_actions paa
where  paa.payroll_action_id =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppp.org_payment_method_id +0 =
             pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METH')
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    ppm.external_account_id = pea.external_account_id
and    ppp.personal_payment_method_id = ppm.personal_payment_method_id
and    paa.pre_payment_id             = ppp.pre_payment_id
and    paf.person_id = ppf.person_id
and    paf.assignment_id = paa.assignment_id
and    ppf.person_id =
             pay_magtape_generic.get_parameter_value('TRANSFER_PERSON_ID')
order by paf.assignment_number;
--
level_cnt number;
--
FUNCTION get_file_creation_number(p_originator_id  varchar2
                                 ,p_fin_institution  varchar2
                                 ,p_override_fcn  varchar2)
                                  return varchar2;

FUNCTION get_dd_file_creation_number(p_org_payment_method_id  number
                                 ,p_fin_institution  varchar2
                                 ,p_override_fcn  varchar2
                                 ,p_pact_id number
                                 ,p_business_group_id number)
                                  return varchar2;

FUNCTION convert_uppercase(p_input_string  varchar2)
                           return varchar2;

PRAGMA RESTRICT_REFERENCES(convert_uppercase, WNDS);

--
--
end pay_ca_direct_deposit_pkg;

 

/
