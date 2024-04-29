--------------------------------------------------------
--  DDL for Package Body PAY_ZA_SOTC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_SOTC_PKG" AS
/* $Header: PYZASOTC.pkb 120.0.12010000.1 2009/11/27 10:43:00 dwkrishn noship $ */

FUNCTION BEFOREREPORT RETURN BOOLEAN IS
   l_eff_date_sql        varchar2(4000);
   l_eff_date            date;
   l_cert_count_sql      varchar2(4000);
   l_man_cert_count_sql  varchar2(4000);
BEGIN
     IF (P_PAYROLL_ACTION_ID is not null) THEN
        C_PAYROLL_ACTION_ID := 'and paa.payroll_action_id = '||P_PAYROLL_ACTION_ID;
     ELSE
        C_PAYROLL_ACTION_ID :=
              ' and paa.payroll_action_id in ( '||
              ' select ppa.payroll_action_id '||
                 'from pay_payroll_actions ppa '||
                'where ppa.business_group_id = '||P_BUSINESS_GROUP_ID||
                  ' and ppa.action_type = ''X'' '||
                  ' and ppa.report_type = ''ZA_TYE'' '||
                  ' and ppa.action_status = ''C'' '||
                  ' and pay_za_irp5_archive_pkg.get_parameter(''CERT_TYPE'',ppa.legislative_parameters) = 1'||
                  ' and pay_za_irp5_archive_pkg.get_parameter(''LEGAL_ENTITY'',ppa.legislative_parameters) = '||P_LEGAL_ENTITY_ID||
                  ' and pay_za_irp5_archive_pkg.get_parameter(''TAX_YEAR'',ppa.legislative_parameters) = '||P_TAX_YEAR||
                  ' )';
     END IF;

   -- Find Effective Date
   l_eff_date_sql := ' select max(ppa.effective_date) '||
                     ' from pay_payroll_actions ppa,'||
                     ' pay_assignment_actions paa'||
                     ' where ppa.payroll_action_id=paa.payroll_action_id '||
                      C_PAYROLL_ACTION_ID;
   EXECUTE IMMEDIATE l_eff_date_sql INTO l_eff_date ;


   -- Find Busincess group name
   select pbg.name
     into CP_BG_NAME
     from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id
      and l_eff_date between pbg.DATE_FROM and nvl(pbg.DATE_TO,to_date('31-12-4712','DD-MM-YYYY'));

   -- Find Legal Entity , Tax Ref
   select haou.name, hoi.org_information3
     into CP_LE_NAME, CP_TAX_REF
     from hr_all_organization_units haou,
          hr_organization_information hoi
    where haou.organization_id = P_LEGAL_ENTITY_ID
   and    hoi.organization_id = haou.organization_id
   and    hoi.org_information_context = 'ZA_LEGAL_ENTITY';

   -- Tax Year
   CP_TAX_YEAR := P_TAX_YEAR;

   -- Payroll Action ID
   IF (P_PAYROLL_ACTION_ID is not null) THEN
      CP_PAYROLL_ACTION_ID := P_PAYROLL_ACTION_ID;
   END IF;

   -- Find First Certificate,Last Certificate and Certificate Count
   l_cert_count_sql := 'select min(pai.action_information1),max(pai.action_information1),count(pai.action_information1)'||
                  ' from pay_action_information pai,'||
                       ' pay_assignment_actions paa'||
                 ' where pai.action_context_id = paa.assignment_action_id'||
                   ' and pai.action_context_type = ''AAP'''||
                   ' and pai.action_information_category = ''ZATYE_EMPLOYEE_INFO'''||
                   C_PAYROLL_ACTION_ID;

   EXECUTE IMMEDIATE l_cert_count_sql INTO CP_FIRST_CERT_NUM,CP_LAST_CERT_NUM,CP_CERT_COUNT;


   -- Old/Manual Certificates
   l_man_cert_count_sql :=    'select count(pai.action_information1)'||
                         ' from pay_action_information pai,'||
                              ' pay_assignment_actions paa'||
                        ' where pai.action_context_id = paa.assignment_action_id'||
                          ' and pai.action_context_type = ''AAP'''||
                          ' and pai.action_information_category = ''ZATYE_EMPLOYEE_INFO'''||
                          C_PAYROLL_ACTION_ID||
                          ' and pai.action_information28 is not null ';
   EXECUTE IMMEDIATE l_man_cert_count_sql INTO CP_MAN_CERT_COUNT;


   RETURN true;
END BEFOREREPORT;


END PAY_ZA_SOTC_PKG;

/
