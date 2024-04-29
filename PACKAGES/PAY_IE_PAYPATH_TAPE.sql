--------------------------------------------------------
--  DDL for Package PAY_IE_PAYPATH_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAYPATH_TAPE" AUTHID CURRENT_USER AS
/* $Header: pyiepppk.pkh 120.1.12010000.2 2009/07/24 09:10:34 namgoyal ship $ */

  level_cnt NUMBER;
  c_credit_type Varchar2(10) :='CREDIT';
  c_xxxxx_type Varchar2(10) :='XXXXX';
  g_pathid varchar2(150);

 -- FUNCTION GET_PAYPATHID return varchar2; -- Bug No 3060464

/*Bug no. 3813140*/
  CURSOR CSR_PPH_HEADER
  IS
  SELECT 'DUMMY=P' , '1' --pay_ie_paypath_tape.get_paypathid pathid
  FROM   dual;

  CURSOR CSR_PPH_HEADER_RECORD
  IS
  SELECT /*+ ORDERED INDEX (ppa PAY_PAYROLL_ACTIONS_PK,
                            paa PAY_ASSIGNMENT_ACTIONS_N50,
                            ppp PAY_PRE_PAYMENTS_PK,
                            popm PAY_ORG_PAYMENT_METHODS_F_PK,
                            pppm PAY_PERSONAL_PAYMENT_METHO_PK,
                            a PER_ASSIGNMENTS_F_PK,
                            p PER_PEOPLE_F_PK ,
                            oea PAY_EXTERNAL_ACCOUNTS_PK,
                            pea PAY_EXTERNAL_ACCOUNTS_PK)
         USE_NL(ppa,paa,ppp,popm,pppm,a,p,oea,pea,hou,org) */
         'VOLUME_ID=P'      ,pay_magtape_generic.get_parameter_value('PAYPATH_VOLUME')
        ,'PAYPATH_ID=P'     ,pay_ie_archive_detail_pkg.get_paypathid --Bug no. 3813140
        ,'PROCESSING_DATE=P',to_char(to_date(pay_magtape_generic.get_parameter_value('PROCESSING_DATE'),'YYYY/MM/DD HH24:MI:SS'),'YYDDD')
        ,'FILE_NUMBER=P'    ,pay_magtape_generic.get_parameter_value('FILE_NUMBER')
        ,'RECEIVER_ID=P'    ,org.org_information9
        ,'SES_DATE=P'       ,to_char(to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'),'YYYY/MM/DD HH24:MI:SS'),'YYMMDD')
        ,'FILE_FORMAT=P'    ,nvl(org.org_information11, 'AIB')
        ,'EXPIRATION_DATE=P',to_char(to_date(pay_magtape_generic.get_parameter_value('PROCESSING_DATE'),'YYYY/MM/DD HH24:MI:SS'),'YYMMDD')
  FROM
           pay_payroll_actions            ppa
    ,      pay_assignment_actions         paa
    ,      pay_pre_payments               ppp
    ,      pay_org_payment_methods_f      popm
    ,      pay_personal_payment_methods_f pppm
    ,      per_all_assignments_f          a
    ,      per_all_people_f               p
    ,      pay_external_accounts          oea
    ,      pay_external_accounts          pea
    ,      hr_organization_units          hou
    ,	   hr_organization_information    org

   -- ,      (select pay_ie_paypath_tape.get_paypathid pathid from dual) paypath -- Bug No 3060464
    where
           ppa.payroll_action_id           =      -- Bug No 3513042
           pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
    and    paa.payroll_action_id           = ppa.payroll_action_id
    and    ppp.pre_payment_id              = paa.pre_payment_id
    and    oea.external_account_id         = popm.external_account_id
    and    popm.org_payment_method_id      = ppp.org_payment_method_id
    and    pea.external_account_id         = pppm.external_account_id
    and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
    and    paa.assignment_id               = a.assignment_id
    and    a.person_id                     = p.person_id
 -- Added nvl function for bug fix 3649139
    and    a.payroll_id                    = nvl(ppa.payroll_id,a.payroll_id ) -- Bug No 3513042
    and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
    and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
    and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
    and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
    and    org.organization_id	      (+)   = p.business_group_id
    and    org.org_information_context(+)   = 'IE_PAYPATH_INFORMATION'
 -- Added for bug fix 3649139
    and    org.organization_id              = hou.organization_id
    and    pppm.business_group_id           = hou.business_group_id
    and    popm.business_group_id           = hou.business_group_id
 -- Added for bug fix 5696117
    and    decode (org.org_information8,' ', pay_ie_archive_detail_pkg.get_paypathid, pay_ie_archive_detail_pkg.get_paypathid)
           in (org.org_information8,'Error',' ')
    and rownum < 2;

   /* and    (org.org_information8            = pay_ie_paypath_tape.g_pathid --Bug no. 3813140
    or     'Error'=pay_ie_paypath_tape.g_pathid --Bug no. 3813140
    or     ' '=pay_ie_paypath_tape.g_pathid ) --Bug no. 3813140 and 3060464
    and rownum < 2;*/


  CURSOR CSR_PPH_CREDIT_RECORD
  IS
  SELECT /*+ ORDERED INDEX (ppa PAY_PAYROLL_ACTIONS_PK,
                            paa PAY_ASSIGNMENT_ACTIONS_N50,
                            ppp PAY_PRE_PAYMENTS_PK,
                            popm PAY_ORG_PAYMENT_METHODS_F_PK,
                            pppm PAY_PERSONAL_PAYMENT_METHO_PK,
                            a PER_ASSIGNMENTS_F_PK,
                            p PER_PEOPLE_F_PK ,
                            oea PAY_EXTERNAL_ACCOUNTS_PK,
                            pea PAY_EXTERNAL_ACCOUNTS_PK,
                            org HR_ORGANIZATION_INFORMATIO_FK2)
         USE_NL(ppa,paa,ppp,popm,pppm,a,p,oea,pea,org) */
         'TYPE=P', c_credit_type
        ,'EMP_NAME=P' ,       p.full_name
        ,'EMPLOYEE_NSC=P',    pea.segment1
        ,'EMPLOYEE_ACC_NO=P', pea.segment4
        ,'TRANSACTION_CODE=P', '99'
        ,'EMPLOYER_NSC=P',    oea.segment1
        ,'EMPLOYER_ACC_NO=P', oea.segment4
        ,'PAY_AMOUNT=P',	   (ppp.value * 100)
        ,'USER_NAME=P',	      oea.segment5
        ,'USER_REFERNCE=P',   org.org_information10
        ,'ACC_CREDIT_NAME=P', pea.segment5
        ,'FILE_FORMAT=P',     nvl(org.org_information11, 'AIB')
  from
         pay_payroll_actions            ppa
  ,      pay_assignment_actions         paa
  ,      pay_pre_payments               ppp
  ,      pay_org_payment_methods_f      popm
  ,      pay_personal_payment_methods_f pppm
  ,      per_all_assignments_f          a        -- Bug No 3513042
  ,      per_all_people_f               p
  ,      pay_external_accounts          oea
  ,      pay_external_accounts          pea
  ,      hr_organization_information    org
 where  ppa.payroll_action_id		 =       -- Bug No 3513042
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    oea.external_account_id         = popm.external_account_id
  and    popm.org_payment_method_id      = ppp.org_payment_method_id
  and    pea.external_account_id         = pppm.external_account_id
  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  and    paa.assignment_id               = a.assignment_id
  and    a.person_id                     = p.person_id
--Added nvl function code for bug fix 3649139
  and    a.payroll_id                    = nvl(ppa.payroll_id,a.payroll_id ) -- Bug No 3513042
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
  and    ppa.effective_date between    a.effective_start_date and a.effective_end_date
  and    ppa.effective_date between    p.effective_start_date and p.effective_end_date
  and    org.organization_id	(+)  = p.business_group_id
  and    org.org_information_context(+)  = 'IE_PAYPATH_INFORMATION'
 -- Added for bug fix 5696117
  and    decode (org.org_information8,' ', pay_ie_archive_detail_pkg.get_paypathid,
         pay_ie_archive_detail_pkg.get_paypathid) in (org.org_information8,' ')

  /*and    (org.org_information8= pay_ie_paypath_tape.g_pathid
  or     ' '=pay_ie_paypath_tape.g_pathid) --Bug No 3086034*/
  union all
  SELECT     'TYPE=P', c_xxxxx_type
            ,'EMP_NAME=P' ,         'null'
            ,'EMPLOYEE_NSC=P',    'null'
            ,'EMPLOYEE_ACC_NO=P', 'null'
            ,'TRANSACTION_CODE=P','null'
            ,'EMPLOYER_NSC=P',    'null'
            ,'EMPLOYER_ACC_NO=P', 'null'
            ,'PAY_AMOUNT=P',	   0
            ,'USER_NAME=P',	   'null'
            ,'USER_REFERNCE=P',   'null'
            ,'ACC_CREDIT_NAME=P', 'null'
            ,'FILE_FORMAT=P','null'
  from dual
  order by 1,2;


  CURSOR CSR_PPH_CONTRA_RECORD
  IS
  SELECT /*+ ORDERED INDEX (ppa PAY_PAYROLL_ACTIONS_PK,
                            paa PAY_ASSIGNMENT_ACTIONS_N50,
                            ppp PAY_PRE_PAYMENTS_PK,
                            popm PAY_ORG_PAYMENT_METHODS_F_PK,
                            pppm PAY_PERSONAL_PAYMENT_METHO_PK,
                            a PER_ASSIGNMENTS_F_PK,
                            p PER_PEOPLE_F_PK ,
                            oea PAY_EXTERNAL_ACCOUNTS_PK,
                            pea PAY_EXTERNAL_ACCOUNTS_PK,
                            org HR_ORGANIZATION_INFORMATIO_FK2)
         USE_NL(ppa,paa,ppp,popm,pppm,a,p,oea,pea,org) */
         'TYPE=P', 'Z'
        ,'EMP_NAME=P' ,         'null'
        ,'EMPLOYEE_ACC_NO=P', oea.segment4
        ,'EMPLOYEE_NSC=P',    oea.segment1
        ,'TRANSACTION_CODE=P','17'
        ,'PAY_AMOUNT=P',	  (sum(ppp.value)* 100)
        ,'USER_NAME=P',	      oea.segment5
        ,'USER_REFERNCE=P',   org.org_information10
        ,'EMPLOYER_NSC=P',    oea.segment1
        ,'EMPLOYER_ACC_NO=P', oea.segment4
        ,'ACC_CREDIT_NAME=P', oea.segment5
        ,'FILE_FORMAT=P',     nvl(org.org_information11, 'AIB')
   from
         pay_payroll_actions            ppa
  ,      pay_assignment_actions         paa
  ,      pay_pre_payments               ppp
  ,      pay_org_payment_methods_f      popm
  ,      pay_personal_payment_methods_f pppm
  ,      per_all_assignments_f          a        -- Bug No 3513042
  ,      per_all_people_f               p
  ,      pay_external_accounts          oea
  ,      pay_external_accounts          pea
  ,      hr_organization_information    org
  where  ppa.payroll_action_id           =       -- Bug No 3513042
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    oea.external_account_id         = popm.external_account_id
  and    popm.org_payment_method_id      = ppp.org_payment_method_id
  and    pea.external_account_id         = pppm.external_account_id
  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  and    paa.assignment_id               = a.assignment_id
  and    a.person_id                     = p.person_id
--Added nvl function code for bug fix 3649139
  and    a.payroll_id                    = nvl(ppa.payroll_id,a.payroll_id ) -- Bug No 3513042
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
  and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
  and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
  and    org.organization_id	  (+)  = p.business_group_id
  and    org.org_information_context(+)  = 'IE_PAYPATH_INFORMATION'
-- Added for bug fix 5696117
  and    decode (org.org_information8,' ', pay_ie_archive_detail_pkg.get_paypathid,
         pay_ie_archive_detail_pkg.get_paypathid) in (org.org_information8,' ')

 /* and    (org.org_information8= pay_ie_paypath_tape.g_pathid
  or     ' '=pay_ie_paypath_tape.g_pathid) --Bug No 3086034*/
  group by 'TYPE=P', 'Z'
      ,'EMPLOYEE_ACC_NO=P', oea.segment4
      ,'EMPLOYEE_NSC=P',    oea.segment1
      ,'USER_NAME=P',       oea.segment5
      ,'USER_REFERNCE=P',   org.org_information10
      ,'FILE_FORMAT=P',     nvl(org.org_information11, 'AIB');


/*PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT NOCOPY VARCHAR2);

*/

PROCEDURE range_code(
                p_payroll_action_id     IN  NUMBER,
                p_sqlstr                OUT NOCOPY VARCHAR2);
--
PROCEDURE assignment_action_code(
                p_payroll_action_id     IN NUMBER,
                p_start_person_id       IN NUMBER,
                p_end_person_id         IN NUMBER,
                p_chunk_number          IN NUMBER);


--Cash Management Reconciliation function
FUNCTION f_get_paypath_recon_data (p_effective_date        IN DATE,
			           p_identifier_name       IN VARCHAR2,
			           p_payroll_action_id	   IN NUMBER,
				   p_payment_type_id	   IN NUMBER,
				   p_org_payment_method_id IN NUMBER,
				   p_personal_payment_method_id	IN NUMBER,
				   p_assignment_action_id	IN NUMBER,
				   p_pre_payment_id	        IN NUMBER,
				   p_delimiter_string   	IN VARCHAR2)
RETURN VARCHAR2;

END pay_ie_paypath_tape;

/
