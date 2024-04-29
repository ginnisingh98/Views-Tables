--------------------------------------------------------
--  DDL for Package PAY_GB_WNU_EDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_WNU_EDI" AUTHID CURRENT_USER as
/* $Header: pygbwnu2.pkh 120.2 2006/12/18 10:49:40 kthampan noship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Nae
    PAY_GB_MOVDED_EDI
  Purpose
    Package to contol archiver process in the creation of assignment actions
    and then the creation of EDI message files using the magtape process for
    EDI Message Types : WNU
Notes

  History
    01-NOV-2000 ILeath       115.0        Date created.
    19-JUN-2001 SRobinson    115.1        Enforce EDI Character validation.
    23-JUN-2001 SRobinson    115.2        Always pass a value for all asg
                                          level parameters to maintain edi
                                          file formatting. Also include
                                          middle names.
    06-MAR-2002 GButler	     115.3	  Altered cursors for UTF8. Added
    					  dbdrv comments
    28-NOV-2002 GButler	     115.4	  11.5.9 performance enhancements to
    					  csr_wnu_full_assign and
    					  csr_wnu_update_assign. nocopy
    					  qualifier added to range_cursor
    18-DEC-2003 asengar      115.6        performance enhancements to
    					  csr_wnu_full_assign and
    					  csr_wnu_update_assign.
    19-JAN-2004 ssekhar      115.7	  Bug 3380271: Changed the value 1.0
                                          to 3.0 for the parameter VERSION=P in
                                          the cursor csr_wnu_header
    09-MAR-2004 amills       115.8        3416212, added nvl to TRANSFER_
                                          SENDER_ID to trap empty value in
                                          formula.
    08-SEP-2004 kthampan     115.9        Put NONE in the field where NI number
                                          is not available
    12-JAN-2005 Kthampan     115.10       Change version from 3.0 to 1.0
                                          Also amended cursor header to return
                                          effective_date.
    21-JAN-2005 Kthampan     115.11       Remove effective_date from cursor
                                          header
    16-JUN-2006 Kthampan     115.12       Code change for EDI Rollback.
    18-DEC-2006 Kthampan     115.13       Fix bug 5718900.  Remapped the achive
                                          column
============================================================================*/
--
--
CURSOR csr_wnu_header IS
SELECT 'TRANSFER_SENDER_ID=P',   nvl(upper(hoi.org_information11),' '),
       'TRANSFER_RECEIVER_ID=P', 'INLAND REVENUE',
       'TEST_INDICATOR=P',       upper(decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1')),
       'URGENT_MARKER=P',        upper(decode(pay_magtape_generic.get_parameter_value('URGENT'),'N',' ','Y','1')),
       'ICR=P',                  upper(fnd_number.number_to_canonical(pact.request_id)),
       'FORM_TYPE=P',            '5',
       'FORM_TYPE_MEANING=P',    'WNU',
       'FORMAT_TYPE=P',          'WNU',
       'VERSION=P',              '1.0',
       'TAX_DIST_NO=P',          upper(substr(hoi.org_information1,1,3)),
       'TAX_DIST_REF=P',         upper(substr(ltrim(substr(hoi.org_information1,4,11),'/') ,1,10))
FROM   pay_payroll_actions pact,
       hr_organization_information hoi
WHERE  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
AND    hoi.org_information_context = 'Tax Details References'
AND    NVL(hoi.org_information10,'UK') = 'UK'
AND    hoi.organization_id = pact.business_group_id
AND    substr(pact.legislative_parameters,instr(pact.legislative_parameters,'TAX_REF=') + 8,
              instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters,'TAX_REF=')+8)
              - instr(pact.legislative_parameters,'TAX_REF=') - 8)
             = hoi.org_information1;
--
--
cursor csr_wnu_full_assign IS
select /*+ ORDERED */
       'CHARS_ALREADY_TESTED=P',   'N',
       'ASSIGNMENT_NUMBER=P',      upper(pai_emp.action_information11),
       'OLD_ASSIGNMENT_NUMBER=P',  nvl(upper(pai_wnu.action_information2),' '),
       'FIRST_NAME=P',             nvl(upper(substr(pai_emp.action_information6,1,35)),' '),
       'LAST_NAME=P',              nvl(upper(substr(pai_emp.action_information8,1,35)),' '),
       'MIDDLE_NAME=P',            nvl(substr(upper(pai_emp.action_information7),1,35),' '),
       'NATIONAL_INSURANCE_NUMBER=P',  nvl(upper(pai_emp.action_information12),'NONE'),
       'TITLE=P',                  nvl(upper(pai_emp.action_information14),' ')
from   pay_assignment_actions  paa,
       pay_action_information  pai_emp,
       pay_action_information  pai_wnu
where  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    paa.assignment_action_id = pai_emp.action_context_id
and    pai_emp.action_information_category = 'GB EMPLOYEE DETAILS'
and    pai_emp.action_context_type = 'AAP'
and    paa.assignment_action_id = pai_wnu.action_context_id(+)
and    pai_wnu.action_information_category(+) = 'GB WNU EDI'
and    pai_wnu.action_context_type(+) = 'AAP';
--
--
CURSOR csr_wnu_update_assign IS
select /*+ ORDERED */
       'CHARS_ALREADY_TESTED=P',   'N',
       'ASSIGNMENT_NUMBER=P',      upper(pai_emp.action_information11),
       'OLD_ASSIGNMENT_NUMBER=P',  nvl(upper(pai_wnu.action_information2),' '),
       'FIRST_NAME=P',             nvl(upper(substr(pai_emp.action_information6,1,35)),' '),
       'LAST_NAME=P',              nvl(upper(substr(pai_emp.action_information8,1,35)),' '),
       'MIDDLE_NAME=P',            nvl(substr(upper(pai_emp.action_information7),1,35),' '),
       'NATIONAL_INSURANCE_NUMBER=P',  nvl(upper(pai_emp.action_information12),'NONE'),
       'TITLE=P',                  nvl(upper(pai_emp.action_information14),' ')
from   pay_assignment_actions  paa,
       pay_action_information  pai_emp,
       pay_action_information  pai_wnu
where  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    paa.assignment_action_id = pai_emp.action_context_id
and    pai_emp.action_information_category = 'GB EMPLOYEE DETAILS'
and    pai_emp.action_context_type = 'AAP'
and    paa.assignment_action_id = pai_wnu.action_context_id(+)
and    pai_wnu.action_information_category(+) = 'GB WNU EDI'
and    pai_wnu.action_context_type(+) = 'AAP';
--
--
level_cnt   number;
--
PROCEDURE archinit ( p_payroll_action_id IN NUMBER);
--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT nocopy VARCHAR2);
--
PROCEDURE wnu_cleanse_act_creation(pactid IN NUMBER,
                                  stperson IN NUMBER,
                                  endperson IN NUMBER,
                                  chunk IN NUMBER);
--
PROCEDURE wnu_update_action_creation(pactid IN NUMBER,
                              stperson IN NUMBER,
                              endperson IN NUMBER,
                              chunk IN NUMBER);
--
PROCEDURE archive_code (p_assactid         IN   NUMBER,
                        p_effective_date   IN   DATE);
--
PROCEDURE deinitialization_code(pactid IN NUMBER);
--
END PAY_GB_WNU_EDI;

/
